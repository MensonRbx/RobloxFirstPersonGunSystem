local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

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
    local ToolSettings = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ToolSettings"))
    return ToolSettings[getCurrentFPSToolInstance().Name]
end

local function getViewportToolModel(viewportModel)
    return viewportModel:FindFirstChildOfClass("Model")
end

return function (_, inputState)
    local viewportModel = getLocalPlayerViewportModel()
    local toolInstance = getCurrentFPSToolInstance()
    local toolModel = getViewportToolModel(viewportModel)
    local toolData = getCurrentToolData()

    if toolModel:GetAttribute("Reloading") or toolModel:GetAttribute("Ammo") == 0 then
        return
    end

    if inputState == Enum.UserInputState.Begin then
        toolInstance:SetAttribute("Firing", true)
        _FireFunction(toolModel, toolInstance)
        task.wait(toolData.WeaponData.FireRate)
        toolInstance:SetAttribute("Firing", false)
    end
end