local SubModules = script.Parent:WaitForChild("SubModules")

local MainServerModule = {}
MainServerModule.__index = MainServerModule

function MainServerModule.new()
    local self = setmetatable({}, MainServerModule)

    self.MainReplicationModule = require(SubModules:WaitForChild("MainReplicationModule"))
    self.WeaponSystemModule = require(SubModules:WaitForChild("WeaponSystemModule"))

    return self
end

return MainServerModule.new()
