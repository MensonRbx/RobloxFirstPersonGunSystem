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
local GunReticle = ReticleGui:WaitForChild("GunReticle")
local MidReticle = GunReticle:WaitForChild("Mid")

local function getReticleDirection()
    local ray1 = workspace.CurrentCamera:ScreenPointToRay(MidReticle.Position.X.Offset, MidReticle.Position.Y.Offset)
    return ray1.Direction
end

local function ApplyViewportToolModelImpulse(toolModel)
    local recoil = toolModel:GetAttribute("Recoil")
    if toolModel:GetAttribute("Aiming") then
        recoil /= 2 
    end

    local viewportModel = currentCamera:FindFirstChild("ViewportModel")
    local neck = viewportModel.Head.Neck
    local currentNeckC0 = neck.C0

    local xValue = math.random(-5, 5) * 0.06 * recoil
    local yValue = math.random(5, 5) * 0.06 * recoil
    local zValue = math.random(5, 10) * -0.1 * recoil

    local impulseCFrame = CFrame.new(xValue, yValue, zValue)
    local targetCFrame = CFrame.new(
        currentNeckC0.X + impulseCFrame.X,
        currentNeckC0.Y + impulseCFrame.Y,
        currentNeckC0.Z + impulseCFrame.Z
    )
    neck.C0 = neck.C0:Lerp(targetCFrame, 0.5)
    

end

local function ApplyCameraRecoilImpulse(toolInstance)

    local recoil = toolInstance:GetAttribute("Recoil")

    local xValue = math.random(1, 10) * 0.08 * recoil
    local yValue = math.random(1, 10) * 0.04 * recoil
    local zValue = math.random(1, 10) * 0.04 * recoil
    
    local startCFrame = currentCamera.CFrame

    for i = 0, 1, 0.1 do
        local easingAmount = EasingStyleConfig.EaseOutBack(i)
        currentCamera.CFrame *= CFrame.Angles(math.rad(xValue * easingAmount), math.rad(yValue * easingAmount), math.rad(zValue * easingAmount))
        task.wait(0.01)
    end

end

local function showMuzzleFlash(toolModel, toolInstance)
    local MuzzleModel = toolModel.Muzzle
    local MuzzleFlashPointLight = MuzzleModel.MuzzleWithPointLight.MuzzleFlashPointLight
    MuzzleFlashPointLight.Enabled = true
    local decalTable = {}
    for _, desc in ipairs(MuzzleModel:GetDescendants()) do
        if desc:IsA("Decal") then
            desc.Transparency = 0
            table.insert(decalTable, desc)
        end
    end
    task.wait(0.03)
    MuzzleFlashPointLight.Enabled = false
    for _, desc in ipairs(decalTable) do
        desc.Transparency = 1
    end
end

local function ExpandReticleFromCenter(toolInstance)
    local RETICLE_MINIMM_XY_SCALE = 0.125 
    local baseSizeIncrease = 0.12
    local recoil = toolInstance:GetAttribute("Recoil")
    local currentReticleSize = GunReticle.Size
    
    local finalIncrease = baseSizeIncrease * recoil
    local newSize = UDim2.fromScale(
        math.clamp(currentReticleSize.X.Scale + finalIncrease, RETICLE_MINIMM_XY_SCALE, 1),
        math.clamp(currentReticleSize.Y.Scale + finalIncrease, RETICLE_MINIMM_XY_SCALE, 1)
    )
    GunReticle:TweenSize(newSize, Enum.EasingDirection.Out, Enum.EasingStyle.Sine, 0.03, true)    
end

local _FireFunction = function(toolModel, toolInstance)
    local gunshotSoundName = toolInstance:GetAttribute("GunshotSound")

    local raycastParams = RaycastParams.new()
    local origin = toolModel.BulletSpawn.CFrame.Position
    local direction = currentCamera.CFrame.LookVector

    raycastParams.FilterDescendantsInstances = {unpack(toolModel:GetDescendants()), unpack(localPlayer.Character:GetDescendants())}
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude

    local raycastResult = workspace:Raycast(currentCamera.CFrame.Position, direction * 1000, raycastParams)

    -- toolInstance:SetAttribute("Ammo", toolInstance:GetAttribute("Ammo") - 1)
    ApplyViewportToolModelImpulse(toolModel)
    task.spawn(ApplyCameraRecoilImpulse, toolInstance)
    task.spawn(ExpandReticleFromCenter, toolInstance)
    task.spawn(showMuzzleFlash, toolModel, toolInstance)

    GunFired:FireServer(toolInstance.Name, raycastResult.Instance)
    PlaySound:Fire(gunshotSoundName, origin, true)
    toolModel:SetAttribute("Ammo", toolModel:GetAttribute("Ammo") - 1)
end

return _FireFunction
