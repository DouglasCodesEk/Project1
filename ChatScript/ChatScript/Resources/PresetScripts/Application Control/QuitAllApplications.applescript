tell application "System Events"
    set runningApps to name of every application process where background only is false
end tell

repeat with appName in runningApps
    if appName is not "Finder" then
        tell application appName to quit
    end if
end tell

display notification "All applications have been closed" with title "Quit All Apps"
