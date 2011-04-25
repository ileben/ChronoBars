--[[

====================================================
ChronoBars - buff, debuff, cooldown, totem tracker
Author: Ivan Leben
====================================================

--]]

local CB = ChronoBars;

--Button
--====================================================================

function ChronoBars.Button_New( name )

	--Frame
	local f = CreateFrame( "Button", name, nil, "UIPanelButtonTemplate2" );
	f:SetWidth( 100 );
	f:SetHeight( 25 );
	
	local t = f:GetFontString();
	t:SetTextColor(1,1,1);
	
	--Functions
	ChronoBars.Object_New( f );
	return f;

end

--Input box
--====================================================================

function ChronoBars.Input_New( name )

	--Frame
	local f = CreateFrame( "Frame", name.."Wrapper", nil );
	f:SetHeight( 33 );
	
	--Label
	local l = f:CreateFontString( name.."Label", "OVERLAY", "GameFontNormal" );
	l:SetFont( "Fonts\\FRIZQT__.TTF", 10 );
	l:SetJustifyH( "LEFT" );
	l:SetPoint( "TOPLEFT", 0,0 );
	l:SetPoint( "TOPRIGHT", 0,0 );
	l:SetHeight( 8 );
	f.label = l;
	
	--Input
    local i = CreateFrame( "EditBox", name.."Input", f, "InputBoxTemplate" );
	i:SetPoint( "TOPLEFT", l, "BOTTOMLEFT", 5,0 );
	i:SetPoint( "TOPRIGHT", l, "BOTTOMRIGHT", -1,0 );
	i:SetHeight( 30 );
	i:SetAutoFocus( false );
	i:SetScript( "OnEditFocusGained", ChronoBars.Input_OnFocusGained );
	i:SetScript( "OnEditFocusLost", ChronoBars.Input_OnFocusLost );
	i:SetScript( "OnEnterPressed", ChronoBars.Input_OnEnterPressed );
	i:SetScript( "OnEscapePressed", ChronoBars.Input_OnEscapePressed );
	i:SetScript( "OnSizeChanged", ChronoBars.Input_OnSizeChanged );
	i.frame = f;
	f.input = i;
	
	--Functions
	ChronoBars.Object_New( f );
	
	f.SetLabelText = ChronoBars.Input_SetLabelText;
	f.SetText      = ChronoBars.Input_SetText;
	f.GetText      = ChronoBars.Input_GetText;
	return f;
end

function ChronoBars.Input_SetLabelText( frame, text )
	frame.label:SetText( text );
end

function ChronoBars.Input_SetText( frame, text )
	frame.input:SetText( text );
end

function ChronoBars.Input_GetText( frame )
	return frame.input:GetText();
end

function ChronoBars.Input_OnFocusGained( input )
	local frame = input.frame;
	frame.oldValue = input:GetText();
end

function ChronoBars.Input_OnFocusLost( input )
	local frame = input.frame;
	input:SetText( frame.oldValue );
end

function ChronoBars.Input_OnEscapePressed( input )
	local frame = input.frame;
	input:SetText( frame.oldValue );
	input:ClearFocus();
end

function ChronoBars.Input_OnEnterPressed( input )
	
	local frame = input.frame;
	frame.oldValue = input:GetText();
	input:ClearFocus();
	
	local script = frame.OnValueChanged;
	if (script) then script( frame ); end
end

function ChronoBars.Input_OnSizeChanged( input )
	input:SetCursorPosition(0);
end

--Check box
--====================================================================

function ChronoBars.Checkbox_New( name )

	--Use a frame wrapper, so that resizing it doesn't mess up the actual box
	local f = CreateFrame( "Frame", name.."Wrapper", nil );
	f:SetHeight( 21 );
	
	--This is the actual checkbox
	local c = CreateFrame( "CheckButton", name, f, "UICheckButtonTemplate" );
	c:SetPoint( "TOPLEFT", f, "TOPLEFT", -5, 5 );
	c:SetScript( "OnClick", ChronoBars.Checkbox_OnClick );
	c.frame = f;
	f.check = c;
	
	--Get font string that contains the text
	f.text = _G[ name.."Text" ];
	f.text:SetFont( "Fonts\\FRIZQT__.TTF", 12 );
	f.text:SetTextColor( 1,1,1 );
	f.text:SetJustifyH( "LEFT" );
	f.text:ClearAllPoints();
	f.text:SetPoint( "BOTTOMLEFT", f, "BOTTOMLEFT", 25, 0 );
	f.text:SetPoint( "TOPRIGHT", f, "TOPRIGHT" );
	
	--Functions
	ChronoBars.Object_New( f );
	
	f.SetText     = ChronoBars.Checkbox_SetText;
	f.SetChecked  = ChronoBars.Checkbox_SetChecked;
	f.GetChecked  = ChronoBars.Checkbox_GetChecked;
	
	return f;
end

function ChronoBars.Checkbox_SetText( frame, text )
	frame.text:SetText( text );
end

function ChronoBars.Checkbox_SetChecked( frame, checked )
	frame.check:SetChecked( checked );
end

function ChronoBars.Checkbox_GetChecked( frame )
	return frame.check:GetChecked();
end

function ChronoBars.Checkbox_OnClick( check )
	local frame = check.frame;
	local script = frame.OnValueChanged;
	if (script) then script( frame ); end
end



--Header
--=====================================================================

function ChronoBars.Header_New( name )

	--Frame
	local f = CreateFrame( "Frame", name, nil );
	f:SetHeight( 25 );
	
	--Background
	local b = f:CreateTexture( nil, "ARTWORK" );
	b:SetTexture( "Interface\\AddOns\\ChronoBars\\Textures\\Header.tga" );
	b:SetAllPoints( f );
	
	--Label
	local l = f:CreateFontString( name.."Label", "OVERLAY", "GameFontNormal" );
	l:SetFont( "Fonts\\FRIZQT__.TTF", 12 );
	l:SetAllPoints( f );
	l:SetText( "Group" );
	f.label = l;
	
	--Functions
	ChronoBars.Object_New( f );
	f.SetText  = ChronoBars.Header_SetText;
	return f;
end

function ChronoBars.Header_SetText( frame, text )
	frame.label:SetText( text );
end


--Group Frame
--=====================================================================

function ChronoBars.GroupFrame_New( name )

	--[[
	--Frame
	local f = CreateFrame( "Frame", name, nil );
	
	--Label
	local l = f:CreateFontString( name.."Label", "OVERLAY", "GameFontNormal" );
	l:SetFont( "Fonts\\FRIZQT__.TTF", 12 );
	l:SetJustifyH( "LEFT" );
	l:SetPoint( "TOPLEFT", 0,0 );
	l:SetPoint( "TOPRIGHT", 0,0 );
	l:SetHeight( 12 );
	f.label = l;
	
	--Border
	local b = CreateFrame( "Frame", name.."Border", f );
	
	b:SetBackdrop(
		{bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
		 edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		 tile = true, tileSize = 16, edgeSize = 16,
		 insets = { left = 3, right = 3, top = 5, bottom = 3 }});
	
	b:SetBackdropColor( 0.1, 0.1, 0.1, 0.5 );
	b:SetBackdropBorderColor( 1.0, 0.9, 0.0 );
	b:SetPoint( "TOPLEFT", 0, -17 );
	b:SetPoint( "BOTTOMRIGHT", 0, 0 );
	
	--Container
	local pad = 15;
	local c = CreateFrame( "Frame", name.."Container", b );
	c:SetPoint( "BOTTOMLEFT", pad, pad );
	c:SetPoint( "TOPRIGHT", -pad,-pad );
	f.container = c;
	
	--Functions
	f.SetLabelText = ChronoBars.GroupFrame_SetLabelText;
	
	return f;
	--]]
	
	--Frame
	local f = CreateFrame( "Frame", name, nil );
	f:SetHeight( 100 );
	
	--Header
	local h = f:CreateTexture( nil, "ARTWORK" );
	h:SetTexture( "Interface\\AddOns\\ChronoBars\\Textures\\Header.tga" );
	h:SetPoint( "TOPLEFT", 0,0 );
	h:SetPoint( "TOPRIGHT", 0,0 );
	h:SetHeight( 25 );
	
	--Label
	local l = f:CreateFontString( name.."Label", "OVERLAY", "GameFontNormal" );
	l:SetFont( "Fonts\\FRIZQT__.TTF", 12 );
	l:SetAllPoints( h );
	l:SetText( "Group" );
	f.label = l;
	
	--Container
	local c = CreateFrame( "Frame", name.."Container", f );
	c:SetPoint( "LEFT",   f, "LEFT",   0,  0 );
	c:SetPoint( "RIGHT",  f, "RIGHT",  0,  0 );
	c:SetPoint( "TOP",    h, "BOTTOM", 0, -10 );
	c:SetPoint( "BOTTOM", f, "BOTTOM", 0,  0 );
	c.frame = f;
	f.container = c;
	
	--Functions
	ChronoBars.Container_New( f );
	
	f.SetLabelText   = ChronoBars.GroupFrame_SetLabelText;
	f.SizeToContent  = ChronoBars.GroupFrame_SizeToContent;
	
	return f;
end

function ChronoBars.GroupFrame_SetLabelText( frame, text )
	frame.label:SetText( text );
end

function ChronoBars.GroupFrame_SizeToContent( frame )
	frame:SetHeight( 25 + 10 + frame:GetContentHeight() );
end
