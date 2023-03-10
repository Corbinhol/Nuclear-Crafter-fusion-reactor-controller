--Boiler Plate [OpenComputers]
local component = require("component");
local filesystem = require("filesystem");
local sides = require("sides");
local event = require("event");
local serialization = require("serialization");
local term = require("term");
local thread = require("thread");
local computer = require("computer");
local gpu = component.gpu
local run = true;
local reactor = component.nc_fusion_reactor;
local tank;
api = {};   
local version = "0.1"
api["status"] = "Offline";

local hasTank = false;
local tankSide;

function checkComponents() --Check all components.
    if component.isAvailable("tank_controller") then --check if tank upgrade/adapter is attatched
        tank = component.tank_controller; 
        for i=1,6 do
            if tank.getTankCapacity() > 0 then --find side with tank
                tankSide == i;
                break;
            end
        end
        if tankSide == nil then --if no side has a tank, assume tank doesn't exist. remove tank.
            tank = nil;
        end
    end
end

function closeListener(_, _, key) --Kill Switch
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

local function indexTime(timeInSeconds) --Convert Uptime to digital time.
    local numberOfSeconds = timeInSeconds % 60;
    local numberOfMinutes = math.floor(timeInSeconds / 60);
    local numberOfHours = math.floor(numberOfMinutes / 60);
    numberOfMinutes = numberOfMinutes % 60;
    local numberOfDays = math.floor(numberOfHours / 24);
    numberOfHours = numberOfHours % 24;

    if numberOfSeconds < 10 then numberOfSeconds = "" .. 0 .. numberOfSeconds; end
    if numberOfMinutes < 10 then numberOfMinutes = "" .. 0 .. numberOfMinutes; end
    if numberOfHours < 10 then numberOfHours = "" .. 0 .. numberOfHours; end
    if numberOfDays < 10 then numberOfDays = "" .. 0 .. numberOfDays; end
    local output = "";
    if numberOfDays ~= "00" then output = output .. numberOfDays .. ":"; end
    if numberOfHours ~= "00" then output = output .. numberOfHours .. ":"; end
    output = output .. numberOfMinutes .. ":" .. numberOfSeconds;
    return output;
end

function updateDisplay() --Update display in background.
    term.clear();
    while run do
    gpu.set(1,1, string.rep("═", 80));
    gpu.set(2,2, "Reactor Controller [Version " .. version .. "]");
    gpu.set(2,3, "Reactor Status: ");
    local uptime = "Uptime: " .. indexTime(math.floor(computer.uptime()))
    gpu.set(80 - string.len(uptime), 2, uptime);
    local fusionHeat = "           Temperature: " .. math.floor(reactor.getTemperature() / 1000);
    gpu.set(80 - string.len(fusionHeat), 3, fusionHeat);
    gpu.set(2, 4, "1st Fission Fuel: " .. reactor.getFirstFusionFuel());
    gpu.set(2, 5, "2nd Fission Fuel: " .. reactor.getSecondFusionFuel());
    local fusionFuel1 = "          " .. tank.getFluidsInTank(sides.)
    end
end
display = thread.create(updateDisplay);

--Main Loop
while run do
    os.sleep(1);
end

--Program Close