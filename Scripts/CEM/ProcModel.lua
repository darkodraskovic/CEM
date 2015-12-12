ProcModel = {}

function ProcModel:AddTri()
    
end

function ProcModel:addQuad(offsetPos, widthDir, heightDir, tileX, tileY)
    local norm = heightDir:Cross(widthDir):Normalize()
    
    self._surface:AddVertex(offsetPos, norm, Vec2(0,0))
    self._surface:AddVertex(offsetPos+widthDir, norm, Vec2(tileX,0))
    self._surface:AddVertex(offsetPos+widthDir+heightDir, norm, Vec2(tileX,tileY))
    self._surface:AddVertex(offsetPos+heightDir, norm, Vec2(0,tileY))

    local offsetInd = self._surface:CountVertices()-4
    self._surface:AddTriangle(offsetInd+2,offsetInd+1,offsetInd+0) 
    self._surface:AddTriangle(offsetInd+0,offsetInd+3,offsetInd+2)    
end

function ProcModel:Model()
    local model = Model:Create()
    local surface = model:AddSurface()
	self:SetModel(model)
    return model, surface
end

function ProcModel:SetModel(model)
    self._model = model
    self._surface = model:GetSurface(0)
end

function ProcModel:Material(texture, shader)
	
end

function ProcModel:SetMaterial(material, model)
	model = model or self._model

	if (type(material) == "string") then
		local material = Material:Load(material)
		model:SetMaterial(material)
		material:Release()
	elseif (type(material) == "userdata") then
		model:SetMaterial(material)
	end
end

function ProcModel:UpdateSurface()
    self._surface:Update() 
    self._model:UpdateAABB(Entity.LocalAABB)
    self._model:UpdateAABB(Entity.GlobalAABB)
end

function ProcModel:Box(width, height, depth, material)
    local model = ProcModel:Model()
	
    local origin = Vec3(0,0,0)
    local forwardDir = Vec3(0, 0, depth)
    local rightDir = Vec3(width, 0, 0)
    local upDir = Vec3(0, height, 0)
	
    self:addQuad(origin, rightDir, upDir, width, height) --front
    self:addQuad(origin+rightDir, forwardDir, upDir,  depth, height) --right
    self:addQuad(origin+rightDir+forwardDir, rightDir:Inverse(), upDir, width, height) --back
    self:addQuad(origin+forwardDir, forwardDir:Inverse(), upDir, depth, height) --left
    self:addQuad(origin+forwardDir, rightDir, forwardDir:Inverse(), width, depth) --bottom
    self:addQuad(origin+upDir, rightDir, forwardDir, width, depth, 20) --top
    self:UpdateSurface()    

	if (material) then self:SetMaterial(material) end	
	
    return model
end