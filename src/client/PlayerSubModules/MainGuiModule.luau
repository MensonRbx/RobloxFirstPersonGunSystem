local GuiModules = script.Parent:WaitForChild("GuiModules")

local MainGuiModule = {}
MainGuiModule.__index = MainGuiModule

function MainGuiModule.new()
    local self = setmetatable({}, MainGuiModule)


    return self
end

return MainGuiModule.new()
