local MainCharacterModule = require(script.Parent:WaitForChild("MainCharacterModule"))

local PlayerSubModules = script.Parent:WaitForChild("PlayerSubModules")

local MainPlayerModule = {}
MainPlayerModule.__index = MainPlayerModule 

function MainPlayerModule.new()
    local self = setmetatable({}, MainPlayerModule)

    print("MainPlayerModule.new")

    self.player = game.Players.LocalPlayer
    self.character = nil
    
    self:init()

    return self
end

function MainPlayerModule:init()
    local onCharacterAdded = function(character)
        self.character = MainCharacterModule.new(character)
    end

    self.player.CharacterAdded:Connect(onCharacterAdded)
    if self.player.Character then
        onCharacterAdded(self.player.Character)
    end

    for _, subModule in PlayerSubModules:GetChildren() do
        require(subModule)
    end

end

return MainPlayerModule.new()
