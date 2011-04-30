--[[

====================================================
ChronoBars - buff, debuff, cooldown, totem tracker
Author: Ivan Leben
====================================================

--]]

local CB = ChronoBars;

--Rounding to pixel
--==========================================================================

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

--Text formatting
--==========================================================================

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

local formatTable =
{
	{ token = "$e", value = nil },
	{ token = "$c", value = nil },
	{ token = "$l", value = nil },
	{ token = "$d", value = nil },
	{ token = "$t", value = nil },
}

function ChronoBars.FormatText( format, effect, count, left, duration, target  )
	
	local value = format;

	--Prepare replacement values
	formatTable[1].value = effect;
	formatTable[2].value = count;
	formatTable[3].value = left;
	formatTable[4].value = duration;
	formatTable[5].value = target;
	
	--Walk through all tokens
	local s;local e;
	for k,item in pairs(formatTable) do
	
		--Find token in string
		s,e = string.find( value, item.token, 1, true );
		if (s ~= nil and e ~= nil) then
		
			--Replace value or skip if missing
			if (item.value == nil or item.value == "") then return "" end
			value = string.sub( value, 1, s-1 ) .. tostring(item.value) .. string.sub( value, e+1 );
		end
	end
	
	return value;
	
end

--Frame positioning
--==========================================================================

function ChronoBars.PositionFrame( frame, prevFrame, outsideFrame, insideFrame, position, x, y, spacing )

	local justifyH;
	local s = CB.RoundToPixel( spacing );
	
	frame:ClearAllPoints();

	if (position == CB.POS_IN_LEFT) then
	
		if (prevFrame)
		then frame:SetPoint("LEFT", prevFrame, "RIGHT", x+s, y);
		else frame:SetPoint("LEFT", insideFrame, "LEFT", x+s, y);
		end
		
		justifyH = "LEFT";
		
	elseif (position == CB.POS_IN_CENTER) then
	
		frame:SetPoint("LEFT", insideFrame, "LEFT", 0, y);
		frame:SetPoint("RIGHT", insideFrame, "RIGHT", 0, y);
		
		justifyH = "CENTER";

	elseif (position == CB.POS_IN_RIGHT) then
	
		if (prevFrame)
		then frame:SetPoint("RIGHT", prevFrame, "LEFT", x-s, y);
		else frame:SetPoint("RIGHT", insideFrame, "RIGHT", x-s, y);
		end
		
		justifyH = "RIGHT";
		
	elseif (position == CB.POS_ABOVE_LEFT) then
	
		frame:SetPoint( "BOTTOM", outsideFrame, "TOP", 0, y+s );
		
		if (prevFrame)
		then frame:SetPoint("LEFT", prevFrame,    "RIGHT", x+s, 0);
		else frame:SetPoint("LEFT", outsideFrame, "LEFT",  x,   0);
		end
		
		justifyH = "LEFT";
		
	elseif (position == CB.POS_ABOVE_CENTER) then
	
		frame:SetPoint( "BOTTOMLEFT", outsideFrame, "TOPLEFT", 0, y+s );
		frame:SetPoint( "BOTTOMRIGHT", outsideFrame, "TOPRIGHT", 0, y+s );
		
		justifyH = "CENTER";
		
	elseif (position == CB.POS_ABOVE_RIGHT) then
	
		if (prevFrame)
		then frame:SetPoint( "BOTTOMRIGHT", prevFrame, "BOTTOMLEFT", x-s, y );
		else frame:SetPoint( "BOTTOMRIGHT", outsideFrame, "TOPRIGHT", x, y+s );
		end
		
		justifyH = "RIGHT";
		
	elseif (position == CB.POS_BELOW_LEFT) then
	
		if (prevFrame)
		then frame:SetPoint("TOPLEFT", prevFrame, "TOPRIGHT", x+s, y);
		else frame:SetPoint("TOPLEFT", outsideFrame, "BOTTOMLEFT", x, y-s);
		end
		
		justifyH = "LEFT";
		
	elseif (position == CB.POS_BELOW_CENTER) then
	
		frame:SetPoint( "TOPLEFT", outsideFrame, "BOTTOMLEFT", 0, y-s );
		frame:SetPoint( "TOPRIGHT", outsideFrame, "BOTTOMRIGHT", 0, y-s );
		
		justifyH = "CENTER";
		
	elseif (position == CB.POS_BELOW_RIGHT) then
	
		if (prevFrame)
		then frame:SetPoint( "TOPRIGHT", prevFrame, "TOPLEFT", x-s, y );
		else frame:SetPoint( "TOPRIGHT", outsideFrame, "BOTTOMRIGHT", x, y-s );
		end
		
		justifyH = "RIGHT";
		
	elseif (position == CB.POS_LEFT_BOTTOM) then
	
		if (prevFrame)
		then frame:SetPoint("BOTTOMRIGHT", prevFrame, "BOTTOMLEFT", x-s, y);
		else frame:SetPoint("BOTTOMRIGHT", outsideFrame, "BOTTOMLEFT", x-s, y );
		end
		
		justifyH = "RIGHT";
		
	elseif (position == CB.POS_LEFT_MIDDLE) then
	
		if (prevFrame)
		then frame:SetPoint("RIGHT", prevFrame, "LEFT", x-s, y);
		else frame:SetPoint("RIGHT", outsideFrame, "LEFT", x-s, y );
		end
		
		justifyH = "RIGHT";
		
	elseif (position == CB.POS_LEFT_TOP) then
	
		if (prevFrame)
		then frame:SetPoint("TOPRIGHT", prevFrame, "TOPLEFT", x-s, y);
		else frame:SetPoint("TOPRIGHT", outsideFrame, "TOPLEFT", x-s, y );
		end
		
		justifyH = "RIGHT";
		
	elseif (position == CB.POS_RIGHT_BOTTOM) then
	
		if (prevFrame)
		then frame:SetPoint("BOTTOMLEFT", prevFrame, "BOTTOMRIGHT", x+s, y);
		else frame:SetPoint("BOTTOMLEFT", outsideFrame, "BOTTOMRIGHT", x+s, y );
		end
		
		justifyH = "LEFT";
		
	elseif (position == CB.POS_RIGHT_MIDDLE) then
	
		if (prevFrame)
		then frame:SetPoint("LEFT", prevFrame, "RIGHT", x+s, y);
		else frame:SetPoint("LEFT", outsideFrame, "RIGHT", x+s, y );
		end
		
		justifyH = "LEFT";
		
	elseif (position == CB.POS_RIGHT_TOP) then
	
		if (prevFrame)
		then frame:SetPoint("TOPLEFT", prevFrame, "TOPRIGHT", x+s, y);
		else frame:SetPoint("TOPLEFT", outsideFrame, "TOPRIGHT", x+s, y );
		end
		
		justifyH = "LEFT";
	end
	
	if (frame.SetJustifyH and justifyH) then
		frame:SetJustifyH( justifyH );
	end
end
