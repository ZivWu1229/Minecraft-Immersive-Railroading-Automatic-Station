local component = require('component')
local event = require('event')
local rs = component.redstone

local speed = 180

while true do
    event.pull('ir_train_overhead')
    for _,strength in pairs(rs.getInput()) do
        if strength ~= 0 then
            goto brake
        end
    end
    goto continue
    ::brake::
    local info
    repeat
        info = component.ir_augment_detector.info()
    until info ~= nil
    if info.speed>=speed then
        component.ir_augment_control.setBrake(1)
        component.ir_augment_control.setThrottle(0)
    end
    ::continue::
end