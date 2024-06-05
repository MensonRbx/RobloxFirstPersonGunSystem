local ReplicatedFirst = game:GetService("ReplicatedFirst")

local MainCharacterModule = require(script.Parent:WaitForChild("MainCharacterModule"))

local PlayerSubModules = script.Parent:WaitForChild("PlayerSubModules")

local GetPlayerModule = ReplicatedFirst.Bindable:WaitForChild("GetPlayerModule")

local MainPlayerModule = {}
MainPlayerModule.__index = MainPlayerModule 

function MainPlayerModule.new()
    local self = setmetatable({}, MainPlayerModule)

    print("MainPlayerModule.new")

    -- self.MainGuiModule = require(PlayerSubModules:WaitForChild("MainGuiModule"))

    self.player = game.Players.LocalPlayer
    self.character = nil
    
    self:init()

    return self
end

function MainPlayerModule:init()
    local onCharacterAdded = function(character)
        self.character = MainCharacterModule.new(character)
    end

    local onGetPlayerModule = function()
        return self
    end

    self.player.CharacterAdded:Connect(onCharacterAdded)
    GetPlayerModule.OnInvoke = onGetPlayerModule
    if self.player.Character then
        onCharacterAdded(self.player.Character)
    end

    for _, subModule in PlayerSubModules:GetChildren() do
        if subModule:IsA("ModuleScript") then
            self[subModule.Name] = require(subModule)
        end
    end

end

return MainPlayerModule.new()
