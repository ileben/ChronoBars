--[[

====================================================
ChronoBars - buff, debuff, cooldown, totem tracker
Author: Ivan Leben
====================================================

--]]

local CB = ChronoBars;


--Version control
--=================================================================================

function ChronoBars.CompareVersions (old, new)

  --Return false if both version the same
  if (new == old) then return false end
  
  --Walk through all the numbers in the version
  local newNumbers = { strsplit( ".", new ) };
  local oldNumbers = { strsplit( ".", old ) };
  for i=1,table.getn(newNumbers) do
    
    --New version is bigger if all previous numbers same
    --and new version has additional numbers to old one
    if (i > table.getn(oldNumbers)) then return true end
    
    --Convert both strings to numbers
    local newNum = tonumber( newNumbers[i] );
    local oldNum = tonumber( oldNumbers[i] );
    
    --New version is bigger or smaller if
    --current number is bigger or smaller
    if (newNum > oldNum) then return true end
    if (newNum < oldNum) then return false end
    
  end
  
  --Old version is bigger if all previous numbers same
  --and old version has additional numbers to new one
  return false;
end

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
    if (CB.CompareVersions( curVersion, nextVersion )) then

      CB.Print( "Upgrading settings from version "
        ..curVersion.." to "..nextVersion );
      
      local verString = string.gsub( nextVersion, "[.]", "_" );
      local funcName = "Upgrade_"..verString;
      local func = ChronoBars[ funcName ];
      
      if (func) then func() else
        CB.Print( "Missing upgrade function!" );
      end
      
      curVersion = nextVersion;
    end
  end
  
  --Check for old char settings version
  local curVersion = ChronoBars_CharSettings.version;
  for i=1,table.getn( ChronoBars.UPGRADE_LIST ) do
    
    local nextVersion = ChronoBars.UPGRADE_LIST[i];
    if (CB.CompareVersions( curVersion, nextVersion )) then
    
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

function ChronoBars.Error (msg)
  print( "|cffffff00"..ChronoBars.MSG_PREFIX.." |cffff0000"..msg );
end

function ChronoBars.Debug (msg)
  if not ChronoBars_Settings.debugEnabled then return end
  print( "|cffff0000"..ChronoBars.MSG_PREFIX.." |cffffffff"..msg );
end

--Slash handler
--===================================================

function ChronoBars.SlashHandler (msg)

  if (msg == "") then
	CB.ModeToggle();

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
  
  --Need to wait until PLAYER_LOGIN for all the game textures to be loaded
  ChronoBars.frame = CreateFrame( "Frame", "ChronoBars_MainFrame" );
  ChronoBars.frame:SetScript( "OnEvent", ChronoBars.MainFrame_OnEvent );
  ChronoBars.frame:RegisterEvent( "PLAYER_LOGIN" );
  
end

--Main entry point
ChronoBars.Init ();


--Events
--=====================================================

function ChronoBars.MainFrame_PLAYER_LOGIN (...)

	--Cache makes it possible to reuse UI elements
	CB.cache = {};
	CB.cache.bars = {};
	CB.cache.groups = {};
	CB.cache.numUsedBars = 0;
	CB.cache.numUsedGroups = 0;

	--Group/bar UI hierarchy
	CB.groups = {};
	
	--Start in design mode
	CB.designMode = false;
	
	--Upgrade settings if needed
	CB.CheckSettings();
	
	--Update all bars
	CB.ModeDesign();
	CB.ModeRun();
  
	--Update other stuff
	CB.UpdateMainSettings();
	
	--Register other events that require init to be done
	CB.frame:RegisterEvent( "ACTIVE_TALENT_GROUP_CHANGED" );
	CB.frame:RegisterEvent( "DISPLAY_SIZE_CHANGED" );
	
end

function ChronoBars.MainFrame_ACTIVE_TALENT_GROUP_CHANGED ()

	--Find index of the current spec
	local spec = GetSpecialization();
	CB.Debug("ActiveSpecGroup " .. spec );

	--Find name of the linked profile
	local specProfile = nil;
	if (spec == 1) then
    specProfile = ChronoBars_CharSettings.primaryProfile;
  elseif (spec == 2) then
    specProfile = ChronoBars_CharSettings.secondaryProfile;
  else
    specProfile = ChronoBars_CharSettings.tertiaryProfile;
	end

	--Check that profile is linked, exists, and isn't already selected
	if (specProfile ~= nil) then
		if (ChronoBars_Settings.profiles[ specProfile ] ~= nil) then
      if (ChronoBars_CharSettings.activeProfile ~= specProfile) then
      
        --Switch to linked profile
        ChronoBars.Print( "Switching profile to '" .. specProfile .. "' to match spec." );
        ChronoBars_CharSettings.activeProfile = specProfile;
        CB.ModeDesign();
        CB.ModeRun();
      end
		end
	end

end

function ChronoBars.MainFrame_DISPLAY_SIZE_CHANGED (...)

	--Update all bars to fix pixel alignment
    CB.ModeDesign();
    CB.ModeRun();
end

--Mode
--=====================================================

function ChronoBars.ModeToggle()

    if (ChronoBars.designMode) then
		ChronoBars.Print( "Switching to |cff00ff00RUN |cffffffffmode" );
		ChronoBars.ModeRun();
    else
		ChronoBars.Print( "Switching to |cffff0000SETUP |cffffffffmode" );
		ChronoBars.ModeDesign();
    end
	
end
	
	
function ChronoBars.ModeDesign()

  CB.designMode = true;
  CB.HideBarConfig();
  CB.ShowConfigHeader();
  CB.UpdateBarSettings();
  
  --Disable all group updates
  for g=1,table.getn( CB.cache.groups ) do
    CB.Group_DisableUpdate( CB.cache.groups[g] );
  end
  
  --Disable all bar events
  for b=1,table.getn( CB.cache.bars) do
    CB.Bar_DisableEvents( CB.cache.bars[b] );
  end
  
end


function ChronoBars.ModeRun()

  CB.designMode = false;
  CB.HideBarConfig();
  CB.HideConfigHeader();
  CB.UpdateBarSettings();

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


--NOTE: this should never be called outside design mode!!!
--It will put the bar UI in the "editing" state.

function ChronoBars.UpdateBarSettings ()
   
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
    
      --Only add enabled bars unless in design mode
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


function ChronoBars.UpdateMainSettings()

	local set = ChronoBars_CharSettings;
	
	if (set.minimapButtonEnabled) then
	
		--Create new minimap button if missing
		if (CB.button == nil) then
			CB.button = CB.CreateMinimapButton();
		end
		
		--Update its position and show it
		CB.button:SetPosition( set.minimapButtonPos );
		CB.button:Show();
	else
	
		--Hide minimap button if exists
		if (CB.button) then
			CB.button:ClearAllPoints();
			CB.button:SetParent(nil);
			CB.button:Hide();
		end
	end
end


--Minimap button
--===================================================

function CB.CreateMinimapButton()

	local button = CB.MinimapButton_New( "ChronoBars_MinimapButton" );
	button:SetIcon( "Interface\\AddOns\\ChronoBars\\Textures\\icon.tga" );
	button:SetPosition( ChronoBars_CharSettings.minimapButtonPos );
	
	button.OnPositionChanged	= CB.MMB_OnPositionChanged;
	button.OnTooltipShow		= CB.MMB_OnTooltipShow;
	button.OnClick				= CB.MMB_OnClick;
	
	return button;
end

function CB.MMB_OnPositionChanged( button )

	ChronoBars_CharSettings.minimapButtonPos = button:GetPosition();
end

function CB.MMB_OnTooltipShow( button )

	GameTooltip:ClearLines();
	GameTooltip:AddLine("ChronoBars", 1, 1, 0);
	GameTooltip:AddLine("|cffffff00Click |cffffffffto toggle bar config");
	GameTooltip:AddLine("|cffffff00Right-Click |cffffffffto open global config");
end

function CB.MMB_OnClick( button, mouseButton )

	if (mouseButton == "LeftButton") then
		
		CB.ModeToggle();
		
	elseif (mouseButton == "RightButton") then
	
		CB.ModeRun();
		CB.ShowMainConfig();
	end
end

