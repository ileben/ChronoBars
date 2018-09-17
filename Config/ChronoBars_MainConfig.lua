--[[

====================================================
ChronoBars - buff, debuff, cooldown, totem tracker
Author: Ivan Leben
====================================================

--]]

local CB = ChronoBars;

--Config structure
--======================================================================

ChronoBars.Frame_MainRoot =
{
	{ type="header",     text="Profile management" },
	{ type="options",    text="Current profile",         var="func|Var_CurrentProfile",   options="func|Options_CurrentProfile" },
	{ type="input",      text="Current profile name",    var="func|Var_ProfileName" },
	{ type="button",     text="New profile",             func="root|Func_ProfileNew" },
	{ type="button",     text="Delete profile",          func="root|Func_ProfileDelete" },
	
	{ type="header",     text="Link profile to spec" },
	{ type="options",    text="Primary spec",      var="char|primaryProfile",       options="func|Options_LinkProfile" },
	{ type="options",    text="Secondary spec",    var="char|secondaryProfile",     options="func|Options_LinkProfile" },
  { type="options",    text="Tertiary spec",     var="char|tertiaryProfile",      options="func|Options_LinkProfile" },

	{ type="header",     text="Copy profile settings" },
	{ type="options",    text="Copy from",         var="temp|copyProfile",          options="func|Options_CopyProfile" },
	{ type="button",     text="Copy",              func="root|Func_ProfileCopy" },
	
	{ type="header",     text="Minimap button" },
	{ type="toggle",     text="Enabled",            var="char|minimapButtonEnabled" },
	{ type="numinput",   text="Position (degrees)", var="char|minimapButtonPos" },
};


--Current profile

function ChronoBars.Options_CurrentProfile_Get()

	local options = {};
	
	--Add all existing profiles to options
	for name,profile in pairs(ChronoBars_Settings.profiles) do
		table.insert( options, { text=name, value=name } );
	end
	
	return options;
end

function ChronoBars.Var_CurrentProfile_Get()

	--Return name of the active profile
	return ChronoBars_CharSettings.activeProfile;
end

function ChronoBars.Var_CurrentProfile_Set( value )
  
	--Check for invalid profile
	if (ChronoBars_Settings.profiles[ value ] == nil) then
		CB.Error( "Selected profile doesn't exist!" );
		return
	end

	--Switch to selected profile
	CB.Print( "Switching profile to '"..value.."'" );
	ChronoBars_CharSettings.activeProfile = value;
	
	CB.UpdateMainConfig();
	CB.ModeDesign();
	CB.ModeRun();
	
end

--Profile name

function ChronoBars.Var_ProfileName_Get()

	--Return name of the active profile
	return ChronoBars_CharSettings.activeProfile;
end

function ChronoBars.Var_ProfileName_Set( newName )

  --Check for existing profile
  if (ChronoBars_Settings.profiles[ newName ] ~= nil) then
    CB.Error( "Cannot rename profile. Another profile with this name exists!" );
    return;
  end
  
  --Change the name of the profile
  local oldName = ChronoBars_CharSettings.activeProfile;
  ChronoBars_Settings.profiles[ newName ] = ChronoBars_Settings.profiles[ oldName ];
  ChronoBars_Settings.profiles[ oldName ] = nil;
  ChronoBars_CharSettings.activeProfile = newName;
  
  --Update char profile setting if set to this one
  if (ChronoBars_CharSettings.primaryProfile == oldName) then
    ChronoBars_CharSettings.primaryProfile = newName;
  end
  
  if (ChronoBars_CharSettings.secondaryProfile == oldName) then
    ChronoBars_CharSettings.secondaryProfile = newName;
  end
  
  if (ChronoBars_CharSettings.tertiaryProfile == oldName) then
    ChronoBars_CharSettings.tertiaryProfile = newName;
  end
  
  CB.UpdateMainConfig();
  CB.ModeDesign();
  CB.ModeRun();
  
end

--New/Delete profile

function ChronoBars.Func_ProfileNew()

	--Find an available name
	local newIndex = 1;
	local newName = "NewProfile";

	while (ChronoBars_Settings.profiles[ newName ] ~= nil) do
		newIndex = newIndex + 1;
		newName = "NewProfile"..newIndex;
	end

	--Add new profile and switch to it
	CB.Print( "Switching to profile '"..newName.."'" );
	ChronoBars_Settings.profiles[ newName ] = CopyTable( CB.DEFAULT_PROFILE );
	ChronoBars_CharSettings.activeProfile = newName;
	
	CB.UpdateMainConfig();
	CB.ModeDesign();
	CB.ModeRun();

end


function ChronoBars.Func_ProfileDelete()

	--Confirm with user
	local delProfile = ChronoBars_CharSettings.activeProfile;
	CB.ShowConfirmFrame( "Are you sure you want to delete profile '"..tostring(delProfile).."'?",
		CB.Func_ProfileDelete_Accept, nil, delProfile );
end

function ChronoBars.Func_ProfileDelete_Accept( delProfile )
  
	--Check if deleting default profile
	if (delProfile == "Default") then
		CB.Error( "Cannot delete default profile!" );
		return;
	end
	
	--Delete profile and switch to default
	ChronoBars_Settings.profiles[ delProfile ] = nil;
	ChronoBars_CharSettings.activeProfile = "Default";

	CB.UpdateMainConfig();
	CB.ModeDesign();
	CB.ModeRun();
  
end


--Copy profile

function ChronoBars.Options_CopyProfile_Get()
	
	local options = {};
	
	--Add all existing profiles except current to options
	for name,profile in pairs(ChronoBars_Settings.profiles) do
		if (name ~= ChronoBars_CharSettings.activeProfile) then
			table.insert( options, { text=name, value=name } );
		end
	end
	
	--Init selection to first on the list
	if (options[1] ~= nil) then
		CB.SetSettingsValue( "temp|copyProfile", options[1].value );
	end
	
	return options;
end

function ChronoBars.Func_ProfileCopy()

	--Valid copy source must be selected
	local srcProfile = CB.GetSettingsValue( "temp|copyProfile" );
	if (srcProfile == nil) then
		return;
	end
	
	--Confirm with user
	CB.ShowConfirmFrame( "Are you sure you want to copy profile settings from '"..srcProfile.."'?",
		CB.Func_ProfileCopy_Accept, nil, srcProfile );
end

function ChronoBars.Func_ProfileCopy_Accept( srcProfile )

	--Check for invalid profile
	if (ChronoBars_Settings.profiles[ srcProfile ] == nil) then
		CB.Error( "Selected profile doesn't exist!" );
		return
	end

	--Copy settings to current profile
	local dstProfile = ChronoBars_CharSettings.activeProfile;
	ChronoBars_Settings.profiles[ dstProfile ] =
		CopyTable( ChronoBars_Settings.profiles[ srcProfile ] );

	CB.ModeDesign();
	CB.ModeRun();
	
end

--Link profile

function ChronoBars.Options_LinkProfile_Get()

	local options = {};
	
	--Add <none> option to unlink
	table.insert( options, {text="<none>", value=nil } );
	
	--Add all existing profiles to options
	for name,profile in pairs(ChronoBars_Settings.profiles) do
		table.insert( options, { text=name, value=name } );
	end
	
	return options;
	
end


--Main config
--======================================================================

function ChronoBars.UpdateMainConfig()

	CB.Config_Show( CB.mainConfigFrame, CB.Frame_MainRoot, CB.UpdateMainSettings );
end

function ChronoBars.ShowMainConfig()

	CB.UpdateMainConfig();
	InterfaceOptionsFrame_OpenToCategory( "ChronoBars" );
end

function ChronoBars.InitOptionsPanel ()

	local f = CreateFrame( "Frame", "ChronoBars.MainOptionsPanel", InterfaceOptionsFramePanelContainer );
	
	CB.mainConfigFrame = CB.ScrollFrame_New( "ChronoBars.MainOptionsScroll" );
	CB.mainConfigFrame:SetParent( f );
	CB.mainConfigFrame:SetPoint( "BOTTOMLEFT", 20,20 );
	CB.mainConfigFrame:SetPoint( "TOPRIGHT", -20,-20 );
	
	--[[
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
	--]]
	
	--Add panel as an interface options category
	f.name = "ChronoBars";
	f.refresh = ChronoBars.UpdateMainConfig;
	InterfaceOptions_AddCategory( f );

end

--Main entry point
ChronoBars.InitOptionsPanel();
