--[[

====================================================
ChronoBars - buff, debuff, cooldown, totem tracker
Author: Ivan Leben
====================================================

--]]

local CB = ChronoBars;


--Container with a scroll bar
--=====================================================================

function ChronoBars.ScrollFrame_New( name )

	local f = CreateFrame( "Frame", name, nil );
	f:SetHeight( 200 );

	--Scroll
	local s = CreateFrame( "ScrollFrame", name.."Scroll", f );
	s:SetPoint( "BOTTOMLEFT" );
	s:SetPoint( "TOPRIGHT", -20 ,0 );
	s:EnableMouseWheel( true );
	s:SetScript("OnMouseWheel", ChronoBars.ScrollFrame_Scroll_OnMouseWheel);
	s:SetScript("OnSizeChanged", ChronoBars.ScrollFrame_Scroll_OnSizeChanged);
	f.scroll = s;
	s.frame = f;
	
	--Bar
	local b = CreateFrame( "Slider", name.."Bar", s, "UIPanelScrollBarTemplate" );
	b:SetMinMaxValues( 0, 200 );
	b:SetValueStep( 1 );
	b:SetValue( 0 );
	b:SetWidth( 16 );
	b:SetPoint( "TOPRIGHT", s, "TOPRIGHT", 20, -16 );
	b:SetPoint( "BOTTOMRIGHT", s, "BOTTOMRIGHT", 20, 16 );
	--b:SetScript("OnValueChanged", ChronoBars.ScrollFrame_Bar_OnValueChanged );
	b.frame = f;
	f.bar = b;
	
	--Container (needs to have width and height set otherwise it doesn't show up!)
	local c = CreateFrame( "Frame", name.."Container", f );
	c:SetWidth( 200 );
	c:SetHeight( 200 );
	s:SetScrollChild( c );
	c.frame = f;
	f.container = c;
	
	--Functions
	ChronoBars.Container_New( f );
	
	f.SizeToContent = ChronoBars.ScrollFrame_SizeToContent;
	
	return f;
end

function ChronoBars.ScrollFrame_SizeToContent( frame )
	--frame:SetHeight( frame:GetContentHeight() );
end

function ChronoBars.ScrollFrame_Scroll_OnSizeChanged( scroll, width, height )

	local frame = scroll.frame;
	frame.container:SetWidth( width );
end

function ChronoBars.ScrollFrame_Scroll_OnMouseWheel( scroll, value )

	local frame = scroll.frame;
	if (value < 0)
	then frame.bar:SetValue( frame.bar:GetValue() + 40 );
	else frame.bar:SetValue( frame.bar:GetValue() - 40 );
	end
end

function ChronoBars.ScrollFrame_Bar_OnValueChanged( bar, value )

	CB.Print( "SCROLL VALUE CHANGED "..tostring(value) );
	local frame = bar.frame;
	frame.scroll:SetVerticalScroll( value );
end
