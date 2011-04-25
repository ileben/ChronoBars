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
	{ type="header",   text="bar|name" },
	{ type="tabs",     tabs="root|Tabs_Root" },
};
--[[
--]]

ChronoBars.Tabs_Root =
{
	{ text="Manage",   frame="root|Frame_Manage" },
	{ text="Bar",      frame="root|Frame_Bar" },
	{ text="Group",    frame="root|Frame_Group" },
};

--Manage

ChronoBars.Frame_Manage =
{
	{ type="scroll" },
	
	{ type="header",   text="Bar management" },
	{ type="button",   text="New Bar",            func="root|Func_BarNew" },
	{ type="button",   text="Delete Bar",         func="root|Func_BarDelete" },
	
	{ type="header",   text="Group management" },
	{ type="button",   text="New Group",            func="root|Func_GroupNew" },
	{ type="button",   text="Delete Group",         func="root|Func_GroupDelete" },
	
	{ type="header",   text="Move bar" },
	{ type="button",   text="Move Up",            func="root|Func_BarMoveUp" },
	{ type="button",   text="Move Down",          func="root|Func_BarMoveDown" },

	{ type="header",   text="Bar settings" },	
	{ type="options",  text="Copy/Paste",         var="temp|copyIndex",     options="root|Options_BarCopyPaste" },
	{ type="button",   text="Copy",               func="root|Func_BarCopy" },
	{ type="button",   text="Paste",              func="root|Func_BarPaste" },
	{ type="button",   text="Paste to all",       func="root|Func_BarPasteToAll" },
	
	{ type="header",   text="Group settings" },
	{ type="button",   text="Copy",               func="root|Func_GroupCopy" },
	{ type="button",   text="Paste",              func="root|Func_GroupPaste" },
	{ type="button",   text="Paste to all",       func="root|Func_GroupPasteToAll" },
};

ChronoBars.Options_BarCopyPaste =
{
	{ text="Front Color",              value=1 },
	{ text="Back Color",               value=2 },
	{ text="Text Color",               value=3 },
	{ text="Texture",                  value=4 },
	{ text="Font",                     value=5 },
	{ text="Font Size",                value=6 },
	{ text="Visibility",               value=7 },
	{ text="Animation",                value=8 },
	{ text="Entire Style",             value=9 },
	{ text="Style Except Front Color", value=10 },
	{ text="All Bar Settings",         value=11 },
};

ChronoBars.BarCopyTable =
{
	--[[ 1  --]] { var="bar|style.fgColor",             temp="temp|color" },
	--[[ 2  --]] { var="bar|style.bgColor",             temp="temp|color" },
	--[[ 3  --]] { var="bar|style.textColor",           temp="temp|color" },
	--[[ 4  --]] { var="bar|style.lsmTexHandle",        temp="temp|tex" },
	--[[ 5  --]] { var="bar|style.lsmFontHandle",       temp="temp|font" },
	--[[ 6  --]] { var="bar|style.fontSize",            temp="temp|fontSize" },
	--[[ 7  --]] { var="bar|style.visibility",          temp="temp|visibility" },
	--[[ 8  --]] { var="bar|style.anim",                temp="temp|anim" },
	--[[ 9  --]] { var="bar|style",                     temp="temp|style" },
	--[[ 10 --]] { var="bar|style",                     temp="temp|style",    exception="bar|style.fgColor" },
	--[[ 11 --]] { var="group|bars[temp|barId]",        temp="temp|bar" },
};

--Bar

ChronoBars.Frame_Bar =
{
	{ type="header",   text="Bar Settings" },
	{ type="toggle",   text="Enabled",          var="bar|enabled" },
	{ type="tabs",     tabs="root|Tabs_Bar" },
};

ChronoBars.Tabs_Bar =
{
	{ text="Effect",     frame="root|Frame_Effect" },
	{ text="Bar",        frame="root|Frame_StyleBar" },
	{ text="Icon",       frame="root|Frame_StyleIcon" },
	{ text="Spark",      frame="root|Frame_StyleSpark" },
	{ text="Text",       frame="root|Frame_StyleText" },
	{ text="Animation",  frame="root|Frame_StyleAnimation" },
	{ text="Visibility", frame="root|Frame_StyleVisibility" },
};

ChronoBars.Frame_Effect =
{
	{ type="scroll" },
	{ type="header",      text="Effect" },
	
	{ type="input",       text="Effect name",     var="bar|name" },
	{ type="options",     text="Effect type",     var="bar|type",   options="root|Options_EffectType",  update=true },
	
	
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
	 
	
	{ type="header",      text="Override" },
	  
	{ type="input",       text="Display name",        var="bar|display.name" },
	{ type="toggle",      text="Use display name",    var="bar|display.enabled" },
	
	{ type="numinput",    text="Maximum time (seconds)",     var="bar|fixed.duration" },
	{ type="toggle",      text="Use maximum time",           var="bar|fixed.enabled" },
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
	{ type="options",     text="Usable type",        var="bar|usable.type",        options="root|Options_UsableType" },
	{ type="toggle",      text="Include cooldown",   var="bar|usable.includeCd" },
};

ChronoBars.Options_UsableType = {

	{ text="Spell",      value = ChronoBars.USABLE_TYPE_SPELL },
	--{ text="Pet Spell",   value = ChronoBars.USABLE_TYPE_PET_SPELL },
	{ text="Item",       value = ChronoBars.USABLE_TYPE_ITEM },
};


ChronoBars.Frame_TotemSettings =
{
	{ type="options",    text="Totem type",     var="bar|totem.type",    options="root|Options_TotemType" },
};

ChronoBars.Options_TotemType =
{
	{ text="Fire",   value=ChronoBars.TOTEM_TYPE_FIRE },
	{ text="Earth",  value=ChronoBars.TOTEM_TYPE_EARTH },
	{ text="Water",  value=ChronoBars.TOTEM_TYPE_WATER },
	{ text="Air",    value=ChronoBars.TOTEM_TYPE_AIR },
};

ChronoBars.Frame_CustomSettings =
{
	{ type="options",       text="Trigger",    var="bar|custom.trigger",    options="root|Options_CustomTrigger" },
	{ type="numinput",      text="Duration",   var="bar|custom.duration" },
};

ChronoBars.Options_CustomTrigger = {

	{ text="Spell cast successful",   value=ChronoBars.CUSTOM_TRIGGER_SPELL_CAST },
	{ text="Another bar activated",   value=ChronoBars.CUSTOM_TRIGGER_BAR_ACTIVE },
};

ChronoBars.Frame_AutoSettings =
{
	{ type="options",   text="Slot",     var="bar|auto.type",     options="root|Options_AutoType" },
};

ChronoBars.Options_AutoType =
{
  { text="Main Hand",  value=CB.AUTO_TYPE_MAIN_HAND },
  { text="Off Hand",   value=CB.AUTO_TYPE_OFF_HAND },
  { text="Wand",       value=CB.AUTO_TYPE_WAND },
  { text="Bow/Gun",    value=CB.AUTO_TYPE_BOW },
};

ChronoBars.Frame_EnchantSettings =
{
	{ type="options",    text="Slot",      var="bar|enchant.hand",     options="root|Options_EnchantHand" },
};

ChronoBars.Options_EnchantHand =
{
	{ text="Main Hand",  value=CB.HAND_MAIN },
	{ text="Off Hand",   value=CB.HAND_OFF },
};

ChronoBars.Frame_StyleBar =
{
	{ type="scroll" },
	{ type="header",     text="Bar" },
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

ChronoBars.Frame_StyleIcon =
{
	{ type="scroll" },
	{ type="header",   text="Icon" },
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
	{ type="scroll" },
	{ type="header",   text="Spark" },
	{ type="toggle",   text="Enabled",  var="bar|style.showSpark" },
	{ type="numinput", text="Height",   var="bar|style.sparkHeight"  },
	{ type="numinput", text="Width",    var="bar|style.sparkWidth" },
};

ChronoBars.Frame_StyleText =
{
	{ type="scroll" },
	{ type="header",     text="Text" },
	
	{ type="options",  text="Text",        var="temp|textIndex",  options="func|Options_Text", update=true },
	{ type="button",   text="New Text",    func="root|Func_NewText" },
	{ type="button",   text="Delete Text", func="root|Func_DeleteText" },
	
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
	
	{ text="Outside Left",    value=CB.POS_OUT_LEFT },
	{ text="Outside Right",   value=CB.POS_OUT_RIGHT },
	
	{ text="Above Left",      value=CB.POS_ABOVE_LEFT },
	{ text="Above Center",    value=CB.POS_ABOVE_CENTER },
	{ text="Above Right",     value=CB.POS_ABOVE_RIGHT },
	
	{ text="Below Left",      value=CB.POS_BELOW_LEFT },
	{ text="Below Center",    value=CB.POS_BELOW_CENTER },
	{ text="Below Right",     value=CB.POS_BELOW_RIGHT },
};

ChronoBars.Frame_StyleAnimation =
{
	{ type="scroll" },
	{ type="header",  text="Animation" },
	{ type="toggle",  text="Slide up when activated",             var="bar|style.anim.up" },
	{ type="toggle",  text="Slide down when consumed",            var="bar|style.anim.down" },
	{ type="toggle",  text="Blink slowly when running out",       var="bar|style.anim.blinkSlow" },
	{ type="toggle",  text="Blink quickly when almost expired",   var="bar|style.anim.blinkFast" },
	{ type="toggle",  text="Blink when usable",                   var="bar|style.anim.blinkUsable" },
	{ type="toggle",  text="Fade out when expired",               var="bar|style.anim.fade" },
};

ChronoBars.Frame_StyleVisibility =
{
	{ type="scroll" },
	{ type="header",   text="Visibility" },
	{ type="options",  text="Show bar",            var="bar|style.visibility",   options="root|Options_Visibility" },
	{ type="toggle",   text="Hide out of combat" },
};

ChronoBars.Options_Visibility =
{
	{ text="Always visible",    value = ChronoBars.VISIBLE_ALWAYS },
	{ text="When active",       value = ChronoBars.VISIBLE_ACTIVE },
};

--Group

ChronoBars.Frame_Group =
{
	{ type="scroll" },
	{ type="header",                  text="Group Settings" },

	{ type="options",                 text="Layout",                    var="group|layout",   options="root|Options_GroupLayout" },
	{ type="options",                 text="Sorting by time",           var="group|sorting",  options="root|Options_GroupSorting" },
	{ type="options",                 text="Grow direction",            var="group|grow",     options="root|Options_GrowDir" },

	{ type="numinput",                text="X position",                var="group|x" },
	{ type="numinput",                text="Y position",                var="group|y" },
	{ type="numinput",                text="Bar width",                 var="group|width" },
	{ type="numinput",                text="Bar height",                var="group|height" },
	{ type="numinput",                text="Bar padding",               var="group|padding" },
	{ type="numinput",                text="Bar spacing",               var="group|spacing" },

	{ type="numinput",                text="Back margin",               var="group|margin" },
	{ type="color",                   text="Back color",                var="group|style.bgColor" },
};

ChronoBars.Options_GroupLayout =
{
  { text="Keep bar positions",      value = ChronoBars.LAYOUT_KEEP },
  { text="Stack active bars",       value = ChronoBars.LAYOUT_STACK },
  { text="Show first active bar",   value = ChronoBars.LAYOUT_PRIORITY },
};

ChronoBars.Options_GroupSorting =
{
  { text="None",            value = ChronoBars.SORT_NONE },
  { text="Ascending",       value = ChronoBars.SORT_ASCENDING },
  { text="Descending",      value = ChronoBars.SORT_DESCENDING },
};

ChronoBars.Options_GrowDir =
{
  { text="Up",      value = ChronoBars.GROW_UP },
  { text="Down",    value = ChronoBars.GROW_DOWN },
};


--Text functions

function ChronoBars.Options_Text_Get()

	local options = {};
	
	local profile = CB.GetActiveProfile();
	local bar = CB.GetSettingsTable( "bar" );
	
	local numText = table.getn( bar.style.text );
	for i=1,numText do
	
		local text = bar.style.text[i];
		table.insert( options, { text = text.name, value = i } );
	end
	
	if (CB.GetSettingsValue( "temp|textIndex" ) == nil) then
		CB.SetSettingsValue( "temp|textIndex", 1 );
	end
	
	return options;
end

function ChronoBars.Func_NewText()
	CB.Print( "NEW TEXT" );
end

function ChronoBars.Func_DeleteText()
	CB.Print( "DELETE TEXT" );
end

--Copy/Paste

function ChronoBars.Func_BarCopy()

	--Get source / destination parameters
	local copyIndex = CB.GetSettingsValue( "temp|copyIndex" ) or 1;
	local copyItem = CB.BarCopyTable[ copyIndex ];
	
	--Copy value to temporary variable
	local value = CB.GetSettingsValue( copyItem.var );
	CB.SetSettingsValue( copyItem.temp, value );
	CB.Print( "Value copied." );
end

function ChronoBars.Func_BarPaste()

	--Get source / destination parameters
	local copyIndex = CB.GetSettingsValue( "temp|copyIndex" ) or 1;
	local copyItem = CB.BarCopyTable[ copyIndex ];
	
	--Copy exception
	local exception = nil;
	if (copyItem.exception) then
		exception = CB.GetSettingsValue( copyItem.exception );
	end
	
	--Paste value to target variable
	local value = CB.GetSettingsValue( copyItem.temp );
	if (value ~= nil) then
		CB.SetSettingsValue( copyItem.var, value );
		CB.Print( "Value pasted." );
	else
		CB.Error( "This value has not been copied yet!" );
	end
	
	--Paste exception
	if (copyItem.exception) then
		CB.SetSettingsValue( copyItem.exception, exception );
	end
	
	CB.UpdateSettings();
end

function ChronoBars.Func_BarPasteToAll()

	local profile = CB.GetActiveProfile();
	local oldGroupId = CB.temp.groupId;
	local oldBarId = CB.temp.barId;
	
	CB.Func_BarCopy();
	
	local numGroups = table.getn(profile.groups);
	for g=1,numGroups do
	
		local numBars = table.getn(profile.groups[g].bars);
		for b=1,numBars do
		
			CB.temp.groupId = g;
			CB.temp.barId = b;
			CB.Func_BarPaste();
		end
	end;
	
	CB.temp.groupId = oldGroupId;
	CB.temp.barId = oldBarId;
	CB.UpdateSettings();
end

function ChronoBars.Func_GroupCopy()

	CB.SetSettingsValue( "temp|groupWidth",    CB.GetSettingsValue( "group|width" ));
	CB.SetSettingsValue( "temp|groupHeight",   CB.GetSettingsValue( "group|height" ));
	CB.SetSettingsValue( "temp|groupPadding",  CB.GetSettingsValue( "group|padding" ));
	CB.SetSettingsValue( "temp|groupSpacing",  CB.GetSettingsValue( "group|spacing" ));
	CB.SetSettingsValue( "temp|groupMargin",   CB.GetSettingsValue( "group|margin" ));
	CB.SetSettingsValue( "temp|groupGrow",     CB.GetSettingsValue( "group|grow" ));
	CB.SetSettingsValue( "temp|groupLayout",   CB.GetSettingsValue( "group|layout" ));
	CB.SetSettingsValue( "temp|groupStyle",    CB.GetSettingsValue( "group|style" ));
  
end

function ChronoBars.Func_GroupPaste()

	CB.SetSettingsValue( "group|width",    CB.GetSettingsValue( "temp|groupWidth" ));
    CB.SetSettingsValue( "group|height",   CB.GetSettingsValue( "temp|groupHeight" ));
	CB.SetSettingsValue( "group|padding",  CB.GetSettingsValue( "temp|groupPadding" ));
	CB.SetSettingsValue( "group|spacing",  CB.GetSettingsValue( "temp|groupSpacing" ));
	CB.SetSettingsValue( "group|margin",   CB.GetSettingsValue( "temp|groupMargin" ));
	CB.SetSettingsValue( "group|grow",     CB.GetSettingsValue( "temp|groupGrow" ));
	CB.SetSettingsValue( "group|layout",   CB.GetSettingsValue( "temp|groupLayout" ));
	CB.SetSettingsValue( "group|style",    CB.GetSettingsValue( "temp|groupStyle" ));
	
end

function ChronoBars.Func_GroupPasteToAll()

	local profile = CB.GetActiveProfile();
	local oldGroupId = CB.temp.groupId;
	
	CB.Func_GroupCopy();
	
	local numGroups = table.getn(profile.groups);
	for g=1,numGroups do
			
		CB.temp.groupId = g;
		CB.Func_GroupPaste();
	end;
	
	CB.temp.groupId = oldGroupId;
	CB.UpdateSettings();
end

--Bar movement

function ChronoBars.Func_BarMoveUp()
  
  local profile = CB.GetActiveProfile();
  local group = profile.groups[ CB.temp.groupId ];
  
  local offset = 0;
  if (group.grow == CB.GROW_UP) then
    offset = 1;
  elseif (group.grow == CB.GROW_DOWN) then
    offset = -1;
  end
  
  CB.MoveBar( offset );
  
end

function ChronoBars.Func_BarMoveDown()

  local profile = CB.GetActiveProfile();
  local group = profile.groups[ CB.temp.groupId ];
  
  local offset = 0;
  if (group.grow == CB.GROW_UP) then
    offset = -1;
  elseif (group.grow == CB.GROW_DOWN) then
    offset = 1;
  end

  CB.MoveBar( offset );
  
end

function ChronoBars.MoveBar( offset )

  local profile = CB.GetActiveProfile();
  local group = profile.groups[ CB.temp.groupId ];
  
  local newBarId = CB.temp.barId + offset;
  if (newBarId < 1) then return end;
  if (newBarId > table.getn( group.bars )) then return end;

  local tempBar = group.bars[ newBarId ];
  group.bars[ newBarId ] = group.bars[ CB.temp.barId ];
  group.bars[ CB.temp.barId ] = tempBar;

  CB.temp.barId = newBarId;
  CB.UpdateSettings();
  
end

--Bar/Group management

function ChronoBars.Func_BarNew()

	--Find bar that was right-clicked
	local profile = CB.GetActiveProfile();
	local curBar = profile.groups[ CB.temp.groupId ].bars[ CB.temp.barId ];

	--Create new bar
	local newBar = CopyTable( CB.DEFAULT_BAR );
	table.insert( profile.groups[ CB.temp.groupId ].bars, newBar );
	
	--Clone style from current bar
	newBar.style = CopyTable( curBar.style );
	
	CB.UpdateSettings();
	CB.HideBarConfig();
	
end

function ChronoBars.Func_BarDelete()

	--Confirm with user
	local name = CB.GetSettingsValue( "bar|name" );
	CB.ShowConfirmFrame( "Are you sure you want to remove bar '"..tostring(name).."'?",
		CB.Func_BarDeleteAccept );
	
end

function ChronoBars.Func_BarDeleteAccept()
	CB.Debug( "Removing bar "..tostring(CB.temp.groupId)..","..tostring(CB.temp.barId) );


	--Check if last bar in group
	local profile = CB.GetActiveProfile();
	if (table.getn( profile.groups[ CB.temp.groupId ].bars ) <= 1) then
		CB.Error( "Cannot delete last bar in the group! Delete group instead." );
		return;
	end
	
	--Delete bar
	table.remove( profile.groups[ CB.temp.groupId ].bars, CB.temp.barId );
	
	CB.UpdateSettings();
	CB.HideBarConfig();
	
end

function ChronoBars.Func_GroupNew()

	--Find bar and group that was right-clicked
	local profile = CB.GetActiveProfile();
	local curBar = profile.groups[ CB.temp.groupId ].bars[ CB.temp.barId ];
	local oldGroupId = CB.temp.groupId;

	--Create new group
	local newGroup = CopyTable( CB.DEFAULT_GROUP );
	table.insert( profile.groups, newGroup);
	
	--Clone settings from current group
	CB.Func_GroupCopy();
	CB.temp.groupId = table.getn( profile.groups );
	CB.Func_GroupPaste();
	CB.temp.groupId = oldGroupId;
	
	--Clone style from current bar
	newGroup.bars[1].style = CopyTable( curBar.style );
	
	CB.UpdateSettings();
	CB.HideBarConfig();
	
end

function ChronoBars.Func_GroupDelete()
	
	--Confirm with user
	CB.ShowConfirmFrame( "Are you sure you want to delete this group?",
		CB.Func_GroupDeleteAccept );
end

function ChronoBars.Func_GroupDeleteAccept ()
	CB.Debug( "Removing group "..tostring(CB.temp.groupId) );

	--Check if last group
	local profile = CB.GetActiveProfile();
	if (table.getn( profile.groups ) <= 1) then
		CB.Error( "Cannot delete last group!" );
		return;
	end
	
	--Delete group
	table.remove( profile.groups, CB.temp.groupId );
	
	CB.UpdateSettings();
	CB.HideBarConfig();
	
end


--Config header
--======================================================================

function ChronoBars.ShowConfigHeader()

  if (not CB.configHeader) then
  
	--Window
	local f = CB.Window_New( "ChronoBars.ConfigHeader", "ChronoBars" );
	f:SetPoint( "TOP", 0,-100 );
	f:SetWidth( 400 );
	f:SetHeight( 110 );
	CB.configHeader = f;
	
	--Message text
    local txt = f:CreateFontString( "ChronoBars.ConfigHeader.Label", "OVERLAY", "GameFontNormal" );
    txt:SetTextColor( 1, 1, 1, 1 );
    txt:SetPoint( "TOPLEFT", 20, -25 );
    txt:SetPoint( "TOPRIGHT", -20, -25 );
    txt:SetHeight( 40 );
    txt:SetWordWrap( true );
	txt:SetJustifyH( "LEFT" );
    txt:SetText( "Config mode. Right-click a bar to open configuration menu." );
    txt:Show();
	
    --Close button
    local btnClose = CreateFrame( "Button", "ChronoBars.ConfigHeader.Close", f, "UIPanelButtonTemplate2" );
    btnClose.frame = f;
    btnClose:SetWidth( 100 );
    btnClose:SetHeight( 25 );
    btnClose:SetPoint( "BOTTOMRIGHT", f, "BOTTOMRIGHT", -20, 20 );
    btnClose:SetText( "Exit config" );
    btnClose:SetScript( "OnClick", ChronoBars.ConfigHeader_Close_OnClick );
		
  end
  
  CB.configHeader:Show();
  
end

function ChronoBars.HideConfigHeader()
	
	if (CB.configHeader) then
		CB.configHeader:Hide();
	end
end

function ChronoBars.ConfigHeader_Close_OnClick()
	CB.ModeRun();
end


--Config window
--===================================================

function ChronoBars.UpdateBarConfig()

	CB.FreeAllObjects();
	CB.configFrame:RemoveAllChildren();
	CB.Config_Construct( CB.configFrame, CB.Frame_Root );
	
end

function ChronoBars.ShowBarConfig (bar)
 
	CB.SetSettingsValue( "temp|groupId", bar.groupId );
	CB.SetSettingsValue( "temp|barId", bar.barId );

	if (not CB.configFrame) then
		CB.configFrame = CB.Window_New( "ChronoBars.ConfigFrame", "ChronoBars", true, true );
		CB.configFrame:RegisterScript( "OnShow", ChronoBars.ConfigFrame_OnShow );
		CB.configFrame:RegisterScript( "OnHide", ChronoBars.ConfigFrame_OnHide );
		CB.configFrame:SetPoint( "TOP", 0, -100 );
		CB.configFrame:SetWidth( 350 );
		CB.configFrame:SetHeight( 500 );
		CB.configFrame:Hide();
	end
	
	CB.UpdateBarConfig();
	CB.configFrame:Show();
end

function ChronoBars.HideBarConfig()

	if (CB.configFrame) then
		CB.configFrame:Hide();
	end
end

function ChronoBars.ConfigFrame_OnShow()

	if (CB.designMode) then
		CB.HideConfigHeader();
	end
end

function ChronoBars.ConfigFrame_OnHide()

	if (CB.designMode) then
		CB.ShowConfigHeader();
	end
end
