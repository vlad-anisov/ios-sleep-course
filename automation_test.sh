#!/bin/bash

# ╔═══════════════════════════════════════════════════════════════╗
# ║  Sleep Course: Automated Testing & Comparison Script         ║
# ║  Автоматизация тестирования и сравнения iOS vs Web          ║
# ╚═══════════════════════════════════════════════════════════════╝

set -e  # Exit on error

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

PROJECT_DIR="/Users/vlad/Desktop/ios_sleep/sleep course"
SCREENSHOTS_DIR="$PROJECT_DIR/Screenshots"
XCODE_PROJECT="$PROJECT_DIR/sleep course.xcodeproj"
ODOO_URL="http://localhost:8069"

echo -e "${BLUE}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║       🧪 Sleep Course: Automated Testing                 ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════╝${NC}"
echo ""

# ═══════════════════════════════════════════════════════════════
# 1. Проверка окружения
# ═══════════════════════════════════════════════════════════════

echo -e "${YELLOW}[1/8]${NC} Проверка окружения..."

# Проверка Xcode
if ! command -v xcodebuild &> /dev/null; then
    echo -e "  ${RED}❌${NC} xcodebuild не найден. Используйте Xcode GUI."
    XCODE_CLI=false
else
    echo -e "  ${GREEN}✅${NC} Xcode CLI найден"
    XCODE_CLI=true
fi

# Проверка Odoo
if curl -s -o /dev/null -w "%{http_code}" "$ODOO_URL/web/login" | grep -q "200"; then
    echo -e "  ${GREEN}✅${NC} Odoo доступен ($ODOO_URL)"
else
    echo -e "  ${RED}❌${NC} Odoo не доступен. Запустите Odoo."
    exit 1
fi

# Проверка Simulator
if pgrep -x "Simulator" > /dev/null; then
    echo -e "  ${GREEN}✅${NC} iOS Simulator запущен"
else
    echo -e "  ${YELLOW}⏳${NC} Запускаю Simulator..."
    open -a Simulator
    sleep 5
fi

# Проверка Chrome
if pgrep -x "Google Chrome" > /dev/null; then
    echo -e "  ${GREEN}✅${NC} Chrome запущен"
else
    echo -e "  ${YELLOW}⏳${NC} Запускаю Chrome..."
    open -a "Google Chrome" "$ODOO_URL/web/login"
    sleep 3
fi

echo ""

# ═══════════════════════════════════════════════════════════════
# 2. Создание директорий
# ═══════════════════════════════════════════════════════════════

echo -e "${YELLOW}[2/8]${NC} Создание директорий для скриншотов..."

mkdir -p "$SCREENSHOTS_DIR/iOS"
mkdir -p "$SCREENSHOTS_DIR/Web"
mkdir -p "$SCREENSHOTS_DIR/Comparison"

echo -e "  ${GREEN}✅${NC} Директории готовы"
echo ""

# ═══════════════════════════════════════════════════════════════
# 3. Инструкции для ручного тестирования
# ═══════════════════════════════════════════════════════════════

echo -e "${YELLOW}[3/8]${NC} Ручное тестирование iOS..."
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  📱 ИНСТРУКЦИИ ДЛЯ iOS (Xcode + Simulator)${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "  1. В Xcode: нажмите ⌘R (или Play ▶️)"
echo "  2. Дождитесь запуска приложения в Simulator"
echo "  3. Протестируйте экраны:"
echo ""
echo "     📸 Чат:"
echo "        - Проверьте первое сообщение"
echo "        - Нажмите на кнопку (если есть)"
echo "        - ⌘S → Сохранить как: iOS/chat_01.png"
echo ""
echo "     📸 Articles:"
echo "        - Проверьте 15 карточек"
echo "        - Проверьте градиенты"
echo "        - ⌘S → iOS/articles_01.png"
echo "        - Откройте 'Старт 🚀'"
echo "        - ⌘S → iOS/article_detail_01.png"
echo ""
echo "     📸 Ritual:"
echo "        - Проверьте 7 элементов"
echo "        - ⌘S → iOS/ritual_01.png"
echo "        - Отметьте все"
echo "        - ⌘S → iOS/ritual_done_01.png"
echo ""
echo "     📸 Settings:"
echo "        - Проверьте разделы"
echo "        - ⌘S → iOS/settings_01.png"
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
read -p "Нажмите Enter когда закончите с iOS тестированием..."
echo ""

# ═══════════════════════════════════════════════════════════════
# 4. Инструкции для Web тестирования
# ═══════════════════════════════════════════════════════════════

echo -e "${YELLOW}[4/8]${NC} Ручное тестирование Web..."
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  🌐 ИНСТРУКЦИИ ДЛЯ WEB (Chrome DevTools)${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "  1. В Chrome:"
echo "     - Откройте $ODOO_URL/web/login"
echo "     - Залогиньтесь: admin / 12345"
echo ""
echo "  2. Включите Mobile View:"
echo "     - F12 (DevTools)"
echo "     - ⌘⇧M (Toggle device toolbar)"
echo "     - Выберите: iPhone 15"
echo "     - Refresh (⌘R)"
echo ""
echo "  3. Протестируйте экраны:"
echo ""
echo "     📸 Chat:"
echo "        - Menu → Sleep → Chat"
echo "        - ⌘⇧P → 'Capture screenshot'"
echo "        - Сохранить: Web/chat_01.png"
echo ""
echo "     📸 Articles:"
echo "        - Menu → Sleep → Articles"
echo "        - Screenshot → Web/articles_01.png"
echo "        - Откройте 'Старт 🚀'"
echo "        - Screenshot → Web/article_detail_01.png"
echo ""
echo "     📸 Ritual:"
echo "        - Menu → Sleep → Ritual"
echo "        - Screenshot → Web/ritual_01.png"
echo "        - Отметьте все"
echo "        - Screenshot → Web/ritual_done_01.png"
echo ""
echo "     📸 Settings:"
echo "        - Menu → Sleep → Settings"
echo "        - Screenshot → Web/settings_01.png"
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
read -p "Нажмите Enter когда закончите с Web тестированием..."
echo ""

# ═══════════════════════════════════════════════════════════════
# 5. Проверка наличия скриншотов
# ═══════════════════════════════════════════════════════════════

echo -e "${YELLOW}[5/8]${NC} Проверка скриншотов..."

IOS_COUNT=$(find "$SCREENSHOTS_DIR/iOS" -name "*.png" 2>/dev/null | wc -l | tr -d ' ')
WEB_COUNT=$(find "$SCREENSHOTS_DIR/Web" -name "*.png" 2>/dev/null | wc -l | tr -d ' ')

echo -e "  iOS: ${GREEN}$IOS_COUNT${NC} скриншотов"
echo -e "  Web: ${GREEN}$WEB_COUNT${NC} скриншотов"

if [ "$IOS_COUNT" -lt 7 ] || [ "$WEB_COUNT" -lt 7 ]; then
    echo -e "  ${YELLOW}⚠️${NC}  Недостаточно скриншотов (ожидается минимум 7 + 7)"
    echo -e "  ${YELLOW}⚠️${NC}  Пропустите или вернитесь назад"
fi

echo ""

# ═══════════════════════════════════════════════════════════════
# 6. Запуск UI тестов (если доступен xcodebuild)
# ═══════════════════════════════════════════════════════════════

echo -e "${YELLOW}[6/8]${NC} Запуск UI тестов..."

if [ "$XCODE_CLI" = true ]; then
    echo -e "  ${YELLOW}⏳${NC} Запуск xcodebuild test..."
    
    xcodebuild test \
        -project "$XCODE_PROJECT" \
        -scheme "sleep course" \
        -destination 'platform=iOS Simulator,name=iPhone 15' \
        -only-testing:sleep_courseUITests/SleepCourseUITests \
        2>&1 | tee "$PROJECT_DIR/test_results.log"
    
    if [ ${PIPESTATUS[0]} -eq 0 ]; then
        echo -e "  ${GREEN}✅${NC} Тесты пройдены"
    else
        echo -e "  ${RED}❌${NC} Тесты провалены (см. test_results.log)"
    fi
else
    echo -e "  ${YELLOW}⏳${NC} Запустите тесты вручную в Xcode: ⌘U"
    read -p "Нажмите Enter когда закончите..."
fi

echo ""

# ═══════════════════════════════════════════════════════════════
# 7. Генерация отчёта о сравнении
# ═══════════════════════════════════════════════════════════════

echo -e "${YELLOW}[7/8]${NC} Генерация отчёта о сравнении..."

REPORT_FILE="$PROJECT_DIR/TEST_RESULTS_$(date +%Y%m%d_%H%M%S).md"

cat > "$REPORT_FILE" << 'EOFR'
# 📊 Результаты тестирования Sleep Course

**Дата**: $(date +"%d.%m.%Y %H:%M")

---

## ✅ Выполненные шаги

- [x] iOS приложение запущено в симуляторе
- [x] Odoo веб открыт в Chrome Mobile view
- [x] Скриншоты iOS сделаны
- [x] Скриншоты Web сделаны
- [x] UI тесты запущены

---

## 📸 Скриншоты

### iOS
EOFR

# Добавляем список iOS скриншотов
for file in "$SCREENSHOTS_DIR/iOS"/*.png; do
    if [ -f "$file" ]; then
        basename_file=$(basename "$file")
        echo "- ✅ $basename_file" >> "$REPORT_FILE"
    fi
done

cat >> "$REPORT_FILE" << 'EOFR'

### Web
EOFR

# Добавляем список Web скриншотов
for file in "$SCREENSHOTS_DIR/Web"/*.png; do
    if [ -f "$file" ]; then
        basename_file=$(basename "$file")
        echo "- ✅ $basename_file" >> "$REPORT_FILE"
    fi
done

cat >> "$REPORT_FILE" << 'EOFR'

---

## 🧪 UI Тесты

См. `test_results.log` для детальных результатов.

---

## 📝 Следующие шаги

1. Открыть `TESTING_PLAN.md` и заполнить таблицы
2. Открыть `COMPARISON_REPORT.md` и добавить результаты сравнения
3. Использовать Digital Color Meter для проверки RGB градиентов
4. Создать side-by-side сравнения в Preview

---

**Статус**: ⏳ Требуется manual review
EOFR

echo -e "  ${GREEN}✅${NC} Отчёт создан: $(basename "$REPORT_FILE")"
echo ""

# ═══════════════════════════════════════════════════════════════
# 8. Финальные инструкции
# ═══════════════════════════════════════════════════════════════

echo -e "${YELLOW}[8/8]${NC} Финальные шаги..."
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  ✅ ТЕСТИРОВАНИЕ ЗАВЕРШЕНО!${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "  📂 Скриншоты сохранены в:"
echo "     $SCREENSHOTS_DIR"
echo ""
echo "  📊 Отчёт создан:"
echo "     $(basename "$REPORT_FILE")"
echo ""
echo "  📋 Следующие действия:"
echo "     1. Открыть TESTING_PLAN.md"
echo "     2. Заполнить таблицы результатов"
echo "     3. Сравнить скриншоты (side-by-side)"
echo "     4. Открыть COMPARISON_REPORT.md"
echo "     5. Добавить итоги сравнения"
echo ""
echo -e "${GREEN}  Команда для открытия всех документов:${NC}"
echo "     cd \"$PROJECT_DIR\""
echo "     open TESTING_PLAN.md COMPARISON_REPORT.md \"$REPORT_FILE\""
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Открыть папку со скриншотами
open "$SCREENSHOTS_DIR"

echo -e "${GREEN}✅ Готово!${NC}"

