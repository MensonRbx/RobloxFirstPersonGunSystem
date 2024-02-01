local RunService = game:GetService("RunService")

if RunService:IsServer() then
    return 1
end

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local localPlayer = Players.LocalPlayer

local playerGui = localPlayer:WaitForChild("PlayerGui")
local ReticleGui = playerGui:WaitForChild("ReticleGui")
local ReticleMain = ReticleGui:WaitForChild("ReticleMain")

local currentCamera = workspace.CurrentCamera

local ALLOWED_STATES = {
    "Begin",
    "End"
}

local function getLocalPlayerViewportModel()
    return currentCamera:FindFirstChild("ViewportModel")
end

local function moveModel(adsJoint, goalC1)
    local start = adsJoint.C1

	for t = 0, 109, 10 do
		game:GetService("RunService").RenderStepped:Wait();
		adsJoint.C1 = start:Lerp(goalC1, t/100);
	end

    adsJoint.C1 = goalC1;
end

return function (_, inputState, inputObject)
    if not table.find(ALLOWED_STATES, inputState.Name) then
        return
    end

    local viewportModel = getLocalPlayerViewportModel()
    local adsJoint = viewportModel.Head:WaitForChild("ModelMotor6D")
    local toolModel = viewportModel.Head:FindFirstChildOfClass("Model")

    if inputState == Enum.UserInputState.Begin then
        local target = toolModel:GetAttribute("AimC1")
        toolModel:SetAttribute("Aiming", true)
        UserInputService.MouseIconEnabled = false
        moveModel(adsJoint, target)
        ReticleMain.Visible = false
    
    elseif inputState == Enum.UserInputState.End then
        task.delay(0.25, toolModel.SetAttribute, toolModel, "Aiming", false)
        UserInputService.MouseIconEnabled = true
        moveModel(adsJoint, CFrame.new())
        ReticleMain.Visible = true
    
    end
end