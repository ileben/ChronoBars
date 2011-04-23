--[[

====================================================
ChronoBars - buff, debuff, cooldown, totem tracker
Author: Ivan Leben
====================================================

--]]

local CB = ChronoBars;



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

function ChronoBars.TabFrameTab_OnClick( tab )
	
	--Select clicked tab
	tab.frame:SelectTab( tab.index );
	
	--Execute script if registered
	local script = tab.frame.OnTabChanged;
	if (script) then script( tab.frame ); end
end
