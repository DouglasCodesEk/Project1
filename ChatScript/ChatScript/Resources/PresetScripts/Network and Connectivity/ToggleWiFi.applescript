do shell script "networksetup -getairportpower en0"
set current_status to the result

if current_status contains "On" then
    do shell script "networksetup -setairportpower en0 off"
    set new_status to "disabled"
else
    do shell script "networksetup -setairportpower en0 on"
    set new_status to "enabled"
end if

display notification "Wi-Fi has been " & new_status with title "Wi-Fi Toggled"
