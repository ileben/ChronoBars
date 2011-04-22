--[[

====================================================
ChronoBars - buff, debuff, cooldown, totem tracker
Author: Ivan Leben
====================================================

--]]

local CB = ChronoBars;

--Dropdown box with font selection
--=====================================================================

function ChronoBars.FontDrop_New( name )

	local f = ChronoBars.Drop_New( name );
	
	f.Init            = ChronoBars.FontDrop_Init;
	f.UpdateItem      = ChronoBars.FontDrop_UpdateItem;
	f.UpdateSelection = ChronoBars.FontDrop_UpdateSelection;
	
	return f;
end

function ChronoBars.FontDrop_Init( frame )

	ChronoBars.Drop_Init( frame );

	--Get list of font handles from LibSharedMedia
	local fontHandles = ChronoBars.LSM:List( "font" );
	for i,v in ipairs(fontHandles) do
	
		--Add item for every font handle
		local handle = fontHandles[i];
		frame:AddItem( handle, handle );
	end
end


function ChronoBars.FontDrop_UpdateItem( frame, item, text, value )

	--Update item text and font
	local fontPath = ChronoBars.LSM:Fetch( "font", value );
	item.label:SetText( text );
	item.label:SetFont( fontPath, 12 );
	
end

function ChronoBars.FontDrop_UpdateSelection( frame, index )

	--Update dropdown text and font
	local fontPath = ChronoBars.LSM:Fetch( "font", frame:GetSelectedValue() );
	frame.text:SetText( frame:GetSelectedText() );
	frame.text:SetFont( fontPath, 10 );
end

