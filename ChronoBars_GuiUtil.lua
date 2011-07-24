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

	if (seconds == nil) then
		return "";
	end
	
	if (format == CB.TIME_MINSEC) then

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

		if (format == CB.TIME_DECIMAL) then
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

ChronoBars.formatTableTemplate =
{
	{ token = "$e", value = nil, found = false },
	{ token = "$c", value = nil, found = false },
	{ token = "$l", value = nil, found = false },
	{ token = "$d", value = nil, found = false },
	{ token = "$t", value = nil, found = false },
	{ token = "$u", value = nil, found = false },
};

function ChronoBars.InitText( text )

	local format = text.settings.format;
	
	--Create table if missing
	if (text.formatTable == nil) then
		text.formatTable = CopyTable( CB.formatTableTemplate );
	end
	
	--Walk all the tokens
	for k,item in pairs(text.formatTable) do

		--Find token
		local s,e = string.find( format, item.token, 1, true );
		
		--Check if valid
		if (s and e)
		then item.found = true;
		else item.found = false;
		end
	end
end

function ChronoBars.FormatText( text, effect, count, left, duration, target, info  )
	
	local final = text.settings.format;
	
	--Prepare replacement values
	local ftable = text.formatTable;
	
	if (ftable[1].found) then
		ftable[1].value = effect;
	end

	if (ftable[2].found) then
		ftable[2].value = count;
	end
	
	if (ftable[3].found) then
		ftable[3].value = CB.FormatSeconds( left, text.settings.timeFormat );
	end
	
	if (ftable[4].found) then
		ftable[4].value = CB.FormatSeconds( duration, text.settings.timeFormat );
	end
	
	if (ftable[5].found) then
		ftable[5].value = target;
	end
	
	if (ftable[6].found) then
		ftable[6].value = info;
	end
	
	--Walk all the tokens
	for k,item in pairs(ftable) do
		if (item.found) then
		
			--Bail if required value is missing
			if (item.value == nil or item.value == "") then
				final = "";
				break;
			end
			
			--Replace value
			local s,e = string.find( final, item.token, 1, true );
			final = string.sub( final, 1, s-1 ) .. tostring(item.value) .. string.sub( final, e+1 );
		end
	end
	
	text:SetText( final );
	
end

--Frame positioning
--==========================================================================

function ChronoBars.PositionFrame( frame, prevFrame, outsideFrame, insideFrame, position, x, y, spacing )

	local justifyH;
	local s = CB.RoundToPixel( spacing );
	
	frame:ClearAllPoints();
	
	--INSIDE

	if (position == CB.POS_IN_LEFT) then
	
		if (prevFrame)
		then frame:SetPoint("LEFT", prevFrame,   "RIGHT", x+s, y);
		else frame:SetPoint("LEFT", insideFrame, "LEFT",  x+s, y);
		end
		
		justifyH = "LEFT";
		
	elseif (position == CB.POS_IN_CENTER) then
	
		frame:SetPoint("LEFT", insideFrame,  "LEFT",  0, y);
		frame:SetPoint("RIGHT", insideFrame, "RIGHT", 0, y);
		
		justifyH = "CENTER";

	elseif (position == CB.POS_IN_RIGHT) then
	
		if (prevFrame)
		then frame:SetPoint("RIGHT", prevFrame,   "LEFT",  x-s, y);
		else frame:SetPoint("RIGHT", insideFrame, "RIGHT", x-s, y);
		end
		
		justifyH = "RIGHT";
	
	--ABOVE
		
	elseif (position == CB.POS_ABOVE_LEFT) then
	
		frame:SetPoint( "BOTTOM", outsideFrame, "TOP", 0, y );
		
		if (prevFrame)
		then frame:SetPoint("LEFT", prevFrame,    "RIGHT", x+s, 0);
		else frame:SetPoint("LEFT", outsideFrame, "LEFT",  x,   0);
		end
		
		justifyH = "LEFT";
		
	elseif (position == CB.POS_ABOVE_CENTER) then
	
		frame:SetPoint( "BOTTOM", outsideFrame, "TOP",    0, y );
		frame:SetPoint( "CENTER", outsideFrame, "CENTER", x, 0 );
		
		justifyH = "CENTER";
		
	elseif (position == CB.POS_ABOVE_RIGHT) then
	
		frame:SetPoint( "BOTTOM", outsideFrame, "TOP", 0, y );
	
		if (prevFrame)
		then frame:SetPoint( "RIGHT", prevFrame,    "LEFT",  x-s, 0 );
		else frame:SetPoint( "RIGHT", outsideFrame, "RIGHT", x,   0 );
		end
		
		justifyH = "RIGHT";
	
	--BELOW
		
	elseif (position == CB.POS_BELOW_LEFT) then
	
		frame:SetPoint( "TOP", outsideFrame, "BOTTOM", 0, y );
		
		if (prevFrame)
		then frame:SetPoint("LEFT", prevFrame,    "RIGHT", x+s, 0);
		else frame:SetPoint("LEFT", outsideFrame, "LEFT",  x,   0);
		end
		
		justifyH = "LEFT";
		
	elseif (position == CB.POS_BELOW_CENTER) then
	
		frame:SetPoint( "TOP", outsideFrame,    "BOTTOM", 0, y );
		frame:SetPoint( "CENTER", outsideFrame, "CENTER", x, 0 );
		
		justifyH = "CENTER";
		
	elseif (position == CB.POS_BELOW_RIGHT) then

		frame:SetPoint( "TOP", outsideFrame, "BOTTOM", 0, y );
		
		if (prevFrame)
		then frame:SetPoint( "RIGHT", prevFrame,    "LEFT",  x-s, 0 );
		else frame:SetPoint( "RIGHT", outsideFrame, "RIGHT", x,   0 );
		end
		
		justifyH = "RIGHT";
		
	--LEFT
	
	elseif (position == CB.POS_LEFT_BOTTOM) then
	
		frame:SetPoint( "BOTTOM", outsideFrame, "BOTTOM", 0, y );
		
		if (prevFrame)
		then frame:SetPoint( "RIGHT", prevFrame,    "LEFT", x-s, 0 );
		else frame:SetPoint( "RIGHT", outsideFrame, "LEFT", x-s, 0 );
		end
		
		justifyH = "RIGHT";
		
	elseif (position == CB.POS_LEFT_MIDDLE) then
	
		frame:SetPoint( "CENTER", outsideFrame, "CENTER", 0, y );
		
		if (prevFrame)
		then frame:SetPoint( "RIGHT", prevFrame,    "LEFT", x-s, 0 );
		else frame:SetPoint( "RIGHT", outsideFrame, "LEFT", x-s, 0 );
		end
		
		justifyH = "RIGHT";
		
	elseif (position == CB.POS_LEFT_TOP) then
	
		frame:SetPoint( "TOP", outsideFrame, "TOP", 0, y );
		
		if (prevFrame)
		then frame:SetPoint( "RIGHT", prevFrame,    "LEFT", x-s, 0 );
		else frame:SetPoint( "RIGHT", outsideFrame, "LEFT", x-s, 0 );
		end
		
		justifyH = "RIGHT";
		
	--RIGHT
		
	elseif (position == CB.POS_RIGHT_BOTTOM) then
	
		frame:SetPoint( "BOTTOM", outsideFrame, "BOTTOM", 0, y );
		
		if (prevFrame)
		then frame:SetPoint( "LEFT", prevFrame,    "RIGHT", x+s, 0 );
		else frame:SetPoint( "LEFT", outsideFrame, "RIGHT", x+s, 0 );
		end
		
		justifyH = "LEFT";
		
	elseif (position == CB.POS_RIGHT_MIDDLE) then
	
		frame:SetPoint( "CENTER", outsideFrame, "CENTER", 0, y );
		
		if (prevFrame)
		then frame:SetPoint( "LEFT", prevFrame,    "RIGHT", x+s, 0 );
		else frame:SetPoint( "LEFT", outsideFrame, "RIGHT", x+s, 0 );
		end
		
		justifyH = "LEFT";
		
	elseif (position == CB.POS_RIGHT_TOP) then
	
		frame:SetPoint( "TOP", outsideFrame, "TOP", 0, y );
		
		if (prevFrame)
		then frame:SetPoint( "LEFT", prevFrame,    "RIGHT", x+s, 0 );
		else frame:SetPoint( "LEFT", outsideFrame, "RIGHT", x+s, 0 );
		end
		
		justifyH = "LEFT";
	end
	
	--Justify if dealing with text frame
	if (frame.SetJustifyH and justifyH) then
		frame:SetJustifyH( justifyH );
	end
end
