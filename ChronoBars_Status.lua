--[[

====================================================
ChronoBars - buff, debuff, cooldown, totem tracker
Author: Ivan Leben
====================================================

--]]

local CB = ChronoBars;

function ChronoBars.Bar_InitEffect (bar)

  local set = bar.settings;
  
  for i=1,table.getn( bar.effectStatus ) do
    
    --Init effect status
    local estatus = bar.effectStatus[i];
    
    if (set.type == CB.EFFECT_TYPE_AURA) then
      CB.Bar_InitStatusAura( bar, estatus );
      
    elseif (set.type == CB.EFFECT_TYPE_MULTI_AURA) then
      CB.Bar_InitStatusMultiAura( bar, estatus );

    elseif (set.type == CB.EFFECT_TYPE_CD) then
      CB.Bar_InitStatusCd( bar, estatus );

    elseif (set.type == CB.EFFECT_TYPE_USABLE) then
      CB.Bar_InitStatusUsable( bar, estatus );

    elseif (set.type == CB.EFFECT_TYPE_TOTEM) then
      CB.Bar_InitStatusTotem( bar, estatus );

    elseif (set.type == CB.EFFECT_TYPE_CUSTOM) then
      CB.Bar_InitStatusCustom( bar, estatus );
      
    elseif (set.type == CB.EFFECT_TYPE_AUTO) then
      CB.Bar_InitStatusAuto( bar, estatus );
      
    elseif (set.type == CB.EFFECT_TYPE_ENCHANT) then
      CB.Bar_InitStatusEnchant( bar, estatus );
    end
    
    --Init bar status to first effect
    if (i == 1) then
      bar.status.id = estatus.id;
      bar.status.name = estatus.name;
      bar.status.icon = estatus.icon;
      bar.status.text = estatus.text;
    end
  end
  
end

function ChronoBars.Bar_UpdateEffect (bar, now, event, ...)

  local set = bar.settings;
  local maxExpires = nil;

  --Walk the list of effects
  for i=1,table.getn( bar.effectStatus ) do
  
    --Update effect status
    local estatus = bar.effectStatus[i];
    
    if (set.type == CB.EFFECT_TYPE_AURA) then
      CB.Bar_UpdateStatusAura( bar, estatus, now, event, ... );
      
    elseif (set.type == CB.EFFECT_TYPE_MULTI_AURA) then
      CB.Bar_UpdateStatusMultiAura( bar, estatus, now, event, ... );

    elseif (set.type == CB.EFFECT_TYPE_CD) then
      CB.Bar_UpdateStatusCd( bar, estatus, now, event, ... );

    elseif (set.type == CB.EFFECT_TYPE_USABLE) then
      CB.Bar_UpdateStatusUsable( bar, estatus, now, event, ... );

    elseif (set.type == CB.EFFECT_TYPE_TOTEM) then
      CB.Bar_UpdateStatusTotem( bar, estatus, now, event, ... );

    elseif (set.type == CB.EFFECT_TYPE_CUSTOM) then
      CB.Bar_UpdateStatusCustom( bar, estatus, now, event, ... );
      
    elseif (set.type == CB.EFFECT_TYPE_AUTO) then
      CB.Bar_UpdateStatusAuto( bar, estatus, now, event, ... );
      
    elseif (set.type == CB.EFFECT_TYPE_ENCHANT) then
      CB.Bar_UpdateStatusEnchant( bar, estatus, now, event, ... );
    end

    --Check if this effect is the last to expire
    if (maxExpires == nil or (estatus.expires ~= nil and estatus.expires > maxExpires)) then
      
      --Copy to bar status
      bar.status.icon = estatus.icon;
      bar.status.count = estatus.count;
      bar.status.text = estatus.text;
      bar.status.duration = estatus.duration;
      bar.status.expires = estatus.expires;
      maxExpires = estatus.expires;
    end
  end
  
  --Check if bar active and if it just activated
  local newActive = (bar.status.duration ~= nil and bar.status.expires ~= nil);
  bar.status.reactive = (newActive and (not bar.status.active));
  bar.status.active = newActive;
  
  --Let other bars know that this bar just activated
  if (bar.status.reactive
  and set.type ~= CB.EFFECT_TYPE_CUSTOM
  and set.type ~= CB.EFFECT_TYPE_MULTI_AURA)
  then
    CB.BroadcastBarEvent( "CHRONOBARS_BAR_ACTIVATED", bar );
  end
  
end

function ChronoBars.Bar_UpdateTime (bar, now)

  local set = bar.settings;
  bar.status.left = 0.0;
  bar.status.ratio = 0.0;

  if (bar.status.active) then
    if (bar.status.duration == 0 and bar.status.expires == 0) then

      --It's an infinite-duration bar
      bar.status.ratio = 1.0;

    elseif (now > bar.status.expires) then

      --It ran out
      bar.status.duration = nil;
      bar.status.expires = nil;
      bar.status.active = false;

    else

      --Check if fixed duration is enabled
      local effectiveDuration = bar.status.duration;
      if (set.fixed.enabled) then
        effectiveDuration = set.fixed.duration;
      end

      --Calculate time ratio
      bar.status.left = bar.status.expires - now;
      if (effectiveDuration > 0.0) then
        bar.status.ratio = bar.status.left / effectiveDuration;
      end

    end
  end

   --Clamp time ratio
  if (bar.status.ratio > 1.0) then
    bar.status.ratio = 1.0;
  elseif (bar.status.ratio < 0.0) then
    bar.status.ratio = 0.0;
  end
  
end

--Aura
--=================================================

function ChronoBars.Bar_InitStatusAura (bar, status)
end

function ChronoBars.Bar_UpdateStatusAura (bar, status, now)

  local set = bar.settings;
  local name, icon, count, duration, expires, caster, id;
  count = 0;

  --Setup buff/debuff filter
  local filter = set.aura.type;
  if (set.aura.byPlayer) then
    filter = filter.."|PLAYER";
  end

  --UnitAura doesn't take spell ID :(
  --If using ID or summing stacks we need to check all auras
  if (set.aura.sum) then

    --Walk all the auras on the unit matching the filter
    local auraIndex = 1;
    while true do

      --Get aura info by index
      local tempCount, tempDur, tempExp;
      local tempName, _, tempIcon, tempCount, _, tempDur, tempExp, tempCaster, _, _, tempId =
        UnitAura( set.aura.unit, auraIndex, filter );
      if (not tempName) then break end;
      auraIndex = auraIndex + 1;

      --Check if ID or name matches
      local match;
      if (status.id)
      then match = (tempId == status.id);
      else match = (tempName == status.name);
      end

      --Add to count, pick largest duration and expiration
      if (match) then
        name = tempName; icon = tempIcon; id = tempId;

        if (not tempCount) then tempCount = 1; end;
        count = count + tempCount;

        if ((not duration) or tempDur > duration) then
          duration = tempDur;
        end

        if ((not expires) or tempExp > expires) then
          expires = tempExp;
        end
      end
    end

  elseif (status.id or set.aura.order > 1) then

    --Walk all the auras on the unit matching the filter
    local auraOrder = 1;
    local auraIndex = 1;
    while true do

      --Get aura info by index
      name, _, icon, count, _, duration, expires, caster, _, _, id =
        UnitAura( set.aura.unit, auraIndex, filter );
      if (not name) then break end;
      auraIndex = auraIndex + 1;

      --Check if ID or name matches
      local match;
      if (status.id)
      then match = (id == status.id);
      else match = (name == status.name);
      end

      --Check if ID matches
      if (match) then
        if (auraOrder == set.aura.order) then break end;
        auraOrder = auraOrder + 1;
      end
    end

  else
    --Get aura info by name
    name, _, icon, count, _, duration, expires =
      UnitAura( set.aura.unit, status.name, nil, filter );
  end
  
  --Update bar time
  status.text = status.name;
  status.count = count;
  status.duration = duration;
  status.expires = expires;

  --Update bar icon
  if (icon) then
    status.icon = icon;
  end
  
end

--Multi-Aura
--=================================================

function ChronoBars.Bar_InitStatusMultiAura (bar, status)
end

function ChronoBars.Bar_UpdateStatusMultiAura (bar, status, now, event, ...)
  
  if (event == "CHRONOBARS_MULTI_AURA_UPDATE") then
    
    --Check if right bar for this aura
    local targetGuid, targetName, spellName = select( 1, ... );
    if (bar.targetGuid ~= targetGuid) then return end;
    if (status.name ~= spellName) then return end;
    
    --Update time
    status.duration = bar.settings.custom.duration;
    status.expires = now + status.duration;
    status.text = targetName;
    return;
    
  elseif (event == "CHRONOBARS_MULTI_AURA_REMOVED") then
  
    --Check if right bar for this aura
    local targetGuid, targetName, spellName = select( 1, ... );
    if (bar.targetGuid ~= targetGuid) then return end;
    if (status.name ~= spellName) then return end;
    
    --Remove bar from the group
    CB.RemoveBar( bar.group, bar );
    CB.FreeBar( bar );
    return;
    
  elseif (event ~= "COMBAT_LOG_EVENT_UNFILTERED") then return end;
  
  --Check the type of combat event
  local combatEvent = select( 2, ... );
  local applied = (combatEvent == "SPELL_AURA_APPLIED");
  local removed = (combatEvent == "SPELL_AURA_REMOVED");
  local refresh = (combatEvent == "SPELL_AURA_REFRESH");
  if (not (applied or removed or refresh)) then return end;
  
  --Check if source of event is player
  local guid = select( 3, ... );
  if (guid ~= UnitGUID("player")) then return end;
  
  --Check if aura name matches effect
  local spellName = select( 10, ... );
  if (spellName ~= status.name) then return end;
  
  --Get aura target info
  local targetName = select( 7, ... );
  local targetGuid = select( 6, ... );
  
  --[[
  if (applied) then
    CB.Print( "Applied "..spellName.." on ".. target.." #"..targetGuid );
  elseif (removed) then
    CB.Print( "Removed "..spellName.." on ".. target.." #"..targetGuid );
  elseif (refresh) then
    CB.Print( "Refresh "..spellName.." on ".. target.." #"..targetGuid );
  end
  --]]
  
  if (applied) then
  
    --Add new bar to this group
    local auraBar = CB.NewBar();
    auraBar.targetGuid = targetGuid;
    CB.AddBar( bar.group, auraBar );
    
    --Apply same settings as this bar to the new bar
    local profile = CB.GetActiveProfile();
    CB.Bar_ApplySettings( auraBar, profile, bar.groupId, bar.barId );
    CB.Group_ApplySettings( auraBar.group, profile, auraBar.groupId );
    
    --Register multi-aura events
    CB.RegisterBarEvent( auraBar, "CHRONOBARS_MULTI_AURA_UPDATE" );
    CB.RegisterBarEvent( auraBar, "CHRONOBARS_MULTI_AURA_REMOVED" );
    
    --Send update event
    CB.SendBarEvent( auraBar, "CHRONOBARS_MULTI_AURA_UPDATE",
      targetGuid, targetName, spellName );
    
  elseif (refresh) then
    
    --Broadcast update event
    CB.BroadcastBarEvent( "CHRONOBARS_MULTI_AURA_UPDATE",
      targetGuid, targetName, spellName );

  elseif (removed) then
  
    --Broadcast removed event
    CB.BroadcastBarEvent( "CHRONOBARS_MULTI_AURA_REMOVED",
      targetGuid, targetName, spellName );
      
  end
  
end

--Cooldown
--===================================================

function ChronoBars.Bar_InitStatusCd (bar, status)
end

function ChronoBars.Bar_UpdateStatusCd (bar, status, now)

  local set = bar.settings;
  local start = nil;
  local duration = nil;

  --Get cooldown times (works with name and ID)
  if (status.isItem)
  then start, duration = GetItemCooldown( status.name );
  else start, duration = GetSpellCooldown( status.name );
  end

  --Update bar time unless it is a global cooldown.
  if (start == nil or duration == nil) then
    status.expires = nil;
    status.duration = nil;
    
  elseif (start == 0 or duration == 0) then
    status.expires = nil;
    status.duration = nil;
    
  elseif (duration > 1.5) then
    status.expires = start + duration;
    status.duration = duration;
  
  elseif ((not (status.expires == nil))) then
    if (status.expires > start + duration) then
      status.expires = nil;
      status.duration = nil;
    end
  end

  --Update bar text
  status.text = status.name;
  
end

--Usable
--===================================================

function ChronoBars.Bar_InitStatusUsable (bar, status)
end

function ChronoBars.Bar_UpdateStatusUsable (bar, status, now)

  local set = bar.settings;
  local usable, start, duration;

  --Check if it is usable in general
  if (status.isItem)
  then usable = IsUsableItem( status.name );
  else usable = IsUsableSpell( status.name );
  end

  if (set.usable.includeCd) then
  
    --Get spell or item cooldown
    if (status.isItem)
    then start, duration = GetItemCooldown( status.name );
    else start, duration = GetSpellCooldown( status.name );
    end
    
    --Update usable cd unless it is global cooldown
    if (start == nil or duration == nil) then
      status.usableCdExpires = nil;
    elseif (start == 0 or duration == 0) then
      status.usableCdExpires = nil;
    elseif (duration > 1.5) then
      status.usableCdExpires = start + duration;
    elseif (not (status.usableCdExpires == nil)) then
      if (status.usableCdExpires > start + duration) then
        status.usableCdExpires = nil;
      end
    end
    
    --Check if usable cd ran out
    if (status.usableCdExpires) then
      if (now > status.usableCdExpires) then
        status.usableCdExpires = nil;
      end
    end
    
    --Include in usability check
    usable = (usable and (status.usableCdExpires==nil));
  end
  
  --Update bar time
  if (usable) then
    status.duration = 0;
    status.expires = 0;
  else
    status.duration = nil;
    status.expires = nil;
  end
  
  --Update bar text
  status.text = status.name;

end


--Totem
--================================================
  
function ChronoBars.Bar_InitStatusTotem (bar, status)
end

function ChronoBars.Bar_UpdateStatusTotem (bar, status, now)

  local set = bar.settings;
  local _, name, start, duration, icon = GetTotemInfo( set.totem.type );

  --Update bar time
  if (name and start and duration) then
  
    --The name we get includes totem rank so search for substring
    if (strfind( name, status.name )) then
      status.expires = start + duration;
      status.duration = duration;
      status.text = name;
      status.icon = icon;
    else
      status.expires = nil;
      status.duration = nil;
    end
  else
    status.expires = nil;
    status.duration = nil;
  end
  
end

--Custom
--===================================================

function ChronoBars.Bar_InitStatusCustom (bar, status)
end

function ChronoBars.Bar_UpdateStatusCustom (bar, status, now, event, arg1, arg2)

  local set = bar.settings;
  local activate = false;

  if (set.custom.trigger == CB.CUSTOM_TRIGGER_SPELL_CAST) then
  
    if (event == "UNIT_SPELLCAST_SUCCEEDED" and arg1 == "player") then
      local spellName = arg2;
      if (spellName == status.name) then
        activate = true;
      end
    end
    
  elseif (set.custom.trigger == CB.CUSTOM_TRIGGER_BAR_ACTIVE) then
  
    if (event == "CHRONOBARS_BAR_ACTIVATED") then
      local otherBar = arg1;
      if (strfind( otherBar.settings.name, status.name )) then
        status.icon = otherBar.icon:GetTexture();
        activate = true;
      end
    end
  end
  
  --Activate bar if trigger detected
  if (activate) then
    status.duration = set.custom.duration;
    status.expires = now + set.custom.duration;
  end
  
  --Update bar text
  status.text = status.name;
  
end

--Auto-Attack
--===================================================

function ChronoBars.Bar_InitStatusAuto (bar, status)

  local set = bar.settings;
  if (set.auto.type == CB.AUTO_TYPE_WAND or set.auto.type == CB.AUTO_TYPE_BOW) then
  
    --Get the localized name of the ranged attack spell
    local rangedName;
    if (set.auto.type == CB.AUTO_TYPE_WAND)
    then rangedName = GetSpellInfo( 5019 );
    else rangedName = GetSpellInfo( "75" );
    end
    
    --Init bar text and icon
    status.text = rangedName;
    status.icon = GetSpellTexture( rangedName );
    
    --Force text to effect name setting
    bar.settings.name = status.text;
    status.name = status.text;
 
  elseif (set.auto.type == CB.AUTO_TYPE_MAIN_HAND or set.auto.type == CB.AUTO_TYPE_OFF_HAND) then
  
    --Get inventory slot
    local slotId;
    
    if (set.auto.type == CB.AUTO_TYPE_MAIN_HAND) then
      slotId = GetInventorySlotInfo( "MainHandSlot" );
      status.text = "Main Hand";
    
    elseif (set.auto.type == CB.AUTO_TYPE_OFF_HAND) then
      slotId = GetInventorySlotInfo( "SecondaryHandSlot" );
      status.text = "Off Hand";
    end
    
    --Set item icon
    itemId = GetInventoryItemID( "player", slotId );
    status.icon = GetItemIcon( itemId );
    
    --Force text to effect name setting
    bar.settings.name = status.text;
    status.name = status.text;
    
  end
end

function ChronoBars.Bar_UpdateStatusAuto (bar, status, now, event, arg1, arg2, arg3)
  
  local set = bar.settings;
  
  if (set.auto.type == CB.AUTO_TYPE_WAND or set.auto.type == CB.AUTO_TYPE_BOW) then
  
    --Register spellcast event when autoattack begins
    if (event == "START_AUTOREPEAT_SPELL") then
      bar:RegisterEvent( "UNIT_SPELLCAST_SUCCEEDED");
    
    --Unregister spellcast event when autoattack stops
    elseif (event == "STOP_AUTOREPEAT_SPELL") then
      bar:UnregisterEvent( "UNIT_SPELLCAST_SUCCEEDED" );
      
    --Check if player cast ranged spell
    elseif (event == "UNIT_SPELLCAST_SUCCEEDED"
    and arg1 == "player" and arg2 == status.name) then
      
      --Get ranged attack speed
      local rangedSpeed = UnitRangedDamage( "player" );
      
      --Update time
      if (rangedSpeed) then
        status.duration = rangedSpeed;
        status.expires = now + status.duration;
      end
    end
    
  elseif (set.auto.type == CB.AUTO_TYPE_MAIN_HAND or set.auto.type == CB.AUTO_TYPE_OFF_HAND) then
  
    --Register combatlog event when autoattack begins
    if (event == "PLAYER_ENTER_COMBAT") then
      bar:RegisterEvent( "COMBAT_LOG_EVENT_UNFILTERED" );
      
    --Unregister combatlog event when autoattack stops
    elseif (event == "PLAYER_LEAVE_COMBAT") then
      bar:UnregisterEvent( "COMBAT_LOG_EVENT_UNFILTERED" );
    
    --Check if player swinged with weapon
    elseif (event == "COMBAT_LOG_EVENT_UNFILTERED"
    and strsub( arg2, 1, 5 ) == "SWING"
    and arg3 == UnitGUID("player")) then
    
      --Get attack speed
      local attackSpeed;
      
      if (set.auto.type == CB.AUTO_TYPE_MAIN_HAND) then
        attackSpeed = UnitAttackSpeed( "player" );
        
      elseif (set.auto.type == CB.AUTO_TYPE_OFF_HAND) then
        attackSpeed = select( 2, UnitAttackSpeed( "player" ) );
      end
      
      --Update time
      if (attackSpeed) then
        status.duration = attackSpeed;
        status.expires = now + status.duration;
      end
        
    end
  end
  
end

--Temporary Weapon Enchant
--===================================================

function ChronoBars.Bar_InitStatusEnchant (bar, status)
  
  local set = bar.settings;
  
  --Get inventory slot
  local slotId;
  
  if (set.enchant.hand == CB.HAND_MAIN) then
    slotId = GetInventorySlotInfo( "MainHandSlot" );
  
  elseif (set.enchant.hand == CB.HAND_OFF) then
    slotId = GetInventorySlotInfo( "SecondaryHandSlot" );
  end
  
  --Set item icon
  local itemId = GetInventoryItemID( "player", slotId );
  status.icon = GetItemIcon( itemId );
  
end

function ChronoBars.Bar_UpdateStatusEnchant (bar, status, now, event, ...)

  local set = bar.settings;
  
  --Get inventory slot and enchant info
  local slotId, enchantOn, enchantTime, enchantCharges;
  
  if (set.enchant.hand == CB.HAND_MAIN) then
    slotId = GetInventorySlotInfo( "MainHandSlot" );
    enchantOn, enchantTime, enchantCharges = GetWeaponEnchantInfo();
    
  elseif (set.enchant.hand == CB.HAND_OFF) then
    slotId = GetInventorySlotInfo( "SecondaryHandSlot" );
    enchantOn, enchantTime, enchantCharges = select( 4, GetWeaponEnchantInfo() );
  end
  
  --Check if enchant is up
  if (enchantOn) then
  
    --Check if name of the enchant matches
    local enchantName = CB.GetWeaponEnchantName( slotId );
    if (enchantName and strfind( enchantName, status.name )) then
    
      --There is no way to get total duration, assuming 30min
      status.duration = 1800;
      status.expires = now + enchantTime / 1000;

      --Update item icon and enchant name
      local itemId = GetInventoryItemID( "player", slotId );
      status.icon = GetItemIcon( itemId );
      status.text = enchantName;
      
    else
      status.duration = nil;
      status.expires = nil;
    end
  else
    status.duration = nil;
    status.expires = nil;
  end
  
end

--Utility enchant scanning from weapon tooltip
--========================================================

function ChronoBars.GetWeaponEnchantName (inventorySlotId)

  local tt1 = CB.GetTooltip(1); tt1:ClearLines();
  local tt2 = CB.GetTooltip(2); tt2:ClearLines();
  
  --Set first tooltip to match inventory slot
  tt1:SetInventoryItem( "player", inventorySlotId );
  
  --Get hyperlink from first tooltip and set it to second tooltip
  local itemLink = select( 2, tt1:GetItem() );
  tt2:SetHyperlink( itemLink );
  
  --Iterate all the lines of first tooltip
  local numLines1 = tt1:NumLines();
  for l1=1,numLines1 do
  
    --Get line text and check if green color (red = 0)
    local line1 = CB.GetTooltipLineLeft( tt1, l1 );
    local text1 = line1:GetText();
    if (line1:GetTextColor() == 0) then

      --Iterate all the lines of second tooltip
      local found = false;
      local numLines2 = tt2:NumLines();    
      for l2=1,numLines2 do
      
        --Get line text and check if line from first tooltip found
        local line2 = CB.GetTooltipLineLeft( tt2, l2 );
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

--Utility scannable tooltips
--========================================================

function ChronoBars.GetTooltip (index)

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

function ChronoBars.GetTooltipLineLeft (tooltip, index)
  return tooltip.text[ index ].left;
end

function ChronoBars.GetTooltopLineRight (tooltip, index)
  return tooltip.text[ index ].right;
end
