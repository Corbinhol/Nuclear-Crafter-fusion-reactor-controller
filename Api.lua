--Allows managing and controlling the reactor via network cards.
--General Purpose API
local component = require("component");
local thread = require("thread");
local event = require("event");
local serialization = require("serialization");
local modem;

function start()
    return "does not exist"
end

function stop()
    return "does not exist"
end

if component.isAvailable("tunnel") then
    if api == nil then
        modem = component.tunnel;
        modem.open(60);
        modem.setWakeMessage("wakeup");
        apiData = {};
        apiChannel = "";
        apiAlias = "";

        local function respond(address, message1, message2, message3, message4, message5, message6, message7)
            local out = modem.send(address, 60, "apiResponse", message1, message2, message3, message4, message5, message6, message7);
            return out, message1;
        end

        local function apiLoop()
            while true do
                local _, _, from, _, _, _, arg1, arg2, arg3, arg4, arg5, arg6, arg7 = event.pull("modem_message", nil, nil, nil, nil, "api"); 
                if arg1 == nil then arg1 = "nothing"; else
                --print("Recieved " .. tostring(arg1));
                end
                --Commands
                if arg1 == "getdata" then
                    if apiData[arg2] == nil then modem.send(from, 60, "nothing") else
                        respond(from, apiData[arg2]);
                    end
                elseif arg1 == "setdata" then
                    local tempData = apiData[arg2];
                    if tempData == nil then tempData = "nothing"; end
                    apiData[arg2] = arg3;
                    respond(from, true, tempData);
                elseif arg1 == "isOnline" then
                    respond(from, true);
                elseif arg1 == "whois" then
                    if arg2 == apiAlias then
                        respond(from, "me");
                    end
                elseif arg1 == "stop" then
                    respond(from, stop())
                elseif arg1 == "start" then
                    respond(from, start())
                else
                    respond(from, "command unrecognized");
                end
                os.sleep(0);
            end
        end
        --apiLoop();
        api = thread.create(apiLoop); 
        api:detach();
        end
    end
else
    print("Error: No Tunnel...Not Starting API");
end