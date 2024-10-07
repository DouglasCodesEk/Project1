on run
	tell application "System Events"
		set triggerKey to key code 100 -- F8 key
		
		repeat
			wait for keypress of triggerKey
			
			-- Copy the selected text
			do shell script "osascript resources/applescripts/copy_selection.applescript"
			delay 0.1 -- Short delay to ensure clipboard is updated
			
			-- Get the clipboard content
			set word_to_find_synonyms to (do shell script "osascript resources/applescripts/get_clipboard.applescript")
			
			-- Run the Python script to fetch synonyms
			set python_script to "python3 /Users/admin/Projects/MyApp/src/synonym_fetcher.py " & quoted form of word_to_find_synonyms
			set synonyms to do shell script python_script
			
			-- Paste the result
			do shell script "osascript resources/applescripts/set_clipboard.applescript " & quoted form of synonyms
			delay 0.1 -- Short delay to ensure clipboard is updated
			keystroke "v" using command down
			
			display notification "Synonyms fetched and pasted for: " & word_to_find_synonyms
		end repeat
	end tell
end run
