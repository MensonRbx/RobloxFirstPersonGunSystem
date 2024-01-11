--[[
    RESPONSIBILITIES

    1: Handle the equipping/unequipping of weapons server-side
    2: Handle the firing of weapons server-side
    3: Handle the reloading of weapons server-side
    4: Handle hit detection  
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteEvents = ReplicatedStorage:WaitForChild("Remote"):WaitForChild("Events")
local ItemModels = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("ItemModels")

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

    EquipItem.OnServerEvent:Connect(onEquipItem)
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
