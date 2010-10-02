--[[

====================================================
ChronoBars - buff, debuff, cooldown, totem tracker
Author: Ivan Leben
====================================================

--]]

local CB = ChronoBars;

function ChronoBars.ScreenToPixelX (coord)
  return coord * CB.pxRatioX;
end

function ChronoBars.ScreenToPixelY (coord)
  return coord * CB.pxRatioY;
end

function ChronoBars.RoundToPixelX (coord)
  return math.floor( coord * CB.pxRatioX + 0.5 ) / CB.pxRatioX;
end

function ChronoBars.RoundToPixelY (coord)
  return math.floor( coord * CB.pxRatioY + 0.5 ) / CB.pxRatioY;
end

--Assuming pixel ratio will be the same in X and Y since WoW preserves
--aspect ratio between the real window and the scaled UI coordinates
ChronoBars.RoundToPixel = ChronoBars.RoundToPixelX;

function ChronoBars.FindPixelRatio ()

  --Parse resolution X and resolution Y
  local resolutions = {GetScreenResolutions()};
  local res = resolutions[ GetCurrentResolution() ];
  local x = strfind( res, "x" );
  local resX = strsub( res, 1, x-1 );
  local resY = strsub( res, x+1 );
  CB.resX = tonumber( resX );
  CB.resY = tonumber( resY );

  --Get the ratio between UI coordinates and actual pixels
  CB.screenW = GetScreenWidth();
  CB.screenH = GetScreenHeight();
  CB.pxRatioX = CB.resX / CB.screenW;
  CB.pxRatioY = CB.resY / CB.screenH;

  --Don't use pixel-perfect correction if not full-screen
  CB.windowed = (GetCVar( "gxWindow" ) == "1");
  CB.maximized = (GetCVar( "gxMaximize" ) == "1" );
  if (CB.windowed and (not CB.maximized)) then
    CB.pxRatioX = 1;
    CB.pxRatioY = 1;
  end

  CB.Debug( "Screen windowed:"..tostring(CB.windowed).." maximized:"..tostring(CB.maximized) );
  CB.Debug( "Pixel ratioX:"..tostring(CB.pxRatioX).." ratioY:"..tostring(CB.pxRatioY) );

end

function ChronoBars.FormatSeconds (seconds, format)

  if (format == ChronoBars.TIME_MINSEC) then

    local minutes = 0;
    seconds = math.ceil( seconds );

    if (seconds >= 60) then
      minutes = math.floor( seconds / 60 );
      seconds = math.ceil( seconds - minutes * 60 );
    end

    return string.format( "%i:%02i", minutes, seconds );

  else

    local time = seconds;
    local letter = "s";
    local fmt;

    if (time >= 60) then
      time = time / 60;
      letter = "m";
    end

    if (format == ChronoBars.TIME_DECIMAL) then
      time = math.ceil( time * 10 ) / 10;
      fmt = "%.1f";
    else
      time = math.ceil( time );
      fmt = "%i";
    end

    return string.format( fmt..letter, time);

  end
end

function ChronoBars.FormatTime (bar, time, fixed)

  local set = bar.settings;
  local timeString = "";

  if (set.style.showTime) then
    if (set.type ~= ChronoBars.EFFECT_TYPE_USABLE) then

      if (time) then
        timeString = ChronoBars.FormatSeconds( time, set.style.timeFormat );
      end

      if (fixed) then
        if (set.fixed.enabled) then
          local fixedString = ChronoBars.FormatSeconds( fixed, set.style.timeFormat );
          timeString = timeString.."/"..fixedString;
        end
      end
    end
  end

  return timeString;
end

function ChronoBars.FormatName (bar, name, id, count, order)

  local set = bar.settings;
  local nameString = "";

  if (set.style.showName) then

    if (set.display.enabled) then
      nameString = set.display.name;
    elseif (name) then
      nameString = name;
    end

    if (id) then
      nameString = "("..tostring( id )..") "..nameString;
    end
  end

  if (count and count > 1) then
    if (set.type == ChronoBars.EFFECT_TYPE_AURA) then
      if (set.style.showCount) then
        if (set.style.countSide == ChronoBars.SIDE_LEFT)
        then nameString = "["..tostring(count).."]  "..nameString;
        else nameString = nameString.."  ["..tostring(count).."]";
        end
      end
    end
  end

  if (order and order > 1) then
    if (set.type == ChronoBars.EFFECT_TYPE_AURA) then
      nameString = nameString.." #"..tostring(order);
    end
  end

  if (set.type == ChronoBars.EFFECT_TYPE_CD) then
    if (set.style.showCd) then
      nameString = nameString.." CD";
    end
  end

  if (set.type == ChronoBars.EFFECT_TYPE_USABLE) then
    if (set.style.showUsable) then
      nameString = nameString.." Usable";
    end
  end

  return nameString;
end


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
  bar.group = grp;
  bar:Show();
  return bar;
end

function ChronoBars.UI_RemoveGroup (grp)
  local numGroups = table.getn( CB.groups );
  for g=1,numGroups do
    if (CB.groups[g] == grp) then
      CB.UI_RemoveAllBars( grp );
      grp:Hide();
      CB.FreeGroup( grp );
      table.remove( CB.groups, g );
      return;
    end
  end
end

function ChronoBars.UI_RemoveBar (bar)
  local numBars = table.getn( bar.group.bars );
  for b=1,numBars do
    if (bar.group.bars[b] == bar) then
      bar:Hide();
      CB.FreeBar( bar );
      table.remove( bar.group.bars, b );
      return;
    end
  end
end

function ChronoBars.UI_RemoveAllBars (grp)
  local numBars = table.getn( grp.bars );
  for b=numBars,1,-1 do
    grp.bars[ b ]:Hide();
    CB.FreeBar( grp.bars[ b ] );
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

--Bar and Group manipulation
--===========================================================================

function ChronoBars.Bar_OnMouseDown (bar, button)
  if (button == "RightButton" and ChronoBars.designMode) then
    ChronoBars.OpenBarMenu (bar);
  end
end


function ChronoBars.Bar_OnDragStart (bar)

  if (ChronoBars.designMode) then
    bar.group:StartMoving();
  end
end

function ChronoBars.Bar_OnDragStop (bar)

  if (ChronoBars.designMode) then
    bar.group:StopMovingOrSizing();
    local x = bar.group:GetLeft();
    local y = bar.group:GetBottom();
    bar.group.settings.x = x - GetScreenWidth()/2;
    bar.group.settings.y = y - GetScreenHeight()/2;
    ChronoBars.UpdateSettings();
  end
end

function ChronoBars.Bar_Create (name)

  local bar = CreateFrame( "Frame", name );

  local bg = bar:CreateTexture( nil, "BACKGROUND" );
  bar.bg = bg;

  local fg = bar:CreateTexture( nil, "ARTWORK" );
  bar.fg = fg;

  local fgBlink = bar:CreateTexture( nil, "ARTWORK" );
  bar.fgBlink = fgBlink;

  local txtName = bar:CreateFontString( name.."txtname" );
  txtName:SetJustifyH( "LEFT" );
  txtName:SetTextColor( 1.0, 1.0, 1.0, 1.0 );
  txtName:SetShadowOffset( 1, -1 );
  txtName:SetWordWrap( false );
  bar.txtName = txtName;

  local txtTime = bar:CreateFontString (name.."txttime" );
  txtTime:SetJustifyH( "RIGHT" );
  txtTime:SetShadowOffset( 1, -1 );
  txtTime:SetWordWrap( false );
  bar.txtTime = txtTime;

  local icon = bar:CreateTexture( nil, "ARTWORK" );
  bar.icon = icon;

  local spark = bar:CreateTexture( nil, "OVERLAY" );
  spark:SetTexture( "Interface\\CastingBar\\UI-CastingBar-Spark" );
  spark:SetBlendMode( "ADD" );
  spark:SetWidth( 32 );
  spark:SetHeight( 60 );
  bar.spark = spark;

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
  bar.status.id = nil;
  bar.status.name = nil;
  bar.status.icon = nil;
  bar.status.count = nil;
  bar.status.text = "";
  bar.status.duration = nil;
  bar.status.expires = nil;
  bar.status.left = 0.0;
  bar.status.ratio = 0.0;
  bar.status.active = false;
  bar.status.animating = true;
  
  --Init effect status
  CB.Bar_InitEffect( bar );

  --Round graphics to actual pixels
  local pad = CB.RoundToPixel( gsettings.padding );
  local h = CB.RoundToPixel( gsettings.height );
  local w = CB.RoundToPixel( gsettings.width );

  --Fetch LibSharedMedia paths
  local fontPath = ChronoBars.LSM:Fetch( "font", settings.style.lsmFontHandle );
  if (not fontPath) then
    settings.style.lsmFontHandle = "Friz Quadrata TT";
    fontPath = "Fonts\\FRIZQT__.TTF";
  end

  local texPath = ChronoBars.LSM:Fetch( "statusbar", settings.style.lsmTexHandle );
  if (not texPath) then
    settings.style.lsmTexHandle = "None";
    texPath = "";
  end

  --Back and front color and texture
  local b = settings.style.bgColor;
  bar.bg:SetTexture( b.r, b.g, b.b, b.a );

  local f = settings.style.fgColor;
  bar.fg:SetHorizTile( true );
  bar.fg:SetVertTile( false );
  bar.fg:SetGradientAlpha( "HORIZONTAL",  f.r,f.g,f.b,f.a,  f.r,f.g,f.b,f.a );

  bar.fgBlink:SetHorizTile( true );
  bar.fgBlink:SetVertTile( false );
  bar.fgBlink:SetGradientAlpha( "HORIZONTAL", f.r,f.g,f.b,0,  f.r,f.g,f.b,0 );

  if (settings.style.lsmTexHandle == "None") then
    bar.fg:SetTexture( 1,1,1,1 );
    bar.fgBlink:SetTexture( 1,1,1,1 );
  else
    bar.fg:SetTexture( texPath );
    bar.fgBlink:SetTexture( texPath );
  end

  --Make foreground half-full
  local offWidth = (w - 2*pad) * 0.5;
  bar.fg:ClearAllPoints();
  bar.fgBlink:ClearAllPoints();

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
  
  --Time text
  local timeString;
  if (settings.type == ChronoBars.EFFECT_TYPE_CUSTOM)
  then timeString = ChronoBars.FormatTime( bar, settings.custom.duration, settings.fixed.duration );
  else timeString = ChronoBars.FormatTime( bar, 0, settings.fixed.duration );
  end
  
  bar.txtTime:SetFont( fontPath, settings.style.fontSize );
  bar.txtTime:SetText( timeString );

  local tcol = settings.style.textColor;
  bar.txtTime:SetTextColor( tcol.r, tcol.g, tcol.b, tcol.a );
  bar.txtTime:ClearAllPoints();

  if (settings.style.timeSide == CB.SIDE_RIGHT) then
    bar.txtTime:SetPoint( "BOTTOMRIGHT", -pad - 2, pad );
    bar.txtTime:SetPoint( "TOPRIGHT", -pad - 2, -pad );
    bar.txtTime:SetJustifyH( "RIGHT" );

  elseif (settings.style.timeSide == CB.SIDE_LEFT) then
    bar.txtTime:SetPoint( "BOTTOMLEFT", pad + 2, pad );
    bar.txtTime:SetPoint( "TOPLEFT", pad + 2, -pad );
    bar.txtTime:SetJustifyH( "LEFT" );
  end

  --Name / id / count text
  local nameString = ChronoBars.FormatName( bar, bar.status.name, nil, 2, settings.aura.order );
  bar.txtName:SetFont( fontPath, settings.style.fontSize );
  bar.txtName:SetText( nameString );

  local tcol = settings.style.textColor;
  bar.txtName:SetTextColor( tcol.r, tcol.g, tcol.b, tcol.a );
  bar.txtName:ClearAllPoints();
  
  if (settings.style.timeSide == CB.SIDE_RIGHT) then
    bar.txtName:SetPoint( "BOTTOMLEFT", pad + 2, pad );
    bar.txtName:SetPoint( "TOPRIGHT", bar.txtTime, "TOPLEFT", -2, 0 );

  elseif (settings.style.timeSide == CB.SIDE_LEFT) then
    bar.txtName:SetPoint( "BOTTOMLEFT", bar.txtTime, "BOTTOMRIGHT", 2, 0 );
    bar.txtName:SetPoint( "TOPRIGHT", -pad - 2, -pad );
  end
  
  if (settings.style.nameJustify == CB.JUSTIFY_LEFT) then
    bar.txtName:SetJustifyH( "LEFT" );
  elseif (settings.style.nameJustify == CB.JUSTIFY_CENTER) then
    bar.txtName:SetJustifyH( "CENTER" );
  elseif (settings.style.nameJustify == CB.JUSTIFY_RIGHT) then
    bar.txtName:SetJustifyH( "RIGHT" );
  end

  bar.txtName:Show();

  --Icon
  if (settings.style.showIcon) then

    --Use ? texture if not found
    local iconTex = bar.status.icon;
    if (not iconTex) then iconTex = "Interface/Icons/INV_Misc_QuestionMark"; end
    bar.icon:SetTexture( iconTex );
    bar.icon:Show();

    --Icon zoom
    if (settings.style.iconZoom) then
      local s = 0.08;
      bar.icon:SetTexCoord( s, 1-s, s, 1-s );
    else
      bar.icon:SetTexCoord( 0,1,0,1 );
    end

    if (settings.style.iconSide == CB.SIDE_LEFT) then

      --Enlarge background to cover the icon
      bar.bg:SetPoint( "TOPRIGHT", 0,0 );
      bar.bg:SetPoint( "BOTTOMLEFT", -h + pad, 0);

      --Set icon to the left of the bar
      bar.icon:SetPoint( "TOPRIGHT", bar, "TOPLEFT", 0, -pad );
      bar.icon:SetPoint( "BOTTOMLEFT", bar, "BOTTOMLEFT", -h + 2*pad, pad );

    elseif (settings.style.iconSide == CB.SIDE_RIGHT) then

      --Enlarge background to cover the icon
      bar.bg:SetPoint( "TOPRIGHT", h - pad, 0 );
      bar.bg:SetPoint( "BOTTOMLEFT", 0, 0 );

      --Set icon to the left of the bar
      bar.icon:SetPoint( "TOPRIGHT", bar, "TOPRIGHT", h - 2*pad, -pad );
      bar.icon:SetPoint( "BOTTOMLEFT", bar, "BOTTOMRIGHT", 0, pad );

    end

  else
    --Shrink background to bar only
    bar.bg:SetPoint( "TOPRIGHT", 0,0 );
    bar.bg:SetPoint( "BOTTOMLEFT", 0,0 );
    bar.icon:Hide();
  end

  --Spark
  if (settings.style.showSpark) then
    bar.spark:SetWidth( settings.style.sparkWidth );
    bar.spark:SetHeight( h * settings.style.sparkHeight );
    bar.spark:Show();

    if (settings.style.fullSide == CB.SIDE_RIGHT)
    then bar.spark:SetPoint( "CENTER", bar.fg, "RIGHT", 0,0 );
    else bar.spark:SetPoint( "CENTER", bar.fg, "LEFT", 0,0 );
    end
  else
    bar.spark:Hide();
  end

  --Set half-transparent if disabled
  if (settings.enabled)
  then bar:SetAlpha( 1 );
  else bar:SetAlpha( 0.5 );
  end

  --Enable for mouse events
  bar:EnableMouse( true );
  
  --Update bounds of children frames
  CB.Bar_UpdateChildBounds( bar );
  
  --HACKY Workaround - need to wait for next OnUpdate for the bounds to return correct values
  if (bar.boundsUpdater == nil) then
    bar.boundsUpdater = CreateFrame( "Frame", bar:GetName().."Updater", nil );
    bar.boundsUpdater.bar = bar;
  end
  
  bar.boundsUpdater:SetScript( "OnUpdate", ChronoBars.Bar_OnUpdateBounds );
end

function ChronoBars.Bar_OnUpdateBounds (self)
  CB.Bar_UpdateChildBounds( self.bar );
  self:SetScript( "OnUpdate", nil );
end

function ChronoBars.Bar_UpdateChildBounds (bar)
  
  local l=nil; local r=nil; local b=nil; local t=nil;
  if (bar.children == nil) then bar.children = {} end;
  CB.Util_ClearTable( bar.children );
  CB.Util_CaptureList( bar.children, bar:GetRegions() );
  --CB.Util_CaptureList( bar.children, bar:GetChildren() );
  
  local numChildren = table.getn( bar.children );
  for c=1,numChildren do
    
    if (bar.children[c]:IsShown()) then
    
      local cl = bar.children[c]:GetLeft() - bar:GetLeft();
      local cr = bar.children[c]:GetRight() - bar:GetLeft();
      local ct = bar.children[c]:GetTop() - bar:GetBottom();
      local cb = bar.children[c]:GetBottom() - bar:GetBottom();
      
      if (l==nil or cl < l) then l = cl; end
      if (r==nil or cr > r) then r = cr; end
      if (b==nil or cb < b) then b = cb; end
      if (t==nil or ct > t) then t = ct; end
      
    end
  end
  
  if (l == nil) then l = 0; end
  if (r == nil) then r = 0; end
  if (b == nil) then b = 0; end
  if (t == nil) then t = 0; end
  bar.boundsL = l;
  bar.boundsR = r;
  bar.boundsB = b;
  bar.boundsT = t;
  
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
  local L=0; local R=0; local B=0; local T=0;
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

    if (b == 1 or bar.boundsL < L) then L = bar.boundsL; end
    if (b == 1 or bar.boundsR > R) then R = bar.boundsR; end
    T = offset + h;
  end
  
  --Stretch background to cover all bars
  grp.bg:ClearAllPoints();
  
  if (grp.settings.grow == ChronoBars.GROW_UP) then
    grp.bg:SetPoint( "TOPRIGHT",   grp, "BOTTOMLEFT", R+m, T+m );
    grp.bg:SetPoint( "BOTTOMLEFT", grp, "BOTTOMLEFT", L-m, 0-m );
  else
    grp.bg:SetPoint( "TOPRIGHT",   grp, "BOTTOMLEFT", R+m, 0+m );
    grp.bg:SetPoint( "BOTTOMLEFT", grp, "BOTTOMLEFT", L-m, -T-m );
  end
  
  grp.bg:Show();
  
  --Back color
  local bgcol = settings.style.bgColor;
  grp.bg:SetTexture( bgcol.r, bgcol.g, bgcol.b, bgcol.a );
  
end

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
    
    --Check if bar has infinite duration
    elseif (bar.status.duration > 0) then

      --Find time to start blinking (half bar or 5 seconds if bar longer)
      local blinkSlow = 0.5 * bar.status.duration
      if (blinkSlow > 5) then blinkSlow = 5 end;
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

  --Hide spark for no-duration and expired bars
  if (bar.status.duration == 0 or bar.anim.ratio == 0) then
    bar.spark:Hide();
  else
    if (set.style.showSpark) then
      bar.spark:Show();
    end
  end

  --Scale front to match ratio
  local maxW = w - 2 * p;

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

  --Get front color and blink alpha
  local f = set.style.fgColor;
  local blinkA = math.abs( bar.anim.blink );

  --Apply blink to full portion if no-duration, exhausted portion otherwise
  if (bar.status.duration == 0) then
    bar.fg:SetGradientAlpha( "HORIZONTAL",
      f.r,f.g,f.b, blinkA * f.a,
      f.r,f.g,f.b, blinkA * f.a );
  else
    bar.fgBlink:SetGradientAlpha( "HORIZONTAL",
      f.r,f.g,f.b, 0.75 * blinkA * f.a,
      f.r,f.g,f.b, 0.75 * blinkA * f.a );
  end

  --Set entire bar alpha to match fade
  bar:SetAlpha( bar.anim.fade );

  --Update bar icon
  if (bar.status.icon) then
    bar.icon:SetTexture( bar.status.icon );
  end

  --Set time text if active 
  if (bar.status.active and bar.status.duration > 0)
  then bar.txtTime:SetText( CB.FormatTime( bar, bar.status.left ));
  else bar.txtTime:SetText( "" );
  end

  --Set name text  
  bar.txtName:SetText( CB.FormatName( bar, bar.status.text, nil, bar.status.count ));

  --Disable mouse events
  bar:EnableMouse( false );

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

function ChronoBars.Group_UpdateUI (grp, now, interval)

  local x = CB.RoundToPixel( grp:GetLeft() );
  local y = CB.RoundToPixel( grp:GetBottom() );
  local m = CB.RoundToPixel( grp.settings.margin );
  local h = CB.RoundToPixel( grp.settings.height );
  local s = CB.RoundToPixel( grp.settings.spacing );
  local numBars = table.getn( grp.bars );

  local L=0; local R=0; local B=0; local T=0;
  local numVisibleBars = 0;

  --Copy bars to sorted array
  for b = 1, numBars do
    grp.sortedBars[ b ] = grp.bars[ b ];
  end
  grp.sortedBars[ numBars+1 ] = nil;

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
        if (numVisibleBars == 1 or bar.boundsL < L) then L = bar.boundsL; end
        if (numVisibleBars == 1 or bar.boundsR > R) then R = bar.boundsR; end
        T = offset + h;
        
      end
    else

      --Hide invisible bar
      bar:Hide();

    end
  end
  
  --Stretch background to cover all bars
  if (numVisibleBars > 0 and grp.settings.style.bgColor.a > 0) then
    
    if (grp.settings.grow == ChronoBars.GROW_UP) then
      grp.bg:SetPoint( "TOPRIGHT",   grp, "BOTTOMLEFT", R+m, T+m );
      grp.bg:SetPoint( "BOTTOMLEFT", grp, "BOTTOMLEFT", L-m, 0-m );
    else
      grp.bg:SetPoint( "TOPRIGHT",   grp, "BOTTOMLEFT", R+m, 0+m );
      grp.bg:SetPoint( "BOTTOMLEFT", grp, "BOTTOMLEFT", L-m, -T-m );
    end
    
    grp.bg:Show();
    
  else
    grp.bg:Hide();
  end
  
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
  local numAnimatingBars = 0;
  for b = 1, numBars do
    
    --Check if bar active
    local bar = grp.bars[b];
    if (bar.status.active or bar.status.animating) then
     
      --Update time left and animate UI
      CB.Bar_UpdateTime( bar, now );
      CB.Bar_UpdateUI( bar, now, interval );
      numAnimatingBars = numAnimatingBars + 1;
    end
  end
  
  --Update group (after bars to sort visible bars)
  CB.Group_UpdateUI( grp, now, interval );
  
  --Disable group update if no bars animating
  if (numAnimatingBars == 0) then
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
    bar:RegisterEvent( "SPELL_UPDATE_COOLDOWN" );
    bar:RegisterEvent( "ACTIONBAR_UPDATE_COOLDOWN" );
    
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
  if (bar.status.active) then
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
