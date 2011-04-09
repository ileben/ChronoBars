--[[

====================================================
ChronoBars - buff, debuff, cooldown, totem tracker
Author: Ivan Leben
====================================================

--]]

local CB = ChronoBars;


--Config structure
--===========================================================================


ChronoBars.Frame_Root =
{
	{ type="tabs", tabs="root|Tabs_Root" },
};

ChronoBars.Tabs_Root =
{
	{ text="Hello",   frame="root|Frame_Test" },
	{ text="Kitty",   frame="root|Frame_Test2" },
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

ChronoBars.Frame_Test2 =
{
	{ type="input",      text="Some other input:" },
	{ type="options",    text="Some other options:",      options="root|Options_Test2" },
};

ChronoBars.Options_Test2 =
{
	{ text="Test1" },
	{ text="Test2" },
	{ text="Test3" },
};

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

function ChronoBars.Config_Construct( container, config )

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
			local tabFrame = CB.NewObject( "tabframe" );
			tabFrame:SetPoint( "BOTTOMRIGHT", container, "BOTTOMRIGHT" );
			tabFrame.OnTabChanged = ChronoBars.Config_OnTabChanged;
			tabFrame.item = item;
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
			local s = CB.GetEnv( item.tabs.."Selection" ) or 1;
			tabFrame:SelectTab(s);
			
			--Get frame config
			local frameConfig = CB.GetSettingsValue( nil, tabConfig[s].frame );
			if (frameConfig ~= nil) then
			
				--Construct sub frame
				CB.Config_Construct( tabFrame.container, frameConfig );
			end
			
			
		elseif (item.type == "options") then
			
			--Create dropdown object
			local ddFrame = CB.NewObject( "dropdown" );
			ddFrame:SetLabelText( item.text );
			ddFrame.OnOptionChanged = ChronoBars.Config_OnOptionChanged;
			frame = ddFrame;
			
			--Get options config
			local ddConfig = CB.GetSettingsValue( nil, item.options );
			if (ddConfig == nil) then
				CB.Print( "Missing options config table '"..tostring(item.options).."'" );
				break;
			end
			
			--Add items from config
			for d = 1, table.getn(ddConfig) do
				ddFrame:AddItem( ddConfig[d].text, item );
			end
			
		elseif (item.type == "toggle") then
		
			--Create checkbox object
			local cbFrame = CB.NewObject( "checkbox" );
			cbFrame:SetText( item.text );
			frame = cbFrame;
			
		elseif (item.type == "input") then
		
			--Create input object
			local inpFrame = CB.NewObject( "input" );
			inpFrame:SetLabelText( item.text );
			frame = inpFrame;
		end
		
		--Position item below previous one			
		if (prevFrame == nil)
		then frame:SetPoint( "TOPLEFT", container, "TOPLEFT", 0,0 );
		--else frame:SetPoint( "TOPLEFT", prevFrame, "BOTTOMLEFT", 0,0 );
		else frame:SetPoint( "TOPLEFT", prevFrame, "BOTTOMLEFT", 0,-10 );
		end
		
		--Resize item to container
		frame:SetPoint( "RIGHT", container, "RIGHT", 0,0 );
		
		--Add to container
		frame:SetParent( container );
		prevFrame = frame;
		
	until true
	end
end

function ChronoBars.Config_OnTabChanged( tabFrame )
	
	CB.Print( "TAB CHANGED" );
	
	local item = tabFrame.item;
	CB.SetEnv( item.tabs.."Selection", tabFrame:GetSelectedIndex() );
	CB.UpdateBarConfig();
	
end

function ChronoBars.Config_OnOptionChanged( ddFrame )

	CB.Print( "OPTION CHANGED" );
	
	local item = ddFrame:GetSelectedValue();
	
end


--Initialization
--===================================================

function ChronoBars.UpdateBarConfig()

	CB.FreeAllObjects();
	CB.Config_Construct( CB.configFrame.container, CB.Frame_Root );
end


function ChronoBars.OpenBarConfig (bar)
 
	CB.MenuId.groupId = bar.groupId;
	CB.MenuId.barId = bar.barId;

	if (not CB.configFrame) then
	
		CB.configFrame = CB.Frame_New( "ChronoBars.ConfigFrame", "Config", true);
		
	end
	
	CB.UpdateBarConfig();
	CB.configFrame:Show();
end


function ChronoBars.CloseBarConfig()

	if (CB.configFrame) then
		CB.configFrame:Hide();
	end
end


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


