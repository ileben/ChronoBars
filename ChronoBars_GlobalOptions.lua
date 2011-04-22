--[[

====================================================
ChronoBars - buff, debuff, cooldown, totem tracker
Author: Ivan Leben
====================================================

--]]

local CB = ChronoBars;

--Test structure
--===============================================================================

--[[
ChronoBars.Frame_Root =
{
	{ type="tabs", tabs="root|Tabs_Test" },
};

--]]
ChronoBars.Tabs_Test =
{
	{ text="Test1",   frame="root|Frame_Test" },
	{ text="Test2" },
};

ChronoBars.Frame_Test =
{
	{ type="input",   text="Some input:",   var="bar|name" },
	{ type="options",  text="Some options:",  var="bar|type",   options="root|Options_EffectType" },
	{ type="font",     text="Font",   var="bar|style.lsmFontHandle" },
};

--Config structure
--===========================================================================


ChronoBars.Frame_Root = 
{
	{ type="tabs",     tabs="root|Tabs_Root" },
};
--[[
--]]
ChronoBars.Tabs_Root =
{
	{ text="Bar",      frame="root|Frame_Bar" },
	{ text="Group",    frame="root|Frame_Group" },
	{ text="Profile",  frame="root|Frame_Profile" },
};

--Bar

ChronoBars.Frame_Bar =
{
	{ type="header",   text="bar|name" },
	{ type="toggle",   text="Enabled",          var="bar|enabled" },
	{ type="tabs",     tabs="root|Tabs_Bar" },
};

ChronoBars.Tabs_Bar =
{
	{ text="Effect",      frame="root|Frame_Effect" },
	{ text="Appearance",  frame="root|Frame_Appearance" },
	{ text="Copy",        frame="root|Frame_Copy" },
	{ text="Paste",       frame="root|Frame_Paste" },
};

ChronoBars.Frame_Effect =
{
	{ type="input",       text="Effect name",     var="bar|name" },
	{ type="options",     text="Effect type",     var="bar|type",   options="root|Options_EffectType" },
	
	{ type="group",       text="Aura Settings",           frame="root|Frame_AuraSettings",
	  conditionVar="bar|type", conditionValue = ChronoBars.EFFECT_TYPE_AURA },
	  
	{ type="group",       text="Multi-Aura Settings",     frame="root|Frame_MultiAuraSettings",
	  conditionVar="bar|type", conditionValue = ChronoBars.EFFECT_TYPE_MULTI_AURA },
	  
	{ type="group",       text="Cooldown settings", frame="root|Frame_CooldownSettings",
	  conditionVar="bar|type", conditionValue = ChronoBars.EFFECT_TYPE_CD },

	{ type="group",       text="Usable settings",   frame="root|Frame_UsableSettings",
	conditionVar="bar|type", conditionValue = ChronoBars.EFFECT_TYPE_USABLE },

	{ type="group",       text="Totem settings",    frame="root|Frame_TotemSettings",
	  conditionVar="bar|type", conditionValue = ChronoBars.EFFECT_TYPE_TOTEM },

	{ type="group",       text="Custom settings",   frame="root|Frame_CustomSettings",
	  conditionVar="bar|type", conditionValue = ChronoBars.EFFECT_TYPE_CUSTOM },

	{ type="group",       text="Auto-Attack settings", frame="root|Frame_AutoSettings",
	  conditionVar="bar|type", conditionValue = ChronoBars.EFFECT_TYPE_AUTO },

	{ type="group",       text="Enchant settings",     frame="root|Frame_EnchantSettings",
	  conditionVar="bar|type", conditionValue = ChronoBars.EFFECT_TYPE_ENCHANT },
};

ChronoBars.Options_EffectType =
{
  { text="Aura",               value = ChronoBars.EFFECT_TYPE_AURA },
  { text="Multi Aura",         value = ChronoBars.EFFECT_TYPE_MULTI_AURA },
  { text="Cooldown",           value = ChronoBars.EFFECT_TYPE_CD },
  { text="Usable",             value = ChronoBars.EFFECT_TYPE_USABLE },
  { text="Totem",              value = ChronoBars.EFFECT_TYPE_TOTEM },
  { text="Custom",             value = ChronoBars.EFFECT_TYPE_CUSTOM },
  { text="Auto-Attack",        value = ChronoBars.EFFECT_TYPE_AUTO },
  { text="Weapon Enchant",     value = ChronoBars.EFFECT_TYPE_ENCHANT },
};

ChronoBars.Frame_AuraSettings =
{
	{ type="options",   text="Aura type",                   var="bar|aura.type",   options="root|Options_AuraType" },
	{ type="options",   text="Unit to monitor",             var="bar|aura.unit",   options="root|Options_AuraUnit" },
	{ type="options",   text="Which when multiple",         var="bar|aura.order",  options="root|Options_AuraOrder" },
	{ type="toggle",    text="Only if cast by self",        var="bar|aura.byPlayer" },
	{ type="toggle",    text="Sum stack from all casters",  var="bar|aura.sum" },
};

ChronoBars.Options_AuraType =
{
  { text="Buff",   value = ChronoBars.AURA_TYPE_BUFF },
  { text="Debuff", value = ChronoBars.AURA_TYPE_DEBUFF },
};

ChronoBars.Options_AuraUnit =
{
  { text="Player",             value = ChronoBars.AURA_UNIT_PLAYER },
  { text="Target",             value = ChronoBars.AURA_UNIT_TARGET },
  { text="Focus",              value = ChronoBars.AURA_UNIT_FOCUS },
  { text="Pet",                value = ChronoBars.AURA_UNIT_PET },
  { text="Target of target",   value = ChronoBars.AURA_UNIT_TARGET_TARGET },
  { text="Target of focus",    value = ChronoBars.AURA_UNIT_FOCUS_TARGET },
  { text="Target of pet",      value = ChronoBars.AURA_UNIT_PET_TARGET },
};

ChronoBars.Options_AuraOrder =
{
  { text="First",    value = 1 },
  { text="Second",   value = 2 },
  { text="Third",    value = 3 },
  { text="Fourth",   value = 4 },
  { text="Fifth",    value = 5 },
};

ChronoBars.Frame_MultiAuraSettings =
{
	{ type="options",   text="Aura type",                     var="bar|aura.type",       options="root|Options_AuraType" },
	{ type="numinput",  text="Estimate duration (seconds)",   var="bar|custom.duration" },
	{ type="toggle",    text="Only if cast by self",          var="bar|aura.byPlayer" },
};


ChronoBars.Frame_CooldownSettings =
{
	{ type="options",   text="Cooldown type",    var="bar|cd.type",    options="root|Options_CooldownType" },
};

ChronoBars.Options_CooldownType =
{
  { text="Spell",       value = ChronoBars.CD_TYPE_SPELL },
  --{ text="Pet Spell",   value = ChronoBars.CD_TYPE_PET_SPELL },
  { text="Item",        value = ChronoBars.CD_TYPE_ITEM },
};

ChronoBars.Frame_UsableSettings =
{
};

ChronoBars.Frame_TotemSettings =
{
};

ChronoBars.Frame_CustomSettings =
{
};

ChronoBars.Frame_AutoSettings =
{
};

ChronoBars.Frame_EnchantSettings =
{
};

ChronoBars.Frame_Appearance =
{  
	{ type="header",  text="Appearance" },
	{ type="tabs",    tabs="root|Tabs_Appearance" },
	
	--[[
	{ type="group",  text="Bar",        frame="root|Frame_StyleBar" },
	{ type="group",  text="Icon",       frame="root|Frame_StyleIcon" },
	{ type="group",  text="Spark",      frame="root|Frame_StyleSpark" },
	{ type="group",  text="Text",       frame="root|Frame_StyleText" },
	{ type="group",  text="Animation",  frame="root|Frame_StyleAnimation" },
	{ type="group",  text="Visibility", frame="root|Frame_StyleVisibility" },
	--]]
};

ChronoBars.Tabs_Appearance =
{
	{ text="Bar",        frame="root|Frame_StyleBar" },
	{ text="Icon",       frame="root|Frame_StyleIcon" },
	{ text="Spark",      frame="root|Frame_StyleSpark" },
	{ text="Text",       frame="root|Frame_StyleText" },
	{ text="Animation",  frame="root|Frame_StyleAnimation" },
	{ text="Visibility", frame="root|Frame_StyleVisibility" },
};

ChronoBars.Frame_StyleBar =
{	
	{ type="options",    text="Direction",     var="bar|style.fullSide",   options="root|Options_FullSide" },
	{ type="toggle",     text="Fill up",       var="bar|style.fillUp" },
	{ type="texture",    text="Texture",       var="bar|style.lsmTexHandle" },
	{ type="color",      text="Front Color",   var="bar|style.fgColor" },
	{ type="color",      text="Back Color",    var="bar|style.bgColor" },
};

ChronoBars.Options_FullSide =
{
	{ text="Empty || Full",  value = ChronoBars.SIDE_RIGHT },
	{ text="Full || Empty",  value = ChronoBars.SIDE_LEFT },
};

ChronoBars.Options_Texture =
{
};

ChronoBars.Frame_StyleIcon =
{
	{ type="toggle",   text="Enabled",   var="bar|style.showIcon" },
	{ type="options",  text="Position",  var="bar|style.iconSide",  options="root|Options_IconPosition" },
	{ type="numinput", text="Offset X",  },
	{ type="numinput", text="Offset Y",  },
	{ type="toggle",   text="Zoom",      var="bar|style.iconZoom" },
};

ChronoBars.Options_IconPosition =
{
	{ text="Left",    value = ChronoBars.SIDE_LEFT },
	{ text="Right",   value = ChronoBars.SIDE_RIGHT },
};

ChronoBars.Frame_StyleSpark =
{
	{ type="toggle",   text="Enabled",  var="bar|style.showSpark" },
	{ type="numinput", text="Height",   var="bar|style.sparkHeight"  },
	{ type="numinput", text="Width",    var="bar|style.sparkWidth" },
};

ChronoBars.Frame_StyleText =
{
	{ type="options",  text="Text",     var="temp|textIndex",  options="func|Options_Text" },
	
	{ type="header",   text="bar|style.text[temp|textIndex].name" },
	
	{ type="toggle",   text="Enabled",    var="bar|style.text[temp|textIndex].enabled" },
	{ type="input",    text="Name",       var="bar|style.text[temp|textIndex].name" },
	{ type="input",    text="Format",     var="bar|style.text[temp|textIndex].format" },
	
	{ type="options",  text="Position",   var="bar|style.text[temp|textIndex].position",   options="root|Options_Position" },
	{ type="numinput", text="Offset X",   var="bar|style.text[temp|textIndex].x" },
	{ type="numinput", text="Offset Y",   var="bar|style.text[temp|textIndex].y" },
	
	{ type="font",     text="Font",       var="bar|style.text[temp|textIndex].font" },
	{ type="numinput", text="Font size",  var="bar|style.text[temp|textIndex].size" },
	
	{ type="color",    text="Text color",    var="bar|style.text[temp|textIndex].textColor" },
	{ type="color",    text="Outline color", var="bar|style.text[temp|textIndex].outColor" },
	{ type="toggle",   text="Outline",       var="bar|style.text[temp|textIndex].outline" },
};

ChronoBars.Options_Position =
{
	{ text="Inside Left",     value=CB.POS_IN_LEFT },
	{ text="Inside Center",   value=CB.POS_IN_CENTER },
	{ text="Inside Right",    value=CB.POS_IN_RIGHT },
	
	--{ type="separator" },
	{ text="Outside Left",    value=CB.POS_OUT_LEFT },
	{ text="Outside Right",   value=CB.POS_OUT_RIGHT },
	
	--{ type="separator" },
	{ text="Above Left",      value=CB.POS_ABOVE_LEFT },
	{ text="Above Center",    value=CB.POS_ABOVE_CENTER },
	{ text="Above Right",     value=CB.POS_ABOVE_RIGHT },
	
	--{ type="separator" },
	{ text="Below Left",      value=CB.POS_BELOW_LEFT },
	{ text="Below Center",    value=CB.POS_BELOW_CENTER },
	{ text="Below Right",     value=CB.POS_BELOW_RIGHT },
};

ChronoBars.Frame_StyleAnimation =
{
	{ type="toggle",  text="Slide up when activated",             var="bar|style.anim.up" },
	{ type="toggle",  text="Slide down when consumed",            var="bar|style.anim.down" },
	{ type="toggle",  text="Blink slowly when running out",       var="bar|style.anim.blinkSlow" },
	{ type="toggle",  text="Blink quickly when almost expired",   var="bar|style.anim.blinkFast" },
	{ type="toggle",  text="Blink when usable",                   var="bar|style.anim.blinkUsable" },
	{ type="toggle",  text="Fade out when expired",               var="bar|style.anim.fade" },
};

ChronoBars.Frame_StyleVisibility =
{
	{ type="options",   text="Show bar",            var="bar|style.visibility",   options="root|Options_Visibility" },
	{ type="toggle",    text="Hide out of combat" },
};

ChronoBars.Options_Visibility =
{
	{ text="Always visible",    value = ChronoBars.VISIBLE_ALWAYS },
	{ text="When active",       value = ChronoBars.VISIBLE_ACTIVE },
};

ChronoBars.Frame_Copy =
{
};

ChronoBars.Frame_Past =
{
};

--Group

ChronoBars.Frame_Group =
{
};

--Profile

ChronoBars.Frame_Profile =
{
};

function ChronoBars.Options_Text_Get()

	local options = {};
	
	local profile = CB.GetActiveProfile();
	local bar = profile.groups[ CB.MenuId.groupId ].bars[ CB.MenuId.barId ];
	
	local numText = table.getn( bar.style.text );
	for i=1,numText do
	
		local text = bar.style.text[i];
		table.insert( options, { text = text.name, value = i } );
	end
	
	CB.Print( "Settings TEXT INDEX" );
	CB.SetSettingsValue( "temp|textIndex", 1 );
	
	return options;
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

function ChronoBars.Config_Construct( parentFrame, config )

	local prevFrame = nil;
	local totalHeight = 0;
	
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
			
			--Select tab by index from environment variable
			local s = CB.GetEnv( item.tabs.."Selection" ) or 1;
			tabFrame:SelectTab(s);
			
			--Get frame config
			local frameConfig = CB.GetSettingsValue( tabConfig[s].frame );
			if (frameConfig ~= nil) then
			
				--Construct sub frame
				CB.Config_Construct( tabFrame, frameConfig );
			end
			
		elseif (item.type == "group") then
		
			--Create group frame object
			local grpFrame = CB.NewObject( "groupframe" );
			grpFrame:SetLabelText( item.text );
			frame = grpFrame;
			
			--Get frame config
			local frameConfig = CB.GetSettingsValue( item.frame );
			if (frameConfig ~= nil) then
			
				--Construct sub frame
				CB.Config_Construct( grpFrame, frameConfig );
			end
			
		elseif (item.type == "header") then
		
			--Create header frame object
			local hdrFrame = CB.NewObject( "header" );
			hdrFrame:SetText( CB.GetSettingsValue( item.text ));
			frame = hdrFrame;
			
		elseif (item.type == "options") then
			
			--Create dropdown object
			local ddFrame = CB.NewObject( "dropdown" );
			ddFrame:SetLabelText( item.text );
			ddFrame.OnValueChanged = ChronoBars.Config_OnOptionChanged;
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
			
			
		elseif (item.type == "toggle") then
		
			--Create checkbox object
			local cbFrame = CB.NewObject( "checkbox" );
			cbFrame:SetText( item.text );
			cbFrame.OnValueChanged = ChronoBars.Config_OnToggleChanged;
			cbFrame.item = item;
			frame = cbFrame;
			
			--Get value and apply to object
			local curValue = ChronoBars.GetSettingsValue( item.var );
			cbFrame:SetChecked( curValue );
			
		elseif (item.type == "input" or item.type == "numinput") then
		
			--Create input object
			local inpFrame = CB.NewObject( "input" );
			inpFrame:SetLabelText( item.text );
			inpFrame.OnValueChanged = ChronoBars.Config_OnInputChanged;
			inpFrame.item = item;
			frame = inpFrame;
			
			--Get value and apply to object
			local curValue = ChronoBars.GetSettingsValue( item.var );
			inpFrame:SetText( tostring(curValue) );
			
		elseif (item.type == "color") then
		
			--Create color swatch object
			local colFrame = CB.NewObject( "color" );
			colFrame:SetText( item.text );
			colFrame.item = item;
			frame = colFrame;
			
			--Get value and apply to object
			local c = ChronoBars.GetSettingsValue( item.var );
			colFrame:SetColor( c.r, c.g, c.b, c.a );
			
		elseif (item.type == "font" or item.type == "texture") then
		
			--Create font object
			local fontFrame = CB.NewObject( item.type );
			fontFrame:SetLabelText( item.text );
			fontFrame.item = item;
			frame = fontFrame;
			
			--Get value and apply to object
			local curValue = ChronoBars.GetSettingsValue( item.var );
			fontFrame:SelectValue( curValue );
			
		end
		--[[
		--Position item below previous one
		if (prevFrame == nil) then
			frame:SetPoint( "TOPLEFT", parentFrame.container, "TOPLEFT", 0,0 );
			totalHeight = totalHeight + frame:GetHeight();
		else
			frame:SetPoint( "TOPLEFT", prevFrame, "BOTTOMLEFT", 0,-10 );
			totalHeight = totalHeight + 10 + frame:GetHeight();
		end
		
		--Resize item to container
		frame:SetPoint( "RIGHT", parentFrame.container, "RIGHT", 0,0 );
		
		--Add to container
		frame:SetParent( parentFrame.container );
		--]]
		--Add to container
		parentFrame:AddChild( frame );
		
		prevFrame = frame;
		
	until true
	end
	
	
	--Size container to contents
	--parentFrame.container:SetHeight( totalHeight + 20 );
	--parentFrame.container:SetHeight( totalHeight + 20 );
	--parentFrame.container:SetPoint( "BOTTOM", prevFrame, "BOTTOM" );
end

function ChronoBars.Config_OnTabChanged( tabFrame )
	
	CB.Print( "TAB CHANGED" );
	
	local item = tabFrame.item;
	CB.SetEnv( item.tabs.."Selection", tabFrame:GetSelectedIndex() );
	CB.UpdateBarConfig();
	
end

function ChronoBars.Config_OnOptionChanged( ddFrame )

	CB.Print( "OPTION CHANGED" );
	
	local item = ddFrame.item;
	local newValue = ddFrame:GetSelectedValue();
	
end

function ChronoBars.Config_OnToggleChanged( cbFrame )

	CB.Print( "TOGGLE CHANGED" );
	
	local item = cbFrame.item;
	local newValue = cbFrame:GetChecked();
	
end

function ChronoBars.Config_OnInputChanged( inpFrame )

	CB.Print( "INPUT CHANGED" );
	
	local item = inpFrame.item;
	local newValue = inpFrame:GetText();
	
end


--Initialization
--===================================================

function ChronoBars.UpdateBarConfig()

	CB.FreeAllObjects();
	CB.configFrame:RemoveAllChildren();
	CB.Config_Construct( CB.configFrame, CB.Frame_Root );
end


function ChronoBars.OpenBarConfig (bar)
 
	CB.MenuId.groupId = bar.groupId;
	CB.MenuId.barId = bar.barId;

	if (not CB.configFrame) then
	
		CB.configFrame = CB.Frame_New( "ChronoBars.ConfigFrame", "ChronoBars", true);
		
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


