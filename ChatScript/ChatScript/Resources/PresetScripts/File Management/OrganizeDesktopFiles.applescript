set desktopPath to (path to desktop folder as text)
set organizedFolder to desktopPath & "Organized Files:"

tell application "Finder"
    if not (exists folder organizedFolder) then
        make new folder at desktop with properties {name:"Organized Files"}
    end if
    
    set fileExtensions to name of every file of desktop whose name extension is not ""
    repeat with ext in fileExtensions
        if not (exists folder (organizedFolder & ext)) then
            make new folder at folder "Organized Files" of desktop with properties {name:ext}
        end if
        move (every file of desktop whose name extension is ext) to folder ext of folder "Organized Files" of desktop
    end repeat
end tell

display notification "Desktop files have been organized" with title "Desktop Cleanup Complete"
