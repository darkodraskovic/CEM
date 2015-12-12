Cuboid = {}

-- SIDE INFO
--stores picked cuboid side info
Cuboid.sideInfo = {
	position3D = Vec3(), --pick position 3D transformed in local space
	normal = Vec3(),
	direction = "",
	vertexIndices = {0,1,2,3},
	vertexPositions = {Vec3(),Vec3(),Vec3(),Vec3()},
	size = Vec3(),
}

--collect picked cuboid side information
function Cuboid:FillSideInfo(pickInfo, sideInfo)
	sideInfo = sideInfo or Cuboid.sideInfo
	--sideInfo.position3D = Transform:Point(pickInfo.position,NULL,pickInfo.entity)
	sideInfo.position3D = pickInfo.position
	
	--normal & direction
	local normal = pickInfo.normal	
	local dir = ""
	--axis aligned cuboid side has x|y|z=+-1
	local precision = 0.1
	if (normal.x < -precision) then dir = "left"
	elseif (normal.x > precision) then dir = "right"
	elseif (normal.y < -precision) then dir = "bottom"
	elseif (normal.y > precision) then dir = "top"
	elseif (normal.z < -precision) then dir = "front"
	elseif (normal.z > precision) then dir = "back"
	end
	sideInfo.normal = normal
	sideInfo.direction = dir
	
	--vertex indices & positions
	local t = pickInfo.triangle
	local s = pickInfo.surface
	--bottom left vertex of the side quad
	local blVertex = math.floor(s:GetTriangleVertex(t,0) / 4)*4
	--[[
	for i,v in ipairs(sideInfo.vertexIndices) do
		local vertex = blVertex+i-1
		sideInfo.vertexIndices[i] = vertex
		sideInfo.vertexPositions[i] = s:GetVertexPosition(vertex)
	end
	--]]
	sideInfo.vertexIndices = {blVertex, blVertex+1, blVertex+2, blVertex+3}
	for i,v in ipairs(sideInfo.vertexIndices) do
		sideInfo.vertexPositions[i] = s:GetVertexPosition(v)
	end
		
	--size
	local aabb = pickInfo.entity:GetAABB(Entity.LocalAABB)
	sideInfo.size = aabb.size
	
	return sideInfo
end

-- CUT INFO
Cuboid.cutInfo = {
	position2D = Vec2(), --pick position 2D transformed in local space
	snapPosition2D = Vec2(), --grid snapped position2D
	direction = 0, --0: Horizontal, 90: Vertical
	facing = 1, --Sprite related; 1: Face X axis, 2: Face Y axis, 3:Face Z axis; 
}

-- used with FillCutInfo
function Cuboid:GetPos2DAndFacing(sideDir, pos3D)
	local pos2D
	local facing
	
    if sideDir == "front" or sideDir == "back" then
		pos2D = pos3D:xy()
		facing = 3
    elseif sideDir == "left" or sideDir == "right" then
		pos2D = pos3D:zy()
		facing = 1
    else
		pos2D = pos3D:xz()
		facing = 2
    end
	
	return pos2D, facing
end

function Cuboid:FillCutInfo(sideInfo, cutInfo)
	sideInfo = sideInfo or Cuboid.sideInfo
    cutInfo = cutInfo or Cuboid.cutInfo
    
	cutInfo.position2D, cutInfo.facing = self:GetPos2DAndFacing(sideInfo.direction, sideInfo.position3D)
    
	local pos2D = cutInfo.position2D
    --quadrant
    local x, y = Math:Round(pos2D.x), Math:Round(pos2D.y)
    --distance from quadrant edges
    local diffX, diffY = math.abs(pos2D.x-x), math.abs(pos2D.y-y)
	--cut direction
    if (diffX < diffY) then 
		cutInfo.direction = 90 --"vertical" 
    else 
		cutInfo.direction = 0 --"horizontal"
    end	
	cutInfo.snapPosition2D = Vec2(x,y)
	
	return cutInfo
end