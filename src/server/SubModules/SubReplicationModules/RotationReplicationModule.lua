local neckC0 = CFrame.new(0, 0.8, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1);
local waistC0 = CFrame.new(0, 0.2, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1);
local rShoulderC0 = CFrame.new(1, 0.5, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1);
local lShoulderC0 = CFrame.new(-1, 0.5, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1);

local RotationReplicationModule = {}
RotationReplicationModule.__index = RotationReplicationModule

function RotationReplicationModule.new()
    local self = setmetatable({}, RotationReplicationModule)

    return self
end

function RotationReplicationModule:UpdateRotation(player, theta)
    local neck = player.Character.Head.Neck;
	local waist = player.Character.UpperTorso.Waist;
	local rShoulder = player.Character.RightUpperArm.RightShoulder;
	local lShoulder = player.Character.LeftUpperArm.LeftShoulder;
	
	neck.C0 = neckC0 * CFrame.fromEulerAnglesYXZ(theta*0.5, 0, 0);
	waist.C0 = waistC0 * CFrame.fromEulerAnglesYXZ(theta*0.5, 0, 0);
	rShoulder.C0 = rShoulderC0 * CFrame.fromEulerAnglesYXZ(theta*0.5, 0, 0);
	lShoulder.C0 = lShoulderC0 * CFrame.fromEulerAnglesYXZ(theta*0.5, 0, 0);
end

return RotationReplicationModule.new()
