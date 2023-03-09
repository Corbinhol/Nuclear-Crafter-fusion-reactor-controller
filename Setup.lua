local filesystem = require("filesystem");
local component = require("component");
local term = require("term");
local version = "0.1";

term.clear();
print(string.rep("═", 80));
print("Starting Reactor Controller Setup | " .. version);
if filesystem.exists("/ReactorController/Controller.lua") then
    print("Detected controller already on system...");
    print("Would you like to uninstall the Controller first? [Y/n]")
    local answer = io.read();
    if answer == "n" or answer == "N" then
        print("Closing Setup...");
        os.sleep(1);
        term.clear();
        os.exit();
    else
        print("Uninstalling Reactor Controller...");
        os.sleep(1);
        filesystem.remove("/ReactorController")
    end
end

print("Starting Setup")
