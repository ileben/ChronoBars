--[[

====================================================
ChronoBars - buff, debuff, cooldown, totem tracker
Author: Ivan Leben
====================================================

--]]

local CB = ChronoBars;

--Input box
--====================================================================

function ChronoBars.Input_New( name )

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
	i:SetScript( "OnEnterPressed", ChronoBars.Input_OnEnterPressed );
	i:SetScript( "OnSizeChanged", ChronoBars.Input_OnSizeChanged );
	i.frame = f;
	f.input = i;
	
	--Functions
	ChronoBars.Object_New( f );
	
	f.SetLabelText = ChronoBars.Input_SetLabelText;
	f.SetText      = ChronoBars.Input_SetText;
	f.GetText      = ChronoBars.Input_GetText;
	return f;
end

function ChronoBars.Input_SetLabelText( frame, text )
	frame.label:SetText( text );
end

function ChronoBars.Input_SetText( frame, text )
	frame.input:SetText( text );
end

function ChronoBars.Input_GetText( frame )
	return frame.input:GetText();
end

function ChronoBars.Input_OnEnterPressed( input )
	local frame = input.frame;
	local script = frame.OnValueChanged;
	if (script) then script( frame ); end
end

function ChronoBars.Input_OnSizeChanged( input )
	input:SetCursorPosition(0);
end

--Check box
--====================================================================

function ChronoBars.Checkbox_New( name )

	--Use a frame wrapper, so that resizing it doesn't mess up the actual box
	local f = CreateFrame( "Frame", name.."Wrapper", nil );
	f:SetHeight( 21 );
	
	--This is the actual checkbox
	local c = CreateFrame( "CheckButton", name, f, "UICheckButtonTemplate" );
	c:SetPoint( "TOPLEFT", f, "TOPLEFT", -5, 5 );
	c:SetScript( "OnClick", ChronoBars.Checkbox_OnClick );
	c.frame = f;
	f.check = c;
	
	--Get font string that contains the text
	f.text = _G[ name.."Text" ];
	f.text:SetFont( "Fonts\\FRIZQT__.TTF", 12 );
	f.text:SetTextColor( 1,1,1 );
	
	--Functions
	ChronoBars.Object_New( f );
	
	f.SetText     = ChronoBars.Checkbox_SetText;
	f.SetChecked  = ChronoBars.Checkbox_SetChecked;
	f.GetChecked  = ChronoBars.Checkbox_GetChecked;
	
	return f;
end

function ChronoBars.Checkbox_SetText( frame, text )
	frame.text:SetText( text );
end

function ChronoBars.Checkbox_SetChecked( frame, checked )
	frame.check:SetChecked( checked );
end

function ChronoBars.Checkbox_GetChecked( frame )
	return frame.check:GetChecked();
end

function ChronoBars.Checkbox_OnClick( check )
	local frame = check.frame;
	local script = frame.OnValueChanged;
	if (script) then script( frame ); end
end


--Color swatch
--=====================================================================

function ChronoBars.ColorSwatch_New( name )

	local size = 20;
	local p = 1;
	
	--Frame
	local f = CreateFrame( "Frame", name, nil );
	f:SetHeight( size );
	
	--Box
	local t = f:CreateTexture( nil, "ARTWORK" );
	t:SetPoint( "TOPLEFT", 0,0 );
	t:SetWidth( size );
	t:SetHeight( size );
	t:SetTexture( 1,1,1, 1 );
	t:SetDrawLayer( "ARTWORK", 1 );
	
	local t2 = f:CreateTexture( nil, "ARTWORK" );
	t2:SetPoint( "BOTTOMLEFT", t, "BOTTOMLEFT", p,p );
	t2:SetPoint( "TOPRIGHT", t, "TOPRIGHT", -p,-p );
	t2:SetTexture( 0,0,0, 1 );
	t2:SetDrawLayer( "ARTWORK", 2 );
	
	local t3 = f:CreateTexture( nil, "ARTWORK" );
	t3:SetPoint( "BOTTOMLEFT", t2, "BOTTOMLEFT", p,p );
	t3:SetPoint( "TOPRIGHT", t2, "TOPRIGHT", -p,-p );
	t3:SetTexture( 0,0,1, 1 );
	t3:SetDrawLayer( "ARTWORK", 3 );
	
	f.box = t3;
	
	--Label
	local l = f:CreateFontString( name.."Label", "OVERLAY", "GameFontNormal" );
	l:SetFont( "Fonts\\FRIZQT__.TTF", 12 );
	l:SetTextColor( 1,1,1 );
	l:SetText( "Color" );
	l:SetJustifyH( "LEFT" );
	l:SetPoint( "TOPLEFT", size + 5, 0 );
	l:SetPoint( "BOTTOMRIGHT", 0,0 );
	f.label = l;
	
	--Functions
	ChronoBars.Object_New( f );
	f.SetColor = ChronoBars.ColorSwatch_SetColor;
	f.SetText  = ChronoBars.ColorSwatch_SetText;
	return f;
	
end

function ChronoBars.ColorSwatch_SetColor( frame, r, g, b, a )

	frame.box:SetTexture( r,g,b,a );
end

function ChronoBars.ColorSwatch_SetText( frame, text )

	frame.label:SetText( text );
end


--Header
--=====================================================================

function ChronoBars.Header_New( name )

	--Frame
	local f = CreateFrame( "Frame", name, nil );
	f:SetHeight( 25 );
	
	--Background
	local b = f:CreateTexture( nil, "ARTWORK" );
	b:SetTexture( "Interface\\AddOns\\ChronoBars\\Textures\\Header.tga" );
	b:SetAllPoints( f );
	
	--Label
	local l = f:CreateFontString( name.."Label", "OVERLAY", "GameFontNormal" );
	l:SetFont( "Fonts\\FRIZQT__.TTF", 12 );
	l:SetAllPoints( f );
	l:SetText( "Group" );
	f.label = l;
	
	--Functions
	ChronoBars.Object_New( f );
	f.SetText  = ChronoBars.Header_SetText;
	return f;
end

function ChronoBars.Header_SetText( frame, text )
	frame.label:SetText( text );
end


--Container
--=====================================================================

function ChronoBars.Container_New( f )
	
	--Private vars
	f.spacing = 10;
	f.width = 0;
	f.height = 0;
	f.contentHeight = 0;
	f.children = {};
	f.childrenWidths = {};
	f.childrenHeights = {};
	
	--Functions
	ChronoBars.Object_New( f );
	
	f.Init              = ChronoBars.Container_Init;
	f.Free              = ChronoBars.Container_Free;
	f.AddChild          = ChronoBars.Container_AddChild;
	f.RemoveAllChildren = ChronoBars.Container_RemoveAllChildren;
	f.FindChildIndex    = ChronoBars.Container_FindChildIndex;
	f.SetSpacing        = ChronoBars.Container_SetSpacing;
	f.GetContentHeight  = ChronoBars.Container_GetContentHeight;
	f.UpdateContent     = ChronoBars.Container_UpdateContent;
	f.QueueUpdate       = ChronoBars.Container_QueueUpdate;
	
	return f;
end

function ChronoBars.Container_Init( frame )

	ChronoBars.Object_Init( frame );
	frame:QueueUpdate();
end

function ChronoBars.Container_Free( frame )

	frame:RemoveAllChildren();	
	ChronoBars.Object_Free( frame );
end

function ChronoBars.Container_SetSpacing( frame, spacing )

	frame.spacing = spacing;
	frame:UpdateContent();
end

function ChronoBars.Container_GetContentHeight( frame )

	return frame.contentHeight;
end

function ChronoBars.Container_AddChild( frame, child )

	--CB.Print( "ADD CHILD " .. frame:GetName() );
	
	table.insert( frame.children, child );
	table.insert( frame.childrenWidths, 0 );
	table.insert( frame.childrenHeights, 0 );
	
	child.parent = frame;
	child:SetParent( frame.container );
	child:RegisterScript( "OnSizeChanged", ChronoBars.Container_OnChildSizeChanged );
	
	frame:QueueUpdate();
end

function ChronoBars.Container_RemoveAllChildren( frame )

	for i,child in ipairs(frame.children) do
	
		child:ClearAllPoints();
		child:SetParent( nil );
		child:UnregisterScript( "OnSizeChanged", ChronoBars.Container_OnChildSizeChanged );
	end
	
	CB.Util_ClearTable( frame.children );
	CB.Util_ClearTable( frame.childrenWidths );
	CB.Util_ClearTable( frame.childrenHeights );
end

function ChronoBars.Container_FindChildIndex( frame, child )
	
	for i,c in ipairs(frame.children) do
		if (c == child) then
			return i;
		end
	end
	
	return 0;
end

function ChronoBars.Container_UpdateContent( frame )
	
	CB.Print( "UPDATING LAYOUT " .. frame:GetName() );
	
	--Set update lock
	frame.updating = true;
	
	local numChildren = table.getn( frame.children );
	local prevChild = nil;
	frame.contentHeight = 0;
	
	for i=1,numChildren do
	
		--Size item to width of container
		local child = frame.children[i];
		child:ClearAllPoints();
		child:SetPoint( "RIGHT", frame.container, 0,0 );

		--Position item below previous one
		if (prevChild == nil) then
			child:SetPoint( "TOPLEFT", frame.container, "TOPLEFT", 0,0 );
			frame.contentHeight = frame.contentHeight + frame.childrenHeights[i];
		else
			child:SetPoint( "TOPLEFT", prevChild, "BOTTOMLEFT", 0,-frame.spacing );
			frame.contentHeight = frame.contentHeight + frame.spacing + frame.childrenHeights[i];
		end
		
		--Store previous
		prevChild = child;
	end
	
	--Resize
	frame:SizeToContent();
	
	--Release update lock
	frame.updating = false;
end

function ChronoBars.Container_OnContainerSizeChanged( container, width, height )

	local frame = container.frame;
	--CB.Print( "CONTAINER SIZE CHANGED " .. frame:GetName() );
	
	local oldWidth = container.width;
	local oldHeight = container.height;
	
	container.width = width;
	container.height = height;
	
	if (oldWidth == width and oldHeight == height) then
		return
	end

	frame:QueueUpdate();
	
end

function ChronoBars.Container_OnChildSizeChanged( child, width, height )
	
	local frame = child.parent;
	local i = frame:FindChildIndex( child );
	--CB.Print( "CHILD SIZE CHANGED " .. frame:GetName() );
	
	local oldWidth = frame.childrenWidths[i];
	local oldHeight = frame.childrenHeights[i];
	
	frame.childrenWidths[i] = width;
	frame.childrenHeights[i] = height;
	
	if (frame.updating) then
		--CB.Print( "UPDATE LOCK" );
		return
	end
	
	if (height == oldHeight) then
		--CB.Print( "HEIGHT LOCK" );
		return
	end
	
	frame:QueueUpdate();

end

function ChronoBars.Container_QueueUpdate( frame )

	frame:SetScript( "OnUpdate", ChronoBars.Container_OnUpdate );
end

function ChronoBars.Container_OnUpdate( frame )	

	frame:UpdateContent();
	frame:SetScript( "OnUpdate", nil );
end

--Group Frame
--=====================================================================

function ChronoBars.GroupFrame_New( name )

	--[[
	--Frame
	local f = CreateFrame( "Frame", name, nil );
	
	--Label
	local l = f:CreateFontString( name.."Label", "OVERLAY", "GameFontNormal" );
	l:SetFont( "Fonts\\FRIZQT__.TTF", 12 );
	l:SetJustifyH( "LEFT" );
	l:SetPoint( "TOPLEFT", 0,0 );
	l:SetPoint( "TOPRIGHT", 0,0 );
	l:SetHeight( 12 );
	f.label = l;
	
	--Border
	local b = CreateFrame( "Frame", name.."Border", f );
	
	b:SetBackdrop(
		{bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
		 edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		 tile = true, tileSize = 16, edgeSize = 16,
		 insets = { left = 3, right = 3, top = 5, bottom = 3 }});
	
	b:SetBackdropColor( 0.1, 0.1, 0.1, 0.5 );
	b:SetBackdropBorderColor( 1.0, 0.9, 0.0 );
	b:SetPoint( "TOPLEFT", 0, -17 );
	b:SetPoint( "BOTTOMRIGHT", 0, 0 );
	
	--Container
	local pad = 15;
	local c = CreateFrame( "Frame", name.."Container", b );
	c:SetPoint( "BOTTOMLEFT", pad, pad );
	c:SetPoint( "TOPRIGHT", -pad,-pad );
	f.container = c;
	
	--Functions
	f.SetLabelText = ChronoBars.GroupFrame_SetLabelText;
	
	return f;
	--]]
	
	--Frame
	local f = CreateFrame( "Frame", name, nil );
	f:SetHeight( 100 );
	
	--Header
	local h = f:CreateTexture( nil, "ARTWORK" );
	h:SetTexture( "Interface\\AddOns\\ChronoBars\\Textures\\Header.tga" );
	h:SetPoint( "TOPLEFT", 0,0 );
	h:SetPoint( "TOPRIGHT", 0,0 );
	h:SetHeight( 25 );
	
	--Label
	local l = f:CreateFontString( name.."Label", "OVERLAY", "GameFontNormal" );
	l:SetFont( "Fonts\\FRIZQT__.TTF", 12 );
	l:SetAllPoints( h );
	l:SetText( "Group" );
	f.label = l;
	
	--Container
	local c = CreateFrame( "Frame", name.."Container", f );
	c:SetPoint( "LEFT",   f, "LEFT",   0,  0 );
	c:SetPoint( "RIGHT",  f, "RIGHT",  0,  0 );
	c:SetPoint( "TOP",    h, "BOTTOM", 0, -10 );
	c:SetPoint( "BOTTOM", f, "BOTTOM", 0,  0 );
	c.frame = f;
	f.container = c;
	
	--Functions
	ChronoBars.Container_New( f );
	
	f.SetLabelText   = ChronoBars.GroupFrame_SetLabelText;
	f.SizeToContent  = ChronoBars.GroupFrame_SizeToContent;
	
	return f;
end

function ChronoBars.GroupFrame_SetLabelText( frame, text )
	frame.label:SetText( text );
end

function ChronoBars.GroupFrame_SizeToContent( frame )
	frame:SetHeight( 25 + 10 + frame:GetContentHeight() );
end


--Tab
--=====================================================================

function ChronoBars.Tab_New( name )

	local t = CreateFrame("Button", name, nil, "OptionsFrameTabButtonTemplate");
	
	t.text = _G[name .. "Text"];
	
	t.Resize = ChronoBars.Tab_Resize;
	t.GetTextWidth = ChronoBars.Tab_GetTextWidth;
	t.SetSelected = ChronoBars.Tab_SetSelected;
	t.GetSelected = ChronoBars.Tab_GetSelected;
	
	t:SetText( "Tab" );
	t:SetSelected( false );
	
	ChronoBars.Object_New( t );
	return t;

end

function ChronoBars.Tab_Resize( tab, width )
	PanelTemplates_TabResize( tab, nil, width );
end

function ChronoBars.Tab_GetTextWidth( tab, selected )
	return tab.text:GetStringWidth()
end

function ChronoBars.Tab_SetSelected( tab, selected )

	tab.selected = selected;
	
	if (tab.selected)
	then PanelTemplates_SelectTab( tab );
	else PanelTemplates_DeselectTab( tab );
	end
	
end

function ChronoBars.Tab_GetSelected( tab )
	return tab.selected;
end


--Tab Frame
--=====================================================================

function ChronoBars.TabFrame_New( name )

	--Frame
	local f = CreateFrame( "Frame", name, nil );
	f:SetWidth( 200 );
	f:SetHeight( 150 );
	
	--Border
	local b = CreateFrame( "Frame", name.."Border", f );
	
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
	c:SetPoint( "LEFT",   pad, 0 );
	c:SetPoint( "RIGHT", -pad, 0 );
	c:SetPoint( "TOP",    0, -pad );
	c:SetPoint( "BOTTOM", 0,  pad );
	c.frame = f;
	f.container = c;
	
	--Private vars
	f.tabframeWidth = 0;
	f.tabframeHeight = 0;
	f.tabs = {};
	f.titles = {};
	f.widths = {};
	f.starts = {};
	f.counts = {};
	f.border = b;
	f.selected = 0;
	
	--Functions
	ChronoBars.Container_New( f );
	
	f.Init              = ChronoBars.TabFrame_Init;
	f.Free              = ChronoBars.TabFrame_Free;
	f.AddTab            = ChronoBars.TabFrame_AddTab;
	f.SelectTab         = ChronoBars.TabFrame_SelectTab;
	f.GetSelectedIndex  = ChronoBars.TabFrame_GetSelectedIndex;
	f.UpdateTabs        = ChronoBars.TabFrame_UpdateTabs;
	f.SizeToContent     = ChronoBars.TabFrame_SizeToContent;
	
	return f;
end

function ChronoBars.TabFrame_Init( frame )

	--Init container
	ChronoBars.Container_Init( frame );
	
	--Reset cached size
	frame.tabframeWidth = nil;
	frame.tabframeHeight = nil;
	
	--Scripts
	frame:RegisterScript( "OnSizeChanged", ChronoBars.TabFrame_OnSizeChanged );
	
end

function ChronoBars.TabFrame_Free( frame )
		
	--Free every tab
	for i,tab in ipairs( frame.tabs ) do
		CB.FreeObject( frame.tabs[i] );
	end
	
	--Clear tabs
	CB.Util_ClearTable( frame.tabs );
	
	--Free container
	ChronoBars.Container_Free( frame );
	
end

function ChronoBars.TabFrame_AddTab( frame, title )

	local numTabs = table.getn( frame.tabs );

	--Create new tab
	local tab = CB.NewObject( "tab" );
	tab:SetParent( frame );
	tab:SetText( title );
	tab:SetPoint( "BOTTOMLEFT", frame, "TOPLEFT", 0, 0 );
	tab:SetScript( "OnClick", ChronoBars.TabFrameTab_OnClick );
	tab.index = numTabs + 1;
	tab.frame = frame;
	
	--Add to list
	table.insert( frame.tabs, tab );
	table.insert( frame.titles, title );
	
	--Select if first
	if (numTabs == 1) then
		frame:SelectTab( 1 );
	end
	
	return tab;
end

function ChronoBars.TabFrame_SelectTab( frame, index )

	--Deselect other tabs
	for i=1,table.getn(frame.tabs) do
		frame.tabs[i]:SetSelected( false );
	end
	
	--Select this tab
	frame.tabs[index]:SetSelected( true );
	frame.selected = index;
end


function ChronoBars.TabFrame_GetSelectedIndex( frame )
	return frame.selected;
end


function ChronoBars.TabFrame_UpdateTabs( frame )
	
	CB.Print( "UPDATE TABS" );
	
	--Bail if OnSizeChanged hasn't happened yet
	if (frame.tabframeWidth == nil) then
		return;
	end
	
	CB.Print( "width: "..tostring(frame.tabframeWidth) );
	
	CB.Util_ClearTable( frame.widths );
	CB.Util_ClearTable( frame.starts );
	CB.Util_ClearTable( frame.counts );
	
	table.insert( frame.widths, 0 );
	table.insert( frame.starts, 1 );
	table.insert( frame.counts, 0 );
	
	--Get total width of each row
	local row = 1;
	local numTabs = table.getn( frame.tabs );
	for t=1,numTabs do
	
		--Set text and measure tab width
		local tab = frame.tabs[t];
		tab:SetText( frame.titles[t] );
		local tabW = tab:GetTextWidth() + 40;
		
		--Go to next row, if limit reached
		if (frame.widths[ row ] + tabW > frame.tabframeWidth and t > 1) then
			table.insert( frame.widths, 0 );
			table.insert( frame.starts, t );
			table.insert( frame.counts, 0 );
			row = row + 1;
		end
		
		--Add to row width
		frame.widths[ row ] = frame.widths[ row ] + tabW;
		frame.counts[ row ] = frame.counts[ row ] + 1;
	end

	--Walk every row
	local y = -5;
	local numRows = table.getn( frame.widths );
	for r = 1, numRows do
	
		--Find extra width to be added to every tab
		local extraW = (frame.tabframeWidth - frame.widths[r]) / frame.counts[r];
		local totalW = 0;
		
		--Walk every tab in this row
		local firstTab = frame.starts[r];
		local lastTab  = frame.starts[r] + frame.counts[r] - 1;
		for t = firstTab, lastTab  do
			
			--Add extra width to tab
			local tab = frame.tabs[t];
			local tabW = tab.text:GetStringWidth() + 40;
			if (extraW > 0) then tabW = tabW + extraW; end
			
			--Resize and position the tab
			tab:Resize( tabW );
			tab:SetPoint( "BOTTOMLEFT", frame, "TOPLEFT", totalW, y - 20 );
			totalW = totalW + tabW;
		end
		
		y = y - 20;
	end
	
	--Reposition top of border
	frame.border:SetPoint( "TOPLEFT", 0, y );
	
	--This will resize bottom properly for the number of rows
	frame:SizeToContent();
end

function ChronoBars.TabFrame_SizeToContent( frame )

	local numRows = table.getn( frame.widths );	
	frame:SetHeight( numRows * 20 + frame:GetContentHeight() + 40 );
end

function ChronoBars.TabFrameTab_OnClick( tab )
	
	--Select clicked tab
	tab.frame:SelectTab( tab.index );
	
	--Execute script if registered
	local script = tab.frame.OnTabChanged;
	if (script) then script( tab.frame ); end
end

function ChronoBars.TabFrame_OnSizeChanged( frame, width, height )

	--Cache size so we don't have to call GetWidth() which
	--for some stupid reason triggers OnSizeChanged again
	--CB.Print( "TABFRAME SIZE CHANGED" );
	
	local oldWidth = frame.tabframeWidth;
	local oldHeight = frame.tabframeHeight;
	
	frame.tabframeWidth = width;
	frame.tabframeHeight = height;
	
	if (width ~= oldWidth) then
		frame:UpdateTabs();
	end
	
end

--Scroll frame
--=====================================================================

function ChronoBars.ScrollFrame_New( name )

	--Frame
	local f = CreateFrame( "ScrollFrame", name, nil, "MinimalScrollFrameTemplate" );
	f.bar = _G[name.."ScrollBar"];
	f.track = _G[name.."ScrollBarTrack"];
	
	f.track:SetTexture( 0.0, 0.0, 0.0, 0.5 );
	
	ChronoBars.Object_New( f );
	return f;
	
end


--Window frame
--=====================================================================

function ChronoBars.Frame_New( name, title, resizable )
	
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
		sizer.frame = f;
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
	
	--Scroll frame
	local pad = 20;
	local s = ChronoBars.ScrollFrame_New( name.."Scroll" );
	s:SetParent( f );
	s:SetPoint( "BOTTOMLEFT", pad, pad + 5 );
	s:SetPoint( "TOPRIGHT", -pad -15, -pad -15 );
	s:RegisterScript( "OnSizeChanged", ChronoBars.Frame_OnScrollSizeChanged );
	s.frame = f;
	
	--Container
	local c = CreateFrame( "Frame", name.."Container", f );
	s:SetScrollChild( c );
	c:SetPoint( "TOPLEFT", 0,0 );
	c:SetWidth( 100 );
	c:SetHeight( 100 );
	c.frame = f;
	f.container = c;
	
	--Functions
	ChronoBars.Container_New( f );
	f.SizeToContent  = ChronoBars.Frame_SizeToContent;
	return f;
end

function ChronoBars.Frame_SizeToContent( frame )
	CB.Print( "SIZE "..tostring( frame:GetContentHeight() ));
	frame.container:SetHeight( frame:GetContentHeight() + 1 );
end

function ChronoBars.Frame_OnScrollSizeChanged( scroll, width, height )
	local frame = scroll.frame;
	frame.container:SetWidth( width );
end

function ChronoBars.Frame_OnDragStart( frame )
	frame:StartMoving();
end

function ChronoBars.Frame_OnDragStop( frame )
	frame:StopMovingOrSizing();
end

function ChronoBars.FrameSizer_OnMouseDown( sizer )
	sizer.frame:StartSizing();
end

function ChronoBars.FrameSizer_OnMouseUp( sizer )
	sizer.frame:StopMovingOrSizing();
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
	local factory = CB.factory[ class ];
	local capacity = table.getn( factory.objects );

	--Check if there's any unused objects left
	if (factory.used < capacity) then

		--Return existing object
		factory.used = factory.used + 1;
		object = factory.objects[ factory.used ];

	else

		--Create new object if capacity exhausted
		factory.used = capacity + 1;

		if     (class == "input")      then object = CB.Input_New       ( "ChronoBars.Input"      .. factory.used );
		elseif (class == "checkbox")   then object = CB.Checkbox_New    ( "ChronoBars.Checkbox"   .. factory.used );
		elseif (class == "dropdown")   then object = CB.Drop_New        ( "ChronoBars.Dropdown"   .. factory.used );
		elseif (class == "color")      then object = CB.ColorSwatch_New ( "ChronoBars.Color"      .. factory.used );
		elseif (class == "header")     then object = CB.Header_New      ( "ChronoBars.Header"     .. factory.used );
		elseif (class == "groupframe") then object = CB.GroupFrame_New  ( "ChronoBars.GroupFrame" .. factory.used );
		elseif (class == "tab")        then object = CB.Tab_New         ( "ChronoBars.Tab"        .. factory.used );
		elseif (class == "tabframe")   then object = CB.TabFrame_New    ( "ChronoBars.TabFrame"   .. factory.used );
		elseif (class == "font")       then object = CB.FontDrop_New    ( "ChronoBars.FontDrop"   .. factory.used );
		elseif (class == "texture")    then object = CB.TexDrop_New     ( "ChronoBars.TexDrop"    .. factory.used );
		end

		--Add to list of objects
		object.factoryClass = class;
		object.factoryId = factory.used;
		table.insert( factory.objects, object );

	end

	--Init object
	object.factoryUsed = true;
	object:Show();
	
	--Notify object it's been inited
	if (object.Init) then
		object:Init();
	end
	
	return object;
end


function ChronoBars.FreeObject( object )

	--Object must be used
	if (object.factoryUsed == false) then
		return
	end
	
	--Swap freed object with last used object and their ids
	local factory = CB.factory[ object.factoryClass ];
	
	if (object.factoryId < factory.used) then

		local objectId = object.factoryId;
		local lastId = factory.used;
		local last = factory.objects[ lastId ];

		factory.objects[ objectId ] = last;
		factory.objects[ lastId ] = object; 

		object.factoryId = lastId;
		last.factoryId = objectId;
	end

	factory.used = factory.used - 1;
	
	--Reset object
	object.factoryUsed = false;
	object:Hide();
	object:ClearAllPoints();
	object:SetParent( nil );
	
	--Notify object it's been freed
	if (object.Free) then
		object:Free();
	end
end


function ChronoBars.FreeAllObjects()

	--Factory must exist
	if (CB.factory == nil) then
		return
	end
	
	--Walk every factory
	for class,factory in pairs(CB.factory) do

		--Walk every object in factory
		for id,object in ipairs(factory.objects) do
		
			--Reset object
			object.factoryUsed = false;
			object:Hide();
			object:ClearAllPoints();
			object:SetParent( nil );
		end
		
		--Walk every object in factory
		for id,object in ipairs(factory.objects) do
		
			--Notify object it's been freed
			if (object.Free) then
				object:Free()
			end
		end
		
		factory.used = 0;
	end
end

--Object
--=============================================================

function ChronoBars.Object_New( o )

	o.Init                  = ChronoBars.Object_Init;
	o.Free                  = ChronoBars.Object_Free;
	o.RegisterScript        = ChronoBars.Object_RegisterScript;
	o.UnregisterScript      = ChronoBars.Object_UnregisterScript;
	o.UnregisterAllScripts  = ChronoBars.Object_UnregisterAllScripts;
	o.InvokeScript          = ChronoBars.Object_InvokeScript;
	
	return o;
end

function ChronoBars.Object_Init( o )
end

function ChronoBars.Object_Free( o )
end

function ChronoBars.Object_RegisterScript( object, script, func )

	--Create callback table if missing
	if (object.callbacks == nil) then
		object.callbacks = {};
	end
	
	if (object.callbacks[ script ] == nil) then
		object.callbacks[ script ] = {};
	end
	
	--Check if function already registered
	local callbacks = object.callbacks[ script ];
	for i,f in ipairs( callbacks ) do
		if (f == func) then
			return
		end
	end
	
	--Add to callback table
	table.insert( callbacks, func );
	
	--Check for missing script handler
	if (object:GetScript( script ) == nil) then
	
		--Closure passes script name to invoke function along with other arguments
		local scriptClosure = function( object, ... )
			ChronoBars.Object_InvokeScript( object, script, ... );
		end
		
		--Set closure as script handler
		object:SetScript( script, scriptClosure );
	end
end

function ChronoBars.Object_UnregisterScript( object, script, func )

	--Must have valid callback table
	if (object.callbacks == nil) then
		return;
	end
	
	if (object.callbacks[ script ] == nil) then
		return
	end
	
	--Search for registered function
	local callbacks = object.callbacks[ script ];
	for i,f in ipairs( callbacks ) do
		if (f == func) then
		
			--Remove from callback table
			table.remove( callbacks, i );
		end
	end
end

function ChronoBars.Object_UnregisterAllScripts( object )

	--Must have valid callback table
	if (object.callbacks == nil) then
		return;
	end
		
	--Remove all callbacks from every callback tables
	for script,callbacks in pairs(object.callbacks) do
		CB.Util_ClearTable( callbacks );
	end
end

function ChronoBars.Object_InvokeScript( object, script, ... )
	
	--Must have valid callback table
	if (object.callbacks == nil) then
		return;
	end
	
	--Invoke all the callback functions
	local callbacks = object.callbacks[ script ];
	for i,func in ipairs( callbacks ) do
		func( object, ... );
	end
end
