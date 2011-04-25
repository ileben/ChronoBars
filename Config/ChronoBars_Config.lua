--[[

====================================================
ChronoBars - buff, debuff, cooldown, totem tracker
Author: Ivan Leben
====================================================

--]]

local CB = ChronoBars;

--Data get/set mechanism
--================================================================

function ChronoBars.GetDeepValue (deepTable, deepPath)

  --Split the path into a set of variable names
  local varNames = { strsplit( ".", deepPath ) };
  local varCount = table.getn( varNames );
  local curTable = deepTable;
  local curVar = deepPath;

  --Walk the list of variable names  
  for v=1,varCount do
    local varName = varNames[v];
	
	--Parse index
	local i = nil;
	local s = strfind( varName, "[[]" );
	local e = strfind( varName, "[]]" );
	if (s ~= nil and e ~= nil) then
	
		--Get index as a settings value recursively 
		local indexVar = strsub( varName, s+1, e-1 );
		i = CB.GetSettingsValue( indexVar );
		varName = strsub( varName, 1, s-1 );
	end
    
    --Return value of final variable
    if (v == varCount) then
      local varValue = curTable[ varName ];
	  if (i ~= nil) then varValue = varValue[i]; end
	  return varValue;
    end
    
    --Recurse into subtable
	local varValue = curTable[ varName ];
	if (i ~= nil) then varValue = varValue[i]; end
    curTable = varValue;
  end
  
  return nil;
end

function ChronoBars.SetDeepValue (deepTable, deepPath, value)

  --Split the path into a set of variable names
  local varNames = { strsplit( ".", deepPath ) };
  local varCount = table.getn( varNames );
  local curTable = deepTable;
  local curVar = deepPath;

  --Walk the list of variable names  
  for v=1,varCount do
    local varName = varNames[v];
	
	--Parse index
	local i = nil;
	local s = strfind( varName, "[[]" );
	local e = strfind( varName, "[]]" );
	if (s ~= nil and e ~= nil) then
	
		--Get index as a settings value recursively
		local indexVar = strsub( varName, s+1, e-1 );
		i = CB.GetSettingsValue( indexVar );
		varName = strsub( varName, 1, s-1 );
	end
    
	--Set value of final variable
	if (v == varCount) then
		if (i ~= nil) then
			local targetTable = curTable[ varName ];
			if (type( value ) == "table")
			then targetTable[ i ] = CopyTable( value );
			else targetTable[ i ] = value; end
		else
			if (type( value ) == "table")
			then curTable[ varName ] = CopyTable( value );
			else curTable[ varName ] = value; end
		end
		return true;
	end
    
    --Recurse into subtable
	local varValue = curTable[ varName ];
	if (i ~= nil) then varValue = varValue[i]; end
    curTable = varValue;
  end
  
  return false;
end

function ChronoBars.GetSettingsValue( var )
  ChronoBars.Debug( "Getting value '"..tostring(var).."'" );
  
  --If variable is not a string return exact value
  if (type(var) ~= "string") then return var; end
  
  --If variable doesn't have location specified return exact string
  local pipe = strfind( var, "|" );
  if (not pipe) then return var; end
  
  --Parse variable location
  local location = strsub( var, 1, pipe-1 );
  local path = strsub( var, pipe+1 );
  if (location == "const") then
  
    --Return the rest unmodified
    return path;
    
  elseif (location == "func") then
  
    --Parse function argument
    local arg = nil;
    local argStart = strfind( path, "[(]" );
    local argEnd = strfind( path, "[)]" );
    
    if (argStart and argEnd) then
      arg = strsub( path, argStart+1, argEnd-1 );
      path = strsub( path, 1, argStart-1 );
    end
    
    --Invoke getter function
    local func = ChronoBars[ path.."_Get" ];
    return func( arg );

  else
  
    --Otherwise get from the table
    local settings = ChronoBars.GetSettingsTable( location );
    return ChronoBars.GetDeepValue( settings, path );
  end
end


function ChronoBars.SetSettingsValue( var, value )

  --Refuse setting nil value to preserve setting variable types
  if (value == nil) then return false; end
  
  --If variable is not a string it cannot be set (const)
  if (type(var) ~= "string") then return false; end
  
  --If variable doesn't have a location it cannot be set (const)
  local pipe = strfind( var, "|" );
  if (not pipe) then return false; end
  
  --Parse variable location
  local location = strsub( var, 1, pipe-1 );
  local path = strsub( var, pipe+1 );
  if (location == "const") then
  
    --Cannot be set
    return false;
    
  elseif (location == "func") then
  
    --Parse function argument
    local arg = nil;
    local argStart = strfind( path, "[(]" );
    local argEnd = strfind( path, "[)]" );
    
    if (argStart and argEnd) then
      arg = strsub( path, argStart+1, argEnd-1 );
      path = strsub( path, 1, argStart-1 );
    end
    
    --Invoke setter function with argument
    local func = ChronoBars[ path.."_Set" ];
    func( value, arg );
    return true;
    
  else
  
    --Otherwise set in the table
    local settings = ChronoBars.GetSettingsTable( location );
    return ChronoBars.SetDeepValue( settings, path, value );
  end
end

function ChronoBars.GetSettingsTable( tableType )

	if (tableType == "root") then
		return ChronoBars;

	elseif (tableType == "temp") then
		if (not ChronoBars.temp) then ChronoBars.temp = {}; end
		return ChronoBars.temp;

	elseif (tableType == "char") then
		return ChronoBars_CharSettings;

	elseif (tableType == "profile") then
		return ChronoBars.GetActiveProfile();

	elseif (tableType == "group") then
		local profile = ChronoBars.GetActiveProfile();
		return profile.groups[ ChronoBars.temp.groupId ];

	elseif (tableType == "bar") then
		local profile = ChronoBars.GetActiveProfile();
		return profile.groups[ ChronoBars.temp.groupId ].bars[ ChronoBars.temp.barId ];
	end
  
  return nil;
end


--Gui construction
--===========================================================================

ChronoBars.configTemp = {};


function ChronoBars.Config_Construct( parentFrame, config )

	--Walk all the items in the config table
	local numItems = table.getn(config);
	for i = 1, numItems do
	repeat

		local item = config[i];

		--Check for condition		
		if (item.conditionVar ~= nil) then
			local curValue = CB.GetSettingsValue( item.conditionVar );
			if (curValue ~= item.conditionValue) then
				break;
			end
		end
		
		
		--Construct item based on type
		local frame = nil;
		
		if (item.type == "tabs") then
		
			--Create tab frame object
			local tabFrame = CB.NewObject( "tabframe" );
			tabFrame.OnTabChanged = ChronoBars.Config_OnTabChanged;
			tabFrame.item = item;
			frame = tabFrame;
			
			--Get tabs config
			local tabConfig = CB.GetSettingsValue( item.tabs );
			if (tabConfig == nil) then
				CB.Print( "Missing tab config table '"..tostring(item.tabs).."'" );
				break;
			end
			
			--Add tabs from config
			for t = 1, table.getn(tabConfig) do
				tabFrame:AddTab( tabConfig[t].text );
			end
			tabFrame:UpdateTabs();
			
			--Select tab by index from temp variable
			local s = CB.configTemp[ item.tabs.."Selection" ] or 1;
			tabFrame:SelectTab(s);
			
			--Get frame config
			local frameConfig = CB.GetSettingsValue( tabConfig[s].frame );
			if (frameConfig ~= nil) then
				
				--Construct sub frame recursively
				CB.Config_Construct( tabFrame, frameConfig );
			end
			
			--Add to container
			parentFrame:AddChild( tabFrame, true, true );
		
		elseif (item.type == "scroll") then
		
			--Create scroll frame object
			local scrFrame = CB.NewObject( "scrollframe" );
			frame = scrFrame;
			
			--[[
			--Get frame config
			local frameConfig = CB.GetSettingsValue( item.frame );
			if (frameConfig ~= nil) then
			
				--Construct sub frame recursively
				CB.Config_Construct( scrFrame, frameConfig );
			end
			--]]
			
			--Add to container
			parentFrame:AddChild( scrFrame, true, true );
			
			parentFrame = scrFrame;
			
		elseif (item.type == "group") then
		
			--Create group frame object
			local grpFrame = CB.NewObject( "groupframe" );
			grpFrame:SetLabelText( item.text );
			frame = grpFrame;
			
			--Get frame config
			local frameConfig = CB.GetSettingsValue( item.frame );
			if (frameConfig ~= nil) then
			
				--Construct sub frame recursively
				CB.Config_Construct( grpFrame, frameConfig );
			end
			
			--Add to container
			parentFrame:AddChild( grpFrame, true, false );
			
			
		elseif (item.type == "header") then
		
			--Create header frame object
			local hdrFrame = CB.NewObject( "header" );
			hdrFrame:SetText( CB.GetSettingsValue( item.text ));
			frame = hdrFrame;
			
			--Add to container
			parentFrame:AddChild( hdrFrame, true, false );
			
			
		elseif (item.type == "options") then
			
			--Create dropdown object
			local ddFrame = CB.NewObject( "dropdown" );
			ddFrame:SetLabelText( item.text );
			ddFrame.item = item;
			frame = ddFrame;
			
			--Get options config
			local ddConfig = CB.GetSettingsValue( item.options );
			if (ddConfig == nil) then
				CB.Print( "Missing options config table '"..tostring(item.options).."'" );
				break;
			end
			
			--Add items from config
			for d = 1, table.getn(ddConfig) do
				ddFrame:AddItem( ddConfig[d].text, ddConfig[d].value );
			end
			
			--Get value and apply to object
			local curValue = ChronoBars.GetSettingsValue( item.var );
			ddFrame:SelectValue( curValue );
			ddFrame.OnValueChanged = ChronoBars.Config_OnOptionChanged;
			
			--Add to container
			parentFrame:AddChild( ddFrame );
			
			
		elseif (item.type == "toggle") then
		
			--Create checkbox object
			local cbFrame = CB.NewObject( "checkbox" );
			cbFrame:SetText( item.text );
			cbFrame.item = item;
			frame = cbFrame;
			
			--Get value and apply to object
			local curValue = ChronoBars.GetSettingsValue( item.var );
			cbFrame:SetChecked( curValue );
			cbFrame.OnValueChanged = ChronoBars.Config_OnToggleChanged;
			
			--Add to container
			parentFrame:AddChild( cbFrame );
			
			
		elseif (item.type == "input" or item.type == "numinput") then
		
			--Create input object
			local inpFrame = CB.NewObject( "input" );
			inpFrame:SetLabelText( item.text );
			inpFrame.item = item;
			frame = inpFrame;
			
			--Get value and apply to object
			local curValue = ChronoBars.GetSettingsValue( item.var );
			inpFrame:SetText( tostring(curValue) );
			inpFrame.OnValueChanged = ChronoBars.Config_OnInputChanged;
			
			--Add to container
			parentFrame:AddChild( inpFrame );
			
			
		elseif (item.type == "color") then
		
			--Create color swatch object
			local colFrame = CB.NewObject( "color" );
			colFrame:SetText( item.text );
			colFrame.item = item;
			frame = colFrame;
			
			--Get value and apply to object
			local c = ChronoBars.GetSettingsValue( item.var );
			colFrame:SetColor( c.r, c.g, c.b, c.a );
			colFrame.OnValueChanged = ChronoBars.Config_OnColorChanged;
			
			--Add to container
			parentFrame:AddChild( colFrame );
			
			
		elseif (item.type == "font" or item.type == "texture") then
		
			--Create font object
			local fontFrame = CB.NewObject( item.type );
			fontFrame:SetLabelText( item.text );
			fontFrame.item = item;
			frame = fontFrame;
			
			--Get value and apply to object
			local curValue = ChronoBars.GetSettingsValue( item.var );
			fontFrame:SelectValue( curValue );
			fontFrame.OnValueChanged = ChronoBars.Config_OnOptionChanged;
			
			--Add to container
			parentFrame:AddChild( fontFrame );
			
		elseif (item.type == "button") then
		
			--Create button object
			local btnFrame = CB.NewObject( "button" );
			btnFrame:SetText( item.text );
			btnFrame.item = item;
			frame = btnFrame;
			
			--Register script
			btnFrame:SetScript( "OnClick", ChronoBars.Config_OnButtonClicked );
			
			--Add to container
			parentFrame:AddChild( btnFrame );
			
		end
		
	until true
	end
end

function ChronoBars.Config_OnTabChanged( tabFrame )
	CB.Debug( "TAB CHANGED" );
	
	local item = tabFrame.item;
	CB.configTemp[ item.tabs.."Selection" ] = tabFrame:GetSelectedIndex();
	CB.UpdateBarConfig();
	
end

function ChronoBars.Config_OnOptionChanged( ddFrame )
	CB.Debug( "OPTION CHANGED" );
	
	local item = ddFrame.item;
	local newValue = ddFrame:GetSelectedValue();
	
	CB.SetSettingsValue( item.var, newValue );
	CB.UpdateSettings();
	
	if (item.update) then
		CB.UpdateBarConfig();
	end
end

function ChronoBars.Config_OnToggleChanged( cbFrame )
	CB.Debug( "TOGGLE CHANGED" );
	
	local item = cbFrame.item;
	local newValue = cbFrame:GetChecked();
	
	if (newValue)
	then CB.SetSettingsValue( item.var, true );
	else CB.SetSettingsValue( item.var, false );
	end
	
	CB.UpdateSettings();
	
	if (item.update) then
		CB.UpdateBarConfig();
	end
end

function ChronoBars.Config_OnInputChanged( inpFrame )
	CB.Debug( "INPUT CHANGED" );
	
	local item = inpFrame.item;
	local newValue = inpFrame:GetText();
	
	if (item.type == "numinput")
	then CB.SetSettingsValue( item.var, tonumber(newValue) or 0 );
	else CB.SetSettingsValue( item.var, newValue );
	end
	
	inpFrame:SetText( tostring(CB.GetSettingsValue( item.var )) );
	CB.UpdateSettings();
	
	if (item.update) then
		CB.UpdateBarConfig();
	end
end

function ChronoBars.Config_OnColorChanged( colFrame )
	CB.Debug( "COLOR CHANGED" );
	
	local item = colFrame.item;
	local newValue = colFrame:GetColor();
	
	CB.SetSettingsValue( item.var, newValue );
	CB.UpdateSettings();
	
	if (item.update) then
		CB.UpdateBarConfig();
	end
end

function ChronoBars.Config_OnButtonClicked( btnFrame )
	CB.Debug( "BUTTON CLICKED" );
	
	local item = btnFrame.item;
	local func = ChronoBars.GetSettingsValue( item.func );
	
	if (func) then
		func( item );
	end
	
	if (item.update) then
		CB.UpdateBarConfig();
	end
	
	if (item.close) then
		CB.HideBarConfig();
	end
end

--Utility frames
--===========================================================================


function ChronoBars.ShowConfirmFrame (message, acceptFunc, cancelFunc, arg)

  if (not ChronoBars.confirmFrame) then
  
    --Create new Frame which subclasses Bling.Roster
    local f = CreateFrame( "Frame", "ChronoBars.ConfirmFrame", UIParent );
    f:SetFrameStrata( "FULLSCREEN_DIALOG" );
    f:SetToplevel( true );
    f:SetWidth( 300 );
    f:SetHeight( 100 );
    f:SetPoint( "CENTER", 0, 150 );
    f:EnableMouse( true );
    
    --Setup the background texture
    f:SetBackdrop(
      {bgFile = "Interface/Tooltips/UI-Tooltip-Background",
       edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
       tile = true, tileSize = 32, edgeSize = 32,
       insets = { left = 11, right = 12, top = 12, bottom = 11 }});
    f:SetBackdropColor(0,0,0,1);
    
    --Create the text label
    local txt = f:CreateFontString( "ChronoBars.InputFrame.Label", "OVERLAY", "GameFontNormal" );
    txt:SetTextColor( 1, 1, 1, 1 );
    txt:SetPoint( "TOPLEFT", 20, -20 );
    txt:SetPoint( "TOPRIGHT", -20, -20 );
    txt:SetHeight( 40 );
    txt:SetWordWrap( true );
    txt:SetText( message );
    txt:Show();
    
    --Create the Accept button
    local btnAccept = CreateFrame( "Button", nul, f, "UIPanelButtonTemplate" );
    btnAccept.myframe = f;
    btnAccept:SetWidth( 100 );
    btnAccept:SetHeight( 20 );
    btnAccept:SetPoint( "TOPRIGHT", f, "CENTER", -10, -10 );
    btnAccept:SetText( "Accept" );
    btnAccept:SetScript( "OnClick",
      function (self)
        self.myframe:Hide();
        if (self.myframe.acceptFunc) then
          self.myframe.acceptFunc( self.myframe.arg );
        end
      end
    );
    
    --Create the Cancel button
    local btnCancel = CreateFrame( "Button", nul, f, "UIPanelButtonTemplate" );
    btnCancel.myframe = f;
    btnCancel:SetWidth( 100 );
    btnCancel:SetHeight( 20 );
    btnCancel:SetPoint( "TOPLEFT", f, "CENTER", 10, -10 );
    btnCancel:SetText( "Cancel" );
    btnCancel:SetScript( "OnClick",
      function (self)
        self.myframe:Hide();
        if (self.myframe.cancelFunc) then
          self.myframe.cancelFunc( self.myframe.arg );
        end
      end
    );
    
    f.text = txt;
    ChronoBars.confirmFrame = f;
  end
  
  --Apply current value and show
  local f = ChronoBars.confirmFrame;
  f.acceptFunc = acceptFunc;
  f.cancelFunc = cancelFunc;
  f.text:SetText( message  );
  f.arg = arg;
  f:Show();
  
end

function ChronoBars.HideConfirmFrame()

	if (ChronoBars.confirmFrame) then
		ChronoBars.confirmFrame:Hide();
	end
end
