# Миграция на SwiftData и @Observable

## Обзор

Приложение успешно мигрировано с устаревших технологий на современный стек iOS 17+:
- ✅ **ObservableObject + @Published** → **@Observable**
- ✅ **Combine** → **SwiftData**
- ✅ **Mock данные в памяти** → **Персистентное хранилище SwiftData**

## Изменения в архитектуре

### 1. Модели (`Models/`)

Все модели конвертированы в SwiftData с использованием макроса `@Model`:

#### `Article.swift`
- ✅ `struct` → `@Model final class`
- ✅ Добавлен `@Attribute(.unique)` для `id`
- ✅ `description` переименовано в `articleDescription` (избежание конфликта имен)
- ✅ Добавлен инициализатор

#### `ChatMessage.swift`
- ✅ `struct` → `@Model final class`
- ✅ Добавлен `@Attribute(.unique)` для `id`
- ✅ Сохраняет computed properties (`dateString`)

#### `Ritual.swift` и `RitualLine.swift`
- ✅ `struct` → `@Model final class`
- ✅ Добавлена связь `@Relationship(deleteRule: .cascade, inverse: \RitualLine.ritual)`
- ✅ Автоматическое удаление линий при удалении ритуала (cascade)

#### `Statistic.swift`
- ✅ `struct` → `@Model final class`
- ✅ Enum `Mood` хранится как `String` в свойстве `moodValue`
- ✅ Computed property для доступа к enum

#### `AppSettings.swift`
- ✅ `struct` → `@Model final class`
- ✅ Enum `ColorSchemeType` хранится как `String`
- ✅ Удалён UserDefaults, все через SwiftData

### 2. ViewModels (`ViewModels/`)

Все ViewModels мигрированы на `@Observable`:

#### Было (ObservableObject):
```swift
@MainActor
class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var isTyping: Bool = false
    
    init() {
        loadMessages()
    }
}
```

#### Стало (@Observable + SwiftData):
```swift
@MainActor
@Observable
class ChatViewModel {
    var messages: [ChatMessage] = []
    var isTyping: Bool = false
    
    private var modelContext: ModelContext?
    
    init(modelContext: ModelContext? = nil) {
        self.modelContext = modelContext
        loadMessages()
    }
}
```

**Мигрированы ViewModels:**
- ✅ `ChatViewModel` - с полной интеграцией SwiftData
- ✅ `ArticlesViewModel` - использует `FetchDescriptor`
- ✅ `RitualViewModel` - работает с relationships
- ✅ `SettingsViewModel` - персистентные настройки
- ✅ `StatisticsViewModel` - сохранение статистики

### 3. Views (`Views/`)

Views обновлены для работы с новой архитектурой:

#### `ChatView.swift`
```swift
@Environment(\.modelContext) private var modelContext
@State private var viewModel: ChatViewModel?

.onAppear {
    if viewModel == nil {
        viewModel = ChatViewModel(modelContext: modelContext)
    }
}
```

#### `ArticlesView.swift`
```swift
@Query(sort: \Article.id) private var articles: [Article]
```
- Используется `@Query` для автоматической загрузки
- Нет необходимости в ViewModel для простого отображения

#### `RitualView.swift`
```swift
@Query private var rituals: [Ritual]
@Environment(\.modelContext) private var modelContext
```
- Прямое взаимодействие с SwiftData
- `toggleLine()` сохраняет изменения немедленно

#### `SettingsView.swift`
```swift
@Query private var allSettings: [AppSettings]
@Environment(\.modelContext) private var modelContext
```
- Персистентные настройки через SwiftData
- Метод `handleLogout()` очищает все данные

### 4. App Entry Point (`sleep_courseApp.swift`)

#### Настройка SwiftData ModelContainer:
```swift
let schema = Schema([
    ChatMessage.self,
    Ritual.self,
    RitualLine.self,
    Article.self,
    Statistic.self,
    AppSettings.self
])

let modelConfiguration = ModelConfiguration(
    schema: schema, 
    isStoredInMemoryOnly: false
)
modelContainer = try ModelContainer(
    for: schema, 
    configurations: [modelConfiguration]
)
```

#### Инициализация данных при первом запуске:
- ✅ 15 статей с реальным контентом
- ✅ Базовый ритуал с 7 линиями
- ✅ Настройки по умолчанию

## Преимущества новой архитектуры

### 1. Производительность
- **@Observable** более эффективен чем ObservableObject
- Автоматическая оптимизация обновлений UI
- Меньше ненужных перерисовок

### 2. Персистентность данных
- Все данные сохраняются автоматически
- Не нужно управлять UserDefaults
- Транзакционная целостность данных

### 3. Relationships
- Автоматическое управление связями между моделями
- Cascade delete для зависимых объектов
- Inverse relationships

### 4. Современный код
- Использование новейших API iOS 17+
- Меньше boilerplate кода
- Более декларативный стиль

## Тестирование

### Проверить после миграции:

1. **Сохранение данных:**
   - [ ] Сообщения чата сохраняются между запусками
   - [ ] Состояние ритуала сохраняется
   - [ ] Настройки сохраняются
   - [ ] Статистика накапливается

2. **Работа UI:**
   - [ ] Статьи отображаются корректно
   - [ ] Чат работает с кнопками и сообщениями
   - [ ] Ритуал можно отмечать и сбрасывать
   - [ ] Настройки изменяются и сохраняются

3. **Первый запуск:**
   - [ ] Создаются начальные данные
   - [ ] Все 15 статей загружаются
   - [ ] Ритуал с 7 линиями создан
   - [ ] Настройки по умолчанию установлены

## Требования

- **iOS 17.0+** (SwiftData и @Observable)
- **Xcode 15.0+**
- **Swift 5.9+**

## Отличия от старой версии

| Аспект | До | После |
|--------|----|----|
| Состояние | ObservableObject + @Published | @Observable |
| Хранение | Mock данные | SwiftData |
| Persistence | Нет / UserDefaults | Автоматическая |
| Views | @StateObject | @State + @Environment |
| Queries | Ручная загрузка | @Query |
| Relationships | Вручную | @Relationship |

## Заметки разработчика

1. **Enums в SwiftData:** Enum значения хранятся как String с computed properties для доступа
2. **Relationships:** Используется cascade delete для автоматической очистки
3. **ModelContext:** Передаётся через Environment, доступен во всех Views
4. **FetchDescriptor:** Используется для сложных запросов вместо простого @Query
5. **Сохранение:** Автоматическое, но можно вызывать `context.save()` вручную

## Дальнейшие улучшения

- [ ] Добавить миграцию данных между версиями схемы
- [ ] Реализовать синхронизацию с iCloud
- [ ] Добавить экспорт/импорт данных
- [ ] Оптимизация запросов для больших объёмов данных
- [ ] Unit тесты для SwiftData моделей

