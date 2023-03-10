--Boiler Plate [OpenComputers]
local component = require("component");
local filesystem = require("filesystem");
local sides = require("sides");
local event = require("event");
local serialization = require("serialization");
local term = require("term");
local gpu = require("gpu");
local run = true;

local version = "0.1"
api["status"] = "Offline";

function closeListener(_, _, key)
    if key == nil then key = 96; end
    if key == 96 then
        print("Killing Program...");
        run = false;
        filesystem.setAutorunEnabled(false)
        event.ignore("key_up", closeListener);
    end
end
event.listen("key_up", closeListener);

function start()

end

function stop()

end

function updateDisplay()
    while run do
    term.clear();
    gpu.set(1,1 string.rep("═", 80))
    gpu.set(2,2 "Reactor Controller [Version " .. version .. "]")
    end
end


--Main Loop
while run do
    os.sleep(0);
end

--Program Close