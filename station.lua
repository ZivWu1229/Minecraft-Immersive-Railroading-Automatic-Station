local component=require('component')
local modem=component.modem

local function config(platform)
    ::start::
    print('Configurating platform '..tostring(platform))
    print('(0)Exit\n(1)Prepare for departure\n(2)Enable/disable auto dispath\n(3)Enable/disable stopping\nSelect a feature:')
    local feature = io.read()
    local arg
    if feature == '2' or feature=='3' then
        ::continue::
        print('(1)Enable\n(2)Disable\nEnter the argumant:')
        arg=io.read()
        if arg == '1' then
            arg=true
        elseif arg == '2' then
            arg=false
        else
            goto continue
        end
    end
    if feature =='0' then
        return
    elseif feature == '1' then
        modem.broadcast(platform,'ready')
        print('Press enter to depart...')
        io.read()
        modem.broadcast(platform,'depart')
    elseif feature == '2' then
        modem.broadcast(platform,'auto_dispatch',arg)
    elseif feature == '3' then
        modem.broadcast(platform,'stop_type',arg)
    end
    goto start
end


while true do
    print('Enter a platform number:')
    local platform = io.read()
    config(tonumber(platform))
end