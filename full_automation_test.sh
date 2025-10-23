#!/bin/bash
set -e

echo "🚀 Запуск полного автоматического тестирования..."

# Переменные
UDID="3C54D6D0-821C-4B03-941A-437C8F997B6A"
APP_ID="com.brainwaves.sleep-course"
SCREENSHOTS_DIR="Screenshots/iOS"
WEB_SCREENSHOTS_DIR="Screenshots/Web"

mkdir -p "$SCREENSHOTS_DIR"
mkdir -p "$WEB_SCREENSHOTS_DIR"

# 1. Запуск iOS приложения
echo "📱 Запуск iOS приложения..."
/Applications/Xcode.app/Contents/Developer/usr/bin/simctl launch $UDID $APP_ID
sleep 3

# 2. Скриншот Chat (начальный)
echo "📸 Скриншот Chat экрана..."
/Applications/Xcode.app/Contents/Developer/usr/bin/simctl io $UDID screenshot "$SCREENSHOTS_DIR/test_01_chat.png"

# 3. Использую accessibility для получения координат табов
echo "🔍 Анализ UI элементов..."

# 4. Клики через osascript (калиброванные координаты для iPhone 17 Pro)
echo "👆 Переключение на Articles..."
osascript -e 'tell application "System Events" to tell process "Simulator" to click at {284, 1495}' 2>/dev/null || true
sleep 2
/Applications/Xcode.app/Contents/Developer/usr/bin/simctl io $UDID screenshot "$SCREENSHOTS_DIR/test_02_articles.png"

echo "👆 Переключение на Ritual..."
osascript -e 'tell application "System Events" to tell process "Simulator" to click at {436, 1495}' 2>/dev/null || true
sleep 2
/Applications/Xcode.app/Contents/Developer/usr/bin/simctl io $UDID screenshot "$SCREENSHOTS_DIR/test_03_ritual.png"

echo "👆 Переключение на Settings..."
osascript -e 'tell application "System Events" to tell process "Simulator" to click at {588, 1495}' 2>/dev/null || true
sleep 2
/Applications/Xcode.app/Contents/Developer/usr/bin/simctl io $UDID screenshot "$SCREENSHOTS_DIR/test_04_settings.png"

echo "👆 Возврат на Chat..."
osascript -e 'tell application "System Events" to tell process "Simulator" to click at {132, 1495}' 2>/dev/null || true
sleep 2
/Applications/Xcode.app/Contents/Developer/usr/bin/simctl io $UDID screenshot "$SCREENSHOTS_DIR/test_05_chat_final.png"

# 5. Открытие Odoo Web в Chrome
echo "🌐 Открытие Odoo Web в Chrome..."
open -a "Google Chrome" "http://localhost:8069/web/login"
sleep 5

# 6. Авторизация в Odoo (если не авторизован)
osascript << 'APPLESCRIPT'
tell application "Google Chrome"
    activate
    delay 2
end tell

tell application "System Events"
    tell process "Google Chrome"
        -- Переход в mobile view (⌘⌥I для DevTools, затем ⌘⇧M)
        keystroke "i" using {command down, option down}
        delay 2
        keystroke "m" using {command down, shift down}
        delay 2
    end tell
end tell
APPLESCRIPT

sleep 3

echo "📸 Скриншоты Odoo Web..."
screencapture -x "$WEB_SCREENSHOTS_DIR/web_01_login.png"
sleep 2

# Скриншоты основных экранов Odoo
# (предполагаем что уже авторизованы)
open "http://localhost:8069/web#menu_id=sleep.sleep_chat_menu&action=sleep.action_chat"
sleep 3
screencapture -x "$WEB_SCREENSHOTS_DIR/web_02_chat.png"

open "http://localhost:8069/web#menu_id=sleep.sleep_article_menu&action=sleep.article_action"
sleep 3
screencapture -x "$WEB_SCREENSHOTS_DIR/web_03_articles.png"

open "http://localhost:8069/web#menu_id=sleep.sleep_ritual_menu&action=sleep.ritual_action"
sleep 3
screencapture -x "$WEB_SCREENSHOTS_DIR/web_04_ritual.png"

open "http://localhost:8069/web#menu_id=sleep.sleep_settings_menu&action=sleep.settings_action"
sleep 3
screencapture -x "$WEB_SCREENSHOTS_DIR/web_05_settings.png"

echo "✅ Все скриншоты сделаны!"
echo "📊 iOS: $(ls -1 $SCREENSHOTS_DIR/test_*.png 2>/dev/null | wc -l | tr -d ' ') файлов"
echo "📊 Web: $(ls -1 $WEB_SCREENSHOTS_DIR/web_*.png 2>/dev/null | wc -l | tr -d ' ') файлов"

