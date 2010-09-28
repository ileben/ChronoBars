--[[

====================================================
ChronoBars - buff, debuff, cooldown, totem tracker
Author: Ivan Leben
====================================================

--]]

ChronoBars = {}
local CB = ChronoBars;

ChronoBars.VERSION = "1.9";
ChronoBars.UPGRADE_LIST = { "1.2","1.3","1.4","1.5","1.6","1.8", "1.9" };

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


-- Define defaults
--=========================================================

ChronoBars.DEFAULT_BAR = {
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
                            blink = true,
                            blinkUsable = true,
                            fade = true,
                          },
                },
};

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


--Upgrade functions
--=====================================================

-- 1.2

function ChronoBars.Upgrade_1_2 ()

  if (ChronoBars_Settings.updateInterval == nil) then
    ChronoBars_Settings.updateInterval = 0.03;
  end
  
  for pname, profile in pairs( ChronoBars_Settings.profiles ) do
    for g=1,table.getn( profile.groups ) do
      for b=1,table.getn( profile.groups[g].bars ) do
      
        local bar = profile.groups[g].bars[b];
        
        if (bar.style.showCd == nil) then
          bar.style.showCd = bar.style.appendCd;
        end
        
        if (bar.style.showCount == nil) then
          bar.style.showCount = true;
        end
        
        if (bar.style.countSide == nil) then
          bar.style.countSide = ChronoBars.SIDE_RIGHT;
        end

        if (bar.style.lsmFontHandle == nil) then
          bar.style.lsmFontHandle  = "Friz Quadrata TT";
        end

        if (bar.style.lsmTexHandle == nil) then
          bar.style.lsmTexHandle   = "None";
        end
        
        if (bar.style.iconZoom == nil) then
          bar.style.iconZoom = true;
        end
        
      end
    end
  end
end

function ChronoBars.UpgradeChar_1_2 ()
end

-- 1.3

function ChronoBars.Upgrade_1_3 ()

  for pname, profile in pairs( ChronoBars_Settings.profiles ) do
    for g=1,table.getn( profile.groups ) do
      local grp = profile.groups[g];
      
      if (grp.style == nil) then
        grp.style = CopyTable( ChronoBars.DEFAULT_GROUP.style );
      end
      
      if (grp.margin == nil) then
        grp.margin = ChronoBars.DEFAULT_GROUP.margin;
      end

      for b=1,table.getn( profile.groups[g].bars ) do
        local bar = profile.groups[g].bars[b];
        
      end
    end
  end
end

function ChronoBars.UpgradeChar_1_3 ()
end


-- 1.4

function ChronoBars.Upgrade_1_4 ()

  for pname, profile in pairs( ChronoBars_Settings.profiles ) do
    for g=1,table.getn( profile.groups ) do
      local grp = profile.groups[g];

      for b=1,table.getn( profile.groups[g].bars ) do
        local bar = profile.groups[g].bars[b];

        if (bar.aura.order == nil) then
          bar.aura.order = 1;
        end
        
        if (bar.usable == nil) then
          bar.usable = CopyTable( CB.DEFAULT_BAR.usable );
        end
        
        if (bar.style.showUsable == nil) then
          bar.style.showUsable = true;
        end
        
      end
    end
  end
end

function ChronoBars.UpgradeChar_1_4 ()
end


-- 1.5

function ChronoBars.Upgrade_1_5 ()

  if (ChronoBars_Settings.updateInterval == 0.03) then
    ChronoBars_Settings.updateInterval = 0.01;
  end
  
  for pname, profile in pairs( ChronoBars_Settings.profiles ) do
    for g=1,table.getn( profile.groups ) do
      local grp = profile.groups[g];

      for b=1,table.getn( profile.groups[g].bars ) do
        local bar = profile.groups[g].bars[b];
        
        if (bar.display == nil) then
          bar.display = CopyTable( CB.DEFAULT_BAR.display );
        end
        
        if (bar.custom == nil) then
          bar.custom = CopyTable( CB.DEFAULT_BAR.custom );
        end
        
        if (bar.type == CB.EFFECT_TYPE_INTERNAL_CD) then
          bar.type = CB.EFFECT_TYPE_CUSTOM;
          bar.custom.trigger = CB.CUSTOM_TRIGGER_BAR_ACTIVE;
          bar.custom.duration = bar.internal.duration;
        end
        
        if (bar.style.showSpark == nil) then
          bar.style.showSpark = true;
        end
        
        if (bar.style.anim == nil) then
          bar.style.anim = CopyTable( CB.DEFAULT_BAR.style.anim );
        end
        
        if (bar.style.anim.blinkUsable == nil) then
          bar.style.anim.blinkUsable = true;
        end
        
      end
    end
  end
end

function ChronoBars.UpgradeChar_1_5 ()
end

-- 1.6

function ChronoBars.Upgrade_1_6 ()

  for pname, profile in pairs( ChronoBars_Settings.profiles ) do
    for g=1,table.getn( profile.groups ) do
      local grp = profile.groups[g];
      
      if (grp.sorting == nil) then
        grp.sorting = CB.DEFAULT_GROUP.sorting;
      end

      for b=1,table.getn( profile.groups[g].bars ) do
        local bar = profile.groups[g].bars[b];
        
        if (bar.style.sparkHeight == nil) then
          bar.style.sparkHeight = CB.DEFAULT_BAR.style.sparkHeight;
        end
        
        if (bar.style.sparkWidth == nil) then
          bar.style.sparkWidth = CB.DEFAULT_BAR.style.sparkWidth;
        end
        
        if (bar.style.visibility == nil) then
          bar.style.visibility = CB.DEFAULT_BAR.style.visibility;
        end
        
      end
    end
  end
end

function ChronoBars.UpgradeChar_1_6 ()
end

-- 1.8

function ChronoBars.Upgrade_1_8 ()

  for pname, profile in pairs( ChronoBars_Settings.profiles ) do
    for g=1,table.getn( profile.groups ) do
      local grp = profile.groups[g];

      for b=1,table.getn( profile.groups[g].bars ) do
        local bar = profile.groups[g].bars[b];

        if (bar.enabled == nil) then
          bar.enabled = true;
        end
        
      end
    end
  end
end

function ChronoBars.UpgradeChar_1_8 ()
end

-- 1.9

function ChronoBars.Upgrade_1_9 ()

  for pname, profile in pairs( ChronoBars_Settings.profiles ) do
    for g=1,table.getn( profile.groups ) do
      local grp = profile.groups[g];

      for b=1,table.getn( profile.groups[g].bars ) do
        local bar = profile.groups[g].bars[b];

        if (bar.auto == nil) then
          bar.auto = CopyTable( ChronoBars.DEFAULT_BAR.auto );
        end
        
        if (bar.enchant == nil) then
          bar.enchant = CopyTable( ChronoBars.DEFAULT_BAR.enchant );
        end
        
      end
    end
  end
end

function ChronoBars.UpgradeChar_1_9 ()
end


-- Check for upgrade

function ChronoBars.CheckSettings()
   
  --Check if global settings missing (first time use)
  if (not ChronoBars_Settings) then
    ChronoBars.Print( "Applying default settings" );
    ChronoBars_Settings = CopyTable( ChronoBars.DEFAULT_SETTINGS );
  end
  
  --Check if character settings missing (first time use)
  if (not ChronoBars_CharSettings) then
    ChronoBars.Print( "Applying default character settings" );
    ChronoBars_CharSettings = CopyTable( ChronoBars.DEFAULT_CHAR_SETTINGS );
    
    --Create profile for this character first time if missing
    local playerName = UnitName( "player" );
    if (ChronoBars_Settings.profiles[ playerName ] == nil) then
      ChronoBars_Settings.profiles[ playerName ] = CopyTable( ChronoBars.DEFAULT_PROFILE );
    end
    
    --Switch to profile with this character name
    ChronoBars_CharSettings.activeProfile = playerName;
  end
  
  --Check for old settings version
  local curVersion = ChronoBars_Settings.version;
  for i=1,table.getn( ChronoBars.UPGRADE_LIST ) do
    
    local nextVersion = ChronoBars.UPGRADE_LIST[i];
    if (curVersion < nextVersion) then
      
      ChronoBars.Print( "Upgrading settings from version "
        ..curVersion.." to "..nextVersion );
      
      local verString = string.gsub( nextVersion, "[.]", "_" );
      local funcName = "Upgrade_"..verString;
      local func = ChronoBars[ funcName ];
      
      if (func) then func() else
        ChronoBars.Print( "Missing upgrade function!" );
      end
      
      curVersion = nextVersion;
    end
  end
  
  --Check for old char settings version
  local curVersion = ChronoBars_CharSettings.version;
  for i=1,table.getn( ChronoBars.UPGRADE_LIST ) do
    
    local nextVersion = ChronoBars.UPGRADE_LIST[i];
    if (curVersion < nextVersion) then
      
      ChronoBars.Print( "Upgrading character settings from version "
        ..curVersion.." to "..nextVersion );
      
      local verString = string.gsub( nextVersion, "[.]", "_" );
      local funcName = "UpgradeChar_"..verString;
      local func = ChronoBars[ funcName ];
      
      if (func) then func() else
        ChronoBars.Print( "Missing upgrade function!" );
      end
      
      curVersion = nextVersion;
    end
  end

  --Set to latest version
  ChronoBars_Settings.version = ChronoBars.VERSION;
  ChronoBars_CharSettings.version = ChronoBars.VERSION;
  
  --Switch to default profile if active profile is missing
  if (ChronoBars_Settings.profiles[ ChronoBars_CharSettings.activeProfile ] == nil) then
    ChronoBars_CharSettings.activeProfile = "Default";
  end
  
end


function ChronoBars.GetActiveProfile ()
  return ChronoBars_Settings.profiles[ ChronoBars_CharSettings.activeProfile ];
end


-- LibSharedMedia support
--===================================================

ChronoBars.LSM = LibStub("LibSharedMedia-3.0", true);


--Output functions
--===================================================

function ChronoBars.Print (msg)
  print( "|cffffff00"..ChronoBars.MSG_PREFIX.." |cffffffff"..msg );
end

function ChronoBars.Debug (msg)
  if not ChronoBars_Settings.debugEnabled then return end
  print( "|cffff0000"..ChronoBars.MSG_PREFIX.." |cffffffff"..msg );
end

--Slash handler
--===================================================

function ChronoBars.SlashHandler (msg)

  if (msg == "") then
    if (ChronoBars.designMode) then
      ChronoBars.Print( "Switching to |cff00ff00RUN |cffffffffmode" );
      ChronoBars.ModeRun();
    else
      ChronoBars.Print( "Switching to |cffff0000SETUP |cffffffffmode" );
      ChronoBars.ModeDesign();
    end

  elseif (msg == "debug") then
    ChronoBars_Settings.debugEnabled = true;
    ChronoBars.Print( "Debug output |cff00ff00enabled" );

  elseif (msg == "nodebug") then
    ChronoBars_Settings.debugEnabled = false;
    ChronoBars.Print( "Debug output |cffff0000disabled" );

  else

    local cmd, param = strsplit( " ", msg );
    if (cmd and param) then

      if (cmd == "update") then

        local interval = tonumber(param);
        if (interval and interval > 0) then
          ChronoBars.Print( "Setting update interval to "..tostring(interval) );
          ChronoBars_Settings.updateInterval = interval;
        end

      elseif (cmd == "reset") then

        if (param == "profile") then
          ChronoBars.ShowConfirmFrame( "Are you sure you want to reset current profile?",
            ChronoBars.ResetProfile_Accept );

        elseif (param == "groups") then
          ChronoBars.ShowConfirmFrame( "Are you sure you want to reset group positions?",
            ChronoBars.ResetGroups_Accept );
        end
      end
    end
  end
end

SLASH_ChronoBars1 = "/chronobars";
SLASH_ChronoBars2 = "/cb";
SlashCmdList["ChronoBars"] = ChronoBars.SlashHandler;


--Initialization
--===================================================

function ChronoBars.MainFrame_OnEvent (self, event, ...)

  local handlerFnName = "MainFrame_" .. event;
  local handlerFn = ChronoBars[ handlerFnName ];
  if (handlerFn) then handlerFn(...) end
  
end

function ChronoBars.Init ()
  
  --The only purpose of main frame is to handle initialization events and global update
  ChronoBars.frame = CreateFrame( "Frame", "ChronoBars_MainFrame" );
  ChronoBars.frame:SetScript( "OnEvent", ChronoBars.MainFrame_OnEvent );
  ChronoBars.frame:RegisterEvent( "ADDON_LOADED" );
  ChronoBars.frame:RegisterEvent( "PLAYER_LOGIN" );
  ChronoBars.frame:RegisterEvent( "DISPLAY_SIZE_CHANGED" );
  ChronoBars.frame:RegisterEvent( "ACTIVE_TALENT_GROUP_CHANGED" );
  
  --Cache makes it possible to reuse UI elements
  CB.cache = {};
  CB.cache.bars = {};
  CB.cache.groups = {};
  CB.cache.numUsedBars = 0;
  CB.cache.numUsedGroups = 0;
  
  --Group/bar UI hierarchy
  CB.groups = {};

end

--Initialization flags
ChronoBars.initUI = false;
ChronoBars.initUpdate = false;
ChronoBars.lastUpdate = 0;
ChronoBars.designMode = false;

--Main entry point
ChronoBars.Init ();


--Events
--=====================================================

function ChronoBars.MainFrame_ADDON_LOADED( addonName, ... )

  --Check that it's really us being loaded
  if (addonName ~= "ChronoBars") then return end
  
  --Hmmmmmm doesn't seem to work correctly from here :/
  --ChronoBars.CheckSettings();
  
end

function ChronoBars.MainFrame_PLAYER_LOGIN (...)
  CB.CheckSettings();
  CB.ModeDesign();
  CB.ModeRun();
  CB.initUI = true;
end

function ChronoBars.MainFrame_DISPLAY_SIZE_CHANGED (...)
  if (ChronoBars.initUI) then
    CB.ModeDesign();
    CB.ModeRun();
  end
end

function ChronoBars.MainFrame_ACTIVE_TALENT_GROUP_CHANGED ()
  local spec = GetActiveTalentGroup( false, false );

  --Find name of the linked profile
  local specProfile = nil;
  if (spec == 1)
  then specProfile = ChronoBars_CharSettings.primaryProfile;
  else specProfile = ChronoBars_CharSettings.secondaryProfile;
  end

  --Check that profile is linked and exists
  if (specProfile ~= nil) then
    if (ChronoBars_Settings.profiles[ specProfile ] ~= nil) then
    
      --Switch to linked profile
      ChronoBars.Print( "Switching profile to '" .. specProfile .. "' to match spec." );
      ChronoBars_CharSettings.activeProfile = specProfile;
      CB.ModeDesign();
      CB.ModeRun();
    end
  end

end

--Mode
--=====================================================

function ChronoBars.ModeDesign ()

  CB.designMode = true;
  CB.UpdateSettings();
  
  --Disable all group updates
  for g=1,table.getn( CB.cache.groups ) do
    CB.Group_DisableUpdate( CB.cache.groups[g] );
  end
  
  --Disable all bar events
  for b=1,table.getn( CB.cache.bars) do
    CB.Bar_DisableEvents( CB.cache.bars[b] );
  end
  
end


function ChronoBars.ModeRun ()

  CB.designMode = false;
  CB.UpdateSettings();

  --Get the character's active profile
  local profile = ChronoBars.GetActiveProfile();

  --Walk UI groups
  local numGroups = table.getn( CB.groups );
  for g = 1, numGroups do
    
    --Walk UI bars
    local numBars = table.getn( CB.groups[g].bars );
    for b = 1, numBars do
    
      --Enable bar events if bar enabled
      if (CB.groups[g].bars[b].settings.enabled) then
        CB.Bar_EnableEvents( CB.groups[g].bars[b] );
        CB.Bar_OnEvent( CB.groups[g].bars[b], "CHRONOBARS_FORCE_UPDATE" );
      end
    end
    
    --Enable group updates
    CB.Group_EnableUpdate( CB.groups[g] );
    CB.Group_OnUpdate( CB.groups[g] );
  end
end

function ChronoBars.UpdateSettings ()
  
  --Update pixel-perfect state
  CB.FindPixelRatio();
  
  --Remove all groups and bars
  CB.UI_RemoveAllGroups();

  --Get the character's active profile
  local profile = CB.GetActiveProfile();

  --Walk profile groups
  for g = 1, table.getn( profile.groups ) do

    --Add new UI group
    local grp = CB.UI_AddGroup();

    --Walk profile bars
    for b = 1, table.getn( profile.groups[g].bars ) do
    
      --Only add disabled bars in design mode
      if (profile.groups[g].bars[b].enabled or CB.designMode) then
      
        --Add new UI bar
        local bar = CB.UI_AddBar( grp );

        --Apply bar settings
        CB.Bar_ApplySettings( bar, profile, g, b );
      end
    end

    --Apply group settings
    CB.Group_ApplySettings( grp, profile, g );
  end
end
