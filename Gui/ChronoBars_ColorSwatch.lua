--[[

====================================================
ChronoBars - buff, debuff, cooldown, totem tracker
Author: Ivan Leben
====================================================

--]]

local CB = ChronoBars;


--Color swatch
--=====================================================================

function ChronoBars.ColorSwatch_New( name )

	local size = 20;
	local p = 1;
	
	--Frame
	local f = CreateFrame( "Frame", name, nil );
	f:SetHeight( size );
	
	--Box
	local t = f:CreateTexture( nil, "ARTWORK" );
	t:SetPoint( "TOPLEFT", 0,0 );
	t:SetWidth( size );
	t:SetHeight( size );
	t:SetTexture( 1,1,1, 1 );
	t:SetDrawLayer( "ARTWORK", 1 );
	
	local t2 = f:CreateTexture( nil, "ARTWORK" );
	t2:SetPoint( "BOTTOMLEFT", t, "BOTTOMLEFT", p,p );
	t2:SetPoint( "TOPRIGHT", t, "TOPRIGHT", -p,-p );
	t2:SetTexture( 0,0,0, 1 );
	t2:SetDrawLayer( "ARTWORK", 2 );
	
	local t3 = f:CreateTexture( nil, "ARTWORK" );
	t3:SetPoint( "BOTTOMLEFT", t2, "BOTTOMLEFT", p,p );
	t3:SetPoint( "TOPRIGHT", t2, "TOPRIGHT", -p,-p );
	t3:SetTexture( 1,1,1, 1 );
	t3:SetDrawLayer( "ARTWORK", 3 );
	
	f.box = t3;
	f.box.frame = f;
	f:SetScript( "OnMouseDown", ChronoBars.ColorSwatch_OnMouseDown );
	
	--Label
	local l = f:CreateFontString( name.."Label", "OVERLAY", "GameFontNormal" );
	l:SetFont( "Fonts\\FRIZQT__.TTF", 12 );
	l:SetTextColor( 1,1,1 );
	l:SetText( "Color" );
	l:SetJustifyH( "LEFT" );
	l:SetPoint( "TOPLEFT", size + 5, 0 );
	l:SetPoint( "BOTTOMRIGHT", 0,0 );
	f.label = l;
	
	--Private vars
	f.value = { r=1, g=1, b=1, a=1 };
	f.oldValue = { r=1, g=1, b=1, a=1 };
	f.OnValueChanged = nil;
	
	--Functions
	ChronoBars.Object_New( f );
	f.Init     = ChronoBars.ColorSwatch_Init;
	f.Free     = ChronoBars.ColorSwatch_Free;
	f.SetColor = ChronoBars.ColorSwatch_SetColor;
	f.GetColor = ChronoBars.ColorSwatch_GetColor;
	f.SetText  = ChronoBars.ColorSwatch_SetText;
	return f;
	
end

function ChronoBars.SetColor( color, r,g,b,a )
	color.r = r;
	color.g = g;
	color.b = b;
	color.a = a;
end

function ChronoBars.CopyColor( dst, src )
	dst.r = src.r;
	dst.g = src.g;
	dst.b = src.b;
	dst.a = src.a;
end

function ChronoBars.ColorSwatch_Init( frame )

	ChronoBars.Object_Init( frame );
	frame:SetColor( 1,1,1,1 );
	frame.OnValueChanged = nil;
end

function ChronoBars.ColorSwatch_Free( frame )

	frame.OnValueChanged = nil;
	ChronoBars.Object_Free( frame );
end

function ChronoBars.ColorSwatch_SetColor( frame, r,g,b,a )
	
	CB.SetColor( frame.value, r,g,b,a );
	frame.box:SetTexture( r,g,b,a );
end

function ChronoBars.ColorSwatch_GetColor( frame )

	return frame.value;
end

function ChronoBars.ColorSwatch_SetText( frame, text )

	frame.label:SetText( text );
end

function ChronoBars.ColorSwatch_OnMouseDown( frame )

	CB.CopyColor( frame.oldValue, frame.value );
	ColorPickerFrame.frame = frame;
	
	ColorPickerFrame.func        = nil;
	ColorPickerFrame.opacityFunc = nil;
	ColorPickerFrame.cancelFunc  = nil;
	
	ColorPickerFrame:SetColorRGB( frame.value.r, frame.value.g, frame.value.b );
	ColorPickerFrame.opacity = (1 - frame.value.a);
	ColorPickerFrame.hasOpacity = true;
	
	ColorPickerFrame.func        = ChronoBars.ColorSwatch_OnColorChange;
	ColorPickerFrame.opacityFunc = ChronoBars.ColorSwatch_OnColorChange;
	ColorPickerFrame.cancelFunc  = ChronoBars.ColorSwatch_OnColorCancel;
	
	ColorPickerFrame:Show();

end

function ChronoBars.ColorSwatch_OnColorChange()

	local newR, newG, newB = ColorPickerFrame:GetColorRGB();
	local newA = OpacitySliderFrame:GetValue();

	local frame = ColorPickerFrame.frame;
	frame:SetColor( newR, newG, newB, 1 - newA );

	if (frame.OnValueChanged) then
		frame:OnValueChanged();
	end
	
end

function ChronoBars.ColorSwatch_OnColorCancel(old)
  
	local frame = ColorPickerFrame.frame;
	local old = frame.oldValue;
	
	frame:SetColor( old.r, old.g, old.b, old.a );

	if (frame.OnValueChanged) then
		frame:OnValueChanged();
	end
	
end
