# 🏗 Архитектура приложения Sleep Course

## 📱 Современная SwiftUI + SwiftData архитектура (2024-2025)

Приложение полностью соответствует последним рекомендациям Apple по архитектуре iOS приложений.

---

## ✅ Ключевые принципы

### 1. **Прямая работа с данными через @Query**
Вместо устаревшего паттерна MVVM, Views работают напрямую с моделями данных через макрос `@Query`:

```swift
struct ArticlesView: View {
    @Query(sort: \Article.id) private var articles: [Article]
    
    var body: some View {
        // Прямой доступ к данным
    }
}
```

### 2. **Бизнес-логика в моделях**
Вся логика находится в самих моделях как методы и computed properties:

```swift
@Model
final class ChatMessage {
    // Бизнес-логика как статические методы
    static func createMessage(body: String, isFromUser: Bool, in context: ModelContext) -> ChatMessage {
        // ...
    }
    
    static func generateEvaResponse(for userMessage: String) -> String {
        // ...
    }
}
```

### 3. **SwiftData вместо Core Data**
Используется современный фреймворк SwiftData с декларативным подходом:

```swift
@Model
final class Article {
    @Attribute(.unique) var id: Int
    var name: String
    // ...
}
```

### 4. **@Observable вместо ObservableObject**
Для состояний используется новый макрос `@Observable` (iOS 17+):

```swift
@State private var isTyping = false
@State private var currentStep: ScriptStep?
```

---

## 📂 Структура проекта

```
sleep course/
├── Models/                   # SwiftData модели с бизнес-логикой
│   ├── Article.swift         # Статьи курса
│   ├── ChatMessage.swift     # Сообщения чата + логика Eva
│   ├── Ritual.swift          # Ритуалы и их элементы
│   ├── Script.swift          # Скрипты диалогов
│   ├── Settings.swift        # Настройки приложения
│   └── Statistic.swift       # Статистика настроения
│
├── Views/                    # SwiftUI представления
│   ├── MainTabView.swift     # Главный TabView
│   ├── ChatView.swift        # Чат с Eva
│   ├── ArticlesView.swift    # Список статей
│   ├── ArticleDetailView.swift
│   ├── RitualView.swift      # Вечерний ритуал
│   └── SettingsView.swift    # Настройки
│
└── sleep_courseApp.swift     # Точка входа + SwiftData setup
```

---

## 🔄 Что изменилось?

### ❌ Удалено (устаревшие паттерны):
- **ViewModels/** - весь слой ViewModel удален
- **ContentView.swift** - неиспользуемый файл
- Промежуточные слои абстракции

### ✅ Добавлено (современные подходы):
- Прямые `@Query` в Views
- Бизнес-логика в Models через extensions
- `Script` и `ScriptStep` как `@Model` классы
- Статические методы для создания и обработки данных

---

## 🎯 Примеры использования

### Пример 1: Получение данных
**Старый подход (MVVM):**
```swift
struct ArticlesView: View {
    @StateObject var viewModel = ArticlesViewModel()
    
    var body: some View {
        List(viewModel.articles) { article in
            // ...
        }
        .onAppear {
            viewModel.loadArticles()
        }
    }
}
```

**Новый подход (Modern SwiftUI):**
```swift
struct ArticlesView: View {
    @Query(sort: \Article.id) private var articles: [Article]
    
    var body: some View {
        List(articles) { article in
            // ...
        }
        // Автоматическое обновление данных!
    }
}
```

### Пример 2: Создание данных
**Старый подход:**
```swift
// В ViewModel
func sendMessage(_ text: String) {
    let message = ChatMessage(...)
    modelContext.insert(message)
    try? modelContext.save()
    messages.append(message)
}
```

**Новый подход:**
```swift
// В Model
extension ChatMessage {
    static func createMessage(body: String, isFromUser: Bool, in context: ModelContext) -> ChatMessage {
        let message = ChatMessage(...)
        context.insert(message)
        try? context.save()
        return message
    }
}

// В View
private func sendMessage(_ text: String) {
    _ = ChatMessage.createMessage(body: text, isFromUser: true, in: modelContext)
}
```

---

## 🚀 Преимущества новой архитектуры

### 1. **Меньше кода**
- Удалено ~500 строк ViewModel кода
- Нет необходимости в синхронизации состояний

### 2. **Автоматические обновления UI**
- SwiftData автоматически уведомляет Views об изменениях
- `@Query` обеспечивает реактивность из коробки

### 3. **Лучшая производительность**
- Меньше промежуточных слоев
- Оптимизированные запросы SwiftData

### 4. **Проще тестирование**
- Логика в моделях легче тестируется
- Не нужны моки ViewModels

### 5. **Соответствие Apple HIG**
- Следует последним рекомендациям Apple
- Использует современные API (iOS 17+)

---

## 🔗 Связи между моделями

```
Script 1──────* ScriptStep
  │
  └── используется в ChatView

Ritual 1──────* RitualLine
  │
  └── используется в RitualView

Article
  │
  └── используется в ArticlesView

ChatMessage
  │
  └── используется в ChatView

AppSettings
  │
  └── используется в SettingsView

Statistic
  │
  └── может использоваться для аналитики
```

---

## 📦 SwiftData Schema

Все модели регистрируются в `sleep_courseApp.swift`:

```swift
let schema = Schema([
    ChatMessage.self,
    Ritual.self,
    RitualLine.self,
    Article.self,
    Statistic.self,
    AppSettings.self,
    Script.self,
    ScriptStep.self
])
```

---

## 🎨 UI Паттерны

### Все Views следуют единому стилю:
- **Темная тема**: `Color(red: 20/255, green: 30/255, blue: 54/255)`
- **Акцентный цвет**: `Color(red: 0/255, green: 120/255, blue: 255/255)`
- **Navigation Bar**: Прозрачный с blur эффектом
- **Анимации**: Spring animations для плавности

---

## 🔮 Будущие улучшения

1. **Swift 6 concurrency** - полная поддержка actor модели
2. **Observation framework** - использование новых инструментов iOS 18+
3. **Widgets** - расширение функциональности через виджеты
4. **App Intents** - интеграция с Siri и Shortcuts

---

## 📚 Ресурсы

- [SwiftData Documentation](https://developer.apple.com/documentation/swiftdata)
- [Modern SwiftUI Architecture](https://developer.apple.com/videos/play/wwdc2023/10154/)
- [Observable Macro](https://developer.apple.com/documentation/observation)

---

**Версия архитектуры:** 2.0  
**Дата обновления:** 22.10.2025  
**Минимальная версия iOS:** 17.0+

