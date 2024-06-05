local RunService = game:GetService("RunService")
local ReplicatedFirst = game:GetService("ReplicatedFirst")

local GetCurrentTool = ReplicatedFirst.Bindable:WaitForChild("GetCurrentTool")

local BEGIN_INPUT_STATE = Enum.UserInputState.Begin

if RunService:IsServer() then
    return 1
end

return function (_, inputState)
    if inputState ~= BEGIN_INPUT_STATE then
        return
    end 
end