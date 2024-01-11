local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteEvents = ReplicatedStorage:WaitForChild("Remote"):WaitForChild("Events")
local UpdateCharacterRotation = RemoteEvents:WaitForChild("UpdateCharacterRotation")

local SubReplicationModules = script.Parent:WaitForChild("SubReplicationModules")


local MainReplicationModule = {}
MainReplicationModule.__index = MainReplicationModule

function MainReplicationModule.new()
    local self = setmetatable({}, MainReplicationModule)
    
    self.RotationReplicationModule = require(SubReplicationModules:WaitForChild("RotationReplicationModule"))

    self:init()

    return self
end

function MainReplicationModule:init()
    local onUpdateRotation = function(player, theta)
        self.RotationReplicationModule:UpdateRotation(player, theta)
    end

    UpdateCharacterRotation.OnServerEvent:Connect(onUpdateRotation)
end

return MainReplicationModule.new()
