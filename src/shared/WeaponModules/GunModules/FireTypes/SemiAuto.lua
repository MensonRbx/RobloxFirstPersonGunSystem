local RunService = game:GetService("RunService")

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

local function getViewportToolModel(viewportModel)
    return viewportModel.Head:FindFirstChildOfClass("Model")
end

return function (_, inputState)
    local viewportModel = getLocalPlayerViewportModel()
    local toolInstance = getCurrentFPSToolInstance()
    local toolModel = getViewportToolModel(viewportModel)

    if inputState == Enum.UserInputState.Begin then
        local currentAmmo = toolInstance:GetAttribute("CurrentAmmo")
        if currentAmmo <= 0 then
            return
        end

        _FireFunction(toolModel, toolInstance)
    end
end