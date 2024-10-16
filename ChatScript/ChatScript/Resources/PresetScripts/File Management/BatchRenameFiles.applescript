set folderPath to choose folder with prompt "Select the folder containing files to rename:"
set prefix to text returned of (display dialog "Enter prefix for renamed files:" default answer "File_")

tell application "Finder"
    set fileList to every file of folder folderPath
    repeat with i from 1 to count of fileList
        set currentFile to item i of fileList
        set fileName to name of currentFile
        set fileExtension to name extension of currentFile
        set newName to prefix & i & "." & fileExtension
        set name of currentFile to newName
    end repeat
end tell

display notification "Files in the selected folder have been renamed" with title "Batch Rename Complete"
