--[[
    Wrapper module for the tool object used in the context of a first person camera system.

    FirstPersonTool.new(toolInstance)
        toolInstance: The tool instance to wrap around.

    FirstPersonTool:init() 
        Connect functions to events per tool settings

    FirstPersonTool:Destroy()   
        Called when the tool is unequipped

]]
local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local ToolSettings = require(Shared:WaitForChild("ToolSettings"))
local WeaponGuiModule = require(script.Parent:WaitForChild("WeaponGuiModule"))

local localPlayer = Players.LocalPlayer

local playerGui = localPlayer:WaitForChild("PlayerGui")
local ReticleGui = playerGui:WaitForChild("ReticleGui")
local GunReticle = ReticleGui:WaitForChild("GunReticle")

local RemoteEvents = ReplicatedStorage:WaitForChild("Remote"):WaitForChild("Events")

local EquipItem = RemoteEvents:WaitForChild("EquipItem")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local ItemModels = Assets:WaitForChild("ItemModels")

local currentlyUnequipping = false

local FirstPersonTool = {}
FirstPersonTool.__index = FirstPersonTool

function FirstPersonTool.new(instance, characterModuleObject)
    local self = setmetatable({}, FirstPersonTool)

    self.instance = instance
    self.name = instance.Name
    self.characterModuleObject = characterModuleObject
    
    self._viewportModelHandler = characterModuleObject.viewportModelHandler
    self._animationController = characterModuleObject.animationController
    
    self._contextActionFunctionNames = {}

    self.toolModel = nil

    if currentlyUnequipping then
        repeat
            task.wait()
        until not currentlyUnequipping or self.instance.Parent ~= characterModuleObject.character

        if self.instance.Parent ~= characterModuleObject.character then
            self:_CleanupForEarlyUnequip()
            return
        end

    end

    self:init()

    return self
end

function FirstPersonTool:_CleanupForEarlyUnequip()
    for i in self do
        self[i] = nil
    end
end

-- Connect functions to events per tool settings
function FirstPersonTool:init()
    self._settingsForTool = ToolSettings[self.name]
    
    EquipItem:FireServer(self.instance.Name)
    
    self.animations = self._animationController:LoadAnimations(self._settingsForTool.Animations)

    self:_SetupViewportAnimations()
    self:_ConnectFunctionsToEvents()
    self:_CreateViewportModel()
    self:_CheckForActiavtionsOnEquip()
    WeaponGuiModule:ShowWeaponInfo(self)
    
    if not self.toolModel:GetAttribute("Aiming") then
        GunReticle.Visible = true
    end
    
    UserInputService.MouseIconEnabled = false
    coroutine.wrap(self._AnimateIdleAsync)(self)
    coroutine.wrap(self._UpdateReticle)(self)
end

function FirstPersonTool:_SetupViewportAnimations()
    self.viewportAnimations = {}

    local viewportModel = ItemModels:FindFirstChild(self.instance.Name, true)
    local animationIds = {
        Idle = viewportModel:GetAttribute("ViewportIdleAnimationId"),
        Aim = viewportModel:GetAttribute("ViewportAimAnimationId"),
        Reload = viewportModel:GetAttribute("ViewportReloadAnimationId")
    }

    for name, id in pairs(animationIds) do
        local animation = Instance.new("Animation")
        animation.AnimationId = "rbxassetid://"..id
        self.viewportAnimations[name] = self._viewportModelHandler.animator:LoadAnimation(animation)
    end
    
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

function FirstPersonTool:_UpdateReticle()
    local RETICLE_MINIMM_XY_SCALE = 0.125

    while self.instance:IsDescendantOf(workspace) do
        local currentReticleSize = GunReticle.Size
        local newSize = UDim2.fromScale(
            math.clamp(currentReticleSize.X.Scale - 0.02, RETICLE_MINIMM_XY_SCALE, 1),
            math.clamp(currentReticleSize.Y.Scale - 0.02, RETICLE_MINIMM_XY_SCALE, 1)
        )
        GunReticle:TweenSize(newSize, Enum.EasingDirection.Out, Enum.EasingStyle.Linear, 0.05, true)
        task.wait() 
    end
end

-- Clone Model from ReplicatedStorage, then attach it to the viewport model
function FirstPersonTool:_CreateViewportModel()
    local modelToClone = ItemModels:FindFirstChild(self.instance.Name, true)

    if modelToClone then
        print("Got model to clone for", self.instance.Name)
        self.toolModel = modelToClone:Clone()
        self._viewportModelHandler:AttachModelToViewportModel(self)
    end

end

function FirstPersonTool:_ConnectFunctionsToEvents()
    -- Context Action Functions
    for functionName, functionData in pairs(self._settingsForTool.ContextActionFunctions) do
        ContextActionService:BindActionAtPriority(functionName, unpack(functionData))
    end

    -- Misc Functions TODO

end

function FirstPersonTool:_CheckForActiavtionsOnEquip()
    
    task.wait(0.3)  -- Yield for tool to be raised

    for functionName, functionData in pairs(self._settingsForTool.ContextActionFunctions) do
        
        if functionName == "Fire" then
            continue
        end

        -- table.insert(self._contextActionFunctionNames, functionName)
        -- ContextActionService:BindActionAtPriority(unpack(functionData))

        local contextActionFunction = functionData[1]
        local activationEnum = functionData[4]
        if activationEnum.EnumType == Enum.UserInputType then -- Mouse Input
            if UserInputService:IsMouseButtonPressed(activationEnum) then
                print(functionName, "Done!")
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

    if currentlyUnequipping then 
        return
    end
    
    for functionName, functionData in pairs(self._settingsForTool.ContextActionFunctions) do
        local contextActionFunction = functionData[1]
        -- contextActionFunction("", Enum.UserInputState.End, nil)
        ContextActionService:UnbindAction(functionName)
    end

    for index, animationTrack in self.animations do
        animationTrack:Stop() 
        self.animations[index] = nil
    end

    self._viewportModelHandler:RemoveCurrentModel()
    -- self.toolModel:Destroy()    -- Tool Model destruction handled by ViewportModelHandler

    currentlyUnequipping = false

    self.toolModel = nil

    -- Wait to see if new tool is equipped
    task.wait(0.1)
    if not localPlayer.Character:FindFirstChildOfClass("Tool") then
        UserInputService.MouseIconEnabled = true
        GunReticle.Visible = false
        WeaponGuiModule:HideInfo()
    end

end

return FirstPersonTool
