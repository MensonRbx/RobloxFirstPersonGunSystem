-- Module used by FirstPersonTool to display information about the weapon

local Players = game:GetService("Players")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local WeaponInfoGui = playerGui:WaitForChild("WeaponInfoGui")
local Main = WeaponInfoGui:WaitForChild("Main")
local WeaponName = Main:WaitForChild("WeaponName")
local Ammo = Main:WaitForChild("Ammo")
local MaxAmmo = Main:WaitForChild("MaxAmmo")

local WeaponGuiModule = {}
WeaponGuiModule.__index = WeaponGuiModule

function WeaponGuiModule.new()
    local self = setmetatable({}, WeaponGuiModule)

    self.currentWeapon = nil

    self.connections = {}

    return self
end

function WeaponGuiModule:ShowWeaponInfo(firstPersonWeapon)
    if self.currentWeapon then
        self:UnbindOldWeapon()
    end

    Main.Visible = true
    self.currentWeapon = firstPersonWeapon

    WeaponName.Text = firstPersonWeapon.instance.Name
    Ammo.Text = firstPersonWeapon.toolModel:GetAttribute("Ammo")
    MaxAmmo.Text = "/" .. firstPersonWeapon.toolModel:GetAttribute("MaxAmmo")

    local onAmmoChanged = function()
        self:UpdateAmmo()
    end

    self.connections.AmmoUpdated = self.currentWeapon.toolModel:GetAttributeChangedSignal("Ammo"):Connect(onAmmoChanged)
end

function WeaponGuiModule:HideInfo()
    Main.Visible = false
end

function WeaponGuiModule:UpdateAmmo()
    Ammo.Text = self.currentWeapon.toolModel:GetAttribute("Ammo")
end

function WeaponGuiModule:UnbindOldWeapon()
    self.connections.AmmoUpdated:Disconnect()
end

return WeaponGuiModule.new()
