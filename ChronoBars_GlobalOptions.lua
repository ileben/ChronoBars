--[[

====================================================
ChronoBars - buff, debuff, cooldown, totem tracker
Author: Ivan Leben
====================================================

--]]

local CB = ChronoBars;

--Input box
--====================================================================

function ChronoBars.CreateInput( name )

	--Frame wrapper
	local f = CreateFrame( "Frame", name.."Wrapper", nil );
	f:SetHeight( 33 );
	
	--Label
	local l = f:CreateFontString( name.."Label", "OVERLAY", "GameFontNormal" );
	l:SetFont( "Fonts\\FRIZQT__.TTF", 10 );
	l:SetJustifyH( "LEFT" );
	l:SetPoint( "TOPLEFT", 0,0 );
	l:SetPoint( "TOPRIGHT", 0,0 );
	l:SetHeight( 8 );
	f.label = l;
	
	--Input
    local i = CreateFrame( "EditBox", name.."Input", f, "InputBoxTemplate" );
	i:SetPoint( "TOPLEFT", l, "BOTTOMLEFT", 5,0 );
	i:SetPoint( "TOPRIGHT", l, "BOTTOMRIGHT", -1,0 );
	i:SetHeight( 30 );
	i:SetAutoFocus( false );
	f.input = i;
	
	--Functions
	f.SetLabelText = ChronoBars.Input_SetLabelText;
	return f;
end

function ChronoBars.Input_SetLabelText( self, text )
	self.label:SetText( text );
end

function ChronoBars.Input_SetText( self, text )
	self.input:SetText( text );
end

function ChronoBars.Input_GetText( self )
	return self.input:GetText();
end

--Check box
--====================================================================

function ChronoBars.CreateCheckbox( name )

	--Use a frame wrapper, so that resizing it doesn't mess up the actual box
	local f = CreateFrame( "Frame", name.."Wrapper", nil );
	f:SetHeight( 21 );
	
	--This is the actual checkbox
	local c = CreateFrame( "CheckButton", name, f, "UICheckButtonTemplate" );
	c:SetPoint( "TOPLEFT", f, "TOPLEFT", -5, 5 );
	
	--Get font string that contains the text
	f.text = _G[ name.."Text" ];
	f.text:SetFont( "Fonts\\FRIZQT__.TTF", 12 );
	f.text:SetTextColor( 1,1,1 );
	
	--Functions
	f.SetText = ChronoBars.Checkbox_SetText;
	return f;
end

function ChronoBars.Checkbox_SetText( self, text )
	self.text:SetText( text );
end

--Dropdown box
--=====================================================================

function ChronoBars.CreateDropdown( name )

	--Wrapper
	local f = CreateFrame( "Frame", name.."Wrapper", nil );
	f:SetHeight( 40 );
	f:SetScript( "OnSizeChanged", ChronoBars.Dropdown_OnSizeChanged );
	
	--Label
	local l = f:CreateFontString( name.."Label", "OVERLAY", "GameFontNormal" );
	l:SetFont( "Fonts\\FRIZQT__.TTF", 10 );
	l:SetJustifyH( "LEFT" );
	l:SetPoint( "TOPLEFT", 0,0 );
	l:SetPoint( "TOPRIGHT", 0,0 );
	l:SetHeight( 8 );
	f.label = l;
	
	local d = CreateFrame( "Frame", name, f, "UIDropDownMenuTemplate" );
	d:SetPoint( "TOPLEFT", l, "BOTTOMLEFT", -20,-4 );
	d:SetPoint( "TOPRIGHT", l, "BOTTOMRIGHT", 0,-4 );
	f.drop = d;
	
	--Functions
	f.items = {};
	f.Free             = ChronoBars.Dropdown_Free;
	f.AddItem          = ChronoBars.Dropdown_AddItem;
	f.SelectItem       = ChronoBars.Dropdown_SelectItem;
	f.GetSelectedIndex = ChronoBars.Dropdown_GetSelectedIndex;
	f.GetSelectedText  = ChronoBars.Dropdown_GetSelectedText;
	f.Initialize       = ChronoBars.Dropdown_Initialize;
	f.SetLabelText     = ChronoBars.Dropdown_SetLabelText;
	
	--Init
	UIDropDownMenu_SetWidth( f.drop, 100 );
	UIDropDownMenu_SetButtonWidth( f.drop, 20 );
	UIDropDownMenu_Initialize( f.drop, function () f:Initialize() end );
	
	return f;
end

function ChronoBars.Dropdown_Free( self )
	CB.Util_ClearTable( self.items );
end

function ChronoBars.Dropdown_Initialize( self )

	local numItems = table.getn(self.items);
	for i = 1, numItems do

		local info = UIDropDownMenu_CreateInfo();
		info.text = self.items[i];
		info.value = i;
		info.owner = self.drop;
		info.checked = nil;
		info.icon = nil;
		info.func = ChronoBars.DropdownItem_Func;
		UIDropDownMenu_AddButton( info, 1 );
	end
end

function ChronoBars.Dropdown_SetBoxWidth( self, width )
  UIDropDownMenu_SetWidth( self.drop, width );
end

function ChronoBars.Dropdown_AddItem( self, text )
  table.insert( self.items, text );
  UIDropDownMenu_Initialize( self.drop, function () self:Initialize() end );
end

function ChronoBars.Dropdown_SelectItem( self, index )
  UIDropDownMenu_SetSelectedValue( self.drop, index );
end

function ChronoBars.Dropdown_GetSelectedIndex( self, index )
  return UIDropDownMenu_GetSelectedValue( self.drop );
end

function ChronoBars.Dropdown_GetSelectedText( self, index )
  return UIDropDownMenu_GetText( self.drop );
end

function ChronoBars.Dropdown_OnSizeChanged( self, width, height )
	UIDropDownMenu_SetWidth( self.drop, width-15 );
end

function ChronoBars.DropdownItem_Func( self )
	UIDropDownMenu_SetSelectedValue( self.owner, self.value );
end

function ChronoBars.Dropdown_SetLabelText( self, text )
	self.label:SetText( text );
end

--Tab
--=====================================================================

function ChronoBars.CreateTab( name )

	local tab = CreateFrame("Button", name, nil, "OptionsFrameTabButtonTemplate");
	
	tab.text = _G[name .. "Text"];
	
	tab.Resize = ChronoBars.Tab_Resize;
	tab.GetTextWidth = ChronoBars.Tab_GetTextWidth;
	tab.SetSelected = ChronoBars.Tab_SetSelected;
	tab.GetSelected = ChronoBars.Tab_GetSelected;
	
	tab:SetText( "Tab" );
	tab:SetSelected( false );
	
	return tab;

end

function ChronoBars.Tab_Resize( self, width )
	PanelTemplates_TabResize( self, nil, width );
end

function ChronoBars.Tab_GetTextWidth( self, selected )
	return self.text:GetStringWidth()
end

function ChronoBars.Tab_SetSelected( self, selected )

	self.selected = selected;
	
	if (self.selected)
	then PanelTemplates_SelectTab( self );
	else PanelTemplates_DeselectTab( self );
	end
	
end

function ChronoBars.Tab_GetSelected( self )
	return self.selected;
end


--Tab Frame
--=====================================================================

function ChronoBars.CreateTabFrame( name )

	--Frame
	local f = CreateFrame( "Frame", name, nil );
	f:SetScript( "OnSizeChanged", ChronoBars.TabFrame_OnSizeChanged );
	
	--Border
	local b = CreateFrame( "Frame", "ChronoBars.TabFrameBorder", f );
	
	b:SetBackdrop(
		{bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
		 edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		 tile = true, tileSize = 16, edgeSize = 16,
		 insets = { left = 3, right = 3, top = 5, bottom = 3 }});
	
	b:SetBackdropColor( 0.1, 0.1, 0.1, 0.5 );
	b:SetBackdropBorderColor( 0.4, 0.4, 0.4 );
	b:SetAllPoints( f );
	
	--Container
	local pad = 15;
	local c = CreateFrame( "Frame", name.."Container", b );
	c:SetPoint( "BOTTOMLEFT", pad, pad );
	c:SetPoint( "TOPRIGHT", -pad,-pad );
	f.container = c;
	
	--Tabs
	f.tabs = {};
	f.titles = {};
	f.widths = {};
	f.starts = {};
	f.counts = {};
	f.border = b;
	f.selected = 0;
	
	f.Free              = ChronoBars.TabFrame_Free;
	f.AddTab            = ChronoBars.TabFrame_AddTab;
	f.SelectTab         = ChronoBars.TabFrame_SelectTab;
	f.GetSelectedIndex  = ChronoBars.TabFrame_GetSelectedIndex;
	f.UpdateTabs        = ChronoBars.TabFrame_UpdateTabs;
	
	return f;
end

function ChronoBars.TabFrame_Free( self )

	--Free every tab
	for i,tab in ipairs( self.tabs ) do
		CB.FreeObject( self.tabs[i] );
	end
	
	CB.Util_ClearTable( self.tabs );
end

function ChronoBars.TabFrame_UpdateTabs( self )
	
	--Bail if OnSizeChanged hasn't happened yet
	if (self.width == nil) then	return; end
	
	CB.Util_ClearTable( self.widths );
	CB.Util_ClearTable( self.starts );
	CB.Util_ClearTable( self.counts );
	
	table.insert( self.widths, 0 );
	table.insert( self.starts, 1 );
	table.insert( self.counts, 0 );
	
	--Get total width of each row
	local row = 1;
	local numTabs = table.getn( self.tabs );
	for t=1,numTabs do
	
		--Set text and measure tab width
		local tab = self.tabs[t];
		tab:SetText( self.titles[t] );
		local tabW = tab:GetTextWidth() + 40;
		
		--Go to next row, if limit reached
		if (self.widths[ row ] + tabW > self.width and t > 1) then
			table.insert( self.widths, 0 );
			table.insert( self.starts, t );
			table.insert( self.counts, 0 );
			row = row + 1;
		end
		
		--Add to row width
		self.widths[ row ] = self.widths[ row ] + tabW;
		self.counts[ row ] = self.counts[ row ] + 1;
	end

	--Walk every row
	local y = -5;
	local numRows = table.getn( self.widths );
	for r = 1, numRows do
	
		--Find extra width to be added to every tab
		local extraW = (self.width - self.widths[r]) / self.counts[r];
		local totalW = 0;
		
		--Walk every tab in this row
		local firstTab = self.starts[r];
		local lastTab  = self.starts[r] + self.counts[r] - 1;
		for t = firstTab, lastTab  do
			
			--Add extra width to tab
			local tab = self.tabs[t];
			local tabW = tab.text:GetStringWidth() + 40;
			if (extraW > 0) then tabW = tabW + extraW; end
			
			--Resize and position the tab
			tab:Resize( tabW );
			tab:SetPoint( "BOTTOMLEFT", self, "TOPLEFT", totalW, y - 20 );
			totalW = totalW + tabW;
		end
		
		y = y - 20;
	end
	
	--Resize border
	self.border:SetPoint( "TOPLEFT", 0, y );
end

function ChronoBars.TabFrame_AddTab( self, title )

	local numTabs = table.getn( self.tabs );

	--Create new tab
	--local tab = CB.CreateTab( self:GetName().."Tab"..tostring(numTabs) );
	local tab = CB.NewObject( "tab" );
	tab:SetParent( self );
	tab:SetText( title );
	tab:SetPoint( "BOTTOMLEFT", self, "TOPLEFT", 0, 0 );
	tab:SetScript( "OnClick", ChronoBars.TabFrameTab_OnClick );
	tab.index = numTabs + 1;
	tab.myframe = self;
	
	--Add to list
	table.insert( self.tabs, tab );
	table.insert( self.titles, title );
	self:UpdateTabs();
	
	--Select if first
	if (numTabs == 1) then
		self:SelectTab( 1 );
	end
	
	return tab;
end

function ChronoBars.TabFrame_SelectTab( self, index )

	--Deselect other tabs
	for i=1,table.getn(self.tabs) do
		self.tabs[i]:SetSelected( false );
	end
	
	--Select this tab
	self.tabs[index]:SetSelected( true );
	self.selected = index;
end

function ChronoBars.TabFrame_GetSelectedIndex( self )
	return self.selected;
end

function ChronoBars.TabFrameTab_OnClick( self )
	self.myframe:SelectTab( self.index );
end

function ChronoBars.TabFrame_OnSizeChanged( self, width, height )

	--Cache size so we don't have to call GetWidth() which
	--for some stupid reason triggers OnSizeChanged again
	self.width = width;
	self.height = height;
	self:UpdateTabs();
end


--Frame
--=====================================================================

function ChronoBars.CreateConfigFrame( title, resizable )

	local name = "ChronoBars.ConfigFrame";
	
	--Frame
	local f = CreateFrame( "Frame", name, UIParent );
	f:SetFrameStrata( "DIALOG" );
	f:SetToplevel( true );
	f:SetWidth( 300 );
	f:SetHeight( 500 );
	f:SetPoint( "CENTER", 0, 150 );
	
	f:SetBackdrop(
	  {bgFile = "Interface/Tooltips/UI-Tooltip-Background",
	   edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
	   tile = true, tileSize = 32, edgeSize = 32,
	   insets = { left = 11, right = 12, top = 12, bottom = 11 }});
	   
	f:SetBackdropColor(0,0,0,0.8);
	
	--Make movable
	f:SetMovable( true );
	f:SetResizable( true );
	f:EnableMouse( true );
	f:RegisterForDrag( "LeftButton" );
	f:SetScript( "OnDragStart", ChronoBars.Frame_OnDragStart );
	f:SetScript( "OnDragStop", ChronoBars.Frame_OnDragStop );
	
	if (title) then
	
		--Create the title frame
		local fTitle = CreateFrame( "Frame", name.."Title", f );
		fTitle.myframe = f;
		fTitle:SetWidth( 185 );
		fTitle:SetHeight( 40 );
		fTitle:SetPoint( "TOP", 0, 15 ); 
		fTitle:SetFrameStrata( "DIALOG" );
		
		--Make the title move the whole frame
		fTitle:EnableMouse( true );
		fTitle:RegisterForDrag( "LeftButton" );
		fTitle:SetScript( "OnDragStart", function (self) self.myframe:StartMoving() end );
		fTitle:SetScript( "OnDragStop", function (self) self.myframe:StopMovingOrSizing() end );
		
		--Create the title texture
		--(the texture is larger and has transparent space around it
		-- so we have to scale it up around the title frame)
		local texTitle = fTitle:CreateTexture( nil, "BACKGROUND" );
		texTitle:SetTexture( "Interface/DialogFrame/UI-DialogBox-Header" );
		texTitle:SetPoint( "TOPRIGHT", 57, 0 );
		texTitle:SetPoint( "BOTTOMLEFT", -58, -24 );

		--Create the title text
		local txtTitle = fTitle:CreateFontString( nil, "OVERLAY", nil );
		txtTitle:SetFont( "Fonts/MORPHEUS.ttf", 15 );
		txtTitle:SetText( title );
		txtTitle:SetWidth( 300 );
		txtTitle:SetHeight( 64 );
		txtTitle:SetPoint( "TOP", 0, 12 );
	end
	
	if (resizable) then
	
		local sizer = CreateFrame("Frame",nil,f)
		sizer:SetPoint("BOTTOMRIGHT",f,"BOTTOMRIGHT",0,0);
		sizer:SetWidth(25);
		sizer:SetHeight(25);
		sizer:EnableMouse( true );
		sizer:SetScript("OnMouseDown", ChronoBars.FrameSizer_OnMouseDown);
		sizer:SetScript("OnMouseUp", ChronoBars.FrameSizer_OnMouseUp);
		sizer.myframe = f;
		f.sizer = sizer;

		local line1 = sizer:CreateTexture(nil, "BACKGROUND");
		line1:SetWidth(14);
		line1:SetHeight(14);
		line1:SetPoint("BOTTOMRIGHT", -8, 8);
		line1:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border");
		local x = 0.1 * 14/17;
		line1:SetTexCoord(0.05 - x, 0.5, 0.05, 0.5 + x, 0.05, 0.5 - x, 0.5 + x, 0.5);
		f.line1 = line1;

		local line2 = sizer:CreateTexture(nil, "BACKGROUND");
		line2:SetWidth(8);
		line2:SetHeight(8);
		line2:SetPoint("BOTTOMRIGHT", -8, 8);
		line2:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border");
		local x = 0.1 * 8/17;
		line2:SetTexCoord(0.05 - x, 0.5, 0.05, 0.5 + x, 0.05, 0.5 - x, 0.5 + x, 0.5);
		f.line2 = line2;
		
	end
	
	--Close button
	local btnClose = CreateFrame( "Button", name.."CloseBtn", f, "UIPanelCloseButton" );
	btnClose.myframe = f;
	btnClose:SetPoint( "TOPRIGHT", -5, -7 );
	btnClose:SetScript( "OnClick", function (self) self.myframe:Hide() end );
	btnClose:Show();
	
	--Container
	local pad = 20;
	local c = CreateFrame( "Frame", name.."Container", f );
	c:SetPoint( "BOTTOMLEFT", pad, pad );
	c:SetPoint( "TOPRIGHT", -pad,-30 );
	f.container = c;

	return f;
end

function ChronoBars.Frame_OnDragStart( frame )
	frame:StartMoving();
end

function ChronoBars.Frame_OnDragStop( frame )
	frame:StopMovingOrSizing();
end

function ChronoBars.FrameSizer_OnMouseDown( self )
	self.myframe:StartSizing();
end

function ChronoBars.FrameSizer_OnMouseUp( self )
	self.myframe:StopMovingOrSizing();
end


--Factory
--===========================================================================

function ChronoBars.NewObject( class )

	--Init class factory first time
	if (CB.factory == nil) then
		CB.factory = {};
	end
	
	if (CB.factory[ class ] == nil) then
		CB.factory[ class ] = {};
		CB.factory[ class ].objects = {};
		CB.factory[ class ].capacity = 0;
		CB.factory[ class ].used = 0;
	end
	
	--Get class-specific factory
	local object = nil;
	local cache = CB.factory[ class ];
	local capacity = table.getn( cache.objects );

	--Check if there's any unused objects left
	if (cache.used < capacity) then

		--Return existing object
		cache.used = cache.used + 1;
		object = cache.objects[ cache.used ];

	else

		--Create new object if capacity exhausted
		cache.used = capacity + 1;

		if     (class == "input")    then object = CB.CreateInput( "ChronoBars.Input" .. cache.used );
		elseif (class == "checkbox") then object = CB.CreateCheckbox( "ChronoBars.Checkbox" .. cache.used );
		elseif (class == "dropdown") then object = CB.CreateDropdown( "ChronoBars.Dropdown" .. cache.used );
		elseif (class == "tab")      then object = CB.CreateTab( "ChronoBars.Tab" .. cache.used );
		elseif (class == "tabframe") then object = CB.CreateTabFrame( "ChronoBars.TabFrame" .. cache.used );
		end

		object.cacheClass = class;
		object.cacheId = cache.used;
		table.insert( cache.objects, object );
	end

	--Init object
	object.cacheUsed = true;
	object:Show();
	return object;
end


function ChronoBars.FreeObject( object )

	--Object must be used
	if (object.cacheUsed == false) then
		return
	end
	
	--Swap freed object with last used object and their ids
	local cache = CB.factory[ object.cacheClass ];
	
	if (object.cacheId < cache.used) then

		local objectId = object.cacheId;
		local lastId = cache.used;
		local last = cache.objects[ lastId ];

		cache.objects[ objectId ] = last;
		cache.objects[ lastId ] = object; 

		object.cacheId = lastId;
		last.cacheId = objectId;
	end

	cache.used = cache.used - 1;
	
	--Reset object
	object.cacheUsed = false;
	object:Hide();
	object:ClearAllPoints();
	object:SetParent( nil );
	
	--Notify object it's been freed
	if (object.Free) then
		object:Free();
	end
end


function ChronoBars.FreeAllObjects()

	--Cache must exist
	if (CB.factory == nil) then
		return
	end
	
	--Walk every cache
	for class,cache in pairs(CB.factory) do

		--Walk every object in cache
		for id,object in ipairs(cache.objects) do
		
			--Reset object
			object.cacheUsed = false;
			object:Hide();
			object:ClearAllPoints();
			object:SetParent( nil );
		end
		
		--Walk every object in cache
		for id,object in ipairs(cache.objects) do
		
			--Notify object it's been freed
			if (object.Free) then
				object:Free()
			end
		end
		
		cache.used = 0;
	end
end


--Construction
--===========================================================================

ChronoBars.Env = {};

function ChronoBars.SetEnv( key, value )
	CB.Env[ key ] = value;
end

function ChronoBars.GetEnv( key )
	return CB.Env[ key ];
end

ChronoBars.FrameId = 0;

function ChronoBars.GetNewFrameId()
	CB.FrameId = CB.FrameId + 1;
	return CB.FrameId;
end

function ChronoBars.ConstructConfigFrame( container, config )

	local prevFrame = nil;
	
	--Walk all the items in the config table
	local numItems = table.getn(config);
	for i = 1, numItems do
	repeat

		--Construct item based on type
		local item = config[i];
		local frame = nil;
		
		
		if (item.type == "tabs") then
		
			--Create tab object
			--local tabFrame = CB.CreateTabFrame( "ChronoBars.TabFrame"..CB.GetNewFrameId() );
			local tabFrame = CB.NewObject( "tabframe" );
			tabFrame:SetPoint( "BOTTOMRIGHT", container, "BOTTOMRIGHT" );
			frame = tabFrame;
			
			--Get tabs config
			local tabConfig = CB.GetSettingsValue( nil, item.tabs );
			if (tabConfig == nil) then
				CB.Print( "Missing tab config table '"..tostring(item.tabs).."'" );
				break;
			end
			
			--Add tabs from config
			for t = 1, table.getn(tabConfig) do
				tabFrame:AddTab( tabConfig[t].text );
			end
			
			--Select tab by index from environment variable
			local s = CB.GetEnv( tabFrame:GetName().."Selection" ) or 1;
			tabFrame:SelectTab(s);
			
			--Get frame config
			local frameConfig = CB.GetSettingsValue( nil, tabConfig[s].frame );
			if (frameConfig ~= nil) then
			
				--Construct sub frame
				CB.ConstructConfigFrame( tabFrame.container, frameConfig );
			end
			
			
		elseif (item.type == "options") then
			
			--Create dropdown object
			--local ddFrame = CB.CreateDropdown( "ChronoBars.Dropdown"..CB.GetNewFrameId() );
			local ddFrame = CB.NewObject( "dropdown" );
			ddFrame:SetLabelText( item.text );
			frame = ddFrame;
			
			--Get options config
			local ddConfig = CB.GetSettingsValue( nil, item.options );
			if (ddConfig == nil) then
				CB.Print( "Missing options config table '"..tostring(item.options).."'" );
				break;
			end
			
			--Add items from config
			for d = 1, table.getn(ddConfig) do
				ddFrame:AddItem( ddConfig[d].text );
			end
			
		elseif (item.type == "toggle") then
		
			--Create checkbox object
			--local cbFrame = CB.CreateCheckbox( "ChronoBars.Checkbox"..CB.GetNewFrameId() );
			local cbFrame = CB.NewObject( "checkbox" );
			cbFrame:SetText( item.text );
			frame = cbFrame;
			
		elseif (item.type == "input") then
		
			--Create input object
			--local inpFrame = CB.CreateInput( "ChronoBars.Input"..CB.GetNewFrameId() );
			local inpFrame = CB.NewObject( "input" );
			inpFrame:SetLabelText( item.text );
			frame = inpFrame;
		end
		
		--Position item below previous one			
		if (prevFrame == nil)
		then frame:SetPoint( "TOPLEFT", container, "TOPLEFT", 0,0 );
		else frame:SetPoint( "TOPLEFT", prevFrame, "BOTTOMLEFT", 0,0 );
		--else frame:SetPoint( "TOPLEFT", prevFrame, "BOTTOMLEFT", 0,-10 );
		end
		
		--Resize item to container
		frame:SetPoint( "RIGHT", container, "RIGHT", 0,0 );
		
		--Add to container
		frame:SetParent( container );
		prevFrame = frame;
		
	until true
	end
end

--Stuff
--===========================================================================


ChronoBars.Frame_Root =
{
	{ type="tabs", tabs="root|Tabs_Root" },
};

ChronoBars.Tabs_Root =
{
	{ text="Hello",   frame="root|Frame_Test" },
	{ text="Kitty" },
	{ text="Cat" },
};

ChronoBars.Frame_Test =
{
	{ type="options",   text="Options:",       options="root|Options_Test" },
	{ type="input",     text="Input:" },
	{ type="toggle",    text="Enabled" },
	{ type="input",     text="Other input:" },
	{ type="tabs",      tabs="root|Tabs_Test" },
};

ChronoBars.Options_Test =
{
	{ text="Test1" },
	{ text="Test2" },
	{ text="Test3" },
};

ChronoBars.Tabs_Test =
{
	{ text="Hello" },
	{ text="World" },
	{ text="of Warcraft" },
};

function ChronoBars.OpenBarConfig (bar)
 
	CB.MenuId.groupId = bar.groupId;
	CB.MenuId.barId = bar.barId;

	if (not CB.configFrame) then
	
		CB.configFrame = CB.CreateConfigFrame("Config", true);
		
	end
	
	CB.FreeAllObjects();
	CB.ConstructConfigFrame( CB.configFrame.container, CB.Frame_Root );
	CB.configFrame:Show();
end

function ChronoBars.CloseBarConfig()

	if (CB.configFrame) then
		CB.configFrame:Hide();
	end
end


--Initialization
--===================================================

function ChronoBars.InitOptionsPanel ()

  CB.Print( "InitOptionsPanel" );
  local f = CreateFrame( "Frame", "ChronoBarsGlobalOptionsPanel", InterfaceOptionsFramePanelContainer );

  local txtTest =  f:CreateFontString( "txtTest" );
  txtTest:SetFontObject( "GameFontNormal" );
  txtTest:SetJustifyH( "LEFT" );
  txtTest:SetTextColor( 1.0, 1.0, 1.0, 1.0 );
  txtTest:SetShadowOffset( 1, -1 );
  txtTest:SetWordWrap( false );
  txtTest:SetPoint( "TOPLEFT", 10, -10 );
  txtTest:SetPoint( "BOTTOMRIGHT", -10, 10 );
  txtTest:SetJustifyH( "LEFT" );
  txtTest:SetJustifyV( "TOP" );
  txtTest:SetText( "Global options coming soon.\n" ..
    "Use |cffffff00/cb |cffffffffto toggle config mode.\n" ..
    "Use |cffffff00/cb update X|cffffffff to set update interval to X seconds.\n" ..
    "Use |cffffff00/cb reset groups|cffffffff to reset group positions to center of screen.\n" ..
    "Use |cffffff00/cb reset profile|cffffffff to reset the entire profile." );
  txtTest:SetWordWrap( true );
  
  --Add panel as an interface options category
  f.name = "ChronoBars";
  InterfaceOptions_AddCategory( f );
  
end

--Main entry point
ChronoBars.InitOptionsPanel();


