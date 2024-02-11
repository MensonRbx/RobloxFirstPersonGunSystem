local RunService = game:GetService("RunService")

if RunService:IsServer() then
    return 1
end

local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local EasingStyleConfig = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ModuleLibrary"):WaitForChild("EasingStyleConfig"))

local localPlayer = Players.LocalPlayer
-- local playerMouse = localPlayer:GetMouse()
local currentCamera = workspace.CurrentCamera

local Bindable = ReplicatedFirst:WaitForChild("Bindable")
local PlaySound = Bindable:WaitForChild("PlaySound")

local RemoteEvents = ReplicatedStorage.Remote.Events
local GunFired = RemoteEvents:WaitForChild("GunFired")

local playerGui = localPlayer:WaitForChild("PlayerGui")
local ReticleGui = playerGui:WaitForChild("ReticleGui")
local ReticleMain = ReticleGui:WaitForChild("ReticleMain")
local MidReticle = ReticleMain:WaitForChild("Mid")

local function getReticleDirection()
    local ray1 = workspace.CurrentCamera:ScreenPointToRay(MidReticle.Position.X.Offset, MidReticle.Position.Y.Offset)
    return ray1.Direction
end

local function ApplyViewportToolModelImpulse(toolModel)
    local currentBaseOffset = toolModel:GetAttribute("CurrentBaseC0Offset")

    if toolModel:GetAttribute("Aiming") then
        local yValue = math.random(-1, 1) * 0.0125
        local zValue = math.random(-1, 1) * 0.0125
        currentBaseOffset = currentBaseOffset + Vector3.new(0, yValue, zValue)
    else
        local xValue = math.random(-1, 1) * 0.1
        local yValue = math.random(-1, 1) * 0.1
    
        currentBaseOffset = currentBaseOffset + Vector3.new(xValue, yValue, 0.6)
    end
    
    toolModel:SetAttribute("CurrentBaseC0Offset", currentBaseOffset)
end

local function ApplyCameraRecoilImpulse()

    local xValue = math.random(1, 10) * 0.06
    local yValue = math.random(1, 10) * 0.06
    local zValue = math.random(1, 10) * 0.06
    
    local startCFrame = currentCamera.CFrame

    for i = 0, 1, 0.1 do
        local easingAmount = EasingStyleConfig.EaseOutBack(i)
        currentCamera.CFrame *= CFrame.Angles(math.rad(xValue * easingAmount), math.rad(yValue * easingAmount), math.rad(zValue * easingAmount))
        task.wait(0.01)
    end

end

local _FireFunction = function(toolModel, toolInstance)

    local gunshotSoundName = toolInstance:GetAttribute("GunshotSound")

    local raycastParams = RaycastParams.new()
    local origin = toolModel.BulletSpawn.CFrame.Position
    local direction = currentCamera.CFrame.LookVector

    raycastParams.FilterDescendantsInstances = {unpack(toolModel:GetDescendants()), unpack(localPlayer.Character:GetDescendants())}
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude

    local raycastResult = workspace:Raycast(currentCamera.CFrame.Position, direction * 1000, raycastParams)

    -- toolInstance:SetAttribute("CurrentAmmo", toolInstance:GetAttribute("CurrentAmmo") - 1)
    ApplyViewportToolModelImpulse(toolModel)
    task.spawn(ApplyCameraRecoilImpulse)
    toolModel.BulletSpawn.MuzzleFlash:Emit(1)

    GunFired:FireServer(toolInstance.Name, raycastResult.Instance)
    PlaySound:Fire(gunshotSoundName, origin, true)
end

return _FireFunction
