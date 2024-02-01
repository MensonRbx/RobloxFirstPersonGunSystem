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

local function beginFire()
    
end

local function stopFire()
    
end

return function (_, inputState)
    if inputState == Enum.UserInputState.Begin then
        print("FullAuto:Begin")
        beginFire()
    elseif inputState == Enum.UserInputState.End then
        print("FullAuto:End")
        stopFire()
    end
end

