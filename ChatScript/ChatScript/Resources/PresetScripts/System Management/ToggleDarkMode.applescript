tell application "System Events"
    tell appearance preferences
        set dark mode to not dark mode
    end tell
end tell

delay 1

if dark mode of appearance preferences of application "System Events" then
    display notification "Dark Mode enabled" with title "Theme Changed"
else
    display notification "Light Mode enabled" with title "Theme Changed"
end if
