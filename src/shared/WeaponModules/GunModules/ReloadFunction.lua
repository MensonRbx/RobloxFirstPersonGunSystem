local RunService = game:GetService("RunService")

if RunService:IsServer() then
    return 1
end

return function ()
    print("reloadFunction")
end