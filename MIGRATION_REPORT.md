# Sleep App - Отчёт о миграции Odoo → iOS

## 0. Проверка рабочего состояния инструментов

### ✅ Odoo (веб-приложение)
- **Статус**: Работает
- **URL**: http://localhost:8069
- **БД**: sleep20
- **Версия**: 17.0.7.0
- **Порт**: 8069
- **Процесс**: Запущен (PID: 32705)

### ✅ PostgreSQL
- **Статус**: Доступен
- **Хост**: localhost:5430
- **База данных**: sleep20
- **Пользователь**: odoo
- **Таблицы Sleep**: 10 основных таблиц найдены

### ⚠️ iOS Simulator (через MCP)
- **Статус**: Требует настройки
- **Проблема**: `simctl` недоступен - требуется переключение на полный Xcode
- **Решение**: Необходимо выполнить `sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer`
- **Альтернатива**: Можно использовать прямой запуск через Xcode IDE

### ✅ iOS Проект
- **Статус**: Существует
- **Путь**: `/Users/vlad/Desktop/ios_sleep/sleep course`
- **Проект**: `sleep course.xcodeproj`
- **Текущее состояние**: Базовый шаблон SwiftUI (Hello World)
- **Build**: Успешен (Debug-iphonesimulator)

### ⚠️ Chrome MCP
- **Статус**: Не проверен в текущей сессии
- **Требуется**: Для снятия скриншотов веб-версии

### ✅ PostgreSQL MCP
- **Статус**: Работает
- **Процесс**: Запущен (PID: 40412)
- **Подключение**: `postgresql://odoo:***@localhost:5430/sleep20`

---

## 1. Инвентаризация Odoo

### Основные модели приложения Sleep

#### 1.1 Script (Скрипты/Сценарии)
**Модель**: `script`
**Назначение**: Управление сценариями взаимодействия с пользователем

**Поля**:
- `name` (Char) - Название
- `step_ids` (One2many → script.step) - Шаги скрипта
- `state` (Selection) - Состояние: not_running, running, done, failed
- `data` (Json) - Дополнительные данные
- `user_id` (Many2one → res.users) - Пользователь
- `next_script_id` (Many2one → script) - Следующий скрипт
- `is_main` (Boolean) - Является главным
- `main_script_id` (Many2one → script) - Главный скрипт
- `ritual_line_id` (Many2one → ritual.line) - Связь с ритуалом
- `article_id` (Many2one → article) - Связь со статьёй

**Методы**:
- `run()` - Запуск скрипта
- `create_script(user_id)` - Создание копии скрипта для пользователя
- `_compute_state()` - Вычисление состояния

#### 1.2 Script Step (Шаги скрипта)
**Модель**: `script.step`
**Назначение**: Отдельные шаги в сценарии

**Связь**: Множественные шаги на один скрипт

#### 1.3 Article (Статьи)
**Модель**: `article`
**Назначение**: Образовательные материалы

**Поля**:
- `name` (Char, translate) - Название
- `text` (Html, translate) - Содержимое статьи
- `user_ids` (Many2many → res.users) - Пользователи с доступом
- `is_available` (Boolean, computed) - Доступность для текущего пользователя
- `image` (Image) - Изображение
- `short_name` (Char) - Краткое название
- `emoji` (Char) - Эмодзи для иконки
- `color` (Char) - Цвет
- `first_color` (Char) - Первый цвет градиента
- `second_color` (Char, computed) - Второй цвет градиента
- `description` (Char) - Описание

**UI**: Kanban view с карточками-градиентами

#### 1.4 Ritual (Ритуалы)
**Модель**: `ritual`
**Назначение**: Персональные ритуалы пользователя

**Поля**:
- `name` (Char, default="Ritual", translate) - Название
- `line_ids` (Many2many → ritual.line) - Элементы ритуала
- `user_id` (Many2one → res.users, required) - Пользователь
- `is_check` (Boolean, computed) - Все элементы выполнены

**Методы**:
- `open()` - Открытие формы ритуала
- `_compute_is_check()` - Проверка выполнения всех элементов

**UI**: Список с чекбоксами, сообщение "✨ Ritual is done ✨"

#### 1.5 Ritual Line (Элементы ритуала)
**Модель**: `ritual.line`

**Связь**: Множественные элементы в ритуале

#### 1.6 Chat (Чат)
**Модель**: `chat`
**Назначение**: Взаимодействие с виртуальным ассистентом

**Поля**:
- `name` (Char, default="Chat") - Название

**Особенность**: Интеграция с discuss.channel (модуль mail Odoo)

#### 1.7 Statistic (Статистика)
**Модель**: `statistic`
**Назначение**: Отслеживание настроения/прогресса

**Поля**:
- `mood` (Selection) - Настроение: 👍, 👌, 👎
- `date` (Datetime, required) - Дата записи
- `count` (Integer, computed) - Числовое значение: 1, 0, -1
- `date_string` (Char, computed) - Форматированная дата

**UI**: График (line chart) с трендом по времени

#### 1.8 Sound (Звуки)
**Модель**: `sound`
**Назначение**: Библиотека звуков для медитации/сна

**Поля**: (модель неполная в коде)

#### 1.9 Settings (Настройки)
**Модель**: `settings`
**Назначение**: Пользовательские настройки

**Поля**:
- `name` (Char, default="Settings", translate)
- `color_scheme` (Selection) - Тема: light, dark
- `lang` (Selection) - Язык
- `tz` (Selection) - Часовой пояс
- `time` (Char) - Время уведомлений

**Методы**:
- `_onchange_settings()` - Применение настроек с перезагрузкой

**UI**: Форма с кнопкой Logout

#### 1.10 About (О приложении)
**Модель**: `about`
**Назначение**: Информация о приложении

**Поля**:
- `name` (Char, default="About")

### Контроллеры

#### 1. ChannelController
**Файл**: `controllers/channel_controller.py`
**Маршруты**:
- `/discuss/channel/notify_typing` (POST, JSON) - Уведомление о наборе текста

#### 2. WebManifest
**Файл**: `controllers/webmanifest.py`
**Маршруты**:
- `/.well-known/assetlinks.json` - Для Android App Links
- `/web/manifest.webmanifest` - PWA манифест

**Особенности**:
- Поддержка PWA (Progressive Web App)
- Service Worker для офлайн-режима
- Категории: health, lifestyle, health & fitness

### Структура навигации (меню)

Из `menuitems.xml` и view файлов:

1. **Sleep** (корневое меню, `sleep_root_menu`)
   - **Chat** (sequence=1, icon: fa-comment)
   - **Articles** (sequence=2, icon: fa-regular fa-newspaper)
   - **Ritual** (sequence=3, icon: fa-regular fa-star)
   - **Settings** (sequence=100, icon: fa-gear)

*Примечание*: Statistic меню закомментировано, но модель существует

### Дополнительные зависимости

Из `__manifest__.py`:
- `base` - Базовый модуль Odoo
- `muk_web_enterprise_theme` - Тема интерфейса
- `mail` - Для чата и уведомлений
- `app_theme` - Дополнительная тема
- `field_timepicker` - Виджет выбора времени
- `onchange_action_17` - Обработка изменений
- `web_window_title` - Настройка заголовков окон

### Ассеты (Frontend)

**JavaScript**: `sleep/static/src/js/*.js`
**XML Templates**: `sleep/static/src/xml/*.xml`
**CSS/SCSS**: `sleep/static/src/css/*.{scss,css}`

---

## 2. Архитектура нативного UI (SwiftUI)

### План структуры приложения

```
SleepApp (iOS)
├── Models/
│   ├── Script.swift
│   ├── ScriptStep.swift
│   ├── Article.swift
│   ├── Ritual.swift
│   ├── RitualLine.swift
│   ├── Chat.swift
│   ├── Statistic.swift
│   ├── Sound.swift
│   └── Settings.swift
├── Views/
│   ├── MainTabView.swift (корневой TabView)
│   ├── ChatView/
│   │   └── ChatView.swift
│   ├── ArticlesView/
│   │   ├── ArticlesListView.swift (Kanban → Grid)
│   │   └── ArticleDetailView.swift
│   ├── RitualView/
│   │   └── RitualView.swift (чеклист)
│   ├── SettingsView/
│   │   └── SettingsView.swift
│   └── StatisticsView/
│       └── StatisticsView.swift (график)
├── ViewModels/
│   ├── ChatViewModel.swift
│   ├── ArticlesViewModel.swift
│   ├── RitualViewModel.swift
│   ├── StatisticsViewModel.swift
│   └── SettingsViewModel.swift
├── Services/
│   ├── DataService.swift (локальное хранилище)
│   └── MockDataService.swift (для разработки)
└── Resources/
    ├── Localizations/
    └── Assets.xcassets

```

### Маппинг экранов Odoo → iOS

| Odoo View | iOS View | UI Component |
|-----------|----------|--------------|
| Chat (mail discuss) | ChatView | List + ScrollView |
| Articles Kanban | ArticlesGridView | LazyVGrid с карточками-градиентами |
| Article Form | ArticleDetailView | ScrollView + HTMLText |
| Ritual Form | RitualChecklistView | List с Toggle |
| Statistics Graph | StatisticsChartView | Charts framework (SwiftUI) |
| Settings Form | SettingsView | Form с Picker'ами |
| About | AboutView | Простая информационная страница |

### Основные компоненты UI

#### TabBar (соответствие меню Odoo)
1. **Chat** - Tab icon: message.circle
2. **Articles** - Tab icon: newspaper
3. **Ritual** - Tab icon: star
4. **Settings** - Tab icon: gearshape

---

## 3. Маппинг моделей Odoo → Swift Structures

### Script
```swift
struct Script: Identifiable, Codable {
    let id: Int
    var name: String
    var steps: [ScriptStep]
    var state: ScriptState
    var data: [String: Any]?
    var userId: Int?
    var isMain: Bool
    
    enum ScriptState: String, Codable {
        case notRunning, running, done, failed
    }
}
```

### Article
```swift
struct Article: Identifiable, Codable {
    let id: Int
    var name: String
    var text: String // HTML content
    var shortName: String?
    var description: String?
    var emoji: String?
    var firstColor: String // RGB "255,120,0"
    var secondColor: String? // computed
    var image: Data?
    var isAvailable: Bool
}
```

### Ritual
```swift
struct Ritual: Identifiable, Codable {
    let id: Int
    var name: String
    var lines: [RitualLine]
    var userId: Int
    var isCheck: Bool // computed
}

struct RitualLine: Identifiable, Codable {
    let id: Int
    var name: String
    var sequence: Int
    var isCheck: Bool
}
```

### Statistic
```swift
struct Statistic: Identifiable, Codable {
    let id: Int
    var mood: Mood
    var date: Date
    var count: Int // computed
    
    enum Mood: String, Codable {
        case good = "👍"
        case neutral = "👌"
        case bad = "👎"
    }
}
```

### Settings
```swift
struct AppSettings: Codable {
    var colorScheme: ColorSchemeType
    var language: String
    var timezone: String
    var notificationTime: String
    
    enum ColorSchemeType: String, Codable {
        case light, dark
    }
}
```

---

## 4. План тестирования

### Unit Tests
- [ ] Модели: инициализация, computed properties
- [ ] ViewModels: бизнес-логика, state management
- [ ] Services: CRUD операции с CoreData/SwiftData

### UI Tests
- [ ] Навигация между табами
- [ ] Открытие/закрытие Article
- [ ] Переключение чекбоксов Ritual
- [ ] Создание записи в Statistics

### Snapshot Tests
- [ ] ChatView (пустой и с сообщениями)
- [ ] ArticlesGridView
- [ ] ArticleDetailView
- [ ] RitualView (не выполнен / выполнен)
- [ ] StatisticsView
- [ ] SettingsView

---

## 5. План MCP-оркестрации

### Фаза 1: Веб-скриншоты (Chrome MCP)
- [ ] Логин в Odoo (localhost:8069)
- [ ] Переход на Chat → скриншот
- [ ] Переход на Articles → скриншот
- [ ] Открытие одной Article → скриншот
- [ ] Переход на Ritual → скриншот
- [ ] Переход на Settings → скриншот

### Фаза 2: Запросы к БД (PostgreSQL MCP)
- [ ] Извлечение примеров записей из `article`
- [ ] Извлечение записей из `ritual` и `ritual_line`
- [ ] Извлечение записей из `statistic`
- [ ] Извлечение структуры таблиц для валидации моделей

### Фаза 3: iOS-скриншоты (iOS Simulator MCP)
- [ ] Запуск симулятора
- [ ] Установка приложения
- [ ] Скриншоты всех табов в той же последовательности
- [ ] Сравнение с веб-скриншотами

---

## 6. Таблица соответствия экранов

| # | Экран | Web URL | iOS View | Скриншот Web | Скриншот iOS | Статус |
|---|-------|---------|----------|--------------|--------------|--------|
| 1 | Chat | /web#menu_id=X&action=Y | ChatView | - | - | Pending |
| 2 | Articles Grid | /web#menu_id=X&action=Y | ArticlesGridView | - | - | Pending |
| 3 | Article Detail | /web#id=N&model=article | ArticleDetailView | - | - | Pending |
| 4 | Ritual | /web#menu_id=X&action=Y | RitualView | - | - | Pending |
| 5 | Settings | /web#menu_id=X&action=Y | SettingsView | - | - | Pending |

---

## 7. Текущий статус

### ✅ Завершено
- Анализ структуры Odoo приложения
- Инвентаризация моделей и контроллеров
- Маппинг Odoo → iOS
- Проверка доступности инструментов (Odoo, PostgreSQL)

### 🔄 В процессе
- Настройка iOS Simulator через MCP

### ⏳ Ожидает выполнения
- Реализация SwiftUI структуры
- MCP-оркестрация скриншотов
- Разработка компонентов UI
- Тестирование и регрессия
- Финальное сравнение Web vs iOS

---

## Примечания

1. **Offline-first**: iOS приложение не будет ходить в PostgreSQL напрямую. Все данные хранятся локально (CoreData/SwiftData).

2. **Цвета и градиенты**: Odoo использует rgba() градиенты в Kanban view для Articles. В SwiftUI это `LinearGradient` или `RadialGradient`.

3. **HTML контент**: Для отображения HTML в Article нужен `WKWebView` или библиотека вроде `SwiftSoup` для парсинга.

4. **Чат**: В Odoo это интеграция с discuss.channel (mail). В iOS можно использовать `MessageKit` или кастомный `List` + `ScrollViewReader`.

5. **Графики**: Для Statistic использовать нативный `Charts` framework (iOS 16+).

6. **Локализация**: Odoo использует `translate=True`. В iOS это Localizable.strings.

---

**Дата создания**: 21.10.2025  
**Версия**: 1.0  
**Автор**: AI Assistant

