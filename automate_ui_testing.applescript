tell application "Simulator"
	activate
	delay 2
end tell

-- Tap на Articles tab (координаты из скриншота)
tell application "System Events"
	tell process "Simulator"
		delay 1
		-- Tap Articles (второй таб)
		click at {284, 1460}
		delay 2
	end tell
end tell

-- Скриншот Articles
do shell script "/Applications/Xcode.app/Contents/Developer/usr/bin/simctl io 3C54D6D0-821C-4B03-941A-437C8F997B6A screenshot \"/Users/vlad/Desktop/ios_sleep/sleep course/Screenshots/iOS/05_articles.png\""
delay 1

-- Tap Ritual tab
tell application "System Events"
	tell process "Simulator"
		click at {436, 1460}
		delay 2
	end tell
end tell

-- Скриншот Ritual
do shell script "/Applications/Xcode.app/Contents/Developer/usr/bin/simctl io 3C54D6D0-821C-4B03-941A-437C8F997B6A screenshot \"/Users/vlad/Desktop/ios_sleep/sleep course/Screenshots/iOS/06_ritual.png\""
delay 1

-- Tap Settings tab
tell application "System Events"
	tell process "Simulator"
		click at {588, 1460}
		delay 2
	end tell
end tell

-- Скриншот Settings
do shell script "/Applications/Xcode.app/Contents/Developer/usr/bin/simctl io 3C54D6D0-821C-4B03-941A-437C8F997B6A screenshot \"/Users/vlad/Desktop/ios_sleep/sleep course/Screenshots/iOS/07_settings.png\""

return "✅ Все скриншоты сделаны!"
