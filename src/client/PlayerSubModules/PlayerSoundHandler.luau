local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local localPlayer = Players.LocalPlayer

local Sounds = ReplicatedStorage.Assets:WaitForChild("Sounds")

local Bindable = ReplicatedFirst:WaitForChild("Bindable")
local PlaySound = Bindable:WaitForChild("PlaySound")

local Remote = ReplicatedStorage.Remote
local Events = Remote:WaitForChild("Events")
local ReplicateSound = Events:WaitForChild("ReplicateSound")

local PlayerSoundHandler = {}
PlayerSoundHandler.__index = PlayerSoundHandler

function PlayerSoundHandler.new()
    local self = setmetatable({}, PlayerSoundHandler)

    self:init()

    return self
end

function PlayerSoundHandler:init()
    local onSoundPlayed = function(soundName, replicate)
        self:PlaySound(soundName, replicate)
    end

    PlaySound.Event:Connect(onSoundPlayed)
    ReplicateSound.OnClientEvent:Connect(onSoundPlayed)
end

function PlayerSoundHandler:PlaySound(soundName, position, replicate)
    local soundToClone = Sounds:FindFirstChild(soundName)
    
    if not soundToClone then
        warn("Sound not found: " .. soundName)
        return
    end

    local sound = soundToClone:Clone()
    local partContainer
    if not position then
        sound.Parent = localPlayer.Character.HumanoidRootPart
    else
        partContainer = Instance.new("Part")
        partContainer.Anchored = true
        partContainer.Position = position
        partContainer.CanCollide = false
        partContainer.CanQuery = false
        partContainer.CanTouch = false
        partContainer.Transparency = 1
        partContainer.Parent = workspace
        sound.Parent = partContainer
    end

    sound.PlaybackSpeed = 1 * math.random(95, 105) / 100

    sound:Play()

    if replicate then
        ReplicateSound:FireServer(soundName, position)        
    end

    sound.Ended:Connect(function()
        sound:Destroy()

        if partContainer then
            partContainer:Destroy()
        end

    end)

end

return PlayerSoundHandler.new()
