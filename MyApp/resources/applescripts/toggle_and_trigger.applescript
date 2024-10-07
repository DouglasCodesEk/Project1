on run
	tell application "System Events"
		set triggerKey to key code 100 -- F8 key
		set isActive to false
		
		repeat
			set keyCombo to (wait for keypress of triggerKey)
			
			if command down of keyCombo then
				-- Toggle active state with Cmd+F8
				set isActive to not isActive
				if isActive then
					display notification "Synonym fetcher activated"
				else
					display notification "Synonym fetcher deactivated"
				end if
			else if isActive then
				-- Process synonym request
				-- Copy the selected text
				keystroke "c" using command down
				delay 0.1 -- Short delay to ensure clipboard is updated
				
				-- Get the clipboard content
				set word_to_find_synonyms to (the clipboard)
				
				-- Run the Python script to fetch synonyms
				set python_script to "python3 /Users/admin/Projects/MyApp/src/fetch_synonyms.py"
				set synonyms to do shell script python_script
				
				-- Paste the result
				set the clipboard to synonyms
				keystroke "v" using command down
				
				display notification "Synonyms fetched and pasted for: " & word_to_find_synonyms
			else
				-- Do nothing if not active
				display notification "Synonym fetcher is not active. Press Cmd+F8 to activate."
			end if
		end repeat
	end tell
end run
