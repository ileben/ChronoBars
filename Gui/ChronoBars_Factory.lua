--[[

====================================================
ChronoBars - buff, debuff, cooldown, totem tracker
Author: Ivan Leben
====================================================

--]]

local CB = ChronoBars;



--Factory
--===========================================================================


function ChronoBars.NewObject( class )

	--Init class factory first time
	if (CB.factory == nil) then
		CB.factory = {};
	end
	
	if (CB.factory[ class ] == nil) then
		CB.factory[ class ] = {};
		CB.factory[ class ].objects = {};
		CB.factory[ class ].capacity = 0;
		CB.factory[ class ].used = 0;
	end
	
	--Get class-specific factory
	local object = nil;
	local factory = CB.factory[ class ];
	local capacity = table.getn( factory.objects );

	--Check if there's any unused objects left
	if (factory.used < capacity) then

		--Return existing object
		factory.used = factory.used + 1;
		object = factory.objects[ factory.used ];

	else

		--Create new object if capacity exhausted
		factory.used = capacity + 1;

		if     (class == "button")      then object = CB.Button_New      ( "ChronoBars.Button"      .. factory.used );
		elseif (class == "input")       then object = CB.Input_New       ( "ChronoBars.Input"       .. factory.used );
		elseif (class == "checkbox")    then object = CB.Checkbox_New    ( "ChronoBars.Checkbox"    .. factory.used );
		elseif (class == "dropdown")    then object = CB.Drop_New        ( "ChronoBars.Dropdown"    .. factory.used );
		elseif (class == "color")       then object = CB.ColorSwatch_New ( "ChronoBars.Color"       .. factory.used );
		elseif (class == "header")      then object = CB.Header_New      ( "ChronoBars.Header"      .. factory.used );
		elseif (class == "groupframe")  then object = CB.GroupFrame_New  ( "ChronoBars.GroupFrame"  .. factory.used );
		elseif (class == "tab")         then object = CB.Tab_New         ( "ChronoBars.Tab"         .. factory.used );
		elseif (class == "tabframe")    then object = CB.TabFrame_New    ( "ChronoBars.TabFrame"    .. factory.used );
		elseif (class == "scrollframe") then object = CB.ScrollFrame_New ( "ChronoBars.ScrollFrame" .. factory.used );
		elseif (class == "font")        then object = CB.FontDrop_New    ( "ChronoBars.FontDrop"    .. factory.used );
		elseif (class == "texture")     then object = CB.TexDrop_New     ( "ChronoBars.TexDrop"     .. factory.used );
		end

		--Add to list of objects
		object.factoryClass = class;
		object.factoryId = factory.used;
		table.insert( factory.objects, object );

	end

	--Init object
	object.factoryUsed = true;
	object:Show();
	
	--Notify object it's been inited
	if (object.Init) then
		object:Init();
	end
	
	return object;
end


function ChronoBars.FreeObject( object )

	--Object must be used
	if (object.factoryUsed == false) then
		return
	end
	
	--Swap freed object with last used object and their ids
	local factory = CB.factory[ object.factoryClass ];
	
	if (object.factoryId < factory.used) then

		local objectId = object.factoryId;
		local lastId = factory.used;
		local last = factory.objects[ lastId ];

		factory.objects[ objectId ] = last;
		factory.objects[ lastId ] = object; 

		object.factoryId = lastId;
		last.factoryId = objectId;
	end

	factory.used = factory.used - 1;
	
	--Reset object
	object.factoryUsed = false;
	object:Hide();
	object:ClearAllPoints();
	object:SetParent( nil );
	
	--Notify object it's been freed
	if (object.Free) then
		object:Free();
	end
end


function ChronoBars.FreeAllObjects()

	--Factory must exist
	if (CB.factory == nil) then
		return
	end
	
	--Walk every factory
	for class,factory in pairs(CB.factory) do

		--Walk every object in factory
		for id,object in ipairs(factory.objects) do
		
			--Reset object
			object.factoryUsed = false;
			object:Hide();
			object:ClearAllPoints();
			object:SetParent( nil );
		end
		
		--Walk every object in factory
		for id,object in ipairs(factory.objects) do
		
			--Notify object it's been freed
			if (object.Free) then
				object:Free()
			end
		end
		
		factory.used = 0;
	end
end
