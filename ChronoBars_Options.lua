--[[

====================================================
ChronoBars - buff, debuff, cooldown, totem tracker
Author: Ivan Leben
====================================================

--]]

local CB = ChronoBars;
ChronoBars.MenuId = { groupId = 1, barId = 1 };
ChronoBars.MenuEnv = {};

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


--Confirmation frame
--================================================================

function ChronoBars.ShowConfirmFrame (message, acceptFunc, cancelFunc, arg)

  if (not ChronoBars.confirmFrame) then
  
    --Create new Frame which subclasses Bling.Roster
    local f = CreateFrame( "Frame", "ChronoBars.ConfirmFrame", UIParent );
    f:SetFrameStrata( "DIALOG" );
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

--Reset functions
--=============================================================

function ChronoBars.ResetProfile_Accept (arg)
  ChronoBars.Debug( "Resetting current profile" );

  local pname = ChronoBars_CharSettings.activeProfile;
  ChronoBars_Settings.profiles[ pname ] = CopyTable( ChronoBars.DEFAULT_PROFILE );
  ChronoBars.UpdateSettings();
  
end


function ChronoBars.ResetGroups_Accept (arg)
  ChronoBars.Debug( "Resetting group positions" );
  
  local profile = ChronoBars.GetActiveProfile();
  for g=1,table.getn( profile.groups ) do
    profile.groups[g].x = 0;
    profile.groups[g].y = 0;
  end
  
  ChronoBars.UpdateSettings();
end
