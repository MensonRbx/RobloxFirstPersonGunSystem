local Players = game:GetService("Players")

local localPlayer = Players.LocalPlayer

local AnimationController = {}
AnimationController.__index = AnimationController

function AnimationController.new(character)
    local self = setmetatable({}, AnimationController)

    return self
end

function AnimationController:LoadAnimations(animationTable: {[string]: string})
    local character = localPlayer.Character
    local animator = character:WaitForChild("Humanoid"):WaitForChild("Animator")
    
    local returnTable = {}
    
    for name, id in animationTable do
        if id == "" then
            continue
        end

        local animation = Instance.new("Animation")
        animation.AnimationId = id
        returnTable[name] = animator:LoadAnimation(animation)
    end

    return returnTable
end

function AnimationController:PlayAnimation(name)
    
end

function AnimationController:StopAnimation(name)
    
end

function AnimationController:StopAllAnimations()
    
end

return AnimationController
