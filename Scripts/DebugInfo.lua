DebugInfo = {}

function DebugInfo:InitInfo(info)
	local verticalPos = 16
	for k,v in pairs(info) do
		local t = LED.Text:Create(k .. ": ")
		t:SetColor(1,1,1,1)
		t:SetPosition(16, verticalPos)
		verticalPos = verticalPos + t:GetHeight() + 8
		DebugInfo[k] = t
	end
end

function DebugInfo:PrintInfo(info)
	for k,v in pairs(info) do
		local text = DebugInfo:GetText(v)
		DebugInfo[k]:SetText(k .. ": " .. text)
	end
end

function DebugInfo:GetText(obj, text)
	text = text or ""
	
	if type(obj) == "userdata" then
		text = text .. obj:ToString()
	elseif type(obj) == "table" then		
		for k,v in pairs(obj) do
			text = DebugInfo:GetText(v, text) .. ", "
		end
	else
		text = text .. inspect(obj)
	end
	
	return text
end