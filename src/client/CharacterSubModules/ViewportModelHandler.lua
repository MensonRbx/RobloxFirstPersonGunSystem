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

    print("ViewportModelHandler.new")

    self.character = character
    self.humanoid = character:WaitForChild("Humanoid")

    self.viewportModel = nil
    self._currentModel = nil

    self._stepConnection = nil

    self._movementBobbingValue = 0
    
    self:init()

    return self
end

function ViewportModelHandler:init()

    self.viewportModel = baseViewportModel:Clone()
    self.modelAttachment = self.viewportModel.Head:WaitForChild("ModelMotor6D")
    self.viewportModel.Parent = workspace.CurrentCamera

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
function ViewportModelHandler:AttachModelToViewportModel(modelToAttach)
    if self._currentModel then
        self:RemoveCurrentModel()
    end

    local viewportModelHead = self.viewportModel.Head
    self.modelAttachment.C0 = CFrame.new(modelToAttach:GetAttribute("DefaultC0Offset"))
    self.modelAttachment.C1 = CFrame.new()
    self.modelAttachment.Part0 = viewportModelHead
    self.modelAttachment.Part1 = modelToAttach.Handle
    modelToAttach.Parent = viewportModelHead

    self._currentModel = modelToAttach

    local onStep = function(dt)
        self:SetCurrentModelCFrame(dt)
    end

    self._currentModel:SetAttribute("AimC1", self.modelAttachment.C0 * self._currentModel.Handle.CFrame:inverse() * self._currentModel.Aim.CFrame)

    self.modelAttachment.C0 = CFrame.new(self._currentModel:GetAttribute("CurrentC0Offset") - Vector3.new(0, 1.4, 0)) * CFrame.Angles(-math.pi/4, 0, 0)

    self._bindModelConnection = RunService.RenderStepped:Connect(onStep)	
end

function ViewportModelHandler:RemoveCurrentModel()
    -- LOWER CURRENT GUN
    self._loweringWeapon = true

    for i = 0, 0.6, 0.1 do
        if self.character:FindFirstChildOfClass("Tool") then
            break
        end
        task.wait(0.1)
    end

    self._bindModelConnection:Disconnect()
    self._currentModel:Destroy()

    self.viewportModel.LeftUpperArm.LeftShoulder.C1 = self._leftArmShoulderC1
    self.viewportModel.RightUpperArm.RightShoulder.C1 = self._rightArmShoulderC1

    self._currentModel = nil
    self._loweringWeapon = false
end

function ViewportModelHandler:SetViewportModelCFrame(dt)
    self.viewportModel.Head.CFrame = currentCamera.CFrame 

    local randNum = math.random(1, 2)

    -- This is horrendous and I plan to fix it later
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

    if self._loweringWeapon then
        local targetC0 = CFrame.new(self._currentModel:GetAttribute("CurrentC0Offset") - Vector3.new(0, 2.2, 0) ) * CFrame.Angles(-math.pi/3, 0, 0)
        self.modelAttachment.C0 = self.modelAttachment.C0:Lerp(targetC0, 0.1)
        self:UpdateArmPositions()
        return
    end

    -- 1: Setting Default Sway of the model
    local CurrentBaseC0Offset = self._currentModel:GetAttribute("CurrentBaseC0Offset")    
    local DefaultC0Offset = self._currentModel:GetAttribute("DefaultC0Offset")
    local baseBobbingSinValue = MATH_SIN(time()) * 0.05

    if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then 
        baseBobbingSinValue *= 0.025
    end

    local targetC0 = CFrame.new(CurrentBaseC0Offset) * CFrame.new(0, baseBobbingSinValue, 0)

    -- 2: Checking if player is jumping, setting C0 from there
    if self:_IsJumping() and not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local jumpYValue = 0.5
        targetC0 = CFrame.new(CurrentBaseC0Offset) * CFrame.new(0, jumpYValue, 0)
    else
    -- 3: Setting Movement CFrame of model
        if self.humanoid.MoveDirection.Magnitude > 0.05 then
            targetC0 = self:_ModifyTargetC0WithMovementBobbing(targetC0)
        end
    end

    -- 4: Modifying CFrame from rotation
    local currentRotationY = self.character.HumanoidRootPart.Orientation.Y
    local rotationDifference = (currentRotationY - self._lastRotationY) * 0.1
    local multiplyAmount = 0.25

    if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then 
        multiplyAmount *= 0.05
    end
    local RotationC0ToLerpTo = targetC0 * CFrame.new(math.sign(rotationDifference) * multiplyAmount, 0, 0)
    targetC0 = targetC0:Lerp(RotationC0ToLerpTo, 0.3)

    -- 5: Setting Aiming CFrame of model   
    local lerpValue = 0.07
    if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then 
        lerpValue = 0.3
    end
    self.modelAttachment.C0 = self.modelAttachment.C0:Lerp(targetC0, lerpValue)

    -- 6: Updating Arm Positions
    self:UpdateArmPositions()

    -- 7: Set current base C0 offset to default c0 offset offset by a lerp amount
    self._currentModel:SetAttribute("CurrentBaseC0Offset", self._currentModel:GetAttribute("CurrentBaseC0Offset"):Lerp(DefaultC0Offset, 0.1))

    self._lastRotationY = currentRotationY
    self._currentModel:SetAttribute("CurrentC0Offset", targetC0.Position)
    self._lastCharacterPosition = self.character.HumanoidRootPart.Position
end

function ViewportModelHandler:_IsJumping()
    return table.find(JUMPING_STATES, self.humanoid:GetState())
end

function ViewportModelHandler:_ModifyTargetC0WithMovementBobbing(currentTargetc0)
    local currentPosition = self.character.HumanoidRootPart.Position

    self._movementBobbingValue += ((currentPosition - self._lastCharacterPosition).Magnitude * 0.5)
    local movementBobbingSinValue = MATH_SIN(self._movementBobbingValue) * 0.075
    local yVal = -0.2

    if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then --self._currentModel:GetAttribute("Aiming") then
        movementBobbingSinValue *= 0.025
        yVal = 0
    end

    currentTargetc0 *= CFrame.new(movementBobbingSinValue, yVal , movementBobbingSinValue * 0.75)

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