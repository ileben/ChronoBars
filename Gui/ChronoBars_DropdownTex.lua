--[[

====================================================
ChronoBars - buff, debuff, cooldown, totem tracker
Author: Ivan Leben
====================================================

--]]

local CB = ChronoBars;

--Dropdown box with texture selection
--=====================================================================


function ChronoBars.TexDrop_New( name )

	local f = ChronoBars.Drop_New( name );
	
	f.Init            = ChronoBars.TexDrop_Init;
	f.CreateItem      = ChronoBars.TexDrop_CreateItem;
	f.UpdateItem      = ChronoBars.TexDrop_UpdateItem;
	f.UpdateSelection = ChronoBars.TexDrop_UpdateSelection;
	
	return f;
end

function ChronoBars.TexDrop_Init( frame )

	ChronoBars.Drop_Init( frame );

	--Get list of texture handles from LibSharedMedia
	local texHandles = ChronoBars.LSM:List( "statusbar" );
	for i,v in ipairs(texHandles) do
	
		--Add item for every font handle
		local handle = texHandles[i];
		frame:AddItem( handle, handle );
	end
end

function ChronoBars.TexDrop_CreateItem( frame )

	--Frame
	local f = CreateFrame( "Frame", "SomeFrame" );
	f:SetHeight( 20 );
	f:SetWidth( 100 );
	f:SetParent( frame.box );
	
	--Texture
	local t = f:CreateTexture( nil, "OVERLAY" );
	t:SetPoint( "BOTTOMLEFT", 1,1 );
	t:SetPoint( "TOPRIGHT", -1,-1 );
	f.texture = t;
	
	--Label
	local l = f:CreateFontString( "SomeString", "OVERLAY", "GameFontNormal" );
	l:SetFont( "Fonts\\FRIZQT__.TTF", 10 );
	l:SetTextColor( 1,1,1 );
	l:SetJustifyH( "LEFT" );
	l:SetAllPoints( f );
	f.label = l;
	
	return f;
end

function ChronoBars.TexDrop_UpdateItem( frame, item, text, value )

	--Update item text and texture
	local texPath = ChronoBars.LSM:Fetch( "statusbar", value );
	item.texture:SetTexture( texPath );
	item.label:SetText( text );
end

function ChronoBars.TexDrop_UpdateSelection( frame, index )
	frame.text:SetText( frame.data[index].text );
end
