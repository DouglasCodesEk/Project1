set deviceName to do shell script "scutil --get ComputerName"
set osVersion to do shell script "sw_vers -productVersion"
set processorInfo to do shell script "sysctl -n machdep.cpu.brand_string"
set memoryInfo to do shell script "echo $(($(sysctl -n hw.memsize) / 1073741824)) GB"

set systemInfo to "Device Name: " & deviceName & return & ¬
                  "OS Version: " & osVersion & return & ¬
                  "Processor: " & processorInfo & return & ¬
                  "Memory: " & memoryInfo

display dialog systemInfo buttons {"OK"} default button "OK" with title "System Information"
