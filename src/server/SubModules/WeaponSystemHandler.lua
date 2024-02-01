--[[
    RESPONSIBILITIES

    1: Handle the equipping/unequipping of weapons server-side
    2: Handle the firing of weapons server-side
    3: Handle the reloading of weapons server-side
    4: Handle hit detection  
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ToolSettings = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ToolSettings"))

local RemoteEvents = ReplicatedStorage:WaitForChild("Remote"):WaitForChild("Events")
local ItemModels = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("ItemModels")

local GunFired = RemoteEvents:WaitForChild("GunFired")
local EquipItem = RemoteEvents:WaitForChild("EquipItem")

local WeaponSystemHandler = {}
WeaponSystemHandler.__index = WeaponSystemHandler

function WeaponSystemHandler.new()
    local self = setmetatable({}, WeaponSystemHandler)

    self:init()

    return self
end

function WeaponSystemHandler:init()
    local onEquipItem = function(player, itemName)
        self:ProcessItemEquip(player, itemName)
    end

    local onGunFired = function(player, itemName, hitInstance)
        self:ProcessGunFired(player, itemName, hitInstance)
    end

    EquipItem.OnServerEvent:Connect(onEquipItem)
    GunFired.OnServerEvent:Connect(onGunFired)
end

function WeaponSystemHandler:ProcessGunFired(player, itemName, hitInstance)

    local character = player.Character

    if not character then
        warn("No character found")
        return
    end

    local itemModel = player.Character:FindFirstChild("EquippedItem")
    local item = player.Character:FindFirstChildOfClass("Tool")

    if not item then
        warn("No item found")
        return
    end

    if item.Name ~= itemName then
        warn("Item name mismatch")
        return
    end

    local damage = ToolSettings[itemName].WeaponData.Damage

    itemModel.BulletSpawn.MuzzleFlash:Emit(1)

    if hitInstance then
        local humanoid = hitInstance.Parent:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:TakeDamage(damage)
        end
    end
    
end

function WeaponSystemHandler:ProcessItemEquip(player, itemName)
    local itemToEquip = ItemModels:FindFirstChild(itemName, true)

    if itemToEquip then
        itemToEquip = itemToEquip:Clone()

        self:_RemoveCurrentEquippedItem(player)
        self:_EquipItem(player, itemToEquip)
    end
    
end

function WeaponSystemHandler:_EquipItem(player, itemToEquip)
    local character = player.Character    
	local joint = Instance.new("Motor6D")
    
	joint.Part0 = character.RightHand
	joint.Part1 = itemToEquip.Handle
	joint.Parent = itemToEquip.Handle

    joint.C0 = itemToEquip:GetAttribute("ServerSideToolHandleCFrame")

	itemToEquip.Parent = character

    itemToEquip:SetAttribute("RealName", itemToEquip.Name)
    itemToEquip.Name = "EquippedItem"
end

function WeaponSystemHandler:_RemoveCurrentEquippedItem(player)
    local character = player.Character
    local itemToDestroy = character:FindFirstChild("EquippedItem")
    if itemToDestroy then
        itemToDestroy:Destroy()
    end
end

return WeaponSystemHandler.new()
