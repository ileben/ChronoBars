--[[

====================================================
ChronoBars - buff, debuff, cooldown, totem tracker
Author: Ivan Leben
====================================================

--]]

local CB = ChronoBars;

function ChronoBars.Bar_InitEffect (bar)

  local set = bar.settings;
  
  --Create new effect names table if missing
  if (bar.effectDesc == nil) then
    bar.effectDesc = {};
  end
  
  --Create new effects table if missing
  if (bar.effectStatus == nil) then
    bar.effectStatus = {};
  end

  --Break the comma-separated list of effect names
  CB.Util_ClearTable( bar.effectDesc );
  CB.Util_CommaSeparate( bar.effectDesc, set.name );
  
  --Walk the list of effects
  bar.numEffectStatus = table.getn( bar.effectDesc );
  for i=1,bar.numEffectStatus do
    
    --Add new effect status if missing
    if (bar.effectStatus[ i ] == nil) then
      bar.effectStatus[ i ] = {};
    end
    
    --Reset effect status
    local status = bar.effectStatus[ i ];
    status.desc = bar.effectDesc[ i ];
    status.id = tonumber( status.desc );
    status.name = nil;
    status.count = nil;
    status.maxCount = nil;
    status.duration = nil;
    status.expires = nil;
    status.chargeDuration = nil;
    status.chargeExpires = nil;
    status.iconDuration = nil;
    status.iconStart = nil;
    status.iconUsable = true;
    status.usableCdExpires = nil;
    
    --Init effect status
    local status = bar.effectStatus[i];
    
    if (set.type == CB.EFFECT_TYPE_AURA) then
      CB.Bar_InitStatusAura( bar, status );
      
    elseif (set.type == CB.EFFECT_TYPE_MULTI_AURA) then
      CB.Bar_InitStatusMultiAura( bar, status );

    elseif (set.type == CB.EFFECT_TYPE_CD) then
      CB.Bar_InitStatusCd( bar, status );
      
    elseif (set.type == CB.EFFECT_TYPE_CHARGES) then
      CB.Bar_InitStatusCharges( bar, status );

    elseif (set.type == CB.EFFECT_TYPE_USABLE) then
      CB.Bar_InitStatusUsable( bar, status );

    elseif (set.type == CB.EFFECT_TYPE_TOTEM) then
      CB.Bar_InitStatusTotem( bar, status );

    elseif (set.type == CB.EFFECT_TYPE_CUSTOM) then
      CB.Bar_InitStatusCustom( bar, status );
      
    elseif (set.type == CB.EFFECT_TYPE_AUTO) then
      CB.Bar_InitStatusAuto( bar, status );
      
    elseif (set.type == CB.EFFECT_TYPE_ENCHANT) then
      CB.Bar_InitStatusEnchant( bar, status );
      
    end
    
    --Init bar status to first effect
    if (i == 1) then
	  bar.status.desc = status.desc;
      bar.status.id = status.id;
      bar.status.name = status.name;
      bar.status.icon = status.icon;
    end
  end
  
end

function ChronoBars.Bar_UpdateEffect (bar, now, event, ...)

  local set = bar.settings;
  local maxExpires = nil;
  local effectDeactivated = false;

  --Walk the list of effects
  for i=1,bar.numEffectStatus do
  
    --Update effect status
    local status = bar.effectStatus[i];
    
    if (set.type == CB.EFFECT_TYPE_AURA) then
      CB.Bar_UpdateStatusAura( bar, status, now, event, ... );
      
    elseif (set.type == CB.EFFECT_TYPE_MULTI_AURA) then
      CB.Bar_UpdateStatusMultiAura( bar, status, now, event, ... );

    elseif (set.type == CB.EFFECT_TYPE_CD) then
      CB.Bar_UpdateStatusCd( bar, status, now, event, ... );
      
    elseif (set.type == CB.EFFECT_TYPE_CHARGES) then
      CB.Bar_UpdateStatusCharges( bar, status, now, event, ... );

    elseif (set.type == CB.EFFECT_TYPE_USABLE) then
      CB.Bar_UpdateStatusUsable( bar, status, now, event, ... );

    elseif (set.type == CB.EFFECT_TYPE_TOTEM) then
      CB.Bar_UpdateStatusTotem( bar, status, now, event, ... );

    elseif (set.type == CB.EFFECT_TYPE_CUSTOM) then
      CB.Bar_UpdateStatusCustom( bar, status, now, event, ... );
      
    elseif (set.type == CB.EFFECT_TYPE_AUTO) then
      CB.Bar_UpdateStatusAuto( bar, status, now, event, ... );
      
    elseif (set.type == CB.EFFECT_TYPE_ENCHANT) then
      CB.Bar_UpdateStatusEnchant( bar, status, now, event, ... );
    end
     
    --Check if this effect is the last to expire
    if (maxExpires == nil or (status.expires ~= nil and status.expires > maxExpires)) then
      
      --Copy to bar status
      bar.status.name = status.name;
      bar.status.icon = status.icon;
      bar.status.count = status.count;
      bar.status.maxCount = status.maxCount;
      bar.status.target = status.target;
      bar.status.duration = status.duration;
      bar.status.expires = status.expires;
      bar.status.chargeDuration = status.chargeDuration;
      bar.status.chargeExpires = status.chargeExpires;
      bar.status.iconDuration = status.iconDuration;
      bar.status.iconStart = status.iconStart;
      bar.status.iconUsable = status.iconUsable;
      
      --Update maximum expiration time
      if (status.expires ~= nil)
      then maxExpires = status.expires;
      else maxExpires = 0;
      end
    end
    
    --Track if any of effects just deactivated and needs the last update
    effectDeactivated = effectDeactivated or status.deactivated;
  end
  
  --Check if bar active and if the active status changed
  local newActive = (bar.status.duration ~= nil and bar.status.expires ~= nil);
  local reActive = (newActive and (not bar.status.active));
  local deActive = ((not newActive) and bar.status.active);
  bar.status.active = newActive;
  bar.status.deactivated = effectDeactivated or deActive;
  
  --Let other bars know if this bar just activated
  if (reActive and set.type ~= CB.EFFECT_TYPE_CUSTOM) then
    CB.BroadcastBarEvent( "CHRONOBARS_BAR_ACTIVATED", bar );
  end
  
  --Let other bars know if this bar just deactivated
  if (deActive) then
    CB.BroadcastBarEvent( "CHRONOBARS_BAR_DEACTIVATED", bar );
  end
  
  -- Update icon cooldown spinner on every event
  CB.Bar_UpdateIcon(bar)
  
end

function ChronoBars.Bar_UpdateTime (bar, now)
 
  local set = bar.settings;
  bar.status.left = 0.0;
  bar.status.ratio = 0.0;

  if (bar.status.active) then
  
    --CB.Print("Bar_UpdateTime  now " .. now .. " expires " .. (bar.status.expires or nil));
    
    if (bar.status.duration == 0 and bar.status.expires == 0) then

      --It's an infinite-duration bar
      bar.status.ratio = 1.0;

    elseif (now > bar.status.expires) then

      --It ran out
      bar.status.duration = nil;
      bar.status.expires = nil;
      bar.status.active = false;
      CB.BroadcastBarEvent( "CHRONOBARS_BAR_DEACTIVATED", bar );

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
      
      -- Override time left for display with the current charge cooldown
      if (set.type == CB.EFFECT_TYPE_CHARGES) then
        bar.status.left = bar.status.chargeExpires - now;
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

--Spell/Item
--=================================================

function ChronoBars.InitStatusSpell( status )
  
  --Init effect name and icon by spell id or spell name
  if (status.id) then
    status.name = select( 1, GetSpellInfo( status.id ) );
    status.icon = select( 3, GetSpellInfo( status.id ) );
  else
    status.name = status.desc;
    status.icon = CB.Util_GetSpellIcon( status.desc );
  end
  
  local spellId = status.id or status.name;
  _, status.maxCount, _, _ = GetSpellCharges(spellId);
  
end

function ChronoBars.InitStatusItem( status )

    --Init bar name and icon by item id or name
    if (status.id) then
		status.name = select( 1,  GetItemInfo( status.id ) );
		status.icon = select( 10, GetItemInfo( status.id ) );
    else
		status.id = CB.Util_GetItemID( status.desc );
		status.name = status.desc;
		status.icon = GetItemIcon( status.desc );
    end
	
end

function ChronoBars.GetActionUsable( actionType, status )

  local usable = nil;
  
  if (actionType  == CB.ACTION_TYPE_SPELL) then

    --Check if spell usable by ID or name
    if (status.id)
    then usable = IsUsableSpell( status.id );
    else usable = IsUsableSpell( status.name );
    end
    
  elseif (actionType == CB.ACTION_TYPE_ITEM) then
  
    --Check if item usable by ID or name
    if (status.id)
    then usable = IsUsableItem( status.id );
    else usable = IsUsableItem( status.name );
    end
  end
  
  return usable;
end

function ChronoBars.GetActionCooldown( actionType, status )

  local start, duration;
  
  if (actionType == CB.ACTION_TYPE_SPELL) then
      
    --Get spell cooldown by ID or name
    if (status.id)
    then start, duration = GetSpellCooldown( status.id );
    else start, duration = GetSpellCooldown( status.name );
    end
    
  elseif (actionType == CB.ACTION_TYPE_ITEM) then
  
    --Get item cooldown by ID or name
    if (status.id)
    then start, duration = GetItemCooldown( status.id );
    else start, duration = nil; --doesn't work with item name anymore :(
    end
  end
  
  return start, duration;
end

--Aura
--=================================================

-- UnitAura doesn't take spell ID or spell name, so
-- we have to go through the whole list to find it
function ChronoBars.UnitAuraByIdNameOrder (unitid, queryId, queryName, queryOrder, filter)

	local name, icon, count, debuffType, duration, expires, caster, canStealOrPurge, nameplateShowPersonal, id;
	
    --Walk all the auras on the unit matching the filter
	local auraOrder = 1;
    local auraIndex = 1;
	local auraMatch;
    while true do

      --Get aura info by index
	  --auraInfo = { UnitAura( set.aura.unit, auraIndex, filter ) };
      name, icon, count, debuffType, duration, expires, caster, canStealOrPurge, nameplateShowPersonal, id =
        UnitAura( unitid, auraIndex, filter );
		
      if (not name) then break end;
      auraIndex = auraIndex + 1;

      --Check if ID or name matches
      if (queryId)
      then auraMatch = (id == queryId);
      else auraMatch = (name == queryName);
      end

      --Check if order is correct
      if (auraMatch) then
        if (auraOrder == queryOrder)
		then return name, icon, count, debuffType, duration, expires, caster, canStealOrPurge, nameplateShowPersonal, id;
		end
        auraOrder = auraOrder + 1;
      end
    end
	
	return nil
end


function ChronoBars.Bar_InitStatusAura (bar, status)

	--Init by spell description
	CB.InitStatusSpell( status );
	
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

  -- Are we summing the stacks?
  if (set.aura.sum) then

    --Walk all the auras on the unit matching the filter
    local auraIndex = 1;
    while true do

      --Get aura info by index
      local tempCount, tempDur, tempExp;
      local tempName, tempIcon, tempCount, _, tempDur, tempExp, tempCaster, _, _, tempId =
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

  else

	name, icon, count, _, duration, expires = 
		CB.UnitAuraByIdNameOrder(set.aura.unit, status.id, status.name, set.aura.order, filter);
		
  end
  
  --Update status
  status.duration = duration;
  status.expires = expires;
  status.target = UnitName( set.aura.unit );
  if (icon) then status.icon = icon; end
  if (count and count > 1) then status.count = count; end
  
end

--Multi-Aura
--=================================================

function ChronoBars.Bar_InitStatusMultiAura (bar, status)

  --Init guid lookup table
  if (bar.auraBars == nil) then
    bar.auraBars = {}
  end
  
  --Clear guid lookup table
  for k,v in pairs( bar.auraBars ) do
    bar.auraBars[ k ] = nil;
  end
  
  --Init by spell description
  CB.InitStatusSpell( status );
  
end

function ChronoBars.Bar_UpdateStatusMultiAura (bar, status, now, event, ...)
  
  --CB.Print("Multi aura event " .. event);
  
  local set = bar.settings;
  local applied, removed, refresh;
  local unitGuid, unitName, unitId;
  local duration, expires;
  
  if (event == "CHRONOBARS_MULTI_AURA_UPDATE") then
     
    -- A duplicate multi-aura bar received status update from the main driver multi-aura bar
    -- We know this is a duplicate bar because this event is only registered on those
    
    local unitGuid, unitName, unitId, spellName, duration, expires = select( 1, ... );
    status.name = spellName;
    status.target = unitName;
    status.duration = duration;
    status.expires = expires;
    
    -- Early exit to avoid further processing of event
    return;
    
  elseif (event == "CHRONOBARS_BAR_DEACTIVATED") then
  
    -- The main driver multi-aura bar received deactivated event from one of the duplicate multi-aura bars
    -- We know this is the main bar because we don't register this event on the duplicates
    
    -- Check if deactivated bar belongs to this multi-aura bar
    local auraBar = select( 1, ... );
    if (auraBar.multiBar == bar) then
      
      --Remove bar from the guid lookup table
      bar.auraBars[ auraBar.unitGuid ] = nil;
      auraBar.unitGuid = nil;
      auraBar.multiBar = nil;
    end
    
    -- Early exit to avoid further processing of event
    return;
  
  elseif (event == "COMBAT_LOG_EVENT_UNFILTERED") then
  
    local eventInfo = { CombatLogGetCurrentEventInfo() }
    
    --Check the type of combat event
    local combatEvent = eventInfo[2];
    --CB.Print("Multi aura COMBAT event " .. (combatEvent or "nil"));
    
    -- From here on processing aura events
    applied = (combatEvent == "SPELL_AURA_APPLIED");
    removed = (combatEvent == "SPELL_AURA_REMOVED");
    refresh = (combatEvent == "SPELL_AURA_REFRESH");
    if (not (applied or removed or refresh)) then return end;
    
    --Check if source of event is player
    local srcGuid = eventInfo[4];
    if (srcGuid ~= UnitGUID("player")) then return end;
    
    --Check if aura name matches effect
    local spellName = eventInfo[13];
    if (spellName ~= status.name) then return end;
    
    --Check if aura type matches effect
    local auraType = eventInfo[15];
    if (auraType == "BUFF"   and set.aura.type ~= CB.AURA_TYPE_BUFF) then return end;
    if (auraType == "DEBUFF" and set.aura.type ~= CB.AURA_TYPE_DEBUFF) then return end;
    
    --Get unit info
    unitGuid = eventInfo[8];
    unitName = eventInfo[9];
    
    --Get UnitID from UnitFlags
    local unitFlags = eventInfo[10];
    if (bit.band( unitFlags, COMBATLOG_OBJECT_TARGET) > 0) then
      unitId = "target";
    elseif (bit.band( unitFlags, COMBATLOG_OBJECT_FOCUS) > 0) then
      unitId = "focus";
    end
    
    if (removed) then
    
      --Check for existing bar
      local auraBar = bar.auraBars[ unitGuid ];
      if (auraBar ~= nil) then
      
        --Send update event
        CB.SendBarEvent( auraBar, "CHRONOBARS_MULTI_AURA_UPDATE",
          unitGuid, unitName, unitId, status.name, nil, nil );
      end
      return;
      
    elseif (unitId) then
    
      --Update time with true aura info
      local filter = set.aura.type;
      if (set.aura.byPlayer) then filter = filter.."|PLAYER"; end
      duration, expires = select( 5, CB.UnitAuraByIdNameOrder( unitId, nil, status.name, 1, filter ));
      if (duration == nil or expires == nil) then return end;
      
    else
      
      --Update time with estimated value
      duration = bar.settings.custom.duration;
      expires = now + duration;
    end
    
  else -- Any of the other registered events
    
    --Get UnitID
    if (event == "UNIT_AURA") then
      unitId = select( 1, ... );
    elseif (event == "UNIT_TARGET") then
      if (select( 1, ... ) == "player") then return end;
      unitId = select( 1, ... ) .. "target";
    elseif (event == "PLAYER_TARGET_CHANGED") then
      unitId = "target";
    elseif (event == "PLAYER_FOCUS_CHANGED") then
      unitId = "focus";
    elseif (event == "UPDATE_MOUSEOVER_UNIT") then
      unitId = "mouseover";
    else return end
    
    --Get unit info from UnitID
    unitGuid = UnitGUID( unitId );
    unitName = UnitName( unitId );
    if (unitGuid == nil) then return end;
    
    --Update time with true aura info
    local filter = set.aura.type;
    if (set.aura.byPlayer) then filter = filter.."|PLAYER"; end
    duration, expires = select( 5, CB.UnitAuraByIdNameOrder( unitId, nil, status.name, 1, filter ));
    if (duration == nil or expires == nil) then return end;
    
    --We only use these events for application
    applied = true;
    
  end
  
  --Find existing duplicate bar for this unit guid and create a new one if missing
  local auraBar = bar.auraBars[ unitGuid ];
  if (auraBar == nil) then
    
    --Add new bar to this group
    auraBar = CB.UI_AddBar( bar.group, auraBar );
    CB.UI_RemoveBarWhenInactive( auraBar );
    
    --Store into guid lookup table
    auraBar.multiBar = bar;
    auraBar.unitGuid = unitGuid;
    bar.auraBars[ unitGuid ] = auraBar;
    
    --Apply same settings as this bar to the new bar
    local profile = CB.GetActiveProfile();
    CB.Bar_ApplySettings( auraBar, profile, bar.groupId, bar.barId );
    CB.Group_ApplySettings( auraBar.group, profile, auraBar.groupId );
    
    --Register update event
    CB.RegisterBarEvent( auraBar, "CHRONOBARS_MULTI_AURA_UPDATE" );
  end
  
  --Send update event to the duplicate bar for this unit guid
  CB.SendBarEvent( auraBar, "CHRONOBARS_MULTI_AURA_UPDATE",
    unitGuid, unitName, unitId, status.name, duration, expires );
  
end

--Cooldown
--===================================================

function ChronoBars.Bar_InitStatusCd (bar, status)
      
  if (bar.settings.cd.type == CB.CD_TYPE_SPELL) then
  
	--Init by spell description
	CB.InitStatusSpell( status );
    
  elseif (bar.settings.cd.type == CB.CD_TYPE_ITEM) then
  
	--Init by item description
	CB.InitStatusItem( status );
	
  end
end

function ChronoBars.Bar_UpdateStatusCd (bar, status, now)

  local set = bar.settings;
  local start, duration;
  
  start, duration = CB.GetActionCooldown(set.cd.type, status);
  
  --Pass unfiltered cooldown and usability to icon
  status.iconStart = start;
  status.iconDuration = duration;
  status.iconUsable = CB.GetActionUsable(set.cd.type, status);

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
  
end

--Charges
--===================================================

function ChronoBars.Bar_InitStatusCharges (bar, status)
      
  if (bar.settings.cd.type == CB.CD_TYPE_SPELL) then
  
	--Init by spell description
	CB.InitStatusSpell( status );
    
  elseif (bar.settings.cd.type == CB.CD_TYPE_ITEM) then
  
	--Init by item description
	CB.InitStatusItem( status );
	
  end
end

function ChronoBars.Bar_UpdateStatusCharges (bar, status, now)

  local set = bar.settings;
  local start, duration, curCharges, maxCharges;
       
  if (set.cd.type == CB.CD_TYPE_SPELL) then
      
    --Get spell cooldown by ID or name   
    local spellId = status.id or status.name;
    curCharges, maxCharges, start, duration = GetSpellCharges(spellId);
    
  elseif (set.cd.type == CB.CD_TYPE_ITEM) then
  
    --Get item cooldown by ID or name
    if (status.id)
    then start, duration = GetItemCooldown( status.id );
    else start, duration = nil; --doesn't work with item name anymore :(
    end
  end
  
  --Pass unfiltered cooldown and usability to icon
  status.iconUsable = CB.GetActionUsable(set.cd.type, status);
  status.iconStart, status.iconDuration = CB.GetActionCooldown(set.cd.type, status);
  
  --CB.Print(" Bar_UpdateStatusCharges usable " .. (tostring(status.iconUsable) or "nil") .. " start " .. (start or "nil") .. " duration " .. (duration or "nil") .. " curCharges " .. (curCharges or "nil") .. " maxCharges " .. (maxCharges or "nil"));
 
  if (curCharges == nil or maxCharges == nil) then
  
    status.expires = nil;
    status.duration = nil;
    status.count = nil;
    status.maxCount = nil;
   
  elseif (curCharges == maxCharges) then

    status.expires = nil;
    status.duration = nil;
    status.count = curCharges;
    status.maxCount = maxCharges;
    
    --Update UI one last time
    status.deactivated = true;
    
  else
  
    --Sub-cooldown for the current charge
    status.chargeExpires = start + duration;
    status.chargeDuration = duration;
    
    --Cooldown for the whole bar includes all charges
    local totalStart = start - curCharges * duration;
    local totalDuration = maxCharges * duration;
    status.expires = totalStart + totalDuration;
    status.duration = totalDuration;
    
    status.count = curCharges;
    status.maxCount = maxCharges;
    
  end
  
end


--Usable
--===================================================

function ChronoBars.Bar_InitStatusUsable (bar, status)

  if (bar.settings.usable.type == CB.USABLE_TYPE_SPELL) then
  
	--Init by spell description
	CB.InitStatusSpell( status );
    
  elseif (bar.settings.usable.type == CB.USABLE_TYPE_ITEM) then
  
	--Init by item description
	CB.InitStatusItem( status );

  end  
end

function ChronoBars.Bar_UpdateStatusUsable (bar, status, now)

  local set = bar.settings;
  local usable, start, duration;

  usable = CB.GetActionUsable(set.usable.type, status);
  start, duration = CB.GetActionCooldown(set.usable.type, status);
  
  --Pass unfiltered cooldown and usability to icon
  status.iconStart = start;
  status.iconDuration = duration;
  status.iconUsable = usable;
  
  if (set.usable.includeCd) then
  
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
  
  --Update status
  if (usable) then
    status.duration = 0;
    status.expires = 0;
  else
    status.duration = nil;
    status.expires = nil;
  end

end


--Totem
--================================================
  
function ChronoBars.Bar_InitStatusTotem (bar, status)

  --Init spellName and icon by spell id or name
  if (status.id) then
    status.spellName = select( 1, GetSpellInfo( status.id ) );
    status.icon = select( 3, GetSpellInfo( status.id ) );
  else
	status.spellName = status.desc;
    status.icon = CB.Util_GetSpellIcon( status.desc );
  end
  
end

function ChronoBars.Bar_UpdateStatusTotem (bar, status, now)

  local set = bar.settings;
  local _, name, start, duration, icon = GetTotemInfo( set.totem.type );

  --Update bar time
  if (name and start and duration) then
  
    --The name we get includes totem rank so search for substring
    if (strfind( name, status.spellName )) then
      status.name = name;
      status.icon = icon;
      status.expires = start + duration;
      status.duration = duration;
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

  local set = bar.settings;
  
  if (set.custom.trigger == CB.CUSTOM_TRIGGER_SPELL_CAST) then
  
	--Init by spell description
	CB.InitStatusSpell( status );
  
  elseif (set.custom.trigger == CB.CUSTOM_TRIGGER_BAR_ACTIVE) then
     
    --Walk UI groups
    local numGroups = table.getn( CB.groups );
    for g = 1, numGroups do
      
      --Walk UI bars
      local numBars = table.getn( CB.groups[g].bars );
      for b = 1, numBars do
      
        --Look for bar with matching effect name in settings
        local otherBar = CB.groups[g].bars[b];
        if (strfind( otherBar.settings.name, status.desc )) then
        
          --Copy name and icon from matching bar
          if (otherBar.status.icon) then
			status.name = otherBar.status.name;
            status.icon = otherBar.status.icon;
          end
        end
      end
    end
  end
  
end

function ChronoBars.Bar_UpdateStatusCustom (bar, status, now, event, arg1, arg2)

	local set = bar.settings;
	local activate = false;
	
	if (set.custom.trigger == CB.CUSTOM_TRIGGER_SPELL_CAST) then

		--Check if spell with matching name was cast
		if (event == "UNIT_SPELLCAST_SUCCEEDED" and arg1 == "player") then
			local spellName = arg2;
			if (spellName == status.name) then
				activate = true;
			end
		end

	elseif (set.custom.trigger == CB.CUSTOM_TRIGGER_BAR_ACTIVE) then

		--Check if bar with matching name just activated
		if (event == "CHRONOBARS_BAR_ACTIVATED") then
			local otherBar = arg1;
			if (strfind( otherBar.settings.name, status.desc )) then
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
    
    --Init bar name and text and icon to match spell
    status.name = rangedName;
    status.icon = GetSpellTexture( rangedName );
 
  elseif (set.auto.type == CB.AUTO_TYPE_MAIN_HAND or set.auto.type == CB.AUTO_TYPE_OFF_HAND) then
  
    --Get inventory slot and init bar name and text
    local slotId;
    
    if (set.auto.type == CB.AUTO_TYPE_MAIN_HAND) then
      slotId = GetInventorySlotInfo( "MainHandSlot" );
      status.name = "Main Hand";
      
    elseif (set.auto.type == CB.AUTO_TYPE_OFF_HAND) then
      slotId = GetInventorySlotInfo( "SecondaryHandSlot" );
      status.name = "Off Hand";
    end
    
    --Init bar icon to match item
    itemId = GetInventoryItemID( "player", slotId );
    status.icon = GetItemIcon( itemId );

  end
end

function ChronoBars.Bar_UpdateStatusAuto (bar, status, now, event, arg1, arg2, arg3, arg4)
  
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
    and arg4 == UnitGUID("player")) then
    
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
  
  --Init bar icon to match item
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
    local enchantName = CB.Util_GetWeaponEnchantName( slotId );
    if (enchantName and strfind( enchantName, status.desc )) then
    
      --There is no way to get total duration, assuming 30min
      status.duration = 1800;
      status.expires = now + enchantTime / 1000;

      --Update item icon and enchant name
      local itemId = GetInventoryItemID( "player", slotId );
      status.icon = GetItemIcon( itemId );
      status.name = enchantName;
      
    else
      status.duration = nil;
      status.expires = nil;
    end
  else
    status.duration = nil;
    status.expires = nil;
  end
  
end
