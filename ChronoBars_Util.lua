--[[

====================================================
ChronoBars - buff, debuff, cooldown, totem tracker
Author: Ivan Leben
====================================================

--]]

local CB = ChronoBars;

--Clear table contents
--=========================================================

function ChronoBars.Util_ClearTable (t)
  while (table.getn( t ) > 0) do
    table.remove( t );
  end
end

function ChronoBars.Util_ClearTableKeys (t)
  for k,v in pairs(t) do
    t[ k ] = nil;
  end
end

--Capture list into table without creating a new one
--=========================================================

function ChronoBars.Util_CaptureList (t, ...)

  --Get first value in the list
  local i = 1;
  local v = select( i, ... );
  
  --Loop until end of list
  while v ~= nil do
  
    --Insert value at the end of the table
    table.insert( t, v );
  
    --Get next value
    i = i + 1;
    v = select( i, ... );
  end
end


--Spell icon cache
--========================================================

function ChronoBars.Util_GetSpellIcon (spellName)

  --Init cache table
  if (CB.iconCache == nil) then
    CB.iconCache = {};
  end
  
  --Check for cached value
  local icon = CB.iconCache[ spellName ];
  if (icon ~= nil) then
    if (icon ~= "")
    then return icon;
    else return nil;
    end
  end
  
  --Try get it from the player's spellbook first
  icon = GetSpellTexture( spellName );
  if (icon ~= nil) then
    CB.iconCache[ spellName ] = icon;
    return icon;
  end
  
  --Search through all the spell IDs
  for i=1,100000 do
    local name,_,icon = GetSpellInfo( i );
    if (name == spellName) then
      CB.iconCache[ spellName ] = icon;
      return icon;
    end
  end
  
  --Mark not found
  CB.iconCache[ spellName ] = "";
end

--Enchant scanning from weapon tooltip
--========================================================

function ChronoBars.Util_GetWeaponEnchantName (inventorySlotId)

  local tt1 = CB.Util_GetTooltip(1); tt1:ClearLines();
  local tt2 = CB.Util_GetTooltip(2); tt2:ClearLines();
  
  --Set first tooltip to match inventory slot
  tt1:SetInventoryItem( "player", inventorySlotId );
  
  --Get hyperlink from first tooltip and set it to second tooltip
  local itemLink = select( 2, tt1:GetItem() );
  tt2:SetHyperlink( itemLink );
  
  --Iterate all the lines of first tooltip
  local numLines1 = tt1:NumLines();
  for l1=1,numLines1 do
  
    --Get line text and check if green color (red = 0)
    local line1 = CB.Util_GetTooltipLineLeft( tt1, l1 );
    local text1 = line1:GetText();
    if (line1:GetTextColor() == 0) then

      --Iterate all the lines of second tooltip
      local found = false;
      local numLines2 = tt2:NumLines();    
      for l2=1,numLines2 do
      
        --Get line text and check if line from first tooltip found
        local line2 = CB.Util_GetTooltipLineLeft( tt2, l2 );
        local text2 = line2:GetText();
        if (text2 == text1) then
          found = true;
          break;
        end
      end
      
      --The green line that is missing in the second tooltip is the enchant!
      if (not found) then
      
        --Get rid of the duration in brackets at the end
        local x = strfind( text1, "[(]" );
        if (x ~= nil) then x = x - 2; end
        return strsub( text1, 1, x );
      end
    end
  end
  
end

--Scannable tooltips
--========================================================

function ChronoBars.Util_GetTooltip (index)

  --Create tooltip table if missing
  if (CB.tooltips == nil) then
    CB.tooltips = {};
  end
  
  --Create tooltip at given index if missing
  if (CB.tooltips[ index ] == nil) then
  
    --Create new tooltip frame
    local tt = CreateFrame( "GameTooltip", "ChronoBars_Tooltip"..index );
    tt:SetOwner( UIParent, "ANCHOR_NONE" );
    CB.tooltips[ index ] = tt;
    
    --Insert custom font strings for tooltip lines
    tt.text = {}
    for l=1,30 do
      tt.text[l] = {};
      tt.text[l].left = tt:CreateFontString();
      tt.text[l].left:SetFontObject( "GameFontNormal" );
      tt.text[l].right = tt:CreateFontString();
      tt.text[l].right:SetFontObject( "GameFontNormal" );
      tt:AddFontStrings( tt.text[l].left, tt.text[l].right );
    end
    
    --Clearing all lines will make tooltip store new text into custom ones
    tt:ClearLines();
  end
  
  return CB.tooltips[ index ];
end

function ChronoBars.Util_GetTooltipLineLeft (tooltip, index)
  return tooltip.text[ index ].left;
end

function ChronoBars.Util_GetTooltopLineRight (tooltip, index)
  return tooltip.text[ index ].right;
end
