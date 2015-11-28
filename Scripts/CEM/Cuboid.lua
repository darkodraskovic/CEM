Cuboid = {}

--stores picked cuboid side info
Cuboid.sideInfo = {
	position = Vec3(),
	normal = Vec3(),
	direction = "",
	vertexIndices = {0,1,2,3},
	vertexPositions = {Vec3(),Vec3(),Vec3(),Vec3()},
	size = Vec3(),
}

--collect picked cuboid side information
function Cuboid:FillSideInfo(pickInfo, sideInfo)
	sideInfo = sideInfo or Cuboid.sideInfo
	sideInfo.position = Transform:Point(pickInfo.position,NULL,pickInfo.entity)
	
	--normal & direction
	local normal = pickInfo.normal	
	local dir = ""
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
	local blVertex = math.floor(s:GetTriangleVertex(t,0) / 4)*4
	sideInfo.vertexIndices = {blVertex, blVertex+1, blVertex+2, blVertex+3}
	for i,v in ipairs(sideInfo.vertexIndices) do
		sideInfo.vertexPositions[i] = s:GetVertexPosition(v)
	end
	
	--size
	local aabb = pickInfo.entity:GetAABB(Entity.LocalAABB)
	sideInfo.size = aabb.size
	
	return sideInfo
end

Cuboid.cutInfo = {
	position2D = Vec2(),
	direction = 0, --0: Horizontal, 90: Vertical
	facing = 1, --1: Face X axis, 2: Face Y axis, Face Z axis
}

function Cuboid:FillCutInfo(sideInfo, cutInfo)
	sideInfo = sideInfo or Cuboid.sideInfo
    cutInfo = cutInfo or Cuboid.cutInfo
    
	--side axes
    local sideDir = sideInfo.direction
    local pos = sideInfo.position
    local pos2D
    if sideDir == "front" or sideDir == "back" then
		pos2D = pos:xy()
		cutInfo.facing = 3
    elseif sideDir == "left" or sideDir == "right" then
		pos2D = pos:zy()
		cutInfo.facing = 1
    else
		pos2D = pos:xz()
		cutInfo.facing = 2
    end
	cutInfo.position2D = pos2D
    
    --quadrant
    local x, y = Math:Round(pos2D.x), Math:Round(pos2D.y)
    --distance from quadrant edges
    local diffX, diffY = math.abs(pos2D.x-x), math.abs(pos2D.y-y)
	--cut direction
    local cutDir
    if (diffX < diffY) then cutDir = 90 --"vertical" 
    else cutDir = 0 --"horizontal"
    end
	cutInfo.direction = cutDir
	
	return cutInfo
end