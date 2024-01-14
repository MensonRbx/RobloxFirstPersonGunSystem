local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

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

local function moveModel(adsJoint, goalC1)

end

local function fireWeapon()
    local toolInstance = getCurrentFPSToolInstance()	
    local viewportModel = getLocalPlayerViewportModel()

end

local function stopFiring()
    local toolInstance = getCurrentFPSToolInstance()	

    
    
end

return function (actionName, inputState, inputObject)



end