--GAME
Game = {}

Game.window = Window:GetCurrent()
Game.windowWidth = Game.window:GetWidth()
Game.windowHeight = Game.window:GetHeight()
Game.windowCenter = Vec2(Game.windowWidth/2, Game.windowHeight/2)

Game.camera = Camera:Create()
Game.camera:SetScript("Scripts/Objects/Cameras/FlyCam.lua")

function Game:Start()	
	--pickinfo
	--DebugInfo:SetPickInfo()
	DebugInfo:InitInfo(Cuboid.sideInfo)
	
	--Create a sphere to indicate where the pick hits
	self.picksphere = Model:Sphere() 
	self.picksphere:SetColor(1.0,0.0,0.0) 
	self.picksphere:SetPickMode(0) 
	self.picksphere:SetScale(0.1) 
	self.picksphere:Hide() 

	local model = ProcModel:Box(4, 1, 3)
	material = Material:Load("Materials/Developer/bluegrid.mat")
	model:SetMaterial(material)
	--model:Move(2,0,-2)	
	
	--System:Print(type({}))
end

function Game:Update()	
	--pick
	if (self.window:MouseHit(1)) then
			self.picksphere:Hide() 
			local pickInfo = PickInfo()
			if (self.camera:Pick(Game.windowCenter.x, Game.windowCenter.y,pickInfo,0,true)) then			
				self.picksphere:Show() 
				self.picksphere:SetPosition(pickInfo.position) 
				--DebugInfo:PrintPickInfo(pickInfo)
				Cuboid:FillSideInfo(pickInfo)
				DebugInfo:PrintInfo(Cuboid.sideInfo)
				--System:Print(inspect(Cuboid.sideInfo))
			end
	end
	
end

--GUI
GUI = {}
GUI.context = Context:GetCurrent()

function GUI:Start()
	--crosshair
	self.crosshair = LED.Image:Create("Materials/GUI/Crosshair.tex")
	self.crosshair:SetPosition(Game.windowCenter.x - self.crosshair:GetWidth()/2, 
		Game.windowCenter.y  - self.crosshair:GetHeight()/2)	
end

function GUI:Update()
	LED:Update(self.context)
end

--CUBOID
Cuboid = {}
--stores picked cuboid side info
Cuboid.sideInfo = {
	pickPosition = Vec3(),
	normal = Vec3(),
	direction = "",
	vertexIndices = {0,1,2,3},
	vertexPositions = {Vec3(),Vec3(),Vec3(),Vec3()},
	size = Vec3(),
}

function Cuboid:FillSideInfo(pickInfo, sideInfo)
	sideInfo = sideInfo or Cuboid.sideInfo
	sideInfo.pickPosition = Transform:Point(pickInfo.position,NULL,pickInfo.entity)
	
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
	
	local t = pickInfo.triangle
	local s = pickInfo.surface
	local blVertex = math.floor(s:GetTriangleVertex(t,0) / 4)*4
	sideInfo.vertexIndices = {blVertex, blVertex+1, blVertex+2, blVertex+3}
	for i,v in ipairs(sideInfo.vertexIndices) do
		sideInfo.vertexPositions[i] = s:GetVertexPosition(v)
		--System:Print(sideInfo.vertexPositions[i]:ToString())
	end
	
	local aabb = pickInfo.entity:GetAABB(Entity.LocalAABB)
	sideInfo.size = aabb.size
end