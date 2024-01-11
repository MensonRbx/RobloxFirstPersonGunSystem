local SubModules = script.Parent:WaitForChild("SubModules")

local MainServerModule = {}
MainServerModule.__index = MainServerModule

function MainServerModule.new()
    local self = setmetatable({}, MainServerModule)

    self.MainReplicationModule = require(SubModules:WaitForChild("MainReplicationModule"))
    self.WeaponSystemHandler = require(SubModules:WaitForChild("WeaponSystemHandler"))

    return self
end

return MainServerModule.new()
