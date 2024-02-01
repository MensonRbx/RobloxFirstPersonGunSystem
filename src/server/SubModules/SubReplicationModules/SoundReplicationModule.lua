local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteEvents = ReplicatedStorage:WaitForChild("Remote"):WaitForChild("Events")
local ReplicateSound = RemoteEvents:WaitForChild("ReplicateSound")

local SoundReplicationModule = {}
SoundReplicationModule.__index = SoundReplicationModule

function SoundReplicationModule.new()
    local self = setmetatable({}, SoundReplicationModule)

    return self
end

function SoundReplicationModule:ReplicateSound(player, soundName, position)
    for _, otherPlayer in Players:GetPlayers() do
        if otherPlayer ~= player then
            ReplicateSound:FireClient(otherPlayer, soundName, position)
        end
    end
end

return SoundReplicationModule.new()