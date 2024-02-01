local MATH_POW = math.pow

local EasingStyleConfig = {}

EasingStyleConfig["EaseOutBack"] = function(x)
    local c1 = 1.70158;
    local c3 = c1 + 1;

    return 1 + c3 * MATH_POW(x - 1, 3) + c1 * MATH_POW(x - 1, 2);
end

return EasingStyleConfig
