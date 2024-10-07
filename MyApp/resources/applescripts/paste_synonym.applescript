try
    tell application "System Events"
        keystroke (the clipboard)
    end tell
on error errMsg
    log "Error pasting synonym: " & errMsg
end try
