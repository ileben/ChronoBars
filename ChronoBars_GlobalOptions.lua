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
	{ type="button",   text="New Bar",            func="root|Func_BarNew",     close=true },
	{ type="button",   text="Delete Bar",         func="root|Func_BarDelete",  close=true },
	
	{ type="header",   text="Group management" },
	{ type="button",   text="New Group",            func="root|Func_GroupNew",    close=true },
	{ type="button",   text="Delete Group",         func="root|Func_GroupDelete", close=true },
	
	{ type="header",   text="Bar settings" },
	{ type="button",   text="Move Up",            func="root|Func_BarMoveUp" },
	{ type="button",   text="Move Down",          func="root|Func_BarMoveDown" },
	
	{ type="options",  text="Copy/Paste",         options="root|Options_BarCopyPaste" },
	{ type="button",   text="Copy",               func="root|Func_BarCopy" },
	{ type="button",   text="Paste",              func="root|Func_BarPaste" },
	
	{ type="header",   text="Group settings" },
	{ type="button",   text="Copy",        func="root|Func_GroupCopy" },
	{ type="button",   text="Paste",       func="root|Func_GroupPaste" },
};

ChronoBars.Options_BarCopyPaste =
{
	{ text="Front Color",              var="temp|color",       value="bar|style.fgColor" },
	{ text="Back Color",               var="temp|color",       value="bar|style.bgColor" },
	{ text="Text Color",               var="temp|color",       value="bar|style.textColor" },
	{ text="Texture",                  var="temp|tex",         value="bar|style.lsmTexHandle" },
	{ text="Font",                     var="temp|font",        value="bar|style.lsmFontHandle" },
	{ text="Font Size",                var="temp|fontSize",    value="bar|style.fontSize" },
	{ text="Visibility",               var="temp|visibility",  value="bar|style.visibility" },
	{ text="Animation",                var="temp|anim",        value="bar|style.anim" },
	{ text="Entire Style",             var="temp|style",       value="bar|style" },
	{ text="Style Except Front Color", var="temp|style",       value="bar|style" },
	{ text="All Bar Settings" },
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


--Profile

ChronoBars.Frame_Profile =
{
  { type="header",                  text="Profile Settings" },
};


--Text functions

function ChronoBars.Options_Text_Get()

	local options = {};
	
	local profile = CB.GetActiveProfile();
	local bar = profile.groups[ CB.MenuId.groupId ].bars[ CB.MenuId.barId ];
	
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
end

function ChronoBars.Func_BarPaste()
end

function ChronoBars.Func_GroupCopy()
end

function ChronoBars.Func_GroupPaste()
end

--Bar movement

function ChronoBars.Func_BarMoveUp()

  local id = CB.MenuId;
  
  local profile = ChronoBars.GetActiveProfile();
  local group = profile.groups[ id.groupId ];
  
  local offset = 0;
  if (group.grow == ChronoBars.GROW_UP) then
    offset = 1;
  elseif (group.grow == ChronoBars.GROW_DOWN) then
    offset = -1;
  end
  
  ChronoBars.MoveBar( offset );
  
end

function ChronoBars.Func_BarMoveDown()

  local id = CB.MenuId;
  
  local profile = ChronoBars.GetActiveProfile();
  local group = profile.groups[ id.groupId ];
  
  local offset = 0;
  if (group.grow == ChronoBars.GROW_UP) then
    offset = -1;
  elseif (group.grow == ChronoBars.GROW_DOWN) then
    offset = 1;
  end

  ChronoBars.MoveBar( offset );
  
end

function ChronoBars.MoveBar( offset )

  local id = CB.MenuId;
  
  local profile = ChronoBars.GetActiveProfile();
  local group = profile.groups[ id.groupId ];
  
  local newBarId = id.barId + offset;
  if (newBarId < 1) then return end;
  if (newBarId > table.getn( group.bars )) then return end;

  local tempBar = group.bars[ newBarId ];
  group.bars[ newBarId ] = group.bars[ id.barId ];
  group.bars[ id.barId ] = tempBar;

  ChronoBars.UpdateSettings();
  CB.MenuId.barId = newBarId;
  
end

--Bar/Group management

function ChronoBars.Func_BarNew()
	local id = CB.MenuId;

	--Find bar that was right-clicked
	local profile = ChronoBars.GetActiveProfile();
	local curBar = profile.groups[ id.groupId ].bars[ id.barId ];

	--Create new bar and clone style from current bar
	local newBar = CopyTable( ChronoBars.DEFAULT_BAR );
	newBar.style = CopyTable( curBar.style );
	table.insert( profile.groups[ id.groupId ].bars, newBar );

	ChronoBars.UpdateSettings();
end

function ChronoBars.Func_BarDelete()
	local id = CB.MenuId;

	--Confirm with user
	local name = ChronoBars.GetSettingsValue( "bar|name" );
	ChronoBars.ShowConfirmFrame( "Are you sure you want to remove bar '"..tostring(name).."'?",
		ChronoBars.DeleteBar_Accept, nil, { ["id"]=id, ["value"]=value } );
	
end

function ChronoBars.Func_GroupNew()
	local id = CB.MenuId;

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
end

function ChronoBars.Func_GroupDelete()
	local id = CB.MenuId;
	
	--Confirm with user
	ChronoBars.ShowConfirmFrame( "Are you sure you want to delete this group?",
		ChronoBars.DeleteGroup_Accept, nil, { ["id"]=id, ["value"]=value } );
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
	CB.SetEnv( item.tabs.."Selection", tabFrame:GetSelectedIndex() );
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
	
	CB.SetSettingsValue( item.var, newValue );
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
		CB.CloseBarConfig();
	end
end

--Initialization
--===================================================

function ChronoBars.UpdateBarConfig()

	CB.FreeAllObjects();
	--CB.configFrame:RemoveAllChildren();
	--CB.Config_Construct( CB.configFrame, CB.Frame_Root );
	
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


