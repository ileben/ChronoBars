--[[

====================================================
ChronoBars - buff, debuff, cooldown, totem tracker
Author: Ivan Leben
====================================================

--]]

local CB = ChronoBars;


--Container
--=====================================================================

function ChronoBars.Container_New( f )
	
	--Private vars
	f.spacing = 10;
	f.width = 0;
	f.height = 0;
	f.containerWidth = 0;
	f.containerHeight = 0;
	f.contentHeight = 0;
	f.rowHeight = {};
	
	f.children = {};
	f.childrenStatus = {};
	
	--Functions
	ChronoBars.Object_New( f );
	
	f.Init              = ChronoBars.Container_Init;
	f.Free              = ChronoBars.Container_Free;
	f.AddChild          = ChronoBars.Container_AddChild;
	f.RemoveAllChildren = ChronoBars.Container_RemoveAllChildren;
	f.FindChildIndex    = ChronoBars.Container_FindChildIndex;
	f.SetSpacing        = ChronoBars.Container_SetSpacing;
	f.GetContentHeight  = ChronoBars.Container_GetContentHeight;
	f.UpdateContent     = ChronoBars.Container_UpdateContent;
	f.QueueUpdate       = ChronoBars.Container_QueueUpdate;
	
	f.container:SetScript( "OnSizeChanged", ChronoBars.Container_OnContainerSizeChanged );
	
	return f;
end

function ChronoBars.Container_Init( frame )

	ChronoBars.Object_Init( frame );
	
	frame.width = 0;
	frame.height = 0;
	frame.containerWidth = 0;
	frame.containerHeight = 0;
	frame.contentHeight = 0;
	
	frame:QueueUpdate();
end

function ChronoBars.Container_Free( frame )

	frame:RemoveAllChildren();	
	ChronoBars.Object_Free( frame );
end

function ChronoBars.Container_SetSpacing( frame, spacing )

	frame.spacing = spacing;
	frame:UpdateContent();
end

function ChronoBars.Container_GetContentHeight( frame )

	return frame.contentHeight;
end

function ChronoBars.Container_AddChild( frame, child, autoWidth, autoHeight )

	--CB.Print( "ADD CHILD " .. frame:GetName() );
	
	if (autoWidth == nil) then autoWidth = false; end
	if (autoHeight == nil) then autoHeight = false; end

	table.insert( frame.children, child );
	local i = table.getn( frame.children );
	
	if (table.getn( frame.childrenStatus ) < i) then
		table.insert( frame.childrenStatus, {} );
	end
	
	local status = frame.childrenStatus[i];
	status.autoWidth = autoWidth;
	status.autoHeight = autoHeight;
	status.width = 0;
	status.height = 0;
	status.x = 0;
	status.y = 0;
	status.r = 0;
	
	child.parent = frame;	
	child.containerIndex = i;
	
	child:SetPoint( "TOPLEFT" );
	child:SetParent( frame.container );
	child:RegisterScript( "OnSizeChanged", ChronoBars.Container_OnChildSizeChanged );
	
	frame:QueueUpdate();
end

function ChronoBars.Container_RemoveAllChildren( frame )

	for i,child in ipairs(frame.children) do
	
		child.parent = nil;
		child.containerIndex = nil;
		
		child:ClearAllPoints();
		child:SetParent( nil );
		child:UnregisterScript( "OnSizeChanged", ChronoBars.Container_OnChildSizeChanged );
	end
	
	CB.Util_ClearTable( frame.children );
end

function ChronoBars.Container_FindChildIndex( frame, child )
	
	for i,c in ipairs(frame.children) do
		if (c == child) then
			return i;
		end
	end
	
	return 0;
end

function ChronoBars.Container_UpdateContent( frame )
	
	--CB.Print( "UPDATING LAYOUT " .. frame:GetName() );

	--Set update lock
	frame.updating = true;

	--Init alignment vars
	CB.Util_ClearTable( frame.rowHeight );
	local leftStatus = nil;
	local leftChild = nil;
	local x = 0;
	local y = 0;
	local h = 0;
	local r = 1;
	
	--Update container size if set directly on the frame
	if (frame.containerWidth == 0) then
		frame.containerWidth = frame.container:GetWidth() or 0;
	end
	
	if (frame.containerHeight == 0) then
		frame.containerHeight = frame.container:GetHeight() or 0;
	end
	
	--Walk all the children
	local numChildren = table.getn( frame.children );
	for i=1,numChildren do

		--Update item size if set directly on the frame
		local child = frame.children[i];
		local status = frame.childrenStatus[i];
		
		if (status.width == 0) then
			status.width = child:GetWidth() or 0;
		end
		if (status.height == 0) then
			status.height = child:GetHeight() or 0;
		end
		
		--Is this not first item in row?
		if (leftChild ~= nil) then
		
			--Check if auto-width or row can't fit another item
			if (status.autoWidth or	leftStatus.autoWidth or x + 200 > frame.containerWidth)	then
				
				--Move down
				table.insert( frame.rowHeight, h );
				y = y + h + frame.spacing;
				r = r + 1;
				x = 0;
				h = 0;
				leftChild = nil;
				leftStatus = nil;
			end
			
			--Move right by spacing distance if still not first in row
			if (leftChild ~= nil) then
				x = x + frame.spacing;
			end
		end
		
		--Store child info
		status.x = x;
		status.y = y;
		status.r = r;
		
		--Move right
		x = x + 200;
		leftChild = child;
		leftStatus = status;
		
		--Update row height
		if (h < status.height) then
			h = status.height;
		end
	end
	
	--Move down for last row
	table.insert( frame.rowHeight, h );
	y = y + h;
	
	
	--Walk all children again
	for i=1,numChildren do
	
		local status = frame.childrenStatus[i];
		local child = frame.children[i];
		child:ClearAllPoints();
		
		--Position item
		local pad = (frame.rowHeight[ status.r ] - status.height) / 2;
		child:SetPoint( "TOPLEFT", frame.container, "TOPLEFT", status.x, -status.y-pad );
		
		--Size item to width of container
		if (status.autoWidth) then
			child:SetPoint( "RIGHT", frame.container, 0,0 );
		
		elseif (frame.containerWidth < 200) then
			child:SetWidth( frame.containerWidth );
		
		else
			child:SetWidth( 200 );
		end
		
		--Size item to height of container
		if (status.autoHeight) then
			child:SetPoint( "BOTTOM", frame.container, "BOTTOM" );
		end
		
	end
	
	--Resize
	--CB.Print( "SIZING TO CONTENT ("..tostring(frame.contentHeight)..") "..frame:GetName() );
	frame.contentHeight = y;
	frame:SizeToContent();
	
	--Release update lock
	frame.updating = false;
end

function ChronoBars.Container_OnContainerSizeChanged( container, width, height )

	local frame = container.frame;
	--CB.Print( "CONTAINER SIZE CHANGED " .. frame:GetName() );
	
	local oldWidth = frame.containerWidth;
	local oldHeight = frame.containerHeight;
	
	frame.containerWidth = width;
	frame.containerHeight = height;
	
	if (oldWidth == width and oldHeight == height) then
		return
	end

	frame:QueueUpdate();
	
end

function ChronoBars.Container_OnChildSizeChanged( child, width, height )
	
	--CB.Print( "CHILD SIZE CHANGED " .. frame:GetName() );
	
	local frame = child.parent;
	local status = frame.childrenStatus[ child.containerIndex ];
	
	local oldWidth = status.width;
	local oldHeight = status.height;
	
	status.width = width;
	status.height = height;
	
	if (frame.updating) then
		--CB.Print( "UPDATE LOCK" );
		return
	end
	
	if (height == oldHeight or status.autoHeight) then
		--CB.Print( "SIZE LOCK" );
		return
	end
	
	frame:QueueUpdate();

end

function ChronoBars.Container_QueueUpdate( frame )

	frame:SetScript( "OnUpdate", ChronoBars.Container_OnUpdate );
end

function ChronoBars.Container_OnUpdate( frame )	

	frame:UpdateContent();
	frame:SetScript( "OnUpdate", nil );
end
