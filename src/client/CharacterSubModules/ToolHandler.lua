local ReplicatedFirst = game:GetService("ReplicatedFirst")

local GetCurrentTool = ReplicatedFirst.Bindable:WaitForChild("GetCurrentTool")

local SubModules = script.Parent:WaitForChild("SubModules")

local FirstPersonTool = require(SubModules:WaitForChild("FirstPersonTool"))

local ToolHandler = {}
ToolHandler.__index = ToolHandler

function ToolHandler.new(characterModuleObject, character)
    local self = setmetatable({}, ToolHandler)

    self.character = character
    self.currnetTool = nil
    self._characterModuleObject = characterModuleObject

    self:init()

    return self
end

function ToolHandler:init()
    local onChildAdded = function(child)
        self:_HandleChildAdded(child)
    end

    local onChildRemoved = function(child)
        self:_HandleChildRemoved(child)
    end

    local onGetCurrentTool = function()
        return self.currnetTool
    end

    GetCurrentTool.OnInvoke = onGetCurrentTool
    self._childAddedConnection = self.character.ChildAdded:Connect(onChildAdded)
    self._childRemovedConnection = self.character.ChildRemoved:Connect(onChildRemoved)
end

function ToolHandler:_HandleChildAdded(child)
    task.wait(0.1) --yield for child removed to finish code first, not sure if required

    if child:GetAttribute("Moduled") then
        self.currnetTool = FirstPersonTool.new(child, self._characterModuleObject)
    end

end

function ToolHandler:_HandleChildRemoved(child)
    if not self.currnetTool then return end

    if child == self.currnetTool.instance then
        self.currnetTool:Destroy()
        self.currnetTool = nil
    end
end

function ToolHandler:Destroy()
    self._childAddedConnection:Disconnect()
    self._childRemovedConnection:Disconnect()
    GetCurrentTool.OnInvoke = nil
    self.currnetTool = nil 
    self.character = nil
end

return ToolHandler
