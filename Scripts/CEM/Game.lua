--GAME
Game = {}

Game.window = Window:GetCurrent()
Game.windowWidth = Game.window:GetWidth()
Game.windowHeight = Game.window:GetHeight()
Game.windowCenter = Vec2(Game.windowWidth/2, Game.windowHeight/2)

Game.camera = Camera:Create()
Game.camera:SetScript("Scripts/Objects/Cameras/FlyCam.lua")

sprite = Sprite:Create()
function Game:Start()	
	DebugInfo:Init(Cuboid.cutInfo)	

	local model = ProcModel:Box(4, 1, 3, "Materials/Developer/bluegrid.mat")
	--model:Move(2,0,-2)	

	--local material = Material:Create()
	--local texture = Texture:Load("Materials/Sprites/Laser_Red.tex")
	--material:SetTexture(texture)
	local material = Material:Load("Materials/Sprites/Laser.mat")
	sprite:SetMaterial(material)
	sprite:SetSize(1,0.05)
	sprite:SetScale(1,0.1,0.1)
end

function Game:Update()	
	--pick
	if (self.window:MouseHit(1)) then
		DebugInfo.pickSphere:Hide() 
		local pickInfo = PickInfo()
		if (self.camera:Pick(Game.windowCenter.x, Game.windowCenter.y,pickInfo,0,true)) then			
			DebugInfo.pickSphere:Show() 
			DebugInfo.pickSphere:SetPosition(pickInfo.position) 
			Cuboid:FillSideInfo(pickInfo)
			local cutInfo = Cuboid:FillCutInfo()
			DebugInfo:PrintInfo(Cuboid.cutInfo)
			
			sprite:SetPosition(pickInfo.position)
			sprite:SetViewMode(cutInfo.facing)
			sprite:SetRotation(pickInfo.normal*cutInfo.direction)
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