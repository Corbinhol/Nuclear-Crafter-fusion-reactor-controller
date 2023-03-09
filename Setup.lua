local filesystem = require("filesystem");
local component = require("component");
local term = require("term");
local version = "0.1";

local args = {...};

local uninstall = false;
local forceInstall = false;
local repair = false;

for i,arg in ipairs(args) do
    if arg == "-u" then uninstall = true; end
    if arg == "-f" then forceInstall = true; end
    if arg == "-r" then repair = true; end
end

function run_uninstall()
    print("Uninstalling Reactor Controller...");
    os.sleep(1);
    filesystem.remove("/ReactorController");
end

term.clear();
print(string.rep("═", 80));
if uninstall then 
    run_uninstall()
else
    if component.isAvailable("nc_fusion_reactor") or forceInstall then
        print("Starting Reactor Controller Setup | " .. version);
        if filesystem.exists("/ReactorController/Controller.lua") then
            if repair == false then
                print("Detected controller already on system...");
                print("Would you like to uninstall the Controller first? [Y/n]")
                local answer = io.read();
            else
                answer = "Y"
            end
            if answer == "n" or answer == "N" then
                print("Closing Setup...");
                os.sleep(1);
                term.clear();
                os.exit();
            else
                run_uninstall();
            end
        end
        print("Starting Setup");

    else
        print("Error: No fusion reactor found, [Use -f to force install without it]");
        os.exit();
    end
end

