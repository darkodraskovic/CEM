--GAME
Game = {}

Game.window = Window:GetCurrent()
Game.windowWidth = Game.window:GetWidth()
Game.windowHeight = Game.window:GetHeight()
Game.windowCenter = Vec2(Game.windowWidth/2, Game.windowHeight/2)

Game.camera = Camera:Create()
Game.camera:SetScript("Scripts/Objects/Cameras/FlyCam.lua")

function Game:Start()	
	--Create a sphere to indicate where the pick hits
	self.picksphere = Model:Sphere() 
	self.picksphere:SetColor(1.0,0.0,0.0) 
	self.picksphere:SetPickMode(0) 
	self.picksphere:SetScale(0.1) 
	self.picksphere:Hide() 

	local model = ProcModel:Box(4, 2, 0.5)
	material = Material:Load("Materials/Developer/bluegrid.mat")
	model:SetMaterial(material)
end

function Game:Update()	
	if (self.window:MouseDown(1)) then
			self.picksphere:Hide() 
			local pickinfo = PickInfo()
			if (self.camera:Pick(Game.windowCenter.x, Game.windowCenter.y,pickinfo,0,true)) then			
				self.picksphere:Show() 
				self.picksphere:SetPosition(pickinfo.position) 
			end
	end
	
end

--HUD
GUI = {}
GUI.context = Context:GetCurrent()

function GUI:Start()
	self.crosshair = LED.Image:Create("Materials/GUI/Crosshair.tex")
	self.crosshair:SetPosition(Game.windowCenter.x - self.crosshair:GetWidth()/2, 
		Game.windowCenter.y  - self.crosshair:GetHeight()/2)
end

function GUI:Update()
	LED:Update(self.context)
end