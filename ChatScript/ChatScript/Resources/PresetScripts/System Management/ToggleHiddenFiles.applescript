do shell script "defaults read com.apple.finder AppleShowAllFiles"
set current_status to the result

if current_status is "TRUE" then
    do shell script "defaults write com.apple.finder AppleShowAllFiles FALSE"
else
    do shell script "defaults write com.apple.finder AppleShowAllFiles TRUE"
end if

do shell script "killall Finder"

if current_status is "TRUE" then
    display notification "Hidden files are now invisible" with title "Hidden Files Toggled"
else
    display notification "Hidden files are now visible" with title "Hidden Files Toggled"
end if
