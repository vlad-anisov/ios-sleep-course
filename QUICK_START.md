# 🚀 Quick Start: Sleep Course Testing

## ⚡️ Быстрый старт за 3 минуты

### 1️⃣ Запустить iOS приложение (30 сек)
```bash
# В Xcode (уже открыт):
1. Убедиться, что выбран "sleep course" и "iPhone 15"
2. Нажать ⌘R
3. Дождаться запуска симулятора
```

### 2️⃣ Открыть Odoo Web в мобильном режиме (30 сек)
```bash
# В Chrome:
1. Открыть http://localhost:8069/web/login
2. Залогиниться: admin / 12345
3. F12 → ⌘⇧M (mobile view)
4. Выбрать "iPhone 15"
```

### 3️⃣ Начать тестирование (2 мин)
```bash
# Следовать инструкциям из:
open "MANUAL_TESTING_INSTRUCTIONS.md"
```

---

## 📚 Документы по приоритету

| # | Документ | Для чего | Статус |
|---|----------|----------|--------|
| 1 | **MANUAL_TESTING_INSTRUCTIONS.md** | 👉 НАЧАТЬ ОТСЮДА | ⏳ Выполнить |
| 2 | **TESTING_PLAN.md** | Чеклист тестирования | ⏳ Заполнить |
| 3 | **COMPARISON_REPORT.md** | Итоговый отчёт | ⏳ После тестов |
| 4 | MIGRATION_REPORT.md | Odoo inventory | ✅ Готово |
| 5 | ODOO_TO_IOS_MAPPING.md | Маппинг моделей | ✅ Готово |
| 6 | DB_DATA_SAMPLES.md | Данные из PostgreSQL | ✅ Готово |
| 7 | SCRIPTS_IMPLEMENTATION.md | Система скриптов | ✅ Готово |

---

## 🎯 Что нужно сделать сейчас

### Шаг 1: Запустить приложение
- [ ] Открыть Xcode (уже открыт ✅)
- [ ] Нажать ⌘R
- [ ] Проверить, что приложение запустилось

### Шаг 2: Протестировать 4 экрана
- [ ] Chat: первое сообщение, кнопки, ввод
- [ ] Articles: 15 карточек, градиенты, детали
- [ ] Ritual: 7 элементов, чекбоксы, done message
- [ ] Settings: пикеры, about, logout

### Шаг 3: Сделать скриншоты
- [ ] 7 скриншотов iOS (⌘S в симуляторе)
- [ ] 7 скриншотов Web (DevTools screenshot)
- [ ] Сохранить в папку `Screenshots/`

### Шаг 4: Запустить UI тесты
- [ ] В Xcode: ⌘U
- [ ] Дождаться результатов (20 тестов)
- [ ] Проверить attachments (скриншоты)

### Шаг 5: Заполнить отчёты
- [ ] Таблицы в `TESTING_PLAN.md`
- [ ] Таблицы в `COMPARISON_REPORT.md`
- [ ] Создать side-by-side сравнения

---

## 🛠️ Команды для терминала

### Открыть все документы сразу:
```bash
cd "/Users/vlad/Desktop/ios_sleep/sleep course"
open MANUAL_TESTING_INSTRUCTIONS.md
open TESTING_PLAN.md
open COMPARISON_REPORT.md
```

### Открыть папку для скриншотов:
```bash
open Screenshots/
```

### Проверить статус Odoo:
```bash
curl -I http://localhost:8069/web/login
```

### Проверить Xcode:
```bash
ps aux | grep Xcode
```

---

## 📸 Быстрое создание скриншотов

### iOS (Симулятор):
```
⌘S — Screenshot
Файл сохраняется на Desktop
Переименовать в: ios_chat_01.png, ios_articles_01.png, etc.
Переместить в: Screenshots/
```

### Web (Chrome DevTools):
```
⌘⇧P → "Capture screenshot"
Или: DevTools → ⋮ → "Capture screenshot"
Сохранить как: web_chat_01.png, etc.
```

---

## ⚠️ Известные проблемы

### Xcode toolchain issue
```bash
# Если xcodebuild не работает:
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer

# Или запускать через Xcode GUI (⌘R)
```

### Odoo не запущен
```bash
cd /Users/vlad/Desktop/sleep
python3 odoo17ee/odoo-bin -c odoo.conf
```

### Симулятор не открывается
```bash
open -a Simulator
# Или в Xcode: Xcode → Open Developer Tool → Simulator
```

---

## 🎯 Критерии успеха

Тестирование завершено, если:
- ✅ Все 4 экрана протестированы
- ✅ 14 скриншотов сделано
- ✅ UI тесты запущены (20 тестов)
- ✅ Таблицы заполнены
- ✅ Отчёт готов

**Целевое время**: 30-40 минут

---

## 📞 Помощь

Если что-то не работает:
1. Проверить `MANUAL_TESTING_INSTRUCTIONS.md` (пошаговые инструкции)
2. Проверить `TESTING_PLAN.md` (детальный чеклист)
3. Проверить `COMPARISON_REPORT.md` (примеры заполнения таблиц)

---

**Статус**: ⏳ Готово к тестированию  
**Следующий шаг**: ⌘R в Xcode! 🚀

