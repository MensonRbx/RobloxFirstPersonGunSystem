local CharacterSubModules = script.Parent:WaitForChild("CharacterSubModules")   

local ViewportModelHandler = require(CharacterSubModules:WaitForChild("ViewportModelHandler"))
local AnimationController = require(CharacterSubModules:WaitForChild("AnimationController"))
local ToolHandler = require(CharacterSubModules:WaitForChild("ToolHandler"))

local MainCharacterModule = {}
MainCharacterModule.__index = MainCharacterModule

function MainCharacterModule.new(character)
    local self = setmetatable({}, MainCharacterModule)

    print("MainCharacterModule.new")

    self.character = character
    self.humanoid = character:WaitForChild("Humanoid")

    self:init()

    return self
end

function MainCharacterModule:init()
    local onDied = function()
        self:HandleHumanoidDeath()
    end

    --setting up everything related to the character
    self.toolHandler = ToolHandler.new(self, self.character) -- character module passed so all functions needed by tools can be located
    self.viewportModelHandler = ViewportModelHandler.new(self.character)
    self.animationController = AnimationController.new(self.character)

    self.humanoid.Died:Connect(onDied)  
end

function MainCharacterModule:HandleHumanoidDeath()
    self.viewportModelHandler:Destroy()
    self.toolHandler:Destroy()
end

return MainCharacterModule