set appList to {"Safari", "Mail", "Calendar", "Notes"}

repeat with appName in appList
    tell application appName to activate
end tell

display notification "Frequent apps have been launched" with title "Apps Launched"  
