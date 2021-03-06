--[[

====================================================
ChronoBars - buff, debuff, cooldown, totem tracker
Author: Ivan Leben
====================================================

--]]

local CB = ChronoBars;


--Bar and Group cache
--================================================================================

function ChronoBars.NewBar ()
  
  local bar = nil;
  local numBars = table.getn( CB.cache.bars );
  
  --Check if any unused bars in cache
  if (CB.cache.numUsedBars < numBars) then
    CB.cache.numUsedBars = CB.cache.numUsedBars + 1;
    bar = CB.cache.bars[ CB.cache.numUsedBars ];
  else
    --Create new bar if all bars used
    CB.cache.numUsedBars = numBars + 1;
    bar = CB.Bar_Create( "ChronoBars_Bar"..CB.cache.numUsedBars );
    bar.cacheId = CB.cache.numUsedBars;
    table.insert( CB.cache.bars, bar );
  end
  
  return bar;
end

function ChronoBars.NewGroup ()

  local grp = nil;
  local numGroups = table.getn( CB.cache.groups );
  
  --Check if any unused groups in cache
  if (CB.cache.numUsedGroups < numGroups) then
    CB.cache.numUsedGroups = CB.cache.numUsedGroups + 1;
    grp = CB.cache.groups[ CB.cache.numUsedGroups ];
  else
    --Create new group if all groups used
    CB.cache.numUsedGroups = numGroups + 1;
    grp = CB.Group_Create( "ChronoBars_Group"..CB.cache.numUsedGroups );
    grp.cacheId = CB.cache.numUsedGroups;
    table.insert( CB.cache.groups, grp );
  end

  return grp;
end

function ChronoBars.FreeBar (bar)

  --Swap freed bar with last used bar and their ids
  if (bar.cacheId < CB.cache.numUsedBars) then

    local barId = bar.cacheId;
    local lastId = CB.cache.numUsedBars;
    local last = CB.cache.bars[ lastId ];
    
    CB.cache.bars[ barId ] = last;
    CB.cache.bars[ lastId ] = bar; 
    
    bar.cacheId = lastId;
    last.cacheId = barId;
  end
  
  CB.cache.numUsedBars = CB.cache.numUsedBars - 1;
end

function ChronoBars.FreeGroup (grp)

  --Swap freed group with last used group and their ids
  if (grp.cacheId < CB.cache.numUsedGroups) then
  
    local grpId = grp.cacheId;
    local lastId = CB.cache.numUsedGroups;
    local last = CB.cache.groups[ lastId ];
    
    CB.cache.groups[ grpId ] = last;
    CB.cache.groups[ lastId ] = grp;
    
    grp.cacheId = lastId;
    last.cacheId = grpId;
  end
  
  CB.cache.numUsedGroups = CB.cache.numUsedGroups - 1;
end

function ChronoBars.FreeAllBars ()
  CB.cache.numUsedBars = 0;
end

function ChronoBars.FreeAllGroups ()
  CB.cache.numUsedGroups = 0;
end

--Bar and Group hierarchy
--================================================================================

function ChronoBars.UI_AddGroup ()
  local grp = CB.NewGroup();
  table.insert( CB.groups, grp );
  grp:Show();
  return grp;
end

function ChronoBars.UI_AddBar (grp)
  local bar = CB.NewBar();
  table.insert( grp.bars, bar );
  bar.removeInactive = false;
  bar.group = grp;
  bar:Show();
  return bar;
end

function ChronoBars.UI_RemoveGroup (grp)
  local numGroups = table.getn( CB.groups );
  for g=1,numGroups do
    if (CB.groups[g] == grp) then
      CB.UI_RemoveAllBars( grp );
      CB.FreeGroup( grp );
      grp:Hide();
      table.remove( CB.groups, g );
      return;
    end
  end
end

function ChronoBars.UI_RemoveBar (bar)
  local numBars = table.getn( bar.group.bars );
  for b=1,numBars do
    if (bar.group.bars[b] == bar) then
      CB.FreeBar( bar );
      bar:Hide();
      table.remove( bar.group.bars, b );
      return;
    end
  end
end

function ChronoBars.UI_RemoveAllBars (grp)
  local numBars = table.getn( grp.bars );
  for b=numBars,1,-1 do
    CB.FreeBar( grp.bars[ b ] );
	grp.bars[ b ]:Hide();
    table.remove( grp.bars );
  end
end

function ChronoBars.UI_RemoveAllGroups ()

  local numGroups = table.getn( CB.groups );
  for g=numGroups,1,-1 do
  
    local numBars = table.getn( CB.groups[g].bars );
    for b=numBars,1,-1 do
    
      CB.groups[ g ].bars[ b ]:Hide();
      table.remove( CB.groups[g].bars );
    end
    
    CB.groups[ g ]:Hide();
    table.remove( CB.groups );
  end
  
  CB.FreeAllBars();
  CB.FreeAllGroups();
end

function ChronoBars.UI_RemoveBarWhenInactive (bar)
  bar.removeInactive = true;
end

function ChronoBars.UI_RemoveInactiveBars (grp)
  local numBars = table.getn( grp.bars );
  for b=numBars,1,-1 do
  
    local bar = grp.bars[b];
    if ((not bar.status.active)
    and (not bar.status.animating)
    and bar.removeInactive) then
  
      CB.UI_RemoveBar( bar );
      bar.removeInactive = false;
      
    end
  end
end

--Bar and group manipulation
--===========================================================================

function ChronoBars.Bar_OnMouseDown (bar, button)
  if (button == "RightButton" and CB.designMode) then
	CB.ShowBarConfig (bar);
  end
end

function ChronoBars.BarIcon_OnMouseDown( icon, button )
	CB.Bar_OnMouseDown( icon.bar, button );
end


function ChronoBars.Bar_OnDragStart (bar)

  if (CB.designMode) then
    bar.group:StartMoving();
  end
end

function ChronoBars.Bar_OnDragStop (bar)

  if (CB.designMode) then
    bar.group:StopMovingOrSizing();
    local x = bar.group:GetLeft();
    local y = bar.group:GetBottom();
    bar.group.settings.x = x - GetScreenWidth()/2;
    bar.group.settings.y = y - GetScreenHeight()/2;
    ChronoBars.UpdateBarSettings();
  end
end

function ChronoBars.BarIcon_OnDragStart( icon )
	CB.Bar_OnDragStart( icon.bar );
end

function ChronoBars.BarIcon_OnDragStop( icon )
	CB.Bar_OnDragStop( icon.bar );
end

function ChronoBars.CreateSpark ( bar )
  local spark = bar:CreateTexture( nil, "ARTWORK", nil, CB.LAYER_SPARK );
  spark:SetTexture( "Interface\\CastingBar\\UI-CastingBar-Spark" );
  spark:SetBlendMode( "ADD" );
  spark:SetWidth( 32 );
  spark:SetHeight( 60 );
  return spark;
end

function ChronoBars.ApplySparkSettings(spark, settings, gsettings)
  local h = CB.RoundToPixel( gsettings.height );
  spark:SetWidth( settings.style.spark.width );
  spark:SetHeight( h * settings.style.spark.height );
end

function ChronoBars.CreateNotch( bar )
  local notch = bar:CreateTexture( nil, "ARTWORK", nil, CB.LAYER_NOTCH );
  --notch:SetTexture("Interface\\AddOns\\ChronoBars\\Textures\\Notch.tga");
  --notch:SetTexture("Interface\\AddOns\\ChronoBars\\Textures\\White.tga");
  --notch:SetTexture("Interface\\AddOns\\ChronoBars\\Textures\\Notch2.tga");
  notch:SetTexture("Interface\\AddOns\\ChronoBars\\Textures\\NotchLeft.tga");
  --notch:SetTexture("Interface\\AddOns\\ChronoBars\\Textures\\NotchTriangle.tga");
  notch:SetWidth( 2 );
  notch:SetHeight( 10 );
  return notch;
end

function ChronoBars.ApplyNotchSettings( notch, settings, gsettings)
  local h = CB.RoundToPixel( gsettings.height );
  local p = CB.RoundToPixel( gsettings.padding );
  local c = settings.style.notch.color;
  --local hh = (h - 2*p - 2) * settings.style.notch.height;
  --notch:SetWidth( hh );
  --notch:SetHeight( hh );
  notch:SetWidth( settings.style.notch.width );
  notch:SetHeight( (h - 2*p - 2) * settings.style.notch.height );
  notch:SetGradientAlpha( "HORIZONTAL",
      c.r, c.g, c.b, c.a,
      c.r, c.g, c.b, c.a);
end

function ChronoBars.Bar_Create (name)

  local bar = CreateFrame( "Frame", name );

  local bg = bar:CreateTexture( nil, "BACKGROUND" );
  bar.bg = bg;

  local fg = bar:CreateTexture( nil, "ARTWORK", nil, CB.LAYER_FG );
  bar.fg = fg;

  local fgBlink = bar:CreateTexture( nil, "ARTWORK" );
  bar.fgBlink = fgBlink;
  
  local fgFade = bar:CreateTexture( nil, "ARTWORK", nil, CB.LAYER_FG_FADE);
  bar.fgFade = fgFade;
  
  local icon = CreateFrame( "Frame", name.."IconFrame" );
  icon:SetParent( bar );
  icon.bar = bar;
  bar.icon = icon;
  
  local iconBg = icon:CreateTexture( nil, "BACKGROUND" );
  iconBg:SetAllPoints( icon );
  icon.bg = iconBg;
  
  local iconTex = icon:CreateTexture( nil, "ARTWORK", nil, 0  );
  iconTex:SetAllPoints( icon );
  icon.tex = iconTex;
  
  local iconFade = icon:CreateTexture( nil, "ARTWORK", nil, 1 );
  iconFade:SetAllPoints( icon );
  iconFade:Hide();
  icon.fade = iconFade;
  
  local iconCd = CreateFrame("Cooldown", "CBIconCooldown", icon, "CooldownFrameTemplate");
  iconCd:SetAllPoints( icon );
  iconCd:Show();
  icon.cd = iconCd;
  
  local spark = CB.CreateSpark( bar );
  bar.spark = spark;
  
  -- Start with 2 notches for preview, more created on demand
  bar.notches = {};
  bar.notches[1] = CB.CreateNotch( bar );
  bar.notches[2] = CB.CreateNotch( bar );

  bar:SetPoint( "LEFT", 0,0 );
  bar:SetPoint( "BOTTOM", 0,0 );
  bar:SetWidth( 100 );
  bar:SetHeight( 20 );
  bar:Hide();

  bar:EnableMouse( true );
  bar:RegisterForDrag( "LeftButton" );
  bar:SetScript( "OnDragStart", ChronoBars.Bar_OnDragStart );
  bar:SetScript( "OnDragStop", ChronoBars.Bar_OnDragStop );
  bar:SetScript( "OnMouseDown", ChronoBars.Bar_OnMouseDown );

  bar.icon:EnableMouse( true );  
  bar.icon:RegisterForDrag( "LeftButton" );
  bar.icon:SetScript( "OnDragStart", ChronoBars.BarIcon_OnDragStart );
  bar.icon:SetScript( "OnDragStop", ChronoBars.BarIcon_OnDragStop );
  bar.icon:SetScript( "OnMouseDown", ChronoBars.BarIcon_OnMouseDown );
  
  bar.events = {};

  return bar;

end

function ChronoBars.Bar_ApplySettings (bar, profile, groupId, barId)

  --Get bar and group settings
  local gsettings = profile.groups[ groupId ];
  local settings = profile.groups[ groupId ].bars[ barId ];

  --Store handy references
  bar.groupId = groupId;
  bar.barId = barId;
  bar.gsettings = gsettings;
  bar.settings = settings;

  --Init bar animation
  if (bar.anim == nil) then bar.anim = {} end
  bar.anim.ratio = 0;
  bar.anim.blink = 0;
  bar.anim.fade = 0;

  --Init bar status
  if (bar.status == nil) then bar.status = {} end
  bar.status.desc = nil;
  bar.status.id = nil;
  bar.status.name = nil;
  bar.status.icon = nil;
  bar.status.count = nil;
  bar.status.maxCount = nil;
  bar.status.target = nil;
  bar.status.duration = nil;
  bar.status.expires = nil;
  bar.status.chargeDuration = nil;
  bar.status.chargeExpires = nil;
  bar.status.iconDuration = nil;
  bar.status.iconStart = nil;
  bar.status.iconUsable = true;
  bar.status.left = 0.0;
  bar.status.ratio = 0.0;
  bar.status.active = false;
  bar.status.deactivated = false;
  bar.status.animating = true;
  
  --Init effect status
  CB.Bar_InitEffect( bar );

  --Round graphics to actual pixels
  local pad = CB.RoundToPixel( gsettings.padding );
  local h = CB.RoundToPixel( gsettings.height );
  local w = CB.RoundToPixel( gsettings.width );

  --Fetch LibSharedMedia paths
  local texPath = ChronoBars.LSM:Fetch( "statusbar", settings.style.lsmTexHandle );
  if (not texPath) then texPath = ""; end
  
  --Background
  bar.bg:SetPoint( "BOTTOMLEFT", 0,0 );
  bar.bg:SetPoint( "TOPRIGHT", 0,0 );

  --Back and front color and texture
  local b = settings.style.bgColor;
  bar.bg:SetColorTexture( b.r, b.g, b.b, b.a );

  local f = settings.style.fgColor;
  bar.fg:SetHorizTile( true );
  bar.fg:SetVertTile( false );
  bar.fg:SetGradientAlpha( "HORIZONTAL",  f.r,f.g,f.b,f.a,  f.r,f.g,f.b,f.a );

  bar.fgBlink:SetHorizTile( true );
  bar.fgBlink:SetVertTile( false );
  bar.fgBlink:SetGradientAlpha( "HORIZONTAL", f.r,f.g,f.b,0,  f.r,f.g,f.b,0 );

  if (settings.style.lsmTexHandle == "None") then
    bar.fg:SetColorTexture( 1,1,1,1 );
    bar.fgBlink:SetColorTexture( 1,1,1,1 );
  else
    bar.fg:SetTexture( texPath );
    bar.fgBlink:SetTexture( texPath );
  end
  
  --TODO: allow choosing colour of charge fade
  bar.fgFade:SetColorTexture( 0,0,0, 0.5 );  
  
  --Make foreground half-full
  local maxW = (w - 2*pad);
  local offWidth = maxW * 0.5;
  bar.fg:ClearAllPoints();
  bar.fgBlink:ClearAllPoints();
  bar.fgFade:ClearAllPoints();

  if (settings.style.fullSide == CB.SIDE_RIGHT) then
    bar.fg:SetPoint( "BOTTOMLEFT", pad, pad );
    bar.fg:SetPoint( "TOPRIGHT", -pad-offWidth, -pad );
    bar.fgBlink:SetPoint( "BOTTOMLEFT", bar.fg, "BOTTOMRIGHT", 0,0 );
    bar.fgBlink:SetPoint( "TOPRIGHT", -pad, -pad );
  else
    bar.fg:SetPoint( "BOTTOMLEFT", pad+offWidth, pad );
    bar.fg:SetPoint( "TOPRIGHT", -pad, -pad );
    bar.fgBlink:SetPoint( "BOTTOMLEFT", pad, pad );
    bar.fgBlink:SetPoint( "TOPRIGHT", bar.fg, "TOPLEFT", 0,0 );
  end
  
  -- Cover some of the foreground as if the 2nd of 3 charges was recharging
  if (settings.type == CB.EFFECT_TYPE_CHARGES and
      settings.style.fillUp) then
    
    if (settings.style.fullSide == CB.SIDE_RIGHT) then
      bar.fgFade:SetPoint( "BOTTOMLEFT", bar.fg, "BOTTOMLEFT", maxW * 0.33, 0);
      bar.fgFade:SetPoint( "TOPRIGHT", bar.fg, "TOPRIGHT", 0,0 );
    else
      bar.fgFade:SetPoint( "TOPRIGHT", bar.fg, "TOPRIGHT", -maxW * 0.33, 0 );
      bar.fgFade:SetPoint( "BOTTOMLEFT", bar.fg, "BOTTOMLEFT", 0, 0);
    end
    bar.fgFade:Show();
  else
    bar.fgFade:Hide();
  end  
  

	--Create layout table if missing
	if (bar.prevFrame == nil) then
		bar.prevFrame = {};
	end
	
	CB.Util_ClearTableKeys( bar.prevFrame );
	
	
	--Icon
	local isettings = settings.style.icon;
	if (isettings.enabled) then

		bar.icon:Show();
		
		--Texture
		local iconTex = bar.status.icon;
		if (not iconTex) then iconTex = "Interface/Icons/INV_Misc_QuestionMark"; end
		bar.icon.tex:SetTexture( iconTex );
		
		--Zoom
		if (isettings.zoom) then
		  local s = 0.08;
		  bar.icon.tex:SetTexCoord( s, 1-s, s, 1-s );
		else
		  bar.icon.tex:SetTexCoord( 0,1,0,1 );
		end
		
		--Back color
		local b = isettings.bgColor;
		if (isettings.inherit) then b = settings.style.bgColor end
		bar.icon.bg:SetColorTexture( b.r, b.g, b.b, b.a );
    
    --Fade overlay
    bar.icon.fade:SetColorTexture( 0,0,0, 0.5 );
    bar.icon.fade:Hide();
    
    --Reset last cooldown info
    bar.icon.start = nil;
    bar.icon.duration = nil;
    
		--Size
		local s = CB.RoundToPixel( isettings.size );
		if (isettings.inherit) then s = h end
		bar.icon:SetWidth( s );
		bar.icon:SetHeight( s );
		
		--Padding
		local p = CB.RoundToPixel( isettings.padding );
		if (isettings.inherit) then p = pad end
		bar.icon.tex:ClearAllPoints();
		bar.icon.tex:SetPoint( "BOTTOMLEFT", bar.icon, "BOTTOMLEFT", p, p );
		bar.icon.tex:SetPoint( "TOPRIGHT", bar.icon, "TOPRIGHT", -p,-p );
		
		--Position
		bar.prevFrame[ isettings.position ] = bar.icon;
		CB.PositionFrame( bar.icon, nil, bar.bg, nil, isettings.position, isettings.x, isettings.y, 0 );

	else
		bar.icon:Hide();
	end

	--Config text
	local displayInfo = nil;
	local displayCount = 0;
	
	if (settings.type == CB.EFFECT_TYPE_CD) then
		displayInfo = "CD";
		displayCount = nil;
	elseif (settings.type == CB.EFFECT_TYPE_USABLE) then
		displayInfo = "Usable";
		displayCount = nil;
	end
	
	--Create text table if missing
	if (bar.text == nil) then
		bar.text = {};
	end
	
	--Hide all text widgets
	for t=1,table.getn(bar.text) do
		bar.text[t]:Hide();
	end
  
	--Walk all the text settings
	local numText = table.getn( settings.style.text );
	for t=1,numText do
	repeat

		--Create new text if missing
		if (t > table.getn( bar.text )) then
			local newText = bar:CreateFontString( bar:GetName().."Text"..tostring(t) );
      newText:SetDrawLayer("ARTWORK", CB.LAYER_TEXT);
			newText:SetShadowOffset( 1, -1 );
			newText:SetWordWrap( false );
			newText:Hide();
			table.insert( bar.text, newText );
		end
		
		--Store reference to settings
		local tsettings = settings.style.text[t];
		bar.text[t].settings = tsettings;

		--Check if text enabled
		if (tsettings.enabled)
		then bar.text[t]:Show();
		else break
		end
		
		--Font
		local flags = nil;
		if (tsettings.outline) then flags = "OUTLINE" end;

		local fontPath = ChronoBars.LSM:Fetch( "font", tsettings.font );
		if (not fontPath) then fontPath = "Fonts\\FRIZQT__.TTF" end;

		bar.text[t]:SetFont( fontPath, tsettings.size, flags );

		--Color
		local tcol = tsettings.textColor;
		bar.text[t]:SetTextColor( tcol.r, tcol.g, tcol.b, tcol.a );
		
		--Shadow
		local scol = tsettings.shadowColor;
		bar.text[t]:SetShadowColor( scol.r, scol.g, scol.b, scol.a );
				
		--Position
		local prevFrame = bar.prevFrame[ tsettings.position ];
		bar.prevFrame[ tsettings.position ] = bar.text[t];
		CB.PositionFrame( bar.text[t], prevFrame, bar.bg, bar, tsettings.position, tsettings.x, tsettings.y, 5 );
		
		--Maximum width
		if (tsettings.width <= 0)
		then bar.text[t]:SetWidth(0);
		else bar.text[t]:SetWidth(tsettings.width);
		end
		
		--Text
		CB.InitText( bar.text[t] );
		CB.FormatText( bar.text[t], bar.status.name or bar.status.desc, displayCount, 0, 0, "Target Name", displayInfo );
		
	until true
	end
	
  --Spark
  if (settings.style.spark.enabled) then

    CB.ApplySparkSettings(bar.spark, settings, gsettings);
    bar.spark:Show();
      
    if (settings.style.fullSide == CB.SIDE_RIGHT)
    then bar.spark:SetPoint( "CENTER", bar.fg, "RIGHT", 0,0 );
    else bar.spark:SetPoint( "CENTER", bar.fg, "LEFT", 0,0 );
    end
  else
    bar.spark:Hide();
  end
  
  -- Charge notches
  for t=1,table.getn(bar.notches) do
    bar.notches[t]:Hide();
    bar.notches[t]:ClearAllPoints();
  end
    
  if (settings.type == CB.EFFECT_TYPE_CHARGES and settings.style.notch.enabled) then

    CB.ApplyNotchSettings(bar.notches[1], settings, gsettings);
    CB.ApplyNotchSettings(bar.notches[2], settings, gsettings);
    bar.notches[1]:Show();
    bar.notches[2]:Show();
    
    local n3 = CB.RoundToPixel(0.33 * maxW - bar.notches[1]:GetWidth()/2);
    local n6 = CB.RoundToPixel(0.66 * maxW - bar.notches[1]:GetWidth()/2);
    if (settings.style.fullSide == CB.SIDE_RIGHT) then
      bar.notches[1]:SetPoint( "LEFT", bar.fg, "LEFT", n3, 0 );
      bar.notches[2]:SetPoint( "LEFT", bar.fg, "LEFT", n6, 0 );
    else
      bar.notches[1]:SetPoint( "RIGHT", bar.fg, "RIGHT", -n3, 0 );
      bar.notches[2]:SetPoint( "RIGHT", bar.fg, "RIGHT", -n6, 0 );
    end
  end

  --Set half-transparent if disabled
  if (settings.enabled)
  then bar:SetAlpha( 1 );
  else bar:SetAlpha( 0.5 );
  end

  --Enable for mouse events
  bar:EnableMouse( true );
  bar.icon:EnableMouse( true );
  
end

-- This function is called from Group_UpdateUI only on bars that are currently active (duration not nil)
-- The group will do that in every OnUpdate which runs as long as any of its bars are active
function ChronoBars.Bar_UpdateUI (bar, now, interval)

  local p = CB.RoundToPixel( bar.gsettings.padding );
  local w = CB.RoundToPixel( bar.gsettings.width );
  local set = bar.settings;

  --Animation
  --===============================

  --Animate ratio
  local dRatio = interval * 3.0;
  if (bar.status.ratio > bar.anim.ratio) then

    --Slide up when refreshed
    if (set.style.anim.up) then
      bar.anim.ratio = bar.anim.ratio + dRatio;
      if (bar.anim.ratio > bar.status.ratio) then
        bar.anim.ratio = bar.status.ratio;
      end
    else bar.anim.ratio = bar.status.ratio end

  elseif (bar.status.ratio < bar.anim.ratio) then

    --Slide down when consumed
    if (set.style.anim.down) then
      bar.anim.ratio = bar.anim.ratio - dRatio;
      if (bar.anim.ratio < bar.status.ratio) then
        bar.anim.ratio = bar.status.ratio;
      end
    else bar.anim.ratio = bar.status.ratio end
  end

  --Find if should blink
  local canBlink = false;
  local blinkSpeed = 0.0;
  if (bar.status.active) then
  
    --Check if usability blinking applies
    if (set.type == CB.EFFECT_TYPE_USABLE) then
      if (set.style.anim.blinkUsable) then
        canBlink = true;
        blinkSpeed = 3.0;
      end
    
    --Check if bar does not have an infinite duration
    elseif (bar.status.duration > 0) then

      --Slow blink threshold is half bar or 5 seconds, whichever is smaller
      local blinkSlow = 0.5 * bar.status.duration
      if (blinkSlow > 5) then blinkSlow = 5 end;
      --Fast blink threshold is always 1 second
      local blinkFast = 1.0;

      --Blink when bar time below threshold
      if (set.style.anim.blinkFast and bar.status.left <= blinkFast) then
        canBlink = true;
        blinkSpeed = 10.0;
        
      elseif (set.style.anim.blinkSlow and bar.status.left <= blinkSlow) then
        canBlink = true;
        blinkSpeed = 3.0;
      end
    end
  end

  --Animate blinking
  if (canBlink) then

    --Alpha is absolute of [1,-1] for back-and-forth animation
    local dBlink = interval * blinkSpeed;
    bar.anim.blink = bar.anim.blink - dBlink;
    if (bar.anim.blink < -1.0) then
      bar.anim.blink = 1;
    end
  
  --Infinite bar blinks full portion, other bars blink expired portion
  elseif (bar.status.duration == 0)
  then bar.anim.blink = 1;
  else bar.anim.blink = 0;
  end

  --Animate fading (fade out when bar expires)
  if (set.style.anim.fade and set.style.visibility ~= CB.VISIBLE_ALWAYS) then
    if (bar.status.ratio == 0) then

      local dFade = interval * 3.0;
      bar.anim.fade = bar.anim.fade - dFade;
      if (bar.anim.fade < 0.0) then
        bar.anim.fade = 0;
      end

    else bar.anim.fade = 1; end
  else bar.anim.fade = 1; end

  --Bar is animating if time is left or animations aren't done yet
  if (set.style.anim.fade and set.style.visibility ~= CB.VISIBLE_ALWAYS) then
    bar.status.animating = (bar.anim.fade > 0.0);
  elseif (set.style.anim.down) then
    bar.status.animating = (bar.anim.ratio > 0.0);
  else
    bar.status.animating = (bar.status.ratio > 0.0);
  end
  
  --UI
  --===============================

  local maxW = w - 2 * p;
  
  --Hide spark for no-duration and expired bars
  if (bar.status.duration == 0 or bar.anim.ratio == 0) then
    bar.spark:Hide();
  else
    if (set.style.spark.enabled) then
      bar.spark:Show();
    end
  end
  
  --Charge notches
  if (set.type == CB.EFFECT_TYPE_CHARGES) then
  
    -- Start by hiding all the notches
    for t=1,table.getn(bar.notches) do
      bar.notches[t]:Hide();
      bar.notches[t]:ClearAllPoints();
    end
    
    -- Show a notch for each charge threshold between the first and the last
    if (set.style.notch.enabled and bar.status.maxCount) then
      local notchCount = bar.status.maxCount - 1;
      for t=1,notchCount do
        if (t > table.getn(bar.notches)) then
          local notch = CB.CreateNotch( bar );
          CB.ApplyNotchSettings(notch, bar.settings, bar.gsettings);
          bar.notches[t] = notch;
        end
        local notch = bar.notches[t];
        local notchOffset = CB.RoundToPixel(t * (maxW / bar.status.maxCount) - notch:GetWidth()/2);
        if (set.style.fullSide == ChronoBars.SIDE_RIGHT) then
          notch:SetPoint( "LEFT", bar.fg, "LEFT", notchOffset, 0 );
        elseif (set.style.fullSide == ChronoBars.SIDE_LEFT) then
          notch:SetPoint( "RIGHT", bar.fg, "RIGHT", -notchOffset, 0 );
        end
        notch:Show();
      end
    end
  end

  --Scale front to match ratio
  local offW;
  if (set.style.fillUp)
  then offW = bar.anim.ratio * maxW;
  else offW = (1.0 - bar.anim.ratio) * maxW;
  end

  if (set.style.fullSide == ChronoBars.SIDE_RIGHT) then
    bar.fg:SetPoint( "TOPRIGHT", -p - offW, -p );
  elseif (set.style.fullSide == ChronoBars.SIDE_LEFT) then
    bar.fg:SetPoint( "BOTTOMLEFT", p + offW, p );
  end
  
   --Cover the next charge coming off cooldown with the foreground fade
  if (set.type == CB.EFFECT_TYPE_CHARGES and bar.status.count and bar.status.maxCount) then
    local chargeRatio = bar.status.count / bar.status.maxCount;
    if (set.style.fullSide == ChronoBars.SIDE_RIGHT) then
      bar.fgFade:SetPoint( "BOTTOMLEFT", bar.fg, "BOTTOMLEFT", maxW * chargeRatio, 0);
    else
      bar.fgFade:SetPoint( "TOPRIGHT", bar.fg, "TOPRIGHT", -maxW * chargeRatio, 0);
    end
    bar.fgFade:Show();
  else
    bar.fgFade:Hide();
  end

  --Get front color and blink alpha
  local f = set.style.fgColor;
  local blinkA = math.abs( bar.anim.blink );
  -- Apply blink to foreground fade of the current charge
  if (set.type == CB.EFFECT_TYPE_CHARGES) then
    bar.fgFade:SetColorTexture( 0,0,0, (1 - blinkA) * 0.5 );
   --Apply blink to full portion if infinite duration
  elseif (bar.status.duration == 0) then
    bar.fg:SetGradientAlpha( "HORIZONTAL",
      f.r,f.g,f.b, blinkA * f.a,
      f.r,f.g,f.b, blinkA * f.a );
  --Apply blink to exhausted portion otherwise    
  else
    bar.fgBlink:SetGradientAlpha( "HORIZONTAL",
      f.r,f.g,f.b, 0.75 * blinkA * f.a,
      f.r,f.g,f.b, 0.75 * blinkA * f.a );
  end

  --Set entire bar alpha to match fade
  bar:SetAlpha( bar.anim.fade );

  --Update bar icon
  if (bar.status.icon) then
    bar.icon.tex:SetTexture( bar.status.icon );
  end
  
	--Formatting input
	local displayLeft = nil;
	local displayDuration = nil;
	local displayCount = nil;
	local displayInfo = nil;

	--Show time left and duration if active and not infinite,	
	if (bar.status.active and bar.status.duration > 0) then
		displayLeft = bar.status.left;
		displayDuration = bar.status.duration;
	end

	--Show count
	if (bar.status.count ~= nil) then
		displayCount = bar.status.count;
	end
	
	--Show usable/CD info
	if (set.type == CB.EFFECT_TYPE_CD) then
		displayInfo = "CD";
	elseif (set.type == CB.EFFECT_TYPE_USABLE) then
		displayInfo = "Usable";
	end

	--Format all text
	for t=1,table.getn(set.style.text) do
		if (set.style.text[t].enabled) then
			CB.FormatText( bar.text[t], bar.status.name, displayCount,
			displayLeft, displayDuration, bar.status.target, displayInfo );
		end
	end

  --Disable mouse events
  bar:EnableMouse( false );
  bar.icon:EnableMouse( false );

end

-- This function is called by Bar_UpdateEffect on every event
function ChronoBars.Bar_UpdateIcon (bar)

  -- It's important to only SetCooldown on the spinner widget when the values change, otherwise it unnecessarily flickers.
  -- The widget template will continue to animate itself after SetCooldown.
  if (bar.status.iconStart and bar.status.iconDuration and
      bar.status.iconStart > 0 and bar.status.iconDuration > 0 and
      (bar.status.iconStart ~= bar.icon.start or bar.status.iconDuration ~= bar.icon.duration)) then
      
    --CB.Print("ICON CD UPDATE start " .. bar.status.iconStart .. " duration " .. bar.status.iconDuration);
    bar.icon.cd:SetCooldown(bar.status.iconStart, bar.status.iconDuration, 1);
    bar.icon.start = bar.status.iconStart;
    bar.icon.duration = bar.status.iconDuration;
  end
  
  -- Add an extra fade behind the cooldown spinner when unusable
  if (bar.status.iconUsable) then
    bar.icon.fade:Hide();
  else
    bar.icon.fade:Show();
  end
end

function ChronoBars_BarSmaller (a,b)
  if (a.status.left ~= b.status.left) then
    return a.status.left < b.status.left;
  else
    return a.barId < b.barId;
  end
end

function ChronoBars_BarGreater (a,b)
  if (a.status.left ~= b.status.left) then
    return a.status.left > b.status.left;
  else
    return a.barId > b.barId;
  end
end


function ChronoBars.Group_Create (name)

  local grp = CreateFrame( "Frame", name, UIParent );
  grp:SetPoint( "BOTTOMLEFT", UIParent, "BOTTOMLEFT", 0,0 );
  grp:SetWidth( 2 );
  grp:SetHeight( 2 );
  grp:Hide();

  local bg = grp:CreateTexture( nil, "BACKGROUND" );
  grp.bg = bg;

  grp:EnableMouse( true );
  grp:SetMovable( true );

  grp.bars = {};
  grp.sortedBars = {};
  return grp;

end

function ChronoBars.Group_UpdateBounds (grp, bar, L, R, B, T)
  
  local barL = L;
  local barR = R;
  local barB = B;
  local barT = T;
  
  if (barL == nil) then
    barL = bar;
    barR = bar;
    barB = bar;
    barT = bar;
  end
  
  if (grp.settings.grow == ChronoBars.GROW_UP)
  then barT = bar;
  else barB = bar;
  end

  return barL, barR, barB, barT;
  
end

function ChronoBars.Group_ApplySettings (grp, profile, groupId)

  --Get group settings
  local settings = profile.groups[ groupId ];

  --Store handy references
  grp.groupId = groupId;
  grp.settings = settings;
  
  --Reset group update times
  grp.initUpdate = false;
  grp.nextUpdate = 0;

  --Init complex variables
  local x = CB.RoundToPixel( GetScreenWidth()/2 + settings.x );
  local y = CB.RoundToPixel( GetScreenHeight()/2 + settings.y );
  local w = CB.RoundToPixel( settings.width );
  local h = CB.RoundToPixel( settings.height );
  local s = CB.RoundToPixel( settings.spacing );
  local m = CB.RoundToPixel( settings.margin );
  local p = CB.RoundToPixel( settings.padding );

  --Position group
  grp:ClearAllPoints();
  grp:SetPoint( "BOTTOMLEFT", UIParent, "BOTTOMLEFT", x,y );

  --Position bars
  local barL, barR, barT, barB;
  local numBars = table.getn( grp.bars );
  for b = 1, numBars do

    local bar = grp.bars[b];
    bar:SetParent( grp );
    bar:SetWidth( w );
    bar:SetHeight( h );

    local offset = (b-1) * (h+s);
    bar:ClearAllPoints();
    bar:SetPoint( "LEFT", 0,0 );

    if (settings.grow == ChronoBars.GROW_UP)
    then bar:SetPoint( "BOTTOM", grp, "BOTTOM", 0, offset );
    else bar:SetPoint( "TOP",    grp, "BOTTOM", 0, -offset );
    end

    --Update group bounds
    barL, barR, barB, barT =
      CB.Group_UpdateBounds( grp, bar, barL, barR, barB, barT );
  end
  
  --Stretch background to cover all bars
  if (numBars > 0) then
  
    grp.bg:ClearAllPoints();
    grp.bg:SetPoint( "LEFT",   barL.bg, "LEFT",   -m,  0 );
    grp.bg:SetPoint( "RIGHT",  barR.bg, "RIGHT",   m,  0 );
    grp.bg:SetPoint( "BOTTOM", barB.bg, "BOTTOM",  0, -m );
    grp.bg:SetPoint( "TOP",    barT.bg, "TOP",     0,  m );
    grp.bg:Show();
    
  else grp.bg:Hide(); end
  
  --Back color
  local bgcol = settings.style.bgColor;
  grp.bg:SetColorTexture( bgcol.r, bgcol.g, bgcol.b, bgcol.a );
  
end

-- This is called from Group_OnUpdate which is set to run on every frame whenever any of the bars
-- in the group are active, and is disabled when the last bar deactivates
function ChronoBars.Group_UpdateUI (grp, now, interval)

  local x = CB.RoundToPixel( grp:GetLeft() );
  local y = CB.RoundToPixel( grp:GetBottom() );
  local m = CB.RoundToPixel( grp.settings.margin );
  local h = CB.RoundToPixel( grp.settings.height );
  local s = CB.RoundToPixel( grp.settings.spacing );
  local numBars = table.getn( grp.bars );

  local numVisibleBars = 0;
  local barL, barR, barT, barB;

  --Copy bars to sorted array
  CB.Util_ClearTable( grp.sortedBars );
  for b = 1, numBars do
    table.insert( grp.sortedBars, grp.bars[ b ] );
  end

  --Sort bars by time left
  if (grp.settings.sorting == CB.SORT_ASCENDING) then
    table.sort( grp.sortedBars, ChronoBars_BarSmaller );
  elseif (grp.settings.sorting == CB.SORT_DESCENDING) then
    table.sort( grp.sortedBars, ChronoBars_BarGreater );
  end

  --Update bar positions
  for b = 1, numBars do
    local bar = grp.sortedBars[b];
    if (bar.status.animating or bar.settings.style.visibility == CB.VISIBLE_ALWAYS) then

      --Hide everything but first visible if priority group
      if (numVisibleBars > 0 and grp.settings.layout == CB.LAYOUT_PRIORITY) then
        bar:Hide();
      else

        --Find bar offset
        local offset = 0;
        if (grp.settings.layout == CB.LAYOUT_KEEP) then
          offset = (b-1) * (h+s);
        elseif (grp.settings.layout == CB.LAYOUT_STACK) then
          offset = numVisibleBars * (h+s);
        end

        --Grow group up or down
        bar:ClearAllPoints();
        bar:SetPoint( "LEFT", 0,0 );

        if (grp.settings.grow == ChronoBars.GROW_UP)
        then bar:SetPoint( "BOTTOM", grp, "BOTTOM", 0, offset );
        else bar:SetPoint( "TOP",    grp, "BOTTOM", 0, -offset );
        end

        --Show visible bar
        bar:Show();
        numVisibleBars = numVisibleBars + 1;
        
        --Update group bounds
        barL, barR, barB, barT =
          CB.Group_UpdateBounds( grp, bar, barL, barR, barB, barT );
        
      end
    else

      --Hide invisible bar
      bar:Hide();

    end
  end
  
  --Stretch background to cover all bars
  if (numVisibleBars > 0 and grp.settings.style.bgColor.a > 0) then
    
    grp.bg:ClearAllPoints();
    grp.bg:SetPoint( "LEFT",   barL.bg, "LEFT",   -m,  0 );
    grp.bg:SetPoint( "RIGHT",  barR.bg, "RIGHT",   m,  0 );
    grp.bg:SetPoint( "BOTTOM", barB.bg, "BOTTOM",  0, -m );
    grp.bg:SetPoint( "TOP",    barT.bg, "TOP",     0,  m );
    grp.bg:Show();
    
  else grp.bg:Hide(); end
  
end

------------------------------------------------------------
-- update

function ChronoBars.Group_EnableUpdate (grp)
  CB.Debug( "Group update enabled" );
  
  --Set the OnUpdate script and init time of last update
  grp:SetScript( "OnUpdate", ChronoBars.Group_OnUpdate );
  if (not grp.initUpdate) then
    grp.nextUpdate = 0;
    grp.lastUpdate = GetTime();
    grp.initUpdate = true;
  end
  
end

function ChronoBars.Group_DisableUpdate (grp)
  CB.Debug( "Group update disabled" );
  
  --Remove OnUpdate script
  grp:SetScript( "OnUpdate", nil );
  grp.initUpdate = false;
  
end

function ChronoBars.Group_OnUpdate (grp)
  
  --Check if time for update
  local now = GetTime();
  if (now < grp.nextUpdate) then
    return;
  end

  -- Find interval and time of next update
  local interval = now - grp.lastUpdate;
  grp.nextUpdate = now + ChronoBars_Settings.updateInterval;
  grp.lastUpdate = now;
  
  --Walk all bars in the group
  local numBars = table.getn( grp.bars );
  local numUpdatingBars = 0;
  for b = 1, numBars do
    
    --Bar needs update if currently active, just deactivated, or still animating out
    local bar = grp.bars[b];
    if (bar.status.active or bar.status.deactivated or bar.status.animating) then
     
      --Update time left and animate UI
      CB.Bar_UpdateTime( bar, now );
      CB.Bar_UpdateUI( bar, now, interval );
      numUpdatingBars = numUpdatingBars + 1;
    end
    
    -- Clear just-deactivated flag here - they got their last update
    bar.status.deactivated = false;
  end
  
  --Update group (after bars to sort visible bars)
  CB.Group_UpdateUI( grp, now, interval );
  
  --Disable group update if no bars updating
  if (numUpdatingBars == 0) then
    CB.Group_DisableUpdate( grp );
  end
  
  --Check if any inactive bars should be removed
  CB.UI_RemoveInactiveBars( grp );
  
end

-------------------------------------------------------------
-- events

function ChronoBars.Bar_EnableEvents (bar)

  local set = bar.settings;
  bar:SetScript( "OnEvent", ChronoBars.Bar_OnEvent );
  CB.RegisterBarEvent( bar, "CHRONOBARS_FORCE_UPDATE" );
  
  if (set.type == CB.EFFECT_TYPE_AURA) then
    bar:RegisterEvent( "UNIT_AURA" );
    
    if (set.aura.unit == CB.AURA_UNIT_TARGET) then
      bar:RegisterEvent( "PLAYER_TARGET_CHANGED" );
      
    elseif (set.aura.unit == CB.AURA_UNIT_FOCUS) then
      bar:RegisterEvent( "PLAYER_FOCUS_CHANGED" );
      
    elseif (set.aura.unit == CB.AURA_UNIT_PET) then
      bar:RegisterEvent( "UNIT_PET" );
      
    elseif (set.aura.unit == CB.AURA_UNIT_TARGET_TARGET or
      set.aura.unit == CB.AURA_UNIT_FOCUS_TARGET or
      set.aura.unit == CB.AURA_UNIT_PET_TARGET) then
      bar:RegisterEvent( "UNIT_TARGET" );
    end
    
  elseif (set.type == CB.EFFECT_TYPE_MULTI_AURA) then
    bar:RegisterEvent( "COMBAT_LOG_EVENT_UNFILTERED" );
    bar:RegisterEvent( "UNIT_AURA" );
    bar:RegisterEvent( "UNIT_TARGET" );
    bar:RegisterEvent( "PLAYER_TARGET_CHANGED" );
    bar:RegisterEvent( "PLAYER_FOCUS_CHANGED" );
    bar:RegisterEvent( "UPDATE_MOUSEOVER_UNIT" );
    CB.RegisterBarEvent( bar, "CHRONOBARS_BAR_DEACTIVATED" );

  elseif (set.type == CB.EFFECT_TYPE_CD) then
    bar:RegisterEvent( "SPELL_UPDATE_USABLE" );
    bar:RegisterEvent( "SPELL_UPDATE_COOLDOWN" );
    bar:RegisterEvent( "ACTIONBAR_UPDATE_COOLDOWN" );
    bar:RegisterEvent( "PET_BAR_UPDATE_COOLDOWN" );
    
  elseif (set.type == CB.EFFECT_TYPE_CHARGES) then
    bar:RegisterEvent( "SPELL_UPDATE_USABLE" );
    bar:RegisterEvent( "SPELL_UPDATE_COOLDOWN" );
    bar:RegisterEvent( "ACTIONBAR_UPDATE_COOLDOWN" );
    bar:RegisterEvent( "PET_BAR_UPDATE_COOLDOWN" );
    
  elseif (set.type == CB.EFFECT_TYPE_USABLE) then
    bar:RegisterEvent( "SPELL_UPDATE_USABLE" );
    bar:RegisterEvent( "SPELL_UPDATE_COOLDOWN" );
    bar:RegisterEvent( "ACTIONBAR_UPDATE_COOLDOWN" );
      
    --Enable blacklist timer, since SPELL_UPDATE_COOLDOWN
    --is not being triggered at end of cooldown
    if (set.usable.includeCd) then
      CB.Bar_EnableEffectTimer( bar );
    end
    
  elseif (set.type == CB.EFFECT_TYPE_TOTEM) then
    bar:RegisterEvent( "PLAYER_TOTEM_UPDATE" );

  elseif (set.type == CB.EFFECT_TYPE_CUSTOM) then
    if (set.custom.trigger == CB.CUSTOM_TRIGGER_SPELL_CAST) then
      bar:RegisterEvent( "UNIT_SPELLCAST_SUCCEEDED" );
    elseif (set.custom.trigger == CB.CUSTOM_TRIGGER_BAR_ACTIVE) then
      CB.RegisterBarEvent( bar, "CHRONOBARS_BAR_ACTIVATED" );
    end
    
  elseif (set.type == CB.EFFECT_TYPE_AUTO) then
    if (set.auto.type == CB.AUTO_TYPE_WAND or set.auto.type == CB.AUTO_TYPE_BOW) then
      bar:RegisterEvent( "START_AUTOREPEAT_SPELL" );
      bar:RegisterEvent( "STOP_AUTOREPEAT_SPELL" );
    elseif (set.auto.type == CB.AUTO_TYPE_MAIN_HAND or set.auto.type == CB.AUTO_TYPE_OFF_HAND) then
      bar:RegisterEvent( "PLAYER_ENTER_COMBAT" );
      bar:RegisterEvent( "PLAYER_LEAVE_COMBAT" );
    end
    
  elseif (set.type == CB.EFFECT_TYPE_ENCHANT) then
    bar:RegisterEvent( "UNIT_INVENTORY_CHANGED" );
    
    --Enable blacklist timer, since enchant info is not yet correct
    --at the time UNIT_INVENTORY_CHANGED event is fired
    CB.Bar_EnableEffectTimer( bar );
  end
end

function ChronoBars.Bar_DisableEvents (bar)
  bar:SetScript( "OnEvent", nil );
  bar:UnregisterEvent( "UNIT_AURA" );
  bar:UnregisterEvent( "UNIT_TARGET" );
  bar:UnregisterEvent( "UNIT_PET" );
  bar:UnregisterEvent( "UPDATE_MOUSEOVER_UNIT" );
  bar:UnregisterEvent( "PLAYER_TARGET_CHANGED" );
  bar:UnregisterEvent( "PLAYER_FOCUS_CHANGED" );
  bar:UnregisterEvent( "PLAYER_TOTEM_UPDATE" );
  bar:UnregisterEvent( "SPELL_UPDATE_USABLE" );
  bar:UnregisterEvent( "SPELL_UPDATE_COOLDOWN" );
  bar:UnregisterEvent( "ACTIONBAR_UPDATE_COOLDOWN" );
  bar:UnregisterEvent( "UNIT_SPELLCAST_SUCCEEDED" );
  bar:UnregisterEvent( "PLAYER_ENTER_COMBAT" );
  bar:UnregisterEvent( "PLAYER_LEAVE_COMBAT" );
  bar:UnregisterEvent( "START_AUTOREPEAT_SPELL" );
  bar:UnregisterEvent( "STOP_AUTOREPEAT_SPELL" );
  bar:UnregisterEvent( "UNIT_INVENTORY_CHANGED");
  bar:UnregisterEvent( "COMBAT_LOG_EVENT_UNFILTERED" );
  CB.UnregisterBarEvent( bar, "CHRONOBARS_FORCE_UPDATE" );
  CB.UnregisterBarEvent( bar, "CHRONOBARS_BAR_ACTIVATED" );
  CB.UnregisterBarEvent( bar, "CHRONOBARS_BAR_DEACTIVATED" );
  CB.UnregisterBarEvent( bar, "CHRONOBARS_MULTI_AURA_UPDATE" );
  CB.Bar_DisableEffectTimer( bar );
end

function ChronoBars.Bar_EnableEffectTimer (bar)
  
  if (bar.timer == nil) then
    bar.timer = CreateFrame( "Frame", bar:GetName().."TimerFrame" );
    bar.timer.group = bar.timer:CreateAnimationGroup( bar:GetName().."TimerAnimGroup" );
    bar.timer.group:SetLooping( "REPEAT" );
    bar.timer.group.bar = bar;
    
    bar.timer.anim = bar.timer.group:CreateAnimation( "Animation", bar:GetName().."TimerAnim" );
    bar.timer.anim:SetDuration( CB.BLACKLIST_TIMER_INTERVAL );
    
    bar.timer.group:SetScript( "OnLoop",
      function (self) CB.SendBarEvent( self.bar, "CHRONOBARS_FORCE_UPDATE" ) end);
  end
  
  if (not bar.timer.group:IsPlaying()) then
    bar.timer.group:Play();
  end
end

function ChronoBars.Bar_DisableEffectTimer (bar)
  if (bar.timer ~= nil) then
    bar.timer.group:Stop();
  end
end

function ChronoBars.Bar_OnEvent (bar, event, ...)

  --Update bar effects
  local now = GetTime();
  CB.Bar_UpdateEffect( bar, now, event, ... );
  
  --Enable group update if bar active
  if (bar.status.active or bar.status.deactivated) then
    CB.Group_EnableUpdate( CB.groups[ bar.groupId ] );
  end
  
end

---------------------------------------------------------------
-- custom events

function ChronoBars.RegisterBarEvent (bar, event)
  bar.events[ event ] = true;
end

function ChronoBars.UnregisterBarEvent (bar, event)
  bar.events[ event ] = nil;
end

function ChronoBars.SendBarEvent (bar, event, ...)
  if (bar.events[ event ]) then
    CB.Bar_OnEvent( bar, event, ... );
  end
end

function ChronoBars.BroadcastBarEvent (event, ...)

  --Walk UI groups
  local numGroups = table.getn( CB.groups );
  for g = 1, numGroups do

    --Walk UI bars
    local numBars = table.getn( CB.groups[g].bars );
    for b = 1, numBars do
    
      --Send custom event to bar if registered
      if (CB.groups[g].bars[b].events[ event ]) then
        CB.Bar_OnEvent( CB.groups[g].bars[b], event, ... );
      end
    end
  end
end
