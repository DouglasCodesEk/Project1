set website to text returned of (display dialog "Enter website to ping (e.g., www.apple.com):" default answer "www.apple.com")

set ping_result to do shell script "ping -c 4 " & website

display dialog ping_result buttons {"OK"} default button "OK"
