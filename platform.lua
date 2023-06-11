local component = require('component')
local event = require('event')
local modem = component.modem
local rs=component.redstone
local status = 0--0:no train 1:stopping 2:stopped 3:departing

local stop_time = 60
local stop_type = true --true:stop false:non-stop
local auto_dispatch=true

local function setRsOutput(value)
    if value then
        rs.setOutput({15,15,15,15,15,15})
    else
        rs.setOutput({0,0,0,0,0,0})
    end
    
end

local function ir_train_overhead(address)
    if status ~= 0 or stop_type == false then
        return
    end
    status = 1
    local rear_controller = component.proxy(address)
    if rear_controller.setBrake == nil then
        return
    end
    local detector = component.ir_augment_detector
    while true do
        local info
        repeat
            info = detector.info()
        until info~= nil
        if info['speed']>10 then
            rear_controller.setBrake(1)
            rear_controller.setThrottle(0)
        else
            rear_controller.setBrake(0)
            rear_controller.setThrottle(.2)
            break
        end
        os.sleep(.1)
    end
    repeat
        _,address = event.pull('ir_train_overhead')
    until address~=rear_controller.address and address ~= detector.address
    local front_controller = component.proxy(address)
    front_controller.setBrake(1)
    front_controller.setThrottle(0)
    print('Train stopped')
    status = 2
    if auto_dispatch then
        print('Departing in',stop_time,'seconds.')
        os.sleep(stop_time)
    else
        print('Waiting for dispatch...')
        repeat
            local event_type,_,_,_,_,arg = event.pull()
        until (event_type=='modem_message' and arg=='depart')
    end
    status = 3
    print('Train departing...')
    front_controller.horn()
    front_controller.setBrake(0)
    front_controller.setThrottle(1)
    os.sleep(60)
    status = 0
    print("Waiting for the train...")
end

local function modem_message(message_type,arg)
    if message_type=="stop_type" then
        stop_type = arg
        setRsOutput(stop_type)
        print('Stop type set to '..tostring(arg))
    elseif message_type=="auto_dispatch" then
        auto_dispatch=arg
        print('Auto dispatching:',auto_dispatch)
    end
end

--init
modem.open(1)
setRsOutput(stop_type)
print("Waiting for the train...")

while true do
    local event_name,address,from,port,_,message_type,arg = event.pull()
    if event_name == "ir_train_overhead" then
        ir_train_overhead(address)
    elseif event_name == "modem_message" then
        modem_message(message_type,arg)
    end
    
end

