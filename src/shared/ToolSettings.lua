local WeaponModules = script.Parent:WaitForChild("WeaponModules")
local GunModules = WeaponModules:WaitForChild("GunModules")

local FireFunction = require(GunModules:WaitForChild("FireFunction"))
local AimDownSightsFunction = require(GunModules:WaitForChild("AimDownSightsFunction"))
local ReloadFunction = require(GunModules:WaitForChild("ReloadFunction"))
local InspectFunction = require(GunModules:WaitForChild("InspectFunction"))

local ToolSettings = {}

ToolSettings["SCAR-H"] = {
    ContextActionFunctions = {
        {"Fire", FireFunction, false, Enum.ContextActionPriority.High.Value, Enum.UserInputType.MouseButton1},
        {"AimDownSights", AimDownSightsFunction, false, Enum.ContextActionPriority.High.Value, Enum.UserInputType.MouseButton2},
        {"Reload", ReloadFunction, false, Enum.ContextActionPriority.High.Value, Enum.KeyCode.R},
        {"Inspect", InspectFunction, false, Enum.ContextActionPriority.High.Value, Enum.KeyCode.T},
    },
    WeaponData = {
        Damage = 5
    },
    Animations = {
        Idle = "rbxassetid://15882435035",
        Fire = "",
        Reload = "",
    }
}

return ToolSettings
