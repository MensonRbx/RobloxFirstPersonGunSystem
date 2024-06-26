--[[
    Handles functions related to the viewport model and weapon models shown within, some code
    taken and modified from https://devforum.roblox.com/t/the-first-person-element-of-a-first-person-shooter/160434

    Also handles humanoid camera offset for recoil effects

]]

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage") 

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Remote = ReplicatedStorage:WaitForChild("Remote")
local baseViewportModel = Assets:WaitForChild("ViewportModel")

local Events = Remote:WaitForChild("Events")
local UpdateCharacterRotation = Events:WaitForChild("UpdateCharacterRotation")

local currentCamera = workspace.CurrentCamera

local MATH_SIN = math.sin
local MATH_ASIN = math.asin

local JUMPING_STATES = {
    Enum.HumanoidStateType.Jumping,
    Enum.HumanoidStateType.Freefall,
}

local BASE_HUMANOID_CAMERA_OFFSET = Vector3.zero

local ViewportModelHandler = {}
ViewportModelHandler.__index = ViewportModelHandler

function ViewportModelHandler.new(character)
    local self = setmetatable({}, ViewportModelHandler)

    self.character = character
    self.humanoid = character:WaitForChild("Humanoid")

    self.viewportModel = nil
    self._currentModel = nil
    self._stepConnection = nil
    self._movementBobbingValue = 0

    self.baseNeckC0 = CFrame.new(-0, 0.849, 0)
    self.baseNeckC1 = CFrame.new(0, -0.491, -0)
    
    self:init()

    return self
end

function ViewportModelHandler:init()

    self.viewportModel = baseViewportModel:Clone()
    self.viewportModel.Parent = workspace.CurrentCamera
    self.animator = self.viewportModel.AnimationController.Animator

    local humanoidRootPart = self.character:WaitForChild("HumanoidRootPart")

    self._lastRotationY = humanoidRootPart.Orientation.Y   
    self._lastCharacterPosition = humanoidRootPart.Position

    self._leftArmShoulderC1 = self.viewportModel.LeftUpperArm.LeftShoulder.C1
    self._rightArmShoulderC1 = self.viewportModel.RightUpperArm.RightShoulder.C1

    UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter

    local onStep1 = function(dt)
        self:SetViewportModelCFrame(dt)
    end

    local onStep2 = function(dt)
        self:UpdateHumanoidCameraOffset(dt)
    end

    self._stepConnection = RunService.RenderStepped:Connect(onStep1)
    self._humanoidCameraOffsetConnection = RunService.RenderStepped:Connect(onStep2)
end

-- ModelToAttach is a model that will be attached to the viewport model, must have a part called "Handle"
function ViewportModelHandler:AttachModelToViewportModel(firstPersonTool)
    self.firstPersonTool = firstPersonTool
    local modelToAttach = firstPersonTool.toolModel
    task.wait(0.1) -- Moment to wait until last model is destroyed and viewportAnimations halted
    if self._currentModel then
        self:RemoveCurrentModel()
    end

    print("Attaching model to viewport model", modelToAttach)

    local viewportModelUpperTorso = self.viewportModel.UpperTorso 
    self.modelAttachment = Instance.new("Motor6D")
    self.modelAttachment.Name = "BodyAttachToViewportModel"
    self.modelAttachment.Part0 = viewportModelUpperTorso
    self.modelAttachment.Part1 = modelToAttach:FindFirstChild("BodyAttach")
    self.modelAttachment.C0 = CFrame.new()
    self.modelAttachment.C1 = CFrame.new()
    self.modelAttachment.Parent = viewportModelUpperTorso
    modelToAttach.Parent = self.viewportModel

    self._currentModel = modelToAttach

    local onRunAnimationsOnStep = function(dt)
        self:AnimateViewportModel(dt)
    end

    local onApplyCFrameImpulse = function(dt)
        self:SetCurrentModelCFrame(dt)
    end

    self._animateConnection = RunService.RenderStepped:Connect(onRunAnimationsOnStep)
    self._applyCFrameImpulseConnection = RunService.RenderStepped:Connect(onApplyCFrameImpulse)
end

function ViewportModelHandler:AnimateViewportModel()
    if self._currentModel:GetAttribute("Reloading") then
        return
    end
    if self._currentModel:GetAttribute("Aiming") then
        if not self.firstPersonTool.viewportAnimations.Aim.IsPlaying then
            self.firstPersonTool.viewportAnimations.Aim:Play()
        end
        self.firstPersonTool.viewportAnimations.Idle:Stop()
    else
        if not self.firstPersonTool.viewportAnimations.Idle.IsPlaying then
            self.firstPersonTool.viewportAnimations.Idle:Play()
        end
        self.firstPersonTool.viewportAnimations.Aim:Stop()
    end     
end

function ViewportModelHandler:RemoveCurrentModel()
    -- LOWER CURRENT GUN
    self._loweringWeapon = true
    local neck = self.viewportModel.Head.Neck

    for i = 0, 1, 0.1 do
        local targetCFrame = self.baseNeckC0 * CFrame.Angles(i, 0, 0)
        neck.C0 = neck.C0:Lerp(targetCFrame, 0.2)
        task.wait()
    end

--  self._bindModelConnection:Disconnect()
    self.firstPersonTool.viewportAnimations.Idle:Stop() 
    self.firstPersonTool.viewportAnimations.Aim:Stop()
    self._animateConnection:Disconnect()
    self._applyCFrameImpulseConnection:Disconnect()
    self._currentModel:Destroy()
    print("Removing current model")

    self.modelAttachment:Destroy()
    self._currentModel = nil
    self._loweringWeapon = false
end

-- Code that sets the current CFrame of the viewport model's head to the camera's CFrame
-- Purpose of random number part is to update the character's rotation serverside every so often depending on the random number
-- This is not ideal at all, and I plan on changing this later to something more fitting.
function ViewportModelHandler:SetViewportModelCFrame(dt)
    self.viewportModel.Head.CFrame = currentCamera.CFrame

    local randNum = math.random(1, 4)
    if randNum == 2 then
        local theta = MATH_ASIN(currentCamera.CFrame.LookVector.Y)
        UpdateCharacterRotation:FireServer(theta)
    end
end

function ViewportModelHandler:UpdateHumanoidCameraOffset()
    local currentOffset = self.humanoid.CameraOffset
    self.humanoid.CameraOffset = currentOffset:Lerp(BASE_HUMANOID_CAMERA_OFFSET, 0.1)
end

-- Setting the CFrame of the model that is attached to the viewport model (the tool)
function ViewportModelHandler:SetCurrentModelCFrame(dt)
    if not self._currentModel then 
        -- self._bindModelConnection:Disconnect()
        return 
    end

    local neck = self.viewportModel.Head.Neck
    local targetC0 = self.baseNeckC0
    local targetC1 = self.baseNeckC1

    -- Speed/Jump Check
    if self.humanoid.MoveDirection.Magnitude > 0.05 and not self:_IsJumping() then
        targetC0 = self:_ModifyCFrameWithMovementBobbing(self.baseNeckC0)
    elseif self:_IsJumping() then
        targetC0 = self.baseNeckC0 * CFrame.new(0, -1, 0)
    end

    -- Rotation Check
    local currentRotationY = self.character.HumanoidRootPart.Orientation.Y
    local rotationDifference = (currentRotationY - self._lastRotationY) * 0.1
    local multiplyAmount = 0.25
    if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then 
        multiplyAmount *= 0.05
    end
    local RotationC0ToLerpTo = targetC0 * CFrame.new(math.sign(rotationDifference) * multiplyAmount, 0, 0)
    targetC0 = targetC0:Lerp(RotationC0ToLerpTo, 0.3)

    neck.C0 = neck.C0:Lerp(targetC0, 0.2)
    neck.C1 = neck.C1:Lerp(targetC1, 0.2)

    self._lastCharacterPosition = self.character.HumanoidRootPart.Position
    self._lastRotationY = currentRotationY
end

function ViewportModelHandler:_IsJumping()
    return table.find(JUMPING_STATES, self.humanoid:GetState())
end

function ViewportModelHandler:_ModifyCFrameWithMovementBobbing(currentTargetc0)
    local currentPosition = self.character.HumanoidRootPart.Position

    self._movementBobbingValue += ((currentPosition - self._lastCharacterPosition).Magnitude)
    local movementBobbingSinValue = MATH_SIN(self._movementBobbingValue * 0.6)
    local yVal = 0.5

    if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then --self._currentModel:GetAttribute("Aiming") then
        movementBobbingSinValue *= 0.025
        yVal = 0
    end

    currentTargetc0 *= CFrame.new(movementBobbingSinValue * 0.3, yVal, movementBobbingSinValue * 0.08)

    return currentTargetc0
end

function ViewportModelHandler:UpdateArmPositions()
    self:_UpdateArmInteral("Left")
    self:_UpdateArmInteral("Right")
end

function ViewportModelHandler:_UpdateArmInteral(armKey)
    
    -- get shoulder we are rotating
	local shoulder = self.viewportModel[armKey.."UpperArm"][armKey.."Shoulder"]
	local cf = self._currentModel[armKey].CFrame * CFrame.Angles(math.pi/2, 0, 0) * CFrame.new(0, 1.5, 0)
	shoulder.C1 = cf:Inverse() * shoulder.Part0.CFrame * shoulder.C0

end

function ViewportModelHandler:Destroy()    
    self._stepConnection:Disconnect()
    self._bindModelConnection:Disconnect()
    self.viewportModel:Destroy()
    self.character = nil
end

function ViewportModelHandler:HandleBobbingAsync()
    while self._currentModel do
        task.wait()
    end
end

return ViewportModelHandler