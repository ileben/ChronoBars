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
	{ type="tabs",     tabs="root|Tabs_Root" },
};

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
	{ type="tabs",    tabs="root|Tabs_Appearance" },
};

ChronoBars.Tabs_Appearance =
{
	{ text="Bar",        frame="root|Frame_StyleBar" },
	{ text="Icon" },
	{ text="Text" },
	{ text="Animation" },
	{ text="Visibility" },
};

ChronoBars.Frame_StyleBar =
{	
	{ type="options",    text="Direction",     var="bar|style.fullSide",   options="root|Options_FullSide" },
	{ type="toggle",     text="Fill up",       var="bar|style.fillUp" },

	--{ type="separator" },
	
	{ type="options",    text="Texture",       var="bar|style.lsmTexHandle",  options="root|Options_Texture"	},
	{ type="toggle",     text="Front Color"  }, --, var="bar|style.fgColor" },
	{ type="toggle",     text="Back Color"  },  --, var="bar|style.bgColor" },
};

ChronoBars.Options_FullSide =
{
	{ text="Empty || Full",  value = ChronoBars.SIDE_RIGHT },
	{ text="Full || Empty",  value = ChronoBars.SIDE_LEFT },
};

ChronoBars.Options_Texture =
{
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

		local item = config[i];

		--Check for condition		
		if (item.conditionVar ~= nil) then
			local curValue = CB.GetSettingsValue( CB.MenuId, item.conditionVar );
			if (curValue ~= item.conditionValue) then
				break;
			end
		end
		
		--Construct item based on type
		local frame = nil;
		
		if (item.type == "tabs") then
		
			--Create tab frame object
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
			
		elseif (item.type == "group") then
		
			--Create group frame object
			local grpFrame = CB.NewObject( "groupframe" );
			--grpFrame:SetHeight( 100 );
			grpFrame:SetLabelText( item.text );
			frame = grpFrame;
			
			--Get frame config
			local frameConfig = CB.GetSettingsValue( nil, item.frame );
			if (frameConfig ~= nil) then
			
				--Construct sub frame
				CB.Config_Construct( grpFrame.container, frameConfig );
			end
			
		elseif (item.type == "header") then
		
			--Create header frame object
			local hdrFrame = CB.NewObject( "header" );
			hdrFrame:SetText( CB.GetSettingsValue( CB.MenuId, item.text ));
			frame = hdrFrame;
			
		elseif (item.type == "options") then
			
			--Create dropdown object
			local ddFrame = CB.NewObject( "dropdown" );
			ddFrame:SetLabelText( item.text );
			ddFrame.OnValueChanged = ChronoBars.Config_OnOptionChanged;
			ddFrame.item = item;
			frame = ddFrame;
			
			--Get options config
			local ddConfig = CB.GetSettingsValue( nil, item.options );
			if (ddConfig == nil) then
				CB.Print( "Missing options config table '"..tostring(item.options).."'" );
				break;
			end
			
			--Add items from config
			for d = 1, table.getn(ddConfig) do
				ddFrame:AddItem( ddConfig[d].text, ddConfig[d].value );
			end
			
			--Get value and apply to object
			local curValue = ChronoBars.GetSettingsValue( CB.MenuId, item.var );
			ddFrame:SelectValue( curValue );
			
			
		elseif (item.type == "toggle") then
		
			--Create checkbox object
			local cbFrame = CB.NewObject( "checkbox" );
			cbFrame:SetText( item.text );
			cbFrame.OnValueChanged = ChronoBars.Config_OnToggleChanged;
			cbFrame.item = item;
			frame = cbFrame;
			
			--Get value and apply to object
			local curValue = ChronoBars.GetSettingsValue( CB.MenuId, item.var );
			cbFrame:SetChecked( curValue );
			
		elseif (item.type == "input" or item.type == "numinput") then
		
			--Create input object
			local inpFrame = CB.NewObject( "input" );
			inpFrame:SetLabelText( item.text );
			inpFrame.OnValueChanged = ChronoBars.Config_OnInputChanged;
			inpFrame.item = item;
			frame = inpFrame;
			
			--Get value and apply to object
			local curValue = ChronoBars.GetSettingsValue( CB.MenuId, item.var );
			inpFrame:SetText( tostring(curValue) );
			
		end
		
		--Position item below previous one
		if (prevFrame == nil)
		then frame:SetPoint( "TOPLEFT", container, "TOPLEFT", 0,0 );
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
	CB.Config_Construct( CB.configFrame.container, CB.Frame_Root );
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


