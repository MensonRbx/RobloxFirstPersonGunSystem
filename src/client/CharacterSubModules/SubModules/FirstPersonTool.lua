--[[
    Wrapper module for the tool object used in the context of a first person camera system.

    FirstPersonTool.new(toolInstance)
        toolInstance: The tool instance to wrap around.

    FirstPersonTool:init() 
        Connect functions to events per tool settings

    FirstPersonTool:Destroy()   
        Called when the tool is unequipped

]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local ToolSettings = require(Shared:WaitForChild("ToolSettings"))

local RemoteEvents = ReplicatedStorage:WaitForChild("Remote"):WaitForChild("Events")

local EquipItem = RemoteEvents:WaitForChild("EquipItem")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local ItemModels = Assets:WaitForChild("ItemModels")

local FirstPersonTool = {}
FirstPersonTool.__index = FirstPersonTool

-- FirstPersonTool.new is called when a tool is equipped
function FirstPersonTool.new(instance, characterModuleObject)
    local self = setmetatable({}, FirstPersonTool)

    self.instance = instance
    self.characterModuleObject = characterModuleObject
    self._viewportModelHandler = characterModuleObject.viewportModelHandler
    self._animationController = characterModuleObject.animationController
    
    self._contextActionFunctionNames = {}

    self._toolModel = nil

    self:init()

    return self
end

-- Connect functions to events per tool settings
function FirstPersonTool:init()
    local settingsForTool = ToolSettings[self.instance.Name]
    
    EquipItem:FireServer(self.instance.Name)
    
    self:_ConnectFunctionsToEvents(settingsForTool)
    self:_CreateViewportModel()

    self.animations = self._animationController:LoadAnimations(settingsForTool["Animations"])
    
    self:_CheckForActiavtionsOnEquip(settingsForTool)

    coroutine.wrap(self._AnimateIdleAsync)(self)
end

function FirstPersonTool:_AnimateIdleAsync()
    while self.animations["Idle"] do
        if not self.animations["Idle"].IsPlaying then
            self.animations["Idle"]:Play()
            task.wait(self.animations["Idle"].Length - 0.1)
        end
        task.wait()
    end
end

-- Clone Model from ReplicatedStorage, then attach it to the viewport model
function FirstPersonTool:_CreateViewportModel()
    local modelToClone = ItemModels:FindFirstChild(self.instance.Name, true)

    if modelToClone then
        self._toolModel = modelToClone:Clone()
        self._viewportModelHandler:AttachModelToViewportModel(self._toolModel)
    end

end

function FirstPersonTool:_ConnectFunctionsToEvents(settingsForTool)
    -- Context Action Functions
    for _, functionData in pairs(settingsForTool.ContextActionFunctions) do
        local functionName = functionData[1]
        table.insert(self._contextActionFunctionNames, functionName)
        ContextActionService:BindActionAtPriority(unpack(functionData))
    end

    -- Misc Functions TODO

end

function FirstPersonTool:_CheckForActiavtionsOnEquip(settingsForTool)
    
    for _, functionData in pairs(settingsForTool.ContextActionFunctions) do
        -- local functionName = functionData[1]
        -- table.insert(self._contextActionFunctionNames, functionName)
        -- ContextActionService:BindActionAtPriority(unpack(functionData))

        local contextActionFunction = functionData[2]
        local activationEnum = functionData[5]
        if activationEnum.EnumType == Enum.UserInputType then -- Mouse Input
            if UserInputService:IsMouseButtonPressed(activationEnum) then
                contextActionFunction("", Enum.UserInputState.Begin, nil)
            end
        elseif activationEnum.EnumType == Enum.KeyCode then   -- Keyboard Input
            if UserInputService:IsKeyDown(activationEnum) then
                contextActionFunction("", Enum.UserInputState.Begin, nil)
            end
        end

    end

end

-- Called when the tool is unequipped
function FirstPersonTool:Destroy()
    for _, functionName in pairs(self._contextActionFunctionNames) do
        ContextActionService:UnbindAction(functionName)
    end

    for index, animationTrack in self.animations do
        animationTrack:Stop() 
        self.animations[index] = nil
    end

    self._viewportModelHandler:RemoveCurrentModel()
    self._toolModel:Destroy()

end

return FirstPersonTool
