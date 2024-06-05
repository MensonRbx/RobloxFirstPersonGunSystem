local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")

if RunService:IsServer() then
    return 1
end

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local _FireFunction = require(script.Parent._FireFunction)

local localPlayer = Players.LocalPlayer
local currentCamera = workspace.CurrentCamera

local function getLocalPlayerViewportModel()
    return currentCamera:FindFirstChild("ViewportModel")
end

-- Tool instance has information related to the gun
local function getCurrentFPSToolInstance()
    local character = localPlayer.Character
    return character:FindFirstChildOfClass("Tool")
end

local function getCurrentToolData()
    local ToolSettings = require(Shared:WaitForChild("ToolSettings"))
    return ToolSettings[getCurrentFPSToolInstance().Name]
end

local function getViewportToolModel(viewportModel)
    return viewportModel:FindFirstChildOfClass("Model")
end

local function beginFire(toolData, toolModel, toolInstance)
    local fireRate = toolData.WeaponData.FireRate

    if toolInstance:GetAttribute("Firing") then
        return
    end
    toolInstance:SetAttribute("Firing", true)
    
    while 
        UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) 
        and toolModel:GetAttribute("Ammo") > 0 
        and toolModel:IsDescendantOf(workspace) 
    do
        _FireFunction(toolModel, toolInstance)
        task.wait(fireRate)
    end
    toolInstance:SetAttribute("Firing", false)
end

local function stopFire(toolData, toolModel, toolInstance)
    
end

return function (_, inputState)
    print("FullAuto", inputState)

    if inputState == Enum.UserInputState.Cancel then
        return
    end

    local toolData = getCurrentToolData()
    local viewportModel = getLocalPlayerViewportModel()
    local toolInstance = getCurrentFPSToolInstance()
    local toolModel = getViewportToolModel(viewportModel)

    if toolModel:GetAttribute("Reloading") or toolModel:GetAttribute("Ammo") == 0 then
        return
    end

    if inputState == Enum.UserInputState.Begin then
        print("FullAuto:Begin")
        beginFire(toolData, toolModel, toolInstance)
    elseif inputState == Enum.UserInputState.End then
        print("FullAuto:End")
        stopFire(toolData, toolModel, toolInstance)
    end
end

