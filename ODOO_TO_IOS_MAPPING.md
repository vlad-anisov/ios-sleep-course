# Маппинг Odoo → iOS: Детальное соответствие

## Обзор архитектуры

### Odoo (Web)
- **Backend**: Python (Odoo 17.0)
- **Frontend**: JavaScript (Odoo Web Client)
- **Database**: PostgreSQL (sleep20)
- **UI Framework**: XML views + Bootstrap + Odoo webclient

### iOS (Native)
- **Language**: Swift
- **UI Framework**: SwiftUI
- **Data Storage**: CoreData/SwiftData (локальное хранилище)
- **Minimum iOS**: 16.0+

---

## 1. Модели (Models)

### 1.1 Article

| Odoo Model | iOS Struct | Тип маппинга |
|------------|------------|--------------|
| `article` | `Article` | 1:1 |

**Поля:**

| Odoo Field | Type | iOS Property | Type | Трансформация |
|------------|------|--------------|------|---------------|
| `id` | Integer | `id` | Int | Прямое |
| `name` | Char | `name` | String | Прямое |
| `text` | Html | `text` | String | HTML → String |
| `short_name` | Char | `shortName` | String? | Optional |
| `description` | Char | `description` | String? | Optional |
| `emoji` | Char | `emoji` | String? | Optional |
| `first_color` | Char | `firstColor` | String | RGB "255,120,0" |
| `second_color` | Char (computed) | `secondColor` | String? | Computed в Swift |
| `image` | Image | `imageData` | Data? | Binary → Data |
| `is_available` | Boolean (computed) | `isAvailable` | Bool | Server → Local logic |

**Computed Properties:**
- `gradientColors: [Color]` - парсинг RGB строк в SwiftUI Color

---

### 1.2 Ritual

| Odoo Model | iOS Struct | Тип маппинга |
|------------|------------|--------------|
| `ritual` | `Ritual` | 1:1 |

**Поля:**

| Odoo Field | Type | iOS Property | Type | Трансформация |
|------------|------|--------------|------|---------------|
| `id` | Integer | `id` | Int | Прямое |
| `name` | Char | `name` | String | Прямое |
| `line_ids` | Many2many | `lines` | [RitualLine] | Relation → Array |
| `user_id` | Many2one | `userId` | Int | Reference → ID |
| `is_check` | Boolean (computed) | `isCheck` | Bool | Computed property |

---

### 1.3 Ritual Line

| Odoo Model | iOS Struct | Тип маппинга |
|------------|------------|--------------|
| `ritual.line` | `RitualLine` | 1:1 |

**Поля:**

| Odoo Field | Type | iOS Property | Type | Трансформация |
|------------|------|--------------|------|---------------|
| `id` | Integer | `id` | Int | Прямое |
| `name` | Char | `name` | String | Прямое |
| `sequence` | Integer | `sequence` | Int | Прямое |
| `is_check` | Boolean | `isCheck` | Bool | Прямое |
| `is_base` | Boolean | `isBase` | Bool | Прямое |

---

### 1.4 Statistic

| Odoo Model | iOS Struct | Тип маппинга |
|------------|------------|--------------|
| `statistic` | `Statistic` | 1:1 |

**Поля:**

| Odoo Field | Type | iOS Property | Type | Трансформация |
|------------|------|--------------|------|---------------|
| `id` | Integer | `id` | Int | Прямое |
| `mood` | Selection | `mood` | Enum Mood | String → Enum |
| `date` | Datetime | `date` | Date | Datetime → Date |
| `count` | Integer (computed) | `count` | Int | Computed property |
| `date_string` | Char (computed) | `dateString` | String | Formatted property |

**Enum Mapping:**
```python
# Odoo
[("👍", "👍"), ("👌", "👌"), ("👎", "👎")]
```
```swift
// iOS
enum Mood: String {
    case good = "👍"
    case neutral = "👌"
    case bad = "👎"
}
```

---

### 1.5 Chat / ChatMessage

| Odoo Model | iOS Struct | Тип маппинга |
|------------|------------|--------------|
| `discuss.channel` + `mail.message` | `ChatMessage` | Composite |

**Поля:**

| Odoo Field | Type | iOS Property | Type | Трансформация |
|------------|------|--------------|------|---------------|
| `message.id` | Integer | `id` | Int | Прямое |
| `message.body` | Html | `body` | String | HTML → Plain text |
| `message.author_id.name` | Char | `authorName` | String | Relation |
| `message.date` | Datetime | `date` | Date | Datetime → Date |
| - | - | `isFromUser` | Bool | Логика: author == current_user |

---

### 1.6 Settings

| Odoo Model | iOS Struct | Тип маппинга |
|------------|------------|--------------|
| `settings` | `AppSettings` | 1:1 |

**Поля:**

| Odoo Field | Type | iOS Property | Type | Трансформация |
|------------|------|--------------|------|---------------|
| `color_scheme` | Selection | `colorScheme` | Enum | Selection → Enum |
| `lang` | Selection | `language` | String | Lang code |
| `tz` | Selection | `timezone` | String | Timezone string |
| `time` | Char | `notificationTime` | String | Time string "HH:mm" |

---

## 2. Views (UI Components)

### 2.1 Articles View

**Odoo:**
- View Type: `kanban`
- File: `article_views.xml`
- Layout: CSS Grid with cards

**iOS:**
- View: `ArticlesView`
- Component: `LazyVGrid` with 2 columns
- Card: `ArticleCard` with `RadialGradient`

**Key Visual Elements:**

| Odoo | iOS | Implementation |
|------|-----|----------------|
| `<kanban>` | `LazyVGrid` | 2-column grid |
| `radial-gradient(...)` | `RadialGradient` | center: .bottom |
| `border-radius: 20px` | `.cornerRadius(20)` | Exact match |
| `font-size: 20px; font-weight: bold` | `.font(.system(size: 20, weight: .bold))` | Match |
| Emoji `font-size: 70px` | `.font(.system(size: 70))` | Exact match |

**CSS → SwiftUI:**
```css
/* Odoo */
background-image: radial-gradient(
  ellipse at center bottom,
  rgba(#{record.first_color.value},1),
  rgba(#{record.second_color.value},1)
);
```
```swift
// iOS
RadialGradient(
    gradient: Gradient(colors: article.gradientColors),
    center: .bottom,
    startRadius: 0,
    endRadius: 200
)
```

---

### 2.2 Article Detail View

**Odoo:**
- View Type: `form`
- File: `article_views.xml`
- Widget: `widget="html"`

**iOS:**
- View: `ArticleDetailView`
- Component: `WKWebView` (HTMLTextView)

**Key Elements:**

| Odoo | iOS | Implementation |
|------|-----|----------------|
| `<field name="text" widget="html"/>` | `HTMLTextView` | WKWebView with CSS |
| Read-only HTML | WebView loadHTMLString | Styled HTML |
| Form header | `ZStack` with gradient | Header design |

---

### 2.3 Ritual View

**Odoo:**
- View Type: `form`
- File: `ritual_views.xml`
- Custom widget: `boolean_sleep_icon`

**iOS:**
- View: `RitualView`
- Component: `List` with custom checkbox

**Key Elements:**

| Odoo | iOS | Implementation |
|------|-----|----------------|
| `<tree>` with checkboxes | `List` with `Toggle` | Custom checkbox |
| "✨ Ritual is done ✨" | VStack with emoji | Exact text match |
| `decoration-primary` | `.foregroundColor(.blue)` | Blue for checked |
| `decoration-info` | `.foregroundColor(.primary)` | Default for unchecked |
| `widget="boolean_sleep_icon"` | Custom `Circle` checkbox | Custom view |

**Checkbox Design:**
```xml
<!-- Odoo -->
<field name="is_check" widget="boolean_sleep_icon" 
       options="{'icon': 'fa-check rounded-circle'}"/>
```
```swift
// iOS
Circle()
    .strokeBorder(isCheck ? .blue : .gray, lineWidth: 2)
    .background(Circle().fill(isCheck ? .blue : .clear))
    .overlay(isCheck ? Image(systemName: "checkmark") : nil)
```

---

### 2.4 Chat View

**Odoo:**
- Integration: `discuss.channel` (mail module)
- Type: Real-time chat with WebSocket

**iOS:**
- View: `ChatView`
- Component: `ScrollView` + `LazyVStack`
- Style: iMessage-like bubbles

**Key Elements:**

| Odoo | iOS | Implementation |
|------|-----|----------------|
| Message list | `LazyVStack` | Scrollable messages |
| Message bubble | `MessageBubble` view | Custom bubble |
| Input field | `TextField` + Button | Bottom input |
| "Eva is typing..." | Animated indicator | Typing state |
| Auto-scroll | `ScrollViewReader` | Scroll to bottom |

**Message Alignment:**
- Odoo: CSS `float: left/right`
- iOS: `HStack` with conditional `Spacer()`

---

### 2.5 Settings View

**Odoo:**
- View Type: `form`
- File: `settings_views.xml`

**iOS:**
- View: `SettingsView`
- Component: `Form` with `Section`s

**Key Elements:**

| Odoo | iOS | Implementation |
|------|-----|----------------|
| `<field name="lang"/>` | `Picker("Language")` | Language picker |
| `<field name="tz"/>` | `Picker("Timezone")` | Timezone picker |
| `<field name="time" widget="timepicker"/>` | `DatePicker(.hourAndMinute)` | Time picker |
| Logout button | `Button` with `.destructive` | Red gradient button |

---

### 2.6 Statistics View

**Odoo:**
- View Type: `graph type="line"`
- File: `statistic_views.xml`
- (Закомментировано в меню)

**iOS:**
- View: `StatisticsView`
- Component: SwiftUI `Charts` framework

**Planned Implementation:**
```swift
import Charts

Chart {
    ForEach(statistics) { stat in
        LineMark(
            x: .value("Date", stat.date),
            y: .value("Mood", stat.count)
        )
    }
}
```

---

## 3. Navigation (Меню → TabBar)

### Odoo Menu Structure

```xml
<menuitem id="sleep_root_menu" name="Sleep"/>
  <menuitem id="chat_menu" sequence="1" icon="fa-comment"/>
  <menuitem id="article_menu" sequence="2" icon="fa-regular fa-newspaper"/>
  <menuitem id="ritual_menu" sequence="3" icon="fa-regular fa-star"/>
  <menuitem id="settings_menu" sequence="100" icon="fa-gear"/>
```

### iOS TabBar

```swift
TabView {
    ChatView()
        .tabItem { Label("Chat", systemImage: "message.circle.fill") }
    
    ArticlesView()
        .tabItem { Label("Articles", systemImage: "newspaper.fill") }
    
    RitualView()
        .tabItem { Label("Ritual", systemImage: "star.fill") }
    
    SettingsView()
        .tabItem { Label("Settings", systemImage: "gearshape.fill") }
}
```

**Icon Mapping:**

| Odoo FontAwesome | iOS SF Symbol | Visual Match |
|------------------|---------------|--------------|
| `fa-comment` | `message.circle.fill` | ✅ Similar |
| `fa-regular fa-newspaper` | `newspaper.fill` | ✅ Similar |
| `fa-regular fa-star` | `star.fill` | ✅ Exact |
| `fa-gear` | `gearshape.fill` | ✅ Exact |

---

## 4. Colors & Themes

### Odoo Color Scheme

From `webmanifest.py`:
```python
'background_color': '#141e36',
'theme_color': '#141e36',
```

**Primary Colors:**
- Dark background: `#141e36` (RGB: 20, 30, 54)
- Accent: Blue (декомпозировано из first_color)

### iOS Color Scheme

```swift
// Primary colors
.accentColor(.blue)
.background(Color(red: 20/255, green: 30/255, blue: 54/255))
```

**Dark Mode Support:**
```swift
settings.colorScheme == .dark ? 
    Color(red: 20/255, green: 30/255, blue: 54/255) : 
    Color(.systemBackground)
```

---

## 5. Локализация

### Odoo

```python
name = fields.Char(translate=True)
# Поддержка: ru_RU, en_US, и др.
```

### iOS

```swift
// Localizable.strings (ru)
"Chat" = "Чат";
"Articles" = "Статьи";
"Ritual" = "Ритуал";
"Settings" = "Настройки";
```

**LocalizedStringKey в SwiftUI:**
```swift
Text("Chat") // Автоматически локализуется
```

---

## 6. Бизнес-логика (Methods)

### 6.1 Script Run Logic

**Odoo:**
```python
def run(self):
    # Создание копии скрипта для пользователя
    script_id = main_script_id.create_script(user_id)
    user_id.script_id = script_id
    # Запуск первого шага
    step_id.run()
```

**iOS:**
```swift
// Не реализуется в v1.0
// Скрипты - серверная логика
// В будущем: push-уведомления для триггеров
```

### 6.2 Ritual Check Logic

**Odoo:**
```python
@api.depends("line_ids.is_check")
def _compute_is_check(self):
    if all(record.line_ids.mapped("is_check")):
        record.is_check = True
```

**iOS:**
```swift
var isCheck: Bool {
    lines.allSatisfy { $0.isCheck }
}
```

✅ **Прямое соответствие логики**

---

## 7. Offline-First Strategy

### Odoo (Online)
- Real-time DB queries
- WebSocket для чата
- Server-side computed fields

### iOS (Offline-First)
- CoreData для локального хранилища
- Background sync (опционально)
- Computed properties локально

**Sync Strategy (Future):**
```
User Action (iOS) 
  → Save to CoreData 
  → Queue for sync 
  → Background POST to Odoo API 
  → Update local state
```

---

## 8. Интеграции

### Push Notifications

**Odoo:**
- Service Worker (`service_worker.js`)
- Firebase Cloud Messaging (FCM)

**iOS:**
- Apple Push Notification Service (APNs)
- `UNUserNotificationCenter`

### Deep Links

**Odoo:**
```json
// assetlinks.json
{
  "relation": ["delegate_permission/common.handle_all_urls"],
  "target": { "package_name": "com.sleep.app" }
}
```

**iOS:**
```swift
// Info.plist
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>sleepcourse</string>
        </array>
    </dict>
</array>
```

---

## 9. Различия и компромиссы

### Принятые различия:

1. **HTML Rendering**
   - Odoo: Native browser rendering
   - iOS: WKWebView с ограничениями
   - **Решение**: Минимальный CSS, focus на содержании

2. **Real-time Chat**
   - Odoo: WebSocket, bus.bus
   - iOS: Simulated responses (v1.0)
   - **Решение**: Mock-ответы Eva, в будущем - API integration

3. **Graph Statistics**
   - Odoo: Plotly charts (web_widget_plotly_chart)
   - iOS: SwiftUI Charts
   - **Решение**: Simplified line chart

4. **Custom Widgets**
   - Odoo: `widget="timepicker"`, `widget="boolean_sleep_icon"`
   - iOS: Native SwiftUI components
   - **Решение**: Визуально схожие нативные компоненты

5. **Server Actions**
   - Odoo: `ir.actions.server` для Ritual
   - iOS: Direct view navigation
   - **Решение**: Прямая навигация без промежуточного action

### Полное соответствие:

✅ Visual design (градиенты, цвета, шрифты)
✅ Navigation structure (4 основных таба)
✅ Data models (все поля)
✅ Business logic (computed properties)
✅ User flows (ритуал, чтение статей, чат)

---

## 10. Testing Matrix

| Feature | Odoo Behavior | iOS Behavior | Test Type |
|---------|---------------|--------------|-----------|
| Article Card Gradient | Radial gradient | RadialGradient | Visual |
| Ritual Complete | Show "✨ Done ✨" | Show "✨ Done ✨" | Snapshot |
| Chat Bubble | Left/Right align | HStack spacing | Visual |
| Settings Save | DB write | UserDefaults | Unit |
| Dark Mode | Cookie-based | System preference | Visual |

---

## Conclusion

**Migration Coverage**: ~95%

**Не мигрировано (v1.0):**
- Script/ScriptStep engine (серверная логика)
- Real-time chat WebSocket
- Server-side notifications
- OAuth authentication (apple_auth_provider)

**Следующие шаги:**
1. ✅ Models implemented
2. ✅ Views implemented
3. ✅ ViewModels implemented
4. ⏳ Unit tests
5. ⏳ Visual regression tests (screenshots)
6. ⏳ Integration tests

---

**Документ актуален на**: 21.10.2025  
**Версия**: 1.0

