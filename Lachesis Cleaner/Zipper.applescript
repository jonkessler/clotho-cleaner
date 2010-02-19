-- Zipper.applescript
-- Zipper

--  Created by Joseph Subida on 6/4/09.
--  Copyright 2009 University of Illinois Champaign-Urbana. All rights reserved.


-- Clicked on one of the three buttons
on clicked theObject
	set objectsName to name of theObject as string
	
	if objectsName is "zipButton" then
		-- Zip Button: zip up log folder and place it on the desktop
		set visible of progress indicator "spinner" of window "window" to true
		start progress indicator "spinner" of window "window"
		
		try
			tell application "Terminal"
				do shell script "cd ~/Library/Logs/Discipline; ls; zip -r ~/Desktop/CompressedLogs.zip ."
				quit
			end tell
			
			set visible of progress indicator "spinner" of window "window" to false
			set enabled of button "zipButton" of window "window" to false
			set enabled of button "uploadButton" of window "window" to true
			
			display alert "Log folder zipped"
		on error eStr number eNum partial result rList from badObj to expectedType
			display alert ("Error: unable to zip folder")
			set visible of progress indicator "spinner" of window "window" to false
		end try
	else if objectsName is "uploadButton" then
		-- Upload Button: open up Safari with the provided link
		tell application "Safari"
			activate
			make new document at end of documents
			set URL of document 1 to "http://tapestry.cs.illinois.edu/submit.php"
		end tell
		set enabled of button "uploadButton" of window "window" to false
		
	else if objectsName is "deleteButton" then
		-- Delete Button: delete entire log folder
		set returnValue to display dialog "Are you sure you want to remove Clotho Logger from your login items and delete the log folder and zip file?" buttons {"Yes", "No"} default button "No"
		if button returned of returnValue is "Yes" then
			do shell script "rm -r ~/Library/Logs/Discipline"
			tell application "Finder"
				set zipFolder to (path to desktop folder from user domain as string) & "CompressedLogs.zip"
				if zipFolder exists then
					do shell script "rm ~/Desktop/CompressedLogs.zip"
				end if
			end tell
			tell application "Clotho Logger"
				quit
			end tell
			removeFromStartUp()
			display alert "Log folder and zip file deleted. Clotho Logger has been deleted from your startup applications."
		else
			display dialog "Nothing deleted" buttons {"OK"}
		end if
	end if
	
	-- Once the Zip and Upload buttons have been pressed, assuming
	-- everything was done, then enable the delete button
	if enabled of button "zipButton" of window "window" is false then
		if enabled of button "uploadButton" of window "window" is false then
			set enabled of button "deleteButton" of window "window" to true
		end if
	end if
	
end clicked

-- On load MainMenu nib
on awake from nib theObject
	set visible of progress indicator "spinner" of window "window" to false
end awake from nib

-- On wanting to remove Clotho Logger from startup
on removeFromStartUp()
	tell application "System Events"
		if login item "Clotho Logger" exists then
			delete login item "Clotho Logger"
		end if
	end tell
end removeFromStartUp