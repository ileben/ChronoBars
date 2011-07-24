--[[

====================================================
ChronoBars - buff, debuff, cooldown, totem tracker
Author: Ivan Leben
====================================================

--]]

local CB = ChronoBars;

-- Define constants
--==============================================================

ChronoBars.MSG_PREFIX = "<ChronoBars>";

ChronoBars.BLACKLIST_TIMER_INTERVAL = 0.5;

ChronoBars.EFFECT_TYPE_AURA         = 1;
ChronoBars.EFFECT_TYPE_CD           = 2;
ChronoBars.EFFECT_TYPE_INTERNAL_CD  = 3;
ChronoBars.EFFECT_TYPE_TOTEM        = 4;
ChronoBars.EFFECT_TYPE_USABLE       = 5;
ChronoBars.EFFECT_TYPE_CUSTOM       = 6;
ChronoBars.EFFECT_TYPE_MULTI_AURA   = 7;
ChronoBars.EFFECT_TYPE_AUTO         = 8;
ChronoBars.EFFECT_TYPE_ENCHANT      = 9;

ChronoBars.AURA_UNIT_PLAYER          = "player";
ChronoBars.AURA_UNIT_TARGET          = "target";
ChronoBars.AURA_UNIT_TARGET_TARGET   = "targettarget";
ChronoBars.AURA_UNIT_FOCUS           = "focus";
ChronoBars.AURA_UNIT_FOCUS_TARGET    = "focustarget";
ChronoBars.AURA_UNIT_PET             = "pet";
ChronoBars.AURA_UNIT_PET_TARGET      = "pettarget";

ChronoBars.AURA_TYPE_BUFF    = "HELPFUL";
ChronoBars.AURA_TYPE_DEBUFF  = "HARMFUL";

ChronoBars.CD_TYPE_SPELL      = 1;
ChronoBars.CD_TYPE_PET_SPELL  = 2;
ChronoBars.CD_TYPE_ITEM       = 3;

ChronoBars.USABLE_TYPE_SPELL      = 1;
ChronoBars.USABLE_TYPE_PET_SPELL  = 2;
ChronoBars.USABLE_TYPE_ITEM       = 3;

ChronoBars.TOTEM_TYPE_FIRE    = 1;
ChronoBars.TOTEM_TYPE_EARTH   = 2;
ChronoBars.TOTEM_TYPE_WATER   = 3;
ChronoBars.TOTEM_TYPE_AIR     = 4;

ChronoBars.CUSTOM_TRIGGER_SPELL_CAST = 1;
ChronoBars.CUSTOM_TRIGGER_BAR_ACTIVE = 2;

ChronoBars.AUTO_TYPE_MAIN_HAND   = 1;
ChronoBars.AUTO_TYPE_OFF_HAND    = 2;
ChronoBars.AUTO_TYPE_WAND        = 3;
ChronoBars.AUTO_TYPE_BOW         = 4;

ChronoBars.HAND_MAIN  = 1;
ChronoBars.HAND_OFF   = 2;

ChronoBars.SIDE_LEFT    = 1;
ChronoBars.SIDE_RIGHT   = 2;

ChronoBars.JUSTIFY_LEFT   = 1;
ChronoBars.JUSTIFY_CENTER = 2;
ChronoBars.JUSTIFY_RIGHT  = 3;

ChronoBars.TIME_SINGLE   = 1;
ChronoBars.TIME_DECIMAL  = 2;
ChronoBars.TIME_MINSEC   = 3;

ChronoBars.LAYOUT_KEEP      = 1;
ChronoBars.LAYOUT_STACK     = 2;
ChronoBars.LAYOUT_PRIORITY  = 3;

ChronoBars.GROW_UP     = 1;
ChronoBars.GROW_DOWN   = 2;

ChronoBars.VISIBLE_ALWAYS   = 1;
ChronoBars.VISIBLE_ACTIVE   = 2;

ChronoBars.SORT_NONE        = 1;
ChronoBars.SORT_ASCENDING   = 2;
ChronoBars.SORT_DESCENDING  = 3;

ChronoBars.POS_IN_LEFT      = 1;
ChronoBars.POS_IN_CENTER    = 2;
ChronoBars.POS_IN_RIGHT     = 3;
ChronoBars.POS_ABOVE_LEFT   = 4;
ChronoBars.POS_ABOVE_CENTER = 5;
ChronoBars.POS_ABOVE_RIGHT  = 6;
ChronoBars.POS_BELOW_LEFT   = 7;
ChronoBars.POS_BELOW_CENTER = 8;
ChronoBars.POS_BELOW_RIGHT  = 9;
ChronoBars.POS_LEFT_TOP     = 10;
ChronoBars.POS_LEFT_MIDDLE  = 11;
ChronoBars.POS_LEFT_BOTTOM  = 12;
ChronoBars.POS_RIGHT_TOP    = 13;
ChronoBars.POS_RIGHT_MIDDLE = 14;
ChronoBars.POS_RIGHT_BOTTOM = 15;


-- Define defaults
--=========================================================

ChronoBars.DEFAULT_TEXT =
{
  enabled     = true,
  name        = "NewText",
  format      = "$e",
  timeFormat  = CB.TIME_SINGLE,
  
  position    = CB.POS_IN_CENTER,
  x           = 0,
  y           = 0,
  
  font        = "Friz Quadrata TT",
  size        = 12,
  outline     = false,
  
  textColor   = { r = 1.0, g = 1.0, b = 1.0, a = 1.0 },
  shadowColor = { r = 0.0, g = 0.0, b = 0.0, a = 1.0 },
  
  default     = true,
};

ChronoBars.PRESET_TEXT_EFFECT = CB.Util_MergeTables( CB.DEFAULT_TEXT, 
{
  enabled    = true,
  name       = "Effect name",
  format     = "$e",
  position   = CB.POS_IN_LEFT,
});

ChronoBars.PRESET_TEXT_INFO = CB.Util_MergeTables( CB.DEFAULT_TEXT,
{
	enabled  = false,
	name     = "Usable/CD",
	format   = "$u",
	position = CB.POS_IN_LEFT,
});

ChronoBars.PRESET_TEXT_COUNT = CB.Util_MergeTables( CB.DEFAULT_TEXT,
{
  enabled    = true,
  name       = "Stack count",
  format     = "[$c]",
  position   = CB.POS_IN_LEFT,
});

ChronoBars.PRESET_TEXT_TIME_LEFT = CB.Util_MergeTables( CB.DEFAULT_TEXT,
{
  enabled    = true,
  name       = "Time left",
  format     = "$l",
  position   = CB.POS_IN_RIGHT,
});

ChronoBars.PRESET_TEXT_TIME_TOTAL = CB.Util_MergeTables( CB.DEFAULT_TEXT,
{
  enabled    = false,
  name       = "Total duration",
  format     = "$d",
  position   = CB.POS_IN_RIGHT,
});

ChronoBars.PRESET_TEXT_TARGET = CB.Util_MergeTables( CB.DEFAULT_TEXT,
{
  enabled    = false,
  name       = "Target name",
  format     = "$t",
  position   = CB.POS_IN_LEFT,
});

ChronoBars.DEFAULT_BAR =
{
  enabled     = true,
  name        = "Effect",
  type        = ChronoBars.EFFECT_TYPE_AURA,
  aura        = {
                  unit = ChronoBars.AURA_UNIT_PLAYER,
                  type = ChronoBars.AURA_TYPE_BUFF,
                  byPlayer = false,
                  sum = false,
                  order = 1,
                },
  cd          = {
                  type = ChronoBars.CD_TYPE_SPELL,
                },
  usable      = {
                  type = ChronoBars.USABLE_TYPE_SPELL,
                  includeCd = true,
                },
  totem       = {
                  type = ChronoBars.TOTEM_TYPE_FIRE,
                },
  custom      = {
                  trigger = ChronoBars.CUSTOM_TRIGGER_SPELL_CAST,
                  duration = 0,
                },
  auto        = {
                  type = ChronoBars.AUTO_TYPE_MAIN_HAND,
                },
  enchant     = {
                  hand = ChronoBars.HAND_MAIN,
                },
  fixed       = {
                  enabled = false,
                  duration = 0,
                },
  style       = {
				
				fullSide       = CB.SIDE_RIGHT,
				fillUp         = false,
				fgColor        = { r = 0.0, g = 0.4, b = 0.8, a = 1.0 },
				bgColor        = { r = 0.0, g = 0.0, b = 0.0, a = 0.7 },
				lsmTexHandle   = "None",
				
				text =  {
							CB.PRESET_TEXT_EFFECT,
							CB.PRESET_TEXT_TARGET,
							CB.PRESET_TEXT_INFO,
							CB.PRESET_TEXT_COUNT,
							CB.PRESET_TEXT_TIME_LEFT,
							CB.PRESET_TEXT_TIME_TOTAL,
				        },
				
				icon =  {
							enabled = true,
							position = CB.POS_LEFT_MIDDLE,
							x = 0,
							y = 0,
							zoom = true,
							size = 20,
							padding = 0,
							bgColor = { r = 0.0, g = 0.0, b = 0.0, a = 0.7 },
							inherit = true,
				        },
				
				spark = {
							enabled = true,
							width = 20,
							height = 1.8,
						},
				
				anim  = {
							up = true,
							down = true,
							blinkSlow = true,
							blinkFast = true,
							blinkUsable = true,
							fade = true,
						},
				
				visibility  = CB.VISIBLE_ACTIVE,
				
				},
};

--[[
ChronoBars.DEFAULT_BAR =
{
  enabled     = true,
  name        = "Effect",
  type        = ChronoBars.EFFECT_TYPE_AURA,
  aura        = {
                  unit = ChronoBars.AURA_UNIT_PLAYER,
                  type = ChronoBars.AURA_TYPE_BUFF,
                  byPlayer = false,
                  sum = false,
                  order = 1,
                },
  cd          = {
                  type = ChronoBars.CD_TYPE_SPELL,
                },
  usable      = {
                  type = ChronoBars.USABLE_TYPE_SPELL,
                  includeCd = true,
                },
  totem       = {
                  type = ChronoBars.TOTEM_TYPE_FIRE,
                },
  custom      = {
                  trigger = ChronoBars.CUSTOM_TRIGGER_SPELL_CAST,
                  duration = 0,
                },
  auto        = {
                  type = ChronoBars.AUTO_TYPE_MAIN_HAND,
                },
  enchant     = {
                  hand = ChronoBars.HAND_MAIN,
                },
  display     = {
                  enabled = false,
                  name = "DisplayName",
                },
  fixed       = {
                  enabled = false,
                  duration = 0,
                },
  style       = {
                  showName       = true,
                  showIcon       = true,
                  showTime       = true,
                  showCount      = true,
                  showCd         = true,
                  showUsable     = true,
                  showSpark      = true,
                  nameJustify    = ChronoBars.JUSTIFY_LEFT,
                  timeSide       = ChronoBars.SIDE_RIGHT,
                  countSide      = ChronoBars.SIDE_RIGHT,
                  fullSide       = ChronoBars.SIDE_RIGHT,
                  iconSide       = ChronoBars.SIDE_LEFT,
                  iconZoom       = true,
                  fillUp         = false,
                  fgColor        = { r = 0.0, g = 0.4, b = 0.8, a = 1.0 },
                  bgColor        = { r = 0.0, g = 0.0, b = 0.0, a = 0.7 },
                  textColor      = { r = 1.0, g = 1.0, b = 1.0, a = 1.0 },
                  fontSize       = 12,
                  sparkHeight    = 1.8,
                  sparkWidth     = 20,
                  timeFormat     = ChronoBars.TIME_SINGLE,
                  lsmFontHandle  = "Friz Quadrata TT",
                  lsmTexHandle   = "None",
                  visibility  = ChronoBars.VISIBLE_ACTIVE,
                  anim  = {
                            up = true,
                            down = true,
                            blinkSlow = true,
                            blinkFast = true,
                            blinkUsable = true,
                            fade = true,
                          },
                },
};
--]]
ChronoBars.DEFAULT_GROUP = {
  bars         = {},
  x            = 0,
  y            = 0,
  width        = 200,
  height       = 20,
  padding      = 0,
  spacing      = 0,
  margin       = 5,
  grow         = ChronoBars.GROW_UP,
  layout       = ChronoBars.LAYOUT_STACK,
  sorting      = ChronoBars.SORT_NONE,
  style        = {
                   bgColor      = { r = 0.0, g = 0.0, b = 0.0, a = 0.0 },
                 },
};

ChronoBars.DEFAULT_PROFILE = {
  groups       = {},
};

ChronoBars.DEFAULT_SETTINGS = {
  version         = ChronoBars.VERSION,
  updateInterval  = 0.03,
  debugEnabled    = false,
  profiles        = {},
}

ChronoBars.DEFAULT_CHAR_SETTINGS = {
  version          = ChronoBars.VERSION,
  activeProfile    = "Default",
  primaryProfile   = nil,
  secondaryProfile = nil,
}


table.insert( ChronoBars.DEFAULT_GROUP.bars, ChronoBars.DEFAULT_BAR );
table.insert( ChronoBars.DEFAULT_PROFILE.groups, ChronoBars.DEFAULT_GROUP );
ChronoBars.DEFAULT_SETTINGS.profiles[ "Default" ] = ChronoBars.DEFAULT_PROFILE;

