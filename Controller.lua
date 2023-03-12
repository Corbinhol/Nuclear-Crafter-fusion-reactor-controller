--Importing all important API's
local component = require("component");
local filesystem = require("filesystem");
local sides = require("sides");
local event = require("event");
local serialization = require("serialization");
local term = require("term");
local thread = require("thread");
local computer = require("computer");
local text = require("text");
local shell = require("shell");

local gpu = component.gpu
local tank;

api = {};   
local version = "0.4"
api["status"] = "Running";
local run = true;

local hasTank = false;
local tankSide;
local reactor;

local function firstToUpper(str) --Capitalizes first letter of a string. Used for fuel names.
    return (str:gsub("^%l", string.upper))
end

local function checkComponents() --Check all components.
    if component.isAvailable("tank_controller") then --check if tank upgrade/adapter is attatched
        tank = component.tank_controller; 
        for i=0,5 do
            if tank.getTankCapacity(i) > 0 then --find side with tank
                tankSide = i;
                print("Found one.")
                break;
            end
        end
        if tankSide == nil then --if no side has a tank, assume tank doesn't exist. remove tank.
            print("No Sides Found.")
            tank = nil;
        end
    end

    if component.isAvailable("nc_fusion_reactor") then --if no reactor, 
        reactor = component.nc_fusion_reactor;
    else    
        print("Reactor not connected. Please connect reactor before starting program");
        os.exit();
    end
end

local function closeListener(_, _, key) --Kill Switch
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

local function indexTime(time) --Convert Uptime to digital time
    local days = math.floor(time/86400)
    local hours = math.floor((time % 86400)/3600)
    local minutes = math.floor((time % 3600)/60)
    local seconds = math.floor((time % 60))
    return string.format("%02d:%02d:%02d:%02d",days,hours,minutes,seconds)
end

--Set colors for display
local color = {};
color["Disabled"] = 0xff0000;
color["Running"] = 0x00ff08;
color["Warming Up"] = 0xff9500
color["green"] = 0x00ff08;
color["red"] = 0xff0000;



local function updateDisplay() --Update display in background.
    term.clear();
    while run do
        gpu.set(1,1, string.rep("═", 80));
        gpu.set(2,2, "Reactor Controller [Version " .. version .. "]");
        gpu.set(2,3, "Reactor Status: ")
        gpu.setForeground(color[api["status"]]); --Set the color based on the status
        gpu.set(2 + string.len("Reactor Status: "),3, api["status"])
        gpu.setForeground(0xffffff); --Set color back to white
        local uptime = indexTime(math.floor(computer.uptime())); -- Get the total uptime of computer, and format it.
        gpu.set(80 - string.len("Uptime: " .. uptime), 2, "Uptime: ");
        gpu.setForeground(color["Warming Up"]); --Set color of timestamp to orange (is same color as Warming Up) 
        gpu.set(80 - string.len(uptime), 2, uptime);
        gpu.setForeground(0xffffff); --Set Color back to white
        --Get total reactor temperature.
        local fusionHeat = "           Temperature: " .. math.floor(reactor.getTemperature() / 1000) .. "kK";
        gpu.set(80 - string.len(fusionHeat), 3, fusionHeat);
        gpu.set(2, 4, "1st Fission Fuel: " .. firstToUpper(reactor.getFirstFusionFuel()));
        gpu.set(2, 5, "2nd Fission Fuel: " .. firstToUpper(reactor.getSecondFusionFuel()));
        if tank ~= nil then --Only print fuel information, if tank controller exist.
            local fusionFluidInTank = tank.getFluidInTank(tankSide);
            local fusionFuel1 = "          " .. math.floor(fusionFluidInTank[1].amount) .. "/" .. math.floor(fusionFluidInTank[1].capacity);
            local fusionFuel2 = "          " .. math.floor(fusionFluidInTank[2].amount) .. "/" .. math.floor(fusionFluidInTank[2].capacity);
            gpu.set(80 - string.len(fusionFuel1),4, fusionFuel1);
            gpu.set(80 - string.len(fusionFuel2),5, fusionFuel2);
        end
        --get amount of rf in reactor
        local rfAmount = "Rf Buffer: " .. math.floor(reactor.getEnergyStored()) .. "/" .. math.floor(reactor.getMaxEnergyStored());
        gpu.set(2, 6, rfAmount); 
        local reactorEnergyChange = reactor.getEnergyChange(); --get rf change
        local rfChange = "                " .. math.floor(reactorEnergyChange) .. " rf/t";

        if reactorEnergyChange > 0 then gpu.setForeground(color["green"]); else gpu.setForeground(color["red"]) end
        gpu.set(80 - string.len(rfChange), 6, rfChange);
        gpu.setForeground(0xffffff) 
        gpu.set(1,7, string.rep("═", 80));
        gpu.set(1,25, string.rep("═", 80))
        gpu.set(2,24, ">");
        gpu.set(1,23, string.rep("═", 80))
        os.sleep(1);
    end
end

checkComponents()
display = thread.create(updateDisplay);
--updateDisplay();

local history = {};
history["nowrap"] = true;
local function getCommand()
    while true do
        term.setCursor(4,24);
        local command = term.read(history, false, hint):sub(1, -2);
        if command ~= "" then
            local args, ops = shell.parse(command);
            if args[1] == "exit" then
                os.sleep(1);
                event.ignore("key_up", closeListener);
                run = false;
                term.clear();
                os.exit();
            else

            end
            gpu.set(4,24, string.rep(" ", 160));
        end
        os.sleep(0.5);
    end
end
commandInput = thread.create(getCommand);
while run do
    os.sleep(.1);
end

--Program Close