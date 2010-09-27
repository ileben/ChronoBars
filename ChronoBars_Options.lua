--[[

====================================================
ChronoBars - buff, debuff, cooldown, totem tracker
Author: Ivan Leben
====================================================

--]]

local CB = ChronoBars;
ChronoBars.MenuGroupId = 1;
ChronoBars.MenuBarId = 1;
ChronoBars.MenuItem = nil;

--Menu Structure
--===================================

ChronoBars.Menu_Bar = {
  
  { type="title", title="bar|name" },
  { text="Enabled",           type="toggle",    var="bar|enabled" },
  
  { type="separator" },
  { text="Effect name...",    type="input",     var="bar|name", input="Enter the name of the effect you want to track: " },
  { text="Effect type",       type="menu",      menu="root|Menu_EffectType" },

  { text="Aura settings",     type="menu",      menu="root|Menu_AuraSettings",
    conditionVar="bar|type", conditionValue = ChronoBars.EFFECT_TYPE_AURA },

  { text="Multi Aura settings", type="menu",      menu="root|Menu_MultiAuraSettings",
    conditionVar="bar|type", conditionValue = ChronoBars.EFFECT_TYPE_MULTI_AURA },
    
  { text="Cooldown settings", type="menu",  menu="root|Menu_CdType",
    conditionVar="bar|type", conditionValue = ChronoBars.EFFECT_TYPE_CD },
    
  { text="Usable settings",   type="menu",  menu="root|Menu_UsableSettings",
    conditionVar="bar|type", conditionValue = ChronoBars.EFFECT_TYPE_USABLE },
    
  { text="Totem settings", type="menu",  menu="root|Menu_TotemSettings",
    conditionVar="bar|type", conditionValue = ChronoBars.EFFECT_TYPE_TOTEM },
    
  { text="Custom settings", type="menu",      menu="root|Menu_CustomSettings",
    conditionVar="bar|type", conditionValue = ChronoBars.EFFECT_TYPE_CUSTOM },
    
  { text="Auto-Attack settings", type="menu",  menu="root|Menu_AutoSettings",
    conditionVar="bar|type", conditionValue = ChronoBars.EFFECT_TYPE_AUTO },
    
  { text="Enchant settings", type="menu",  menu="root|Menu_EnchantSettings",
    conditionVar="bar|type", conditionValue = ChronoBars.EFFECT_TYPE_ENCHANT },

  { type="separator" },
  { text="Display name",   type="menu",  menu="root|Menu_Display" },
  { text="Maximum time",  type="menu",  menu="root|Menu_Fixed" },
  
  { type="separator" },
  { text="Style",             type="menu",      menu="root|Menu_BarStyle" },
  { text="Copy",              type="menu",      menu="root|Menu_BarCopy" },
  { text="Paste",             type="menu",      menu="root|Menu_BarPaste" },
  { text="Copy to all",       type="menu",      menu="root|Menu_BarCopyToAll" },
  { text="Move up",           type="func",      func="MenuFunc_BarMoveUp" },
  { text="Move down",         type="func",      func="MenuFunc_BarMoveDown" },
  
  { type="separator" },
  { text="New",               type="menu",      menu="root|Menu_New" },
  { text="Delete",            type="menu",      menu="root|Menu_Delete" },
  
  { type="separator" },
  { text="Group settings",    type="menu",      menu="root|Menu_GroupSettings" },
  { text="Profile settings",  type="menu",      menu="root|Menu_ProfileSettings" },
};

ChronoBars.Menu_EffectType = {

  { text="Aura",               type="option",   closeAll=true, var="bar|type",  option = ChronoBars.EFFECT_TYPE_AURA },
  { text="Multi Aura",         type="option",   closeAll=true, var="bar|type",  option = ChronoBars.EFFECT_TYPE_MULTI_AURA },
  { text="Cooldown",           type="option",   closeAll=true, var="bar|type",  option = ChronoBars.EFFECT_TYPE_CD },
  { text="Usable",             type="option",   closeAll=true, var="bar|type",  option = ChronoBars.EFFECT_TYPE_USABLE },
  { text="Totem",              type="option",   closeAll=true, var="bar|type",  option = ChronoBars.EFFECT_TYPE_TOTEM },
  { text="Custom",             type="option",   closeAll=true, var="bar|type",  option = ChronoBars.EFFECT_TYPE_CUSTOM },
  { text="Auto-Attack",        type="option",   closeAll=true, var="bar|type",  option = ChronoBars.EFFECT_TYPE_AUTO },
  { text="Weapon Enchant",     type="option",   closeAll=true, var="bar|type",  option = ChronoBars.EFFECT_TYPE_ENCHANT },
};

ChronoBars.Menu_AuraSettings = {
  
  { text="Aura type",                   type="menu",     menu="root|Menu_AuraType" },
  { text="Unit to monitor",             type="menu",     menu="root|Menu_AuraUnit" },
  { text="Which when multiple",         type="menu",     menu="root|Menu_AuraOrder" },
  { text="Only if cast by self",        type="toggle",   var="bar|aura.byPlayer" },
  { text="Sum stack from all casters",  type="toggle",   var="bar|aura.sum" },
};

ChronoBars.Menu_MultiAuraSettings = {
  
  { text="Aura type",              type="menu",       menu="root|Menu_AuraType" },
  { text="Estimate duration...",   type="numinput",   var="bar|custom.duration", input="Estimated aura duration (seconds):" },
};

ChronoBars.Menu_AuraType = {

  { text="Buff",          type="option",  var="bar|aura.type", option = ChronoBars.AURA_TYPE_BUFF },
  { text="Debuff",        type="option",  var="bar|aura.type", option = ChronoBars.AURA_TYPE_DEBUFF },
};

ChronoBars.Menu_AuraUnit = {

  { text="Player",             type="option",     var="bar|aura.unit", option = ChronoBars.AURA_UNIT_PLAYER },
  { text="Target",             type="option",     var="bar|aura.unit", option = ChronoBars.AURA_UNIT_TARGET },
  { text="Focus",              type="option",     var="bar|aura.unit", option = ChronoBars.AURA_UNIT_FOCUS },
  { text="Pet",                type="option",     var="bar|aura.unit", option = ChronoBars.AURA_UNIT_PET },
  { text="Target of target",   type="option",     var="bar|aura.unit", option = ChronoBars.AURA_UNIT_TARGET_TARGET },
  { text="Target of focus",    type="option",     var="bar|aura.unit", option = ChronoBars.AURA_UNIT_FOCUS_TARGET },
  { text="Target of pet",      type="option",     var="bar|aura.unit", option = ChronoBars.AURA_UNIT_PET_TARGET },
};

ChronoBars.Menu_AuraOrder = {

  { text="First",             type="option",     var="bar|aura.order",  option = 1 },
  { text="Second",            type="option",     var="bar|aura.order",  option = 2 },
  { text="Third",             type="option",     var="bar|aura.order",  option = 3 },
  { text="Fourth",            type="option",     var="bar|aura.order",  option = 4 },
  { text="Fifth",             type="option",     var="bar|aura.order",  option = 5 },
};

ChronoBars.Menu_CdSettings = {

  { text="Cooldown type",   type="menu",   menu="root|Menu_CdType" },
};

ChronoBars.Menu_CdType = {

  { text="Spell",       type="option",   var="bar|cd.type",   option = ChronoBars.CD_TYPE_SPELL },
  --{ text="Pet Spell",   type="option",   var="bar|cd.type",   option = ChronoBars.CD_TYPE_PET_SPELL },
  { text="Item",        type="option",   var="bar|cd.type",   option = ChronoBars.CD_TYPE_ITEM },
};

ChronoBars.Menu_UsableSettings = {

  { text="Usable type",        type="menu",    menu="root|Menu_UsableType" },
  { text="Include cooldown",   type="toggle",  var="bar|usable.includeCd" },
};

ChronoBars.Menu_UsableType = {

  { text="Spell",       type="option",   var="bar|usable.type",   option = ChronoBars.USABLE_TYPE_SPELL },
  --{ text="Pet Spell",   type="option",   var="bar|usable.type",   option = ChronoBars.USABLE_TYPE_PET_SPELL },
  { text="Item",        type="option",   var="bar|usable.type",   option = ChronoBars.USABLE_TYPE_ITEM },
};

ChronoBars.Menu_TotemSettings = {

  { text="Fire",   type="option",   var="bar|totem.type",   option=ChronoBars.TOTEM_TYPE_FIRE },
  { text="Earth",  type="option",   var="bar|totem.type",   option=ChronoBars.TOTEM_TYPE_EARTH },
  { text="Water",  type="option",   var="bar|totem.type",   option=ChronoBars.TOTEM_TYPE_WATER },
  { text="Air",    type="option",   var="bar|totem.type",   option=ChronoBars.TOTEM_TYPE_AIR },
};

ChronoBars.Menu_CustomSettings = {

  { text="Trigger",       type="menu",       menu="root|Menu_CustomTrigger" },
  { text="Duration...",   type="numinput",   var="bar|custom.duration", input="Custom effect duration (seconds):" },
};

ChronoBars.Menu_CustomTrigger = {

  { text="Spell cast successful",   type="option",   var="bar|custom.trigger",   option=ChronoBars.CUSTOM_TRIGGER_SPELL_CAST },
  { text="Another bar activated",   type="option",   var="bar|custom.trigger",   option=ChronoBars.CUSTOM_TRIGGER_BAR_ACTIVE },
};

ChronoBars.Menu_AutoSettings = {

  { text="Main Hand",  type="option",  var="bar|auto.type",   option=CB.AUTO_TYPE_MAIN_HAND },
  { text="Off Hand",   type="option",  var="bar|auto.type",   option=CB.AUTO_TYPE_OFF_HAND },
  { text="Wand",       type="option",  var="bar|auto.type",   option=CB.AUTO_TYPE_WAND },
  { text="Bow/Gun",    type="option",  var="bar|auto.type",   option=CB.AUTO_TYPE_BOW },
};

ChronoBars.Menu_EnchantSettings = {

  { text="Main Hand",  type="option", var="bar|enchant.hand",  option=CB.HAND_MAIN },
  { text="Off Hand",   type="option", var="bar|enchant.hand",  option=CB.HAND_OFF },
};

ChronoBars.Menu_Display = {

  { text="Use display name",      type="toggle", var="bar|display.enabled" },
  { text="Set display name...",   type="input",  var="bar|display.name" },
};

ChronoBars.Menu_Fixed = {
  
  { text="Use maximum time",      type="toggle",    var="bar|fixed.enabled" },
  { text="Set maximum time...",   type="numinput",  var="bar|fixed.duration", input="Maximum time visible on the bar (seconds):" },
};

ChronoBars.Menu_BarShow = {

  { type="title", title="Show" },
  { text="Name",       type="toggle",    var="bar|style.showName" },
  { text="Count",      type="toggle",    var="bar|style.showCount" },
  { text="Time",       type="toggle",    var="bar|style.showTime" },
  { text="Icon",       type="toggle",    var="bar|style.showIcon" },
  { text="CD",         type="toggle",    var="bar|style.showCd" },
  { text="Usable",     type="toggle",    var="bar|style.showUsable" },
  { text="Spark",      type="toggle",    var="bar|style.showSpark" },
};

ChronoBars.Menu_BarStyle = {

  { type="title", title="Style" },
  { text="Show",                  type="menu",      menu="root|Menu_BarShow" },
  { text="Count Side",            type="menu",      menu="root|Menu_CountSide" },
  { text="Time Side",             type="menu",      menu="root|Menu_TimeSide" },
  { text="Full Side",             type="menu",      menu="root|Menu_FullSide" },
  { text="Icon Side",             type="menu",      menu="root|Menu_IconSide" },
  { text="Icon Zoom",             type="toggle",    var="bar|style.iconZoom" },
  { text="Fill up",               type="toggle",    var="bar|style.fillUp" },
 
  { type="separator" },
  { text="Texture",               type="menu",      menu="func|VarFunc_MenuTexture" },
  { text="Font",                  type="menu",      menu="func|VarFunc_MenuFont" },
  { text="Font Size...",          type="numinput",  var="bar|style.fontSize",  input="Font size:" },
  { text="Spark Height...",       type="numinput",  var="bar|style.sparkHeight", input="Spark height relative to bar height:" },
  { text="Spark Width...",        type="numinput",  var="bar|style.sparkWidth",  input="Spark width:" },
  { text="Time Format",           type="menu",      menu="root|Menu_TimeFormat" },
  
  { type="separator" },
  { text="Text Color...",         type="color",     var="bar|style.textColor" },
  { text="Front Color...",        type="color",     var="bar|style.fgColor" },
  { text="Back Color...",         type="color",     var="bar|style.bgColor" },

  { type="separator" },
  { text="Visibility",            type="menu",      menu="root|Menu_Visibility" },
  { text="Animation",             type="menu",      menu="root|Menu_Animation" },
};

ChronoBars.Menu_IconSide = {

  { type="title", title="Icon Side" };
  { text="Left",    type="option",   var="bar|style.iconSide",   option = ChronoBars.SIDE_LEFT },
  { text="Right",   type="option",   var="bar|style.iconSide",   option = ChronoBars.SIDE_RIGHT },
};

ChronoBars.Menu_TimeSide = {

  { type="title",   title="Time Side" };
  { text="Name || Time",   type="option",   var="bar|style.timeSide",   option = ChronoBars.SIDE_RIGHT },
  { text="Time || Name",   type="option",   var="bar|style.timeSide",   option = ChronoBars.SIDE_LEFT },
};

ChronoBars.Menu_CountSide = {

  { type="title",   title="Count Side" };
  { text="Name [count]",   type="option",   var="bar|style.countSide",   option = ChronoBars.SIDE_RIGHT },
  { text="[count] Name",   type="option",   var="bar|style.countSide",   option = ChronoBars.SIDE_LEFT },
};

ChronoBars.Menu_FullSide = {

  { type="title", title="Full Side" };
  { text="Empty || Full",  type="option",   var="bar|style.fullSide",   option = ChronoBars.SIDE_RIGHT },
  { text="Full || Empty",  type="option",   var="bar|style.fullSide",   option = ChronoBars.SIDE_LEFT },
};

ChronoBars.Menu_TimeFormat = {

  { text="Single unit (1m)",        type="option",   var="bar|style.timeFormat",  option=ChronoBars.TIME_SINGLE },
  { text="One decimal (1.1m)",      type="option",   var="bar|style.timeFormat",  option=ChronoBars.TIME_DECIMAL },
  { text="Minutes:seconds (1:10)",  type="option",   var="bar|style.timeFormat",  option=ChronoBars.TIME_MINSEC },
};

ChronoBars.Menu_Font = {

  { text="Friz Quadrata",   type="option", var="bar|style.fontName", option="Fonts\\FRIZQT__.TTF", font="Fonts\\FRIZQT__.TTF" },
  { text="Arial Narrow",    type="option", var="bar|style.fontName", option="Fonts\\ARIALN.TTF",   font="Fonts\\ARIALN.TTF" },
  { text="Skurri",          type="option", var="bar|style.fontName", option="Fonts\\skurri.TTF",   font="Fonts\\skurri.TTF" },
  { text="Morpheus",        type="option", var="bar|style.fontName", option="Fonts\\MORPHEUS.TTF", font="Fonts\\MORPHEUS.TTF" },
};

ChronoBars.Menu_BarCopy = {

  { type="title", title="Copy" },
  { text="Front Color",              type="value", var="temp|color",       value="bar|style.fgColor" },
  { text="Back Color",               type="value", var="temp|color",       value="bar|style.bgColor" },
  { text="Text Color",               type="value", var="temp|color",       value="bar|style.textColor" },
  { text="Texture",                  type="value", var="temp|tex",         value="bar|style.lsmTexHandle" },
  { text="Font",                     type="value", var="temp|font",        value="bar|style.lsmFontHandle" },
  { text="Font Size",                type="value", var="temp|fontSize",    value="bar|style.fontSize" },
  { text="Visibility",               type="value", var="temp|visibility",  value="bar|style.visibility" },
  { text="Entire Style",             type="value", var="temp|style",       value="bar|style" },
  { text="Style Except Front Color", type="value", var="temp|style",       value="bar|style" },
  { text="All Bar Settings",         type="func",  func="MenuFunc_CopyBar" },
};

ChronoBars.Menu_BarPaste = {

  { type="title", title="Paste" },
  { text="Front Color",              type="value", var="bar|style.fgColor",       value="temp|color" },
  { text="Back Color",               type="value", var="bar|style.bgColor",       value="temp|color" },
  { text="Text Color",               type="value", var="bar|style.textColor",     value="temp|color" },
  { text="Texture",                  type="value", var="bar|style.lsmTexHandle",  value="temp|tex" },
  { text="Font",                     type="value", var="bar|style.lsmFontHandle", value="temp|font" },
  { text="Font Size",                type="value", var="bar|style.fontSize",      value="temp|fontSize" },
  { text="Visibility",               type="value", var="bar|style.visibility",    value="temp|visibility" },
  { text="Entire Style",             type="value", var="bar|style",               value="temp|style" },
  { text="Style Except Front Color", type="func",  func="MenuFunc_PasteStyleExceptFg" },
  { text="All Bar Settings",         type="func",  func="MenuFunc_PasteBar" },
};

ChronoBars.Menu_BarCopyToAll = {

  { type="title", title="Copy to All" },
  { text="Front Color",              type="func",  func="MenuFunc_CopyToAll", value="const|bar|style.fgColor" },
  { text="Back Color",               type="func",  func="MenuFunc_CopyToAll", value="const|bar|style.bgColor" },
  { text="Text Color",               type="func",  func="MenuFunc_CopyToAll", value="const|bar|style.textColor" },
  { text="Texture",                  type="func",  func="MenuFunc_CopyToAll", value="const|bar|style.lsmTexHandle" },
  { text="Font",                     type="func",  func="MenuFunc_CopyToAll", value="const|bar|style.lsmFontHandle" },
  { text="Font Size",                type="func",  func="MenuFunc_CopyToAll", value="const|bar|style.fontSize" },
  { text="Visibility",               type="func",  func="MenuFunc_CopyToAll", value="const|bar|style.visibility" },
  { text="Entire Style",             type="func",  func="MenuFunc_CopyToAll", value="const|bar|style" },
  { text="Style Except Front Color", type="func",  func="MenuFunc_CopyToAll", value="const|styleExceptFg" },
  { text="All Bar Settings",         type="func",  func="MenuFunc_CopyToAll", value="const|all" },
};

ChronoBars.Menu_Visibility = {

  { type="title", title="Visibility" },
  { text="Always visible",      type="option", var="bar|style.visibility", option=ChronoBars.VISIBLE_ALWAYS },
  { text="When active",         type="option", var="bar|style.visibility", option=ChronoBars.VISIBLE_ACTIVE },
};

ChronoBars.Menu_Animation = {

  { text="Slide up when activated",   type="toggle",  var="bar|style.anim.up" },
  { text="Slide down when consumed",  type="toggle",  var="bar|style.anim.down" },
  { text="Blink when running out",    type="toggle",  var="bar|style.anim.blink" },
  { text="Blink when usable",         type="toggle",  var="bar|style.anim.blinkUsable" },
  { text="Fade out when expired",     type="toggle",  var="bar|style.anim.fade" },
};

ChronoBars.Menu_New = {

  { type="title", title="New" },
  { text="Bar",      type="func",     func="MenuFunc_NewBar" },
  { text="Group",    type="func",     func="MenuFunc_NewGroup" },
};

ChronoBars.Menu_Delete = {

  { type="title", title="Delete" },
  { text="Bar",     type="func",     func="MenuFunc_DeleteBar" },
  { text="Group",   type="func",     func="MenuFunc_DeleteGroup" },
};

ChronoBars.Menu_GroupSettings = {

  { type="title", title="Group" },
  { text="Layout",                    type="menu",     menu="root|Menu_GroupLayout" },
  { text="Sorting by time",           type="menu",     menu="root|Menu_GroupSorting" },
  { text="Grow direction",            type="menu",     menu="root|Menu_GrowDir" },
  
  { type="separator" },
  { text="X position...",             type="numinput", var="group|x",       input="Enter group X offset from center:" },
  { text="Y position...",             type="numinput", var="group|y",       input="Enter group Y offset from center:" },
  { text="Bar width...",              type="numinput", var="group|width",   input="Enter bar width:" },
  { text="Bar height...",             type="numinput", var="group|height",  input="Enter bar height:" },
  { text="Bar padding...",            type="numinput", var="group|padding", input="Enter bar padding:" },
  { text="Bar spacing...",            type="numinput", var="group|spacing", input="Enter bar spacing:" },

  { type="separator" },
  { text="Back margin...",            type="numinput", var="group|margin",  input="Enter group background margin:" },
  { text="Back color...",             type="color",    var="group|style.bgColor" },
  
  { type="separator" },
  { text="Copy settings",             type="func", func="MenuFunc_CopyGroup" },
  { text="Paste settings",             type="func", func="MenuFunc_PasteGroup" },
};

ChronoBars.Menu_GrowDir = {

  { text="Up",      type="option",    var="group|grow",  option = ChronoBars.GROW_UP },
  { text="Down",    type="option",    var="group|grow",  option = ChronoBars.GROW_DOWN },
};

ChronoBars.Menu_GroupLayout = {

  { text="Keep bar positions",      type="option",   var="group|layout",   option=ChronoBars.LAYOUT_KEEP },
  { text="Stack active bars",       type="option",   var="group|layout",   option=ChronoBars.LAYOUT_STACK },
  { text="Show first active bar",   type="option",   var="group|layout",   option=ChronoBars.LAYOUT_PRIORITY },
};

ChronoBars.Menu_GroupSorting = {

  { text="None",            type="option",  var="group|sorting",  option=ChronoBars.SORT_NONE },
  { text="Ascending",       type="option",  var="group|sorting",  option=ChronoBars.SORT_ASCENDING },
  { text="Descending",      type="option",  var="group|sorting",  option=ChronoBars.SORT_DESCENDING },
};

ChronoBars.Menu_ProfileSettings = {

  { type="title", title="char|activeProfile" },
  { text="Link to current spec",  type="func",      func="MenuFunc_LinkProfile" },
  { text="Manage",                type="menu",      menu="root|Menu_ProfileManage" },
  { text="Switch To",             type="menu",      menu="func|VarFunc_MenuSwitchProfile" },
  { text="Copy From",             type="menu",      menu="func|VarFunc_MenuCopyProfile" },
};

ChronoBars.Menu_ProfileManage = {
  { text="Rename Profile",    type="input",     var="func|VarFunc_RenameProfile", input="Rename profile:" },
  { text="New Profile",       type="input",     var="func|VarFunc_NewProfile", input="Name of the new profile:" },
  { text="Delete Profile",    type="func",      func="MenuFunc_DeleteProfile" },
};


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
    
    --Return value of final variable in the current table
    if (v == varCount) then
      return curTable[ varName ];
    end
    
    --Recurse into subtable
    curTable = curTable[ varName ];
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
    
    --Set value of final variable in the current table
    if (v == varCount) then
      if (type( value ) == "table")
      then curTable[ varName ] = CopyTable( value );
      else curTable[ varName ] = value; end
      return true;
    end
    
    --Recurse into subtable
    curTable = curTable[ varName ];
  end
  
  return false;
end

function ChronoBars.GetSettingsTable (id, tableType)

  if (tableType == "root") then
    return ChronoBars;
  
  elseif (tableType == "char") then
    return ChronoBars_CharSettings;

  elseif (tableType == "bar") then
    local profile = ChronoBars.GetActiveProfile();
    return profile.groups[ id.groupId ].bars[ id.barId ];

  elseif (tableType == "group") then
    local profile = ChronoBars.GetActiveProfile();
    return profile.groups[ id.groupId ];
    
  elseif (tableType == "temp") then
    if (not ChronoBars.temp) then ChronoBars.temp = {}; end
    return ChronoBars.temp;
  end
  
  return nil;
end

function ChronoBars.GetSettingsValue (id, var)
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
    return func( id, arg );

  else
  
    --Otherwise get from the table
    local settings = ChronoBars.GetSettingsTable( id, location );
    return ChronoBars.GetDeepValue( settings, path );
  end
end


function ChronoBars.SetSettingsValue (id, var, value)

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
    func( id, value, arg );
    return true;
    
  else
  
    --Otherwise set in the table
    local settings = ChronoBars.GetSettingsTable( id, location );
    return ChronoBars.SetDeepValue( settings, path, value );
  end
end


--Menu construction
--================================================================

--[[

This function gets called everytime the root menu or a submenu needs to be
filled with items. The global variables UIDROPDOWNMENU_... hold additional
properties regarding the current menu that is being initialised at the time
the function is called.

MENU_LEVEL tells which level in the hierachy the current menu is on.
When the menu level is greater than 1 (not root), MENU_VALUE holds the value
of the item in the parent menu that activated this submenu. We use this value
to look up the table holding the item list for the current menu.

--]]
function ChronoBars.InitBarMenu (menu, level)

  ChronoBars.Debug( "InitBarMenu level:"
    ..tostring(UIDROPDOWNMENU_MENU_LEVEL).." value:"
    ..tostring(UIDROPDOWNMENU_MENU_VALUE)  );

  ChronoBars.Debug( "currentbar: "
    ..tostring( menu.id.groupId )..","
    ..tostring( menu.id.barId ));
    
  --Check that the bar settings still exist (in case of removal)
  local id = menu.id;
  local profile = ChronoBars.GetActiveProfile();
  if (not profile.groups[ id.groupId ]) then return end;
  if (not profile.groups[ id.groupId ].bars[ id.barId ]) then return end;
  
  --Start with root menu and check level
  local parentMenu = ChronoBars.Menu_Bar;
  if (UIDROPDOWNMENU_MENU_LEVEL > 1) then
  
    --Get value of parent menu item
    local parentItem = UIDROPDOWNMENU_MENU_VALUE;
    parentMenu = ChronoBars.GetSettingsValue( id, parentItem.menu );
    
    --Check for missing menu
    if (parentMenu == nil) then
      ChronoBars.Debug( "Failed finding menu '"..parentItem.menu.."'" );
      return
    end
  end
  
  --Walk the submenu nodes
  for i,item in ipairs( parentMenu ) do
    
    --Check if the menu is conditional
    local conditionOk = true;
    if (item.conditionVar and item.conditionValue) then
    
      --Test conditional variable
      local testValue = ChronoBars.GetSettingsValue( id, item.conditionVar );
      conditionOk = (testValue == item.conditionValue);
    end
    
    --Skip buttons when condition failed
    if (conditionOk) then
    
      --Defaults (arg1 and arg2 get passed into info.func)
      local info = UIDropDownMenu_CreateInfo();
      info.text = item.text;
      info.value = item.value;
      info.owner = frame;
      info.checked = nil;
      info.icon = nil;
      info.notCheckable = true;
      info.arg1 = item;
      info.arg2 = id;
      info.disabled = false;
      
      --Type-specific initialization
      if (item.type == "separator") then
        info.notClickable = true;
      
      elseif (item.type == "title") then
        local curValue = ChronoBars.GetSettingsValue( id, item.title );
        info.text = curValue;
        info.isTitle = true;
        
        local titleLimit = 24;
        if (info.text ~= nil) then
          if (strlen(info.text) > titleLimit) then
            info.text = strsub( info.text, 1, titleLimit ).."...";
          end
        end
      
      elseif (item.type == "menu") then
        info.hasArrow = true;
        info.value = item;
        
      elseif (item.type == "value") then
        info.func = ChronoBars.BarMenu_OnClickValue;
        
      elseif (item.type == "option") then
        local curValue = ChronoBars.GetSettingsValue( id, item.var );
        local itemValue = ChronoBars.GetSettingsValue( id, item.option );
        info.checked = (curValue == itemValue);
        info.notCheckable = false;
        info.func = ChronoBars.BarMenu_OnClickOption;
        
      elseif (item.type == "toggle") then
        local curValue = ChronoBars.GetSettingsValue( id, item.var );
        info.checked = curValue;
        info.notCheckable = false;
        info.func = ChronoBars.BarMenu_OnClickToggle;
        
      elseif (item.type == "color") then
        local curValue = ChronoBars.GetSettingsValue( id, item.var );

        --[[
        --This would be nice, but there's no way of telling which item
        --the ColorPickerFrame comes from
        info.hasColorSwatch = 1;
        info.hasOpacity = true;
        info.r = curValue.r;
        info.g = curValue.g;
        info.b = curValue.b;
        info.opacity = 1 - curValue.a;
        info.swatchFunc = ChronoBar.BarMenu_ColorFunc;
        info.opacityFunc = ChronoBar.BarMenu_ColorFunc;
        info.cancelFunc = ChronoBar.BarMenu_ColorCancelFunc;
        info.func = UIDropDownMenuButton_OpenColorPicker;
        --]]
        
        --We show the ColorPickerFrame manually instead
        info.func = ChronoBars.BarMenu_OnClickColor;
        
      elseif (item.type == "input" or item.type == "numinput") then
        info.func = ChronoBars.BarMenu_OnClickInput;
        
      elseif (item.type == "func") then
        info.func = ChronoBars.BarMenu_OnClickFunc;
      
      end
      
      --Add button if text non-empty
      --if (info.text ~= nil and info.text ~= "") then
      UIDropDownMenu_AddButton( info, UIDROPDOWNMENU_MENU_LEVEL );
      --end
    end
  end
  
end

function ChronoBars.OpenBarMenu (bar)
  
  ChronoBars.MenuGroupId = bar.groupId;
  ChronoBars.MenuBarId = bar.barId;

  if (not bar.menu) then
    bar.menu = CreateFrame( "Frame", bar:GetName().."menu", bar, "UIDropDownMenuTemplate" );
    UIDropDownMenu_SetWidth( bar.menu, 80 );
    UIDropDownMenu_SetButtonWidth( bar.menu, 20 );
  end
  
  bar.menu.id = { ["groupId"] = bar.groupId, ["barId"] = bar.barId };
  UIDropDownMenu_Initialize( bar.menu, ChronoBars.InitBarMenu, "MENU" );
  ToggleDropDownMenu(1, nil, bar.menu, "cursor", 0, 0);
  
end

function ChronoBars.CloseBarMenu (id)

  local bar = ChronoBars.groups[ id.groupId ].bars[ id.barId ];
  ToggleDropDownMenu(1, nil, bar.menu);
  
end

function ChronoBars.BarMenu_OnClickFunc (info, item, id)  
  ChronoBars.Debug( "Calling func '"..item.func..'"' );
  
  local itemValue = ChronoBars.GetSettingsValue( id, item.value );
  local func = ChronoBars[ item.func ];
  func( id, itemValue );
  
end

function ChronoBars.BarMenu_OnClickValue (info, item, id)
  ChronoBars.Debug ("Setting value '"..item.var.."' to "..tostring( item.value ) );
  
  local itemValue = ChronoBars.GetSettingsValue( id, item.value );
  ChronoBars.SetSettingsValue( id, item.var, itemValue );
  ChronoBars.UpdateSettings();
  
  if (item.closeAll) then
    ChronoBars.CloseBarMenu( id );
  end
  
end

function ChronoBars.BarMenu_OnClickOption (info, item, id)
  ChronoBars.Debug( "Setting option '"..item.var.."' to "..tostring( item.option ) );
  
  local itemValue = ChronoBars.GetSettingsValue( id, item.option );
  ChronoBars.SetSettingsValue( id, item.var, itemValue );
  ChronoBars.UpdateSettings();
  
  if (item.closeAll) then
    ChronoBars.CloseBarMenu( id );
  end
  
end

function ChronoBars.BarMenu_OnClickToggle (info, item, id)
  ChronoBars.Debug( "Toggling toggle '"..item.var.."'" );
  
  local curValue = ChronoBars.GetSettingsValue( id, item.var );
  ChronoBars.SetSettingsValue( id, item.var, (not curValue) );
  ChronoBars.UpdateSettings();
  
  if (item.closeAll) then
    ChronoBars.CloseBarMenu( id );
  end
  
end

function ChronoBars.BarMenu_OnClickColor (info, item, id)
  ChronoBars.Debug( "OpenColorPicker" );
 
  local curValue = ChronoBars.GetSettingsValue( id, item.var );
  
  ColorPickerFrame.id = id;
  ColorPickerFrame.item = item;
  ColorPickerFrame.oldValue = curValue;

  ColorPickerFrame.func = ChronoBars.BarMenu_ColorFunc;
  ColorPickerFrame.opacityFunc = ChronoBars.BarMenu_ColorFunc;
  ColorPickerFrame.cancelFunc = ChronoBars.BarMenu_ColorCancelFunc;
  
  ColorPickerFrame:SetColorRGB( curValue.r, curValue.g, curValue.b );
  ColorPickerFrame.opacity = (1 - curValue.a);
  ColorPickerFrame.hasOpacity = true;
  
  ColorPickerFrame:Show();
  ChronoBars.CloseBarMenu( id );
  
end

function ChronoBars.BarMenu_ColorFunc ()

  local id = ColorPickerFrame.id;
  local item = ColorPickerFrame.item;
  if ((not id) or (not item)) then return end;
    
  local newR, newG, newB = ColorPickerFrame:GetColorRGB();
  local newA = OpacitySliderFrame:GetValue();
  
  ChronoBars.Debug(
    "Setting '"..item.var.."' to "..
    "r"..string.format("%.1f",newR)..
    ",g"..string.format("%.1f",newG)..
    ",b"..string.format("%.1f",newB)..
    ",a"..string.format("%.1f",newA)
  );
  
  ChronoBars.SetSettingsValue( id, item.var, { r = newR, g = newG, b = newB, a = (1-newA) } );
  ChronoBars.UpdateSettings();

end

function ChronoBars.BarMenu_ColorCancelFunc ()
  
  local id = ColorPickerFrame.id;
  local item = ColorPickerFrame.item;
  if ((not id) or (not item)) then return end;
  
  ChronoBars.SetSettingsValue( id, item.var, ColorPickerFrame.oldValue );
  ChronoBars.UpdateSettings();
  
end

function ChronoBars.BarMenu_OnClickInput (info, item, id)

  if (not ChronoBars.inputFrame) then
  
    --Create new Frame which subclasses Bling.Roster
    local f = CreateFrame( "Frame", "ChronoBars.InputFrame", UIParent );
    f:SetFrameStrata( "DIALOG" );
    f:SetToplevel( true );
    f:SetWidth( 300 );
    f:SetHeight( 150 );
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
    txt:SetText( item.input );
    txt:Show();
    
    --Create input field
    local inp = CreateFrame( "EditBox", "ChronoBars.InputFrame.Input", f, "InputBoxTemplate" );
    inp.myframe = f;
    inp:SetPoint( "CENTER", 0, 0 );
    inp:SetWidth( 240 );
    inp:SetHeight( 30 );
    inp:SetAutoFocus( true );
    inp:SetScript( "OnEnterPressed",
      function (self) ChronoBars.InputFrame_OnClickAccept( self.myframe ) end );
    
    --Create the Accept button
    local btnAccept = CreateFrame( "Button", nul, f, "UIPanelButtonTemplate" );
    btnAccept.myframe = f;
    btnAccept:SetWidth( 100 );
    btnAccept:SetHeight( 20 );
    btnAccept:SetPoint( "TOPRIGHT", f, "CENTER", -10, -30 );
    btnAccept:SetText( "Accept" );
    btnAccept:SetScript( "OnClick",
      function (self) ChronoBars.InputFrame_OnClickAccept( self.myframe ) end );
    
    --Create the Cancel button
    local btnCancel = CreateFrame( "Button", nul, f, "UIPanelButtonTemplate" );
    btnCancel.myframe = f;
    btnCancel:SetWidth( 100 );
    btnCancel:SetHeight( 20 );
    btnCancel:SetPoint( "TOPLEFT", f, "CENTER", 10, -30 );
    btnCancel:SetScript( "OnClick", function (self) self.myframe:Hide() end );
    btnCancel:SetText( "Cancel" );
    btnCancel:Show();
    
    f.text = txt;
    f.input = inp;
    ChronoBars.inputFrame = f;
  end
  
  --Apply current value and show
  local f = ChronoBars.inputFrame;
  f.input:SetText( tostring( ChronoBars.GetSettingsValue( id, item.var )));
  f.text:SetText( item.input );
  f.item = item;
  f.id = id;
  f:Show();
  
  ChronoBars.CloseBarMenu( id );
  
end


function ChronoBars.InputFrame_OnClickAccept (self)

  --Get input and convert to number if necessary
  local value = self.input:GetText();
  if (self.item.type == "numinput") then
    value = tonumber( value );
  end
  
  --Check for invalid value
  if (value == nil) then
    ChronoBars.Debug( "Input value is nil!" );
    return
  end
  
  ChronoBars.Debug( "Setting value '"..self.item.var.."'".." to "..tostring(value) );
  ChronoBars.SetSettingsValue( self.id, self.item.var, value );
  ChronoBars.UpdateSettings();
  self:Hide();

end

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



--Dynamic Texture and Font menus
--=============================================================

function ChronoBars.SplitMenuOptions (options, subtext, subname, var)

  local menu = {};
  
  --Check if more than 10 options
  local numOptions = table.getn( options );
  if (numOptions > 10) then
  
    --Find the required number of groups of 10 options
    local numGroups = math.ceil( numOptions / 10 );
    for i=1,numGroups do

      --Create a group submenu and insert 10 option items
      local groupLast = i * 10;
      local groupFirst = i * 10 - 9;
      local groupMenu = {};
      
      for o = groupFirst, groupLast do
        if (o > numOptions) then break end
        local optionItem = {
          text = options[o],
          type = "option",
          var  = var,
          option = options[o] };
        table.insert( groupMenu, optionItem );
      end

      --Store group submenu globaly and add an item pointing to it
      local groupMenuText = subtext..tostring(i);
      local groupMenuName = subname..tostring(i);
      
      local groupItem = {
        text = groupMenuText,
        type = "menu",
        menu = "root|"..groupMenuName };
      table.insert( menu, groupItem );
      ChronoBars[ groupMenuName ] = groupMenu;
      
    end
  else
    
    --Insert all options directly
    for o=1,numOptions do
      local optionItem = {
        text = options[o],
        type = "option",
        var = var,
        option = options[o] };
      table.insert( menu, optionItem );
    end
  end
  
  return menu;
end

function ChronoBars.VarFunc_MenuTexture_Get (id)

  local handles = ChronoBars.LSM:List( "statusbar" );
  local menu = ChronoBars.SplitMenuOptions( handles,
    "Textures", "Menu_Textures", "bar|style.lsmTexHandle" );
  
  local noneItem = {
    text="None",
    type="option",
    var="bar|style.lsmTexHandle",
    option="None" };
  
  table.insert( menu, 1, noneItem );
  return menu;
  
end

function ChronoBars.VarFunc_MenuFont_Get (id)

  local handles = ChronoBars.LSM:List( "font" );
  local menu = ChronoBars.SplitMenuOptions( handles,
    "Fonts", "Menu_Fonts", "bar|style.lsmFontHandle" );
  return menu;
  
end

--Copy/Paste all bar settings
--=============================================================

function ChronoBars.MenuFunc_CopyBar (id, value)

  if (not ChronoBars.temp) then ChronoBars.temp = {} end;
  
  local profile = ChronoBars.GetActiveProfile();
  ChronoBars.temp.bar = CopyTable( profile.groups[ id.groupId ].bars[ id.barId ] );

  ChronoBars.UpdateSettings();
  ChronoBars.CloseBarMenu( id );
end

function ChronoBars.MenuFunc_PasteBar (id, value)

  if (not ChronoBars.temp) then return end;
  if (not ChronoBars.temp.bar) then return end;
  
  local profile = ChronoBars.GetActiveProfile();
  profile.groups[ id.groupId ].bars[ id.barId ] = CopyTable( ChronoBars.temp.bar );

  ChronoBars.UpdateSettings();
  ChronoBars.CloseBarMenu( id );  
end

function ChronoBars.MenuFunc_PasteStyleExceptFg (id, value)

  if (not ChronoBars.temp) then return end;
  if (not ChronoBars.temp.style) then return end;
  
  local tempFg = CB.GetSettingsValue( id, "bar|style.fgColor" );
  CB.SetSettingsValue( id, "bar|style", CB.temp.style );
  CB.SetSettingsValue( id, "bar|style.fgColor", tempFg );
  
  ChronoBars.UpdateSettings();
  ChronoBars.CloseBarMenu( id );
end

--Copy to all bars
--=============================================================

function ChronoBars.MenuFunc_CopyToAll (id, value)
  local profile = ChronoBars.GetActiveProfile();
  
  --Copy source value
  local temp;
  if (value == "all") then
    temp = CopyTable( profile.groups[ id.groupId ].bars[ id.barId ] );
  elseif (value == "styleExceptFg") then
    temp = CB.GetSettingsValue( id, "bar|style" );
  else
    temp = CB.GetSettingsValue( id, value );
  end
  
  --Walk all the bars in the profile
  for g=1,table.getn( profile.groups ) do
    for b=1,table.getn( profile.groups[g].bars ) do
      if (g ~= id.groupId or b ~= id.barId) then
        local otherId = { groupId = g, barId = b };
        
        --Paste destination value
        if (value == "all") then
          profile.groups[ g ].bars[ b ] = CopyTable( temp );
        elseif (value == "styleExceptFg") then
          local tempFg = CB.GetSettingsValue( otherId, "bar|style.fgColor" );
          CB.SetSettingsValue( otherId, "bar|style", temp );
          CB.SetSettingsValue( otherId, "bar|style.fgColor", tempFg );
        else
          CB.SetSettingsValue( otherId, value, temp );  
        end
        
      end
    end
  end
  
  ChronoBars.UpdateSettings();
  ChronoBars.CloseBarMenu( id );
end

--Copy/Paste all group settings
--=============================================================

function ChronoBars.CopyGroup (group)

  if (not ChronoBars.temp) then ChronoBars.temp = {} end;
  if (not ChronoBars.temp.group) then ChronoBars.temp.group = {} end;
  
  ChronoBars.temp.group.width     = group.width;
  ChronoBars.temp.group.height    = group.height;
  ChronoBars.temp.group.padding   = group.padding;
  ChronoBars.temp.group.spacing   = group.spacing;
  ChronoBars.temp.group.margin    = group.margin;
  ChronoBars.temp.group.grow      = group.grow;
  ChronoBars.temp.group.layout    = group.layout;
  ChronoBars.temp.group.style     = CopyTable( group.style );
  
end

function ChronoBars.PasteGroup (group)

  if (not ChronoBars.temp) then return end;
  if (not ChronoBars.temp.group) then return end;
  
  group.width     = ChronoBars.temp.group.width;
  group.height    = ChronoBars.temp.group.height;
  group.padding   = ChronoBars.temp.group.padding;
  group.spacing   = ChronoBars.temp.group.spacing;
  group.margin    = ChronoBars.temp.group.margin;
  group.grow      = ChronoBars.temp.group.grow;
  group.layout    = ChronoBars.temp.group.layout;
  group.style     = CopyTable( ChronoBars.temp.group.style );
  
end

function ChronoBars.MenuFunc_CopyGroup (id, value)
  
  local profile = ChronoBars.GetActiveProfile();
  local group = profile.groups[ id.groupId ];
  ChronoBars.CopyGroup( group );
  ChronoBars.UpdateSettings();
  ChronoBars.CloseBarMenu( id );
  
end

function ChronoBars.MenuFunc_PasteGroup (id, value)

  local profile = ChronoBars.GetActiveProfile();
  local group = profile.groups[ id.groupId ];
  ChronoBars.PasteGroup( group );  
  ChronoBars.UpdateSettings();
  ChronoBars.CloseBarMenu( id );
  
end

--Move bar up/down
--=============================================================

function ChronoBars.MoveBar (id, offset)

  local profile = ChronoBars.GetActiveProfile();
  local group = profile.groups[ id.groupId ];
  
  local newBarId = id.barId + offset;
  if (newBarId < 1) then return end;
  if (newBarId > table.getn( group.bars )) then return end;

  local tempBar = group.bars[ newBarId ];
  group.bars[ newBarId ] = group.bars[ id.barId ];
  group.bars[ id.barId ] = tempBar;

  ChronoBars.UpdateSettings();
  ChronoBars.CloseBarMenu( id );
  
end

function ChronoBars.MenuFunc_BarMoveUp (id, value)

  local profile = ChronoBars.GetActiveProfile();
  local group = profile.groups[ id.groupId ];
  
  local offset = 0;
  if (group.grow == ChronoBars.GROW_UP) then
    offset = 1;
  elseif (group.grow == ChronoBars.GROW_DOWN) then
    offset = -1;
  end
  
  ChronoBars.MoveBar( id, offset );
  
end

function ChronoBars.MenuFunc_BarMoveDown (id, value)

  local profile = ChronoBars.GetActiveProfile();
  local group = profile.groups[ id.groupId ];
  
  local offset = 0;
  if (group.grow == ChronoBars.GROW_UP) then
    offset = -1;
  elseif (group.grow == ChronoBars.GROW_DOWN) then
    offset = 1;
  end

  ChronoBars.MoveBar( id, offset );
  
end

--New and Delete functions
--=============================================================

function ChronoBars.MenuFunc_NewBar (id, value)
  ChronoBars.Debug( "Adding bar" );
  
  --Find bar that was right-clicked
  local profile = ChronoBars.GetActiveProfile();
  local curBar = profile.groups[ id.groupId ].bars[ id.barId ];
  
  --Create new bar and clone style from current bar
  local newBar = CopyTable( ChronoBars.DEFAULT_BAR );
  newBar.style = CopyTable( curBar.style );
  table.insert( profile.groups[ id.groupId ].bars, newBar );
  
  ChronoBars.UpdateSettings();
  ChronoBars.CloseBarMenu( id );
end


function ChronoBars.MenuFunc_DeleteBar (id, value)
  local name = ChronoBars.GetSettingsValue( id, "bar|name" );
  ChronoBars.ShowConfirmFrame( "Are you sure you want to remove bar '"..tostring(name).."'?",
    ChronoBars.DeleteBar_Accept, nil, { ["id"]=id, ["value"]=value } );
  ChronoBars.CloseBarMenu( id );
end

function ChronoBars.DeleteBar_Accept (arg)
  ChronoBars.Debug( "Removing bar "..tostring(arg.id.groupId)..","..tostring(arg.id.barId) );
  
  local id = arg.id;
  local profile = ChronoBars.GetActiveProfile();
  if (table.getn( profile.groups[ id.groupId ].bars ) <= 1) then return end
  table.remove( profile.groups[ id.groupId ].bars, id.barId );
  ChronoBars.UpdateSettings();
  
end


function ChronoBars.MenuFunc_NewGroup (id, value)
  ChronoBars.Debug( "Adding group" );
  
  --Find bar and group that was right-clicked
  local profile = ChronoBars.GetActiveProfile();
  local curBar = profile.groups[ id.groupId ].bars[ id.barId ];
  local curGroup = profile.groups[ id.groupId ];
  
  --Create new group and clone style from current bar to its first bar
  local newGroup = CopyTable( ChronoBars.DEFAULT_GROUP );
  ChronoBars.CopyGroup( curGroup );
  ChronoBars.PasteGroup( newGroup );
  newGroup.bars[1].style = CopyTable( curBar.style );
  table.insert( profile.groups, newGroup);
  
  ChronoBars.UpdateSettings();
  ChronoBars.CloseBarMenu( id );
end


function ChronoBars.MenuFunc_DeleteGroup (id, value)
  ChronoBars.ShowConfirmFrame( "Are you sure you want to delete this group?",
    ChronoBars.DeleteGroup_Accept, nil, { ["id"]=id, ["value"]=value } );
  ChronoBars.CloseBarMenu( id );
end

function ChronoBars.DeleteGroup_Accept (arg)
  ChronoBars.Debug( "Removing group "..tostring(arg.id.groupId) );

  local id = arg.id;
  local profile = ChronoBars.GetActiveProfile();
  if (table.getn( profile.groups ) <= 1) then return end
  table.remove( profile.groups, id.groupId );
  ChronoBars.UpdateSettings();
  
end

--Profile handlers
--=============================================================

function ChronoBars.MenuFunc_LinkProfile (id, value)
  local profileName = ChronoBars_CharSettings.activeProfile;
  local spec = GetActiveTalentGroup( false, false );

  local specName;
  if (spec == 1)
  then specName = "primary";
  else specName = "secondary";
  end
  
  CB.ShowConfirmFrame( "Are you sure you want to link profile '"
    .. profileName .. "' to your " .. specName .. " talents?",
    CB.LinkProfile_Accept );
  CB.CloseBarMenu( id );
end


function ChronoBars.LinkProfile_Accept (arg)
  ChronoBars.Debug ( "Linking profile to current spec" );
  
  local profileName = ChronoBars_CharSettings.activeProfile;
  local spec = GetActiveTalentGroup( false, false );
  
  if (spec == 1)
  then ChronoBars_CharSettings.primaryProfile = profileName;
  else ChronoBars_CharSettings.secondaryProfile = profileName;
  end
end


function ChronoBars.VarFunc_MenuSwitchProfile_Get (id)
  ChronoBars.Debug( "Switch Profile menu" );

  local submenu = {};
  table.insert( submenu, { type="title", title="Switch To" } );

  for name,profile in pairs( ChronoBars_Settings.profiles) do
    if (profile ~= nil) then

      table.insert( submenu, { text=name, type="option", var="func|VarFunc_SwitchProfile", option=name } );
    end
  end
  return submenu;
end

function ChronoBars.VarFunc_MenuCopyProfile_Get (id)
  ChronoBars.Debug( "Copy Profile menu" );

  local submenu = {};
  table.insert( submenu, { type="title", title="Copy From" } );

  for name,profile in pairs( ChronoBars_Settings.profiles) do
    if (name ~= ChronoBars_CharSettings.activeProfile) then
      if (profile ~= nil) then

        table.insert( submenu, { text=name, type="func", func="MenuFunc_CopyProfile", value=name } );
      end
    end
  end
  return submenu;
end


function ChronoBars.VarFunc_SwitchProfile_Get (id)

  --Check option against current profile
  return ChronoBars_CharSettings.activeProfile;

end

function ChronoBars.VarFunc_SwitchProfile_Set (id, value)
  ChronoBars.Debug( "Switching to profile '"..value.."'" );
  
  --Check for invalid profile
  if (ChronoBars_Settings.profiles[ value ] == nil) then
    ChronoBars.Debug( "Selected profile doesn't exist!" );
    return
  end
  
  --Switch to selected profile
  ChronoBars_CharSettings.activeProfile = value;
  ChronoBars.UpdateSettings();
  ChronoBars.CloseBarMenu( id );

end


function ChronoBars.MenuFunc_CopyProfile (id, value)
  ChronoBars.ShowConfirmFrame( "Are you sure you want to copy profile?",
    ChronoBars.CopyProfile_Accept, nil, { ["id"]=id, ["value"]=value } );
  ChronoBars.CloseBarMenu( id );
end

function ChronoBars.CopyProfile_Accept (arg)
  ChronoBars.Debug( "Copying from profile '"..arg.value.."'" );
  
  --Check for invalid profile
  if (ChronoBars_Settings.profiles[ arg.value ] == nil) then
    ChronoBars.Debug( "Selected profile doesn't exist!" );
    return
  end
  
  --Copy settings to current profile
  local pname = ChronoBars_CharSettings.activeProfile;
  ChronoBars_Settings.profiles[ pname ] =
    CopyTable( ChronoBars_Settings.profiles[ arg.value ] );
  ChronoBars.UpdateSettings();
  
end


function ChronoBars.VarFunc_RenameProfile_Get (id)
  return ChronoBars_CharSettings.activeProfile;
end

function ChronoBars.VarFunc_RenameProfile_Set (id, newName)
  CB.Debug( "Renaming profile to '"..newName.."'" );

  --Check for existing profile
  if (ChronoBars_Settings.profiles[ newName ] ~= nil) then
    CB.Print( "Cannot rename profile. Another profile with this name exists!" );
    return;
  end
  
  --Change the name of the profile
  local oldName = ChronoBars_CharSettings.activeProfile;
  ChronoBars_Settings.profiles[ newName ] = ChronoBars_Settings.profiles[ oldName ];
  ChronoBars_Settings.profiles[ oldName ] = nil;
  ChronoBars_CharSettings.activeProfile = newName;
  
  if (ChronoBars_CharSettings.primaryProfile == oldName) then
    ChronoBars_CharSettings.primaryProfile = newName;
  end
  
  if (ChronoBars_CharSettings.secondaryProfile == oldName) then
    ChronoBars_CharSettings.secondaryProfile = newName;
  end
  
end


function ChronoBars.VarFunc_NewProfile_Get (id)
  return "NewProfile";
end

function ChronoBars.VarFunc_NewProfile_Set (id, value)
  ChronoBars.Debug( "Making new profile '"..value.."'" );
  
  --Check for bad value
  if (value == nil or value == "") then return end

  --Check for existing profile
  if (ChronoBars_Settings.profiles[ value ] ~= nil) then
    ChronoBars.Debug( "Profile with this name already exists!" );
    return
  end
  
  --Add new profile and switch to it
  ChronoBars_Settings.profiles[ value ] = CopyTable( ChronoBars.DEFAULT_PROFILE );
  ChronoBars_CharSettings.activeProfile = value;
  ChronoBars.UpdateSettings();
  ChronoBars.CloseBarMenu( id );
  
end


function ChronoBars.MenuFunc_DeleteProfile (id, value)
  local name = ChronoBars_CharSettings.activeProfile;
  ChronoBars.ShowConfirmFrame( "Are you sure you want to delete profile '"..tostring(name).."'?",
    ChronoBars.DeleteProfile_Accept, nil, { ["id"]=id, ["value"]=value } );
  ChronoBars.CloseBarMenu( id );
end

function ChronoBars.DeleteProfile_Accept (arg)
  ChronoBars.Debug( "Deleting current profile" );
  
  --Check if existing profile is default
  local pname = ChronoBars_CharSettings.activeProfile;
  if (pname == "Default") then
    ChronoBars.Print( "Cannot delete default profile!" );
    return;
  end
  
  --Delete profile and switch to default
  ChronoBars_Settings.profiles[ pname ] = nil;
  ChronoBars_CharSettings.activeProfile = "Default";
  ChronoBars.UpdateSettings();
  
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
