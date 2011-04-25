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
	{ type="header",     text="Profile settings" },
	{ type="options",    text="Current profile",   var="func|Var_CurrentProfile",  options="func|Options_CurrentProfile" },
	{ type="options",    text="Copy from",         var="temp|copyFromProfile",     options="func|Options_CopyFromProfile" },
	{ type="button",     text="Copy",              func="root|Func_ProfileCopy" },
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
	ChronoBars_CharSettings.activeProfile = value;
	
	CB.UpdateSettings();
	CB.HideBarConfig();
	
end

--Copy from profile

function ChronoBars.Options_CopyFromProfile_Get()
	
	local options = {};
	
	--Add all existing profiles except current to options
	for name,profile in pairs(ChronoBars_Settings.profiles) do
		if (name ~= ChronoBars_CharSettings.activeProfile) then
			table.insert( options, { text=name, value=name } );
		end
	end
	
	--Init selection to first on the list
	if (options[1] ~= nil) then
		CB.SetSettingsValue( "temp|copyFromProfile", options[1].value );
	end
	
	return options;
end

function ChronoBars.Func_ProfileCopy (value)

	--Valid copy source must be selected
	local srcProfile = CB.GetSettingsValue( "temp|copyFromProfile" );
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

	CB.UpdateSettings();		
	CB.HideBarConfig();
	
end


--Main config
--======================================================================

function ChronoBars.UpdateMainConfig()

	CB.mainConfigFrame:RemoveAllChildren();
	CB.Config_Construct( CB.mainConfigFrame, CB.Frame_MainRoot );
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
