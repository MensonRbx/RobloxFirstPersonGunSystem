local WeaponModules = script.Parent:WaitForChild("WeaponModules")
local GunModules = WeaponModules:WaitForChild("GunModules")

local ReloadTypes = GunModules:WaitForChild("ReloadTypes")
local FireTypes = GunModules:WaitForChild("FireTypes")

-- local FireFunction = require(GunModules:WaitForChild("FireFunction"))

local AimDownSightsFunction = require(GunModules:WaitForChild("AimDownSightsFunction"))
local InspectFunction = require(GunModules:WaitForChild("InspectFunction"))

local FireTypes = {
    FullAuto = require(FireTypes:WaitForChild("FullAuto")),
    SemiAuto = require(FireTypes:WaitForChild("SemiAuto")),
}

local ReloadTypes = {
    Magazine = require(ReloadTypes:WaitForChild("Magazine")),
    Increment = require(ReloadTypes:WaitForChild("Increment")),
}

local ToolSettings = {}

ToolSettings["SCAR-H"] = {
    ContextActionFunctions = {
        Fire = {FireTypes["SemiAuto"], false, Enum.ContextActionPriority.High.Value, Enum.UserInputType.MouseButton1},
        AimDownSights = {AimDownSightsFunction, false, Enum.ContextActionPriority.High.Value, Enum.UserInputType.MouseButton2},
        Reload = {ReloadTypes["Magazine"], false, Enum.ContextActionPriority.High.Value, Enum.KeyCode.R},
        Inspect = {InspectFunction, false, Enum.ContextActionPriority.High.Value, Enum.KeyCode.T},
    },
    WeaponData = {
        Damage = 20
    },
    Animations = {
        Idle = "rbxassetid://15882435035",
        Fire = "",
        Reload = "",
    }
}

ToolSettings["SCAR-L"] = ToolSettings["SCAR-H"]

return ToolSettings
