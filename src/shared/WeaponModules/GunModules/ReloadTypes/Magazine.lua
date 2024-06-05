local RunService = game:GetService("RunService")
if RunService:IsServer() then return 1 end

local ReplicatedFirst = game:GetService("ReplicatedFirst")
local GetCurrentTool = ReplicatedFirst.Bindable:WaitForChild("GetCurrentTool")
local GetPlayerModule = ReplicatedFirst.Bindable:WaitForChild("GetPlayerModule")

local BEGIN_INPUT_STATE = Enum.UserInputState.Begin

return function (_, inputState)
    if inputState ~= BEGIN_INPUT_STATE then
        return
    end 

    local viewportModel = workspace.CurrentCamera:FindFirstChild("ViewportModel")
    local toolModel = viewportModel:FindFirstChildOfClass("Model")

    if toolModel:GetAttribute("Reloading") or toolModel:GetAttribute("Firing") or toolModel:GetAttribute("Ammo") == toolModel:GetAttribute("MaxAmmo") then
        return
    end

    toolModel:SetAttribute("Reloading", true)
    local animationId = toolModel:GetAttribute("ViewportReloadAnimationId")
    local animation = Instance.new("Animation")
    animation.AnimationId = "rbxassetid://"..animationId
    local animator = viewportModel.AnimationController.Animator
    local reloadAnimation = animator:LoadAnimation(animation)
    toolModel:SetAttribute("Ammo", 0)
    reloadAnimation:Play()
    task.wait(toolModel:GetAttribute("ReloadTime"))
    toolModel:SetAttribute("Ammo", toolModel:GetAttribute("MaxAmmo"))
    toolModel:SetAttribute("Reloading", false)
end