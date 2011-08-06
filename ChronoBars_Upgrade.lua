--[[

====================================================
ChronoBars - buff, debuff, cooldown, totem tracker
Author: Ivan Leben
====================================================

--]]

local CB = ChronoBars;


--Upgrade functions
--=====================================================

-- 1.2

function ChronoBars.Upgrade_1_2 ()

  if (ChronoBars_Settings.updateInterval == nil) then
    ChronoBars_Settings.updateInterval = 0.03;
  end
  
  for pname, profile in pairs( ChronoBars_Settings.profiles ) do
    for g=1,table.getn( profile.groups ) do
      for b=1,table.getn( profile.groups[g].bars ) do
      
        local bar = profile.groups[g].bars[b];
        
        if (bar.style.showCd == nil) then
          bar.style.showCd = bar.style.appendCd;
        end
        
        if (bar.style.showCount == nil) then
          bar.style.showCount = true;
        end
        
        if (bar.style.countSide == nil) then
          bar.style.countSide = ChronoBars.SIDE_RIGHT;
        end

        if (bar.style.lsmFontHandle == nil) then
          bar.style.lsmFontHandle  = "Friz Quadrata TT";
        end

        if (bar.style.lsmTexHandle == nil) then
          bar.style.lsmTexHandle   = "None";
        end
        
        if (bar.style.iconZoom == nil) then
          bar.style.iconZoom = true;
        end
        
      end
    end
  end
end

function ChronoBars.UpgradeChar_1_2 ()
end

-- 1.3

function ChronoBars.Upgrade_1_3 ()

  for pname, profile in pairs( ChronoBars_Settings.profiles ) do
    for g=1,table.getn( profile.groups ) do
      local grp = profile.groups[g];
      
      if (grp.style == nil) then
        grp.style = CopyTable( ChronoBars.DEFAULT_GROUP.style );
      end
      
      if (grp.margin == nil) then
        grp.margin = ChronoBars.DEFAULT_GROUP.margin;
      end

      for b=1,table.getn( profile.groups[g].bars ) do
        local bar = profile.groups[g].bars[b];
        
      end
    end
  end
end

function ChronoBars.UpgradeChar_1_3 ()
end


-- 1.4

function ChronoBars.Upgrade_1_4 ()

  for pname, profile in pairs( ChronoBars_Settings.profiles ) do
    for g=1,table.getn( profile.groups ) do
      local grp = profile.groups[g];

      for b=1,table.getn( profile.groups[g].bars ) do
        local bar = profile.groups[g].bars[b];

        if (bar.aura.order == nil) then
          bar.aura.order = 1;
        end
        
        if (bar.usable == nil) then
          bar.usable = CopyTable( CB.DEFAULT_BAR.usable );
        end
        
        if (bar.style.showUsable == nil) then
          bar.style.showUsable = true;
        end
        
      end
    end
  end
end

function ChronoBars.UpgradeChar_1_4 ()
end


-- 1.5

function ChronoBars.Upgrade_1_5 ()

  if (ChronoBars_Settings.updateInterval == 0.03) then
    ChronoBars_Settings.updateInterval = 0.01;
  end
  
  for pname, profile in pairs( ChronoBars_Settings.profiles ) do
    for g=1,table.getn( profile.groups ) do
      local grp = profile.groups[g];

      for b=1,table.getn( profile.groups[g].bars ) do
        local bar = profile.groups[g].bars[b];
        
        if (bar.display == nil) then
          bar.display = CopyTable( CB.DEFAULT_BAR.display );
        end
        
        if (bar.custom == nil) then
          bar.custom = CopyTable( CB.DEFAULT_BAR.custom );
        end
        
        if (bar.type == CB.EFFECT_TYPE_INTERNAL_CD) then
          bar.type = CB.EFFECT_TYPE_CUSTOM;
          bar.custom.trigger = CB.CUSTOM_TRIGGER_BAR_ACTIVE;
          bar.custom.duration = bar.internal.duration;
        end
        
        if (bar.style.showSpark == nil) then
          bar.style.showSpark = true;
        end
        
        if (bar.style.anim == nil) then
          bar.style.anim = CopyTable( CB.DEFAULT_BAR.style.anim );
        end
        
        if (bar.style.anim.blinkUsable == nil) then
          bar.style.anim.blinkUsable = true;
        end
        
      end
    end
  end
end

function ChronoBars.UpgradeChar_1_5 ()
end

-- 1.6

function ChronoBars.Upgrade_1_6 ()

  for pname, profile in pairs( ChronoBars_Settings.profiles ) do
    for g=1,table.getn( profile.groups ) do
      local grp = profile.groups[g];
      
      if (grp.sorting == nil) then
        grp.sorting = CB.DEFAULT_GROUP.sorting;
      end

      for b=1,table.getn( profile.groups[g].bars ) do
        local bar = profile.groups[g].bars[b];
        
        if (bar.style.sparkHeight == nil) then
          bar.style.sparkHeight = CB.DEFAULT_BAR.style.sparkHeight;
        end
        
        if (bar.style.sparkWidth == nil) then
          bar.style.sparkWidth = CB.DEFAULT_BAR.style.sparkWidth;
        end
        
        if (bar.style.visibility == nil) then
          bar.style.visibility = CB.DEFAULT_BAR.style.visibility;
        end
        
      end
    end
  end
end

function ChronoBars.UpgradeChar_1_6 ()
end

-- 1.8

function ChronoBars.Upgrade_1_8 ()

  for pname, profile in pairs( ChronoBars_Settings.profiles ) do
    for g=1,table.getn( profile.groups ) do
      local grp = profile.groups[g];

      for b=1,table.getn( profile.groups[g].bars ) do
        local bar = profile.groups[g].bars[b];

        if (bar.enabled == nil) then
          bar.enabled = true;
        end
        
      end
    end
  end
end

function ChronoBars.UpgradeChar_1_8 ()
end

-- 1.9

function ChronoBars.Upgrade_1_9 ()

  for pname, profile in pairs( ChronoBars_Settings.profiles ) do
    for g=1,table.getn( profile.groups ) do
      local grp = profile.groups[g];

      for b=1,table.getn( profile.groups[g].bars ) do
        local bar = profile.groups[g].bars[b];

        if (bar.auto == nil) then
          bar.auto = CopyTable( ChronoBars.DEFAULT_BAR.auto );
        end
        
        if (bar.enchant == nil) then
          bar.enchant = CopyTable( ChronoBars.DEFAULT_BAR.enchant );
        end
        
      end
    end
  end
end

function ChronoBars.UpgradeChar_1_9 ()
end

-- 1.10

function ChronoBars.Upgrade_1_10 ()

  for pname, profile in pairs( ChronoBars_Settings.profiles ) do
    for g=1,table.getn( profile.groups ) do
      local grp = profile.groups[g];

      for b=1,table.getn( profile.groups[g].bars ) do
        local bar = profile.groups[g].bars[b];

          if (bar.style.anim.blinkSlow == nil) then
            bar.style.anim.blinkSlow = bar.style.anim.blink;
          end
          
          if (bar.style.anim.blinkFast == nil) then
            bar.style.anim.blinkFast = CB.DEFAULT_BAR.style.anim.blinkFast;
          end
          
        end
    end
  end
end

function ChronoBars.UpgradeChar_1_10 ()
end

-- 1.12

function ChronoBars.Upgrade_1_12 ()

  for pname, profile in pairs( ChronoBars_Settings.profiles ) do
    for g=1,table.getn( profile.groups ) do
      local grp = profile.groups[g];

      for b=1,table.getn( profile.groups[g].bars ) do
        local bar = profile.groups[g].bars[b];
          
          if (bar.style.nameJustify == nil) then
            if (bar.style.timeSide == CB.SIDE_RIGHT)
            then bar.style.nameJustify = CB.JUSTIFY_LEFT;
            else bar.style.nameJustify = CB.JUSTIFY_RIGHT;
            end
          end
          
        end
    end
  end
end

function ChronoBars.UpgradeChar_1_12 ()
end


-- 2.0

function ChronoBars.Upgrade_2_0 ()

	for pname, profile in pairs( ChronoBars_Settings.profiles ) do
		for g=1,table.getn( profile.groups ) do
			local grp = profile.groups[g];

			for b=1,table.getn( profile.groups[g].bars ) do
				local bar = profile.groups[g].bars[b];
				
				--Icon
				if (bar.style.icon == nil) then
					bar.style.icon = CopyTable( CB.DEFAULT_BAR.style.icon );
					
					bar.style.icon.enabled = bar.style.showIcon;
					bar.style.icon.zoom = bar.style.iconZoom;
					
					if (bar.style.iconSide == CB.SIDE_LEFT)
					then bar.style.icon.position = CB.POS_LEFT_MIDDLE;
					else bar.style.icon.position = CB.POS_RIGHT_MIDDLE;
					end
				end
				
				--Spark
				if (bar.style.spark == nil) then
					bar.style.spark = CopyTable( CB.DEFAULT_BAR.style.spark );
					
					bar.style.spark.enabled = bar.style.showSpark;
					bar.style.spark.width = bar.style.sparkWidth;
					bar.style.spark.height = bar.style.sparkHeight;
				end
				
				--Text
				if (bar.style.text == nil) then
					bar.style.text = CopyTable( CB.DEFAULT_BAR.style.text );
					
					for t=1,table.getn(bar.style.text) do
						bar.style.text[t].timeFormat = bar.style.timeFormat;
						bar.style.text[t].font = bar.style.lsmFontHandle;
						bar.style.text[t].size = bar.style.fontSize;
						bar.style.text[t].textColor = CopyTable( bar.style.textColor );
					end
				end
				
			end
		end
	end
end

function ChronoBars.UpgradeChar_2_0 ()
end


-- 2.1

function CB.Upgrade_2_1 ()
end

function CB.UpgradeChar_2_1 ()

	local save = ChronoBars_CharSettings;
	
	if (save.minimapButtonPos == nil) then
		save.minimapButtonPos = CB.DEFAULT_CHAR_SETTINGS.minimapButtonPos;
	end
end

-- 2.1

function CB.Upgrade_2_2 ()

	for pname, profile in pairs( ChronoBars_Settings.profiles ) do
		for g=1,table.getn( profile.groups ) do
			local grp = profile.groups[g];

			for b=1,table.getn( profile.groups[g].bars ) do
				local bar = profile.groups[g].bars[b];
				
				--Text width
				for t=1,table.getn( bar.style.text ) do
					if (bar.style.text[t].width == nil) then
						bar.style.text[t].width = 0;
					end
				end
				
			end
		end
	end
end

function CB.UpgradeChar_2_2 ()

	local save = ChronoBars_CharSettings;
	
	if (save.minimapButtonEnabled == nil) then
		save.minimapButtonEnabled = true;
	end
end
