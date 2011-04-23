--[[

====================================================
ChronoBars - buff, debuff, cooldown, totem tracker
Author: Ivan Leben
====================================================

--]]

local CB = ChronoBars;



--Object
--=============================================================

function ChronoBars.Object_New( o )

	o.Init                  = ChronoBars.Object_Init;
	o.Free                  = ChronoBars.Object_Free;
	o.RegisterScript        = ChronoBars.Object_RegisterScript;
	o.UnregisterScript      = ChronoBars.Object_UnregisterScript;
	o.UnregisterAllScripts  = ChronoBars.Object_UnregisterAllScripts;
	o.InvokeScript          = ChronoBars.Object_InvokeScript;
	
	return o;
end

function ChronoBars.Object_Init( o )
end

function ChronoBars.Object_Free( o )
end

function ChronoBars.Object_RegisterScript( object, script, func )

	--Create callback table if missing
	if (object.callbacks == nil) then
		object.callbacks = {};
	end
	
	if (object.callbacks[ script ] == nil) then
		object.callbacks[ script ] = {};
	end
	
	--Check if function already registered
	local callbacks = object.callbacks[ script ];
	for i,f in ipairs( callbacks ) do
		if (f == func) then
			return
		end
	end
	
	--Add to callback table
	table.insert( callbacks, func );
	
	--Check for missing script handler
	if (object:GetScript( script ) == nil) then
	
		--Closure passes script name to invoke function along with other arguments
		local scriptClosure = function( object, ... )
			ChronoBars.Object_InvokeScript( object, script, ... );
		end
		
		--Set closure as script handler
		object:SetScript( script, scriptClosure );
	end
end

function ChronoBars.Object_UnregisterScript( object, script, func )

	--Must have valid callback table
	if (object.callbacks == nil) then
		return;
	end
	
	if (object.callbacks[ script ] == nil) then
		return
	end
	
	--Search for registered function
	local callbacks = object.callbacks[ script ];
	for i,f in ipairs( callbacks ) do
		if (f == func) then
		
			--Remove from callback table
			table.remove( callbacks, i );
		end
	end
end

function ChronoBars.Object_UnregisterAllScripts( object )

	--Must have valid callback table
	if (object.callbacks == nil) then
		return;
	end
		
	--Remove all callbacks from every callback tables
	for script,callbacks in pairs(object.callbacks) do
		CB.Util_ClearTable( callbacks );
	end
end

function ChronoBars.Object_InvokeScript( object, script, ... )
	
	--Must have valid callback table
	if (object.callbacks == nil) then
		return;
	end
	
	--Invoke all the callback functions
	local callbacks = object.callbacks[ script ];
	for i,func in ipairs( callbacks ) do
		func( object, ... );
	end
end
