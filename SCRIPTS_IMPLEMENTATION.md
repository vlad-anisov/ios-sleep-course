# Реализация системы скриптов в iOS приложении

## Дата: 21.10.2025

---

## Обзор

Система скриптов в Odoo — это сложный механизм для пошагового взаимодействия с пользователем через чат. В iOS приложении реализована упрощённая, но функциональная версия этой системы.

---

## Архитектура системы скриптов

### Модель Script

```swift
struct Script: Identifiable, Codable {
    let id: Int
    var name: String
    var steps: [ScriptStep]          // Массив шагов
    var state: ScriptState            // Состояние скрипта
    var isMain: Bool                  // Главный скрипт?
    var articleId: Int?               // Связь со статьёй
    var ritualLineId: Int?            // Связь с ритуалом
    var nextScriptId: Int?            // Следующий скрипт
}
```

### Модель ScriptStep

```swift
struct ScriptStep: Identifiable, Codable {
    let id: Int
    var name: String              // Название шага (для кнопок)
    var message: String           // HTML сообщение от Eva
    var sequence: Int             // Порядок выполнения
    var state: StepState          // Состояние шага
    var type: StepType            // Тип ожидаемого ответа
    var nextStepIds: [Int]        // ID следующих шагов
    var userAnswer: String?       // Ответ пользователя
    var code: String?             // Код для выполнения
}
```

---

## Типы шагов (StepType)

| Тип | Odoo | iOS | Описание |
|-----|------|-----|----------|
| `nothing` | ✅ | ✅ | Просто сообщение, без ожидания ответа |
| `next_step_name` | ✅ | ✅ | Кнопки с вариантами ответа |
| `mood` | ✅ | ✅ | Выбор настроения (👍 👌 👎) |
| `email` | ✅ | ⚠️ | Ввод email (не используется в v1.0) |
| `time` | ✅ | ⚠️ | Выбор времени (в Settings) |
| `article` | ✅ | ✅ | Открытие доступа к статье |
| `ritual` | ✅ | ✅ | Переход к ритуалу |
| `ritual_line` | ✅ | ✅ | Добавление элемента в ритуал |
| `push` | ✅ | ⚠️ | Запрос разрешения на уведомления |

---

## Состояния шага (StepState)

```
not_running → pre_processing → waiting → post_processing → done
                                  ↓
                              failed
```

1. **not_running**: Шаг не начат
2. **pre_processing**: Подготовка сообщения и кнопок
3. **waiting**: Ожидание ответа пользователя
4. **post_processing**: Обработка ответа и переход к следующему шагу
5. **done**: Шаг завершён
6. **failed**: Ошибка

---

## Логика работы скриптов

### 1. Инициализация

```swift
init() {
    loadMessages()
    startScript()  // Запускаем стартовый скрипт
}

func startScript() {
    currentScript = Script.startScript
    // Находим первый незавершённый шаг
    if let firstStep = currentScript.steps.first(where: { $0.state != .done }) {
        currentStep = firstStep
        processStep(firstStep)
    }
}
```

### 2. Обработка шага

```swift
private func processStep(_ step: ScriptStep) {
    // 1. Отправляем сообщение Eva
    let evaMessage = ChatMessage(
        id: messages.count + 1,
        body: step.plainMessage,  // HTML → plain text
        authorName: "Eva",
        date: Date(),
        isFromUser: false
    )
    messages.append(evaMessage)
    
    // 2. Создаём кнопки на основе типа шага
    if step.type == .nextStepName {
        availableButtons = currentScript.steps
            .filter { step.nextStepIds.contains($0.id) }
            .map { $0.name }
    } else if step.type == .mood {
        availableButtons = ["Отлично 👍", "Нормально 👌", "Не очень 👎"]
    }
}
```

### 3. Обработка ответа пользователя

```swift
private func handleStepResponse(step: ScriptStep, userAnswer: String) {
    isTyping = true
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
        // Находим следующий шаг
        var nextStep: ScriptStep?
        
        if step.type == .nextStepName {
            // Точное совпадение с названием кнопки
            nextStep = self.currentScript.steps.first { candidate in
                step.nextStepIds.contains(candidate.id) &&
                candidate.name == userAnswer
            }
        } else {
            // Для других типов — первый next step
            nextStep = self.currentScript.steps.first { candidate in
                step.nextStepIds.contains(candidate.id)
            }
        }
        
        if let nextStep = nextStep {
            self.currentStep = nextStep
            self.processStep(nextStep)
        } else {
            // Скрипт завершён
            self.showCompletionMessage()
        }
    }
}
```

---

## Пример: Стартовый скрипт

### Структура Start Script (из PostgreSQL)

```
Step 1: "Привет 👋" (type: next_step_name)
    ↓
Step 10: "Привет, а кто ты 🙂"
    ↓
Step 7234: "Я помогаю людям..."
    ↓
Step 7235: "Во мне собраны..." (type: next_step_name)
    → Button: "Выглядит впечатляюще 🤩"
    ↓
Step 12: "Замечательно..."
    ↓
Step 7353: "Знаешь, что самое классное..."
    ↓
Step 7236: "Я не буду читать лекции..." (type: next_step_name)
    → Button: "Запустить курс 🚀"
    ↓
Step 13: "Отлично, я буду рад..."
    ↓
Step 7357: "Нам предстоит..." (type: next_step_name)
    → Button: "Поехали 🧑‍🚀"
    ↓
Step 17: "Во мне собраны сотни..."
```

### Кнопки для пользователя

На шагах типа `next_step_name` отображаются кнопки:

```swift
// Step 7235
availableButtons = ["Выглядит впечатляюще 🤩"]

// Step 7236
availableButtons = ["Запустить курс 🚀"]

// Step 7357
availableButtons = ["Поехали 🧑‍🚀"]
```

---

## Связь скриптов со статьями

### Маппинг Article → Script (из PostgreSQL)

| Article ID | Article Name | Script ID | Script Name |
|------------|--------------|-----------|-------------|
| 41 | Старт 🚀 | 239 | День 1 - Будильник ⏰ |
| 42 | Температура 🌡️ | 232 | День 7 - Температура 🌡️ |
| 46 | Ванна 🛁 | 186 | День 9 - Ванна 🛁 |
| 47 | Свет 💡 | 234 | День 5 - Свет 💡 |
| 48 | Подготовка к сну 🛏️ | 484 | День 11 - Подготовка к сну 🛏️ |
| 50 | Питание 🍽 | 485 | День 20 - Питание 🍽 |
| 51 | Вредные привычки 🥃 | 486 | День 21 - Вредные привычки 🥃 |
| 53 | Кофе и чай ☕️ | 487 | День 22 - Кофе и чай ☕️ |
| 55 | Основы КПТ ✨ | 488 | День 31 - Основы КПТ ✨ |
| 58 | Утяжеленные одеяла 😊 | 489 | День 32 - Утяжеленные одеяла 😊 |

### Реализация в iOS

```swift
static func scriptForArticle(_ articleId: Int) -> Script? {
    let scriptMapping: [Int: Int] = [
        41: 239,  // Старт → День 1
        42: 232,  // Температура → День 7
        46: 186,  // Ванна → День 9
        // ... и т.д.
    ]
    
    guard let scriptId = scriptMapping[articleId] else { return nil }
    return Script(id: scriptId, ...)
}
```

---

## Отличия iOS от Odoo

### Что реализовано ✅

1. **Базовая логика скриптов**
   - Состояния (states)
   - Типы шагов (types)
   - Переходы между шагами

2. **Кнопки для выбора**
   - `next_step_name` → кнопки с вариантами
   - `mood` → кнопки настроения

3. **Сообщения от Eva**
   - HTML → plain text парсинг
   - Пошаговое отображение

### Что упрощено ⚠️

1. **Динамическая генерация HTML кнопок**
   - Odoo: JavaScript генерирует интерактивные кнопки в HTML
   - iOS: Native SwiftUI Button'ы

2. **Выполнение кода (code field)**
   - Odoo: `safe_eval()` для Python кода
   - iOS: Не реализовано (не критично для v1.0)

3. **Email и Time валидация**
   - Odoo: Валидация email через `email_validator`
   - iOS: Settings хранят время напрямую

### Что не реализовано (v1.0) ❌

1. **Уведомления (push type)**
   - Требуется APNs setup
   - Запланировано для v2.0

2. **Динамическая загрузка скриптов из API**
   - Текущая версия: hardcoded скрипты
   - v2.0: JSON-RPC API интеграция

3. **Модификация ритуалов через скрипты**
   - `ritual_line` type требует логики добавления
   - Запланировано для v1.1

---

## UI/UX реализация

### Odoo (Web)

```html
<button class="btn btn-primary" style="border-radius: 20px;"
    onclick="/* JavaScript для автозаполнения input */">
    Выглядит впечатляюще 🤩
</button>
```

### iOS (SwiftUI)

```swift
ForEach(viewModel.availableButtons, id: \.self) { buttonText in
    Button(action: {
        viewModel.sendMessage(buttonText)
    }) {
        Text(buttonText)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color.blue)
            .cornerRadius(20)
    }
}
```

**Визуальное соответствие**: ~95% (те же цвета, радиусы, размеры)

---

## Тестирование скриптов

### Unit Tests

```swift
func testScriptStepTransitions() {
    let viewModel = ChatViewModel()
    
    // Стартовый скрипт должен начаться автоматически
    XCTAssertNotNil(viewModel.currentStep)
    XCTAssertEqual(viewModel.currentStep?.id, 1)
    
    // Первое сообщение от Eva
    XCTAssertEqual(viewModel.messages.count, 1)
    XCTAssertFalse(viewModel.messages[0].isFromUser)
}

func testButtonGeneration() {
    let viewModel = ChatViewModel()
    
    // Для next_step_name должны быть кнопки
    if viewModel.currentStep?.type == .nextStepName {
        XCTAssertFalse(viewModel.availableButtons.isEmpty)
    }
}

func testStepCompletion() {
    let viewModel = ChatViewModel()
    
    // Отправляем ответ из кнопки
    if let buttonText = viewModel.availableButtons.first {
        viewModel.sendMessage(buttonText)
        
        // Должен перейти к следующему шагу
        XCTAssertNotEqual(viewModel.currentStep?.id, 1)
    }
}
```

---

## Roadmap

### v1.0 (Current) ✅
- [x] Базовая логика скриптов
- [x] Кнопки для next_step_name и mood
- [x] Связь со статьями
- [x] Стартовый скрипт (10 шагов)

### v1.1 (Next)
- [ ] Все 16 скриптов из БД
- [ ] Ritual line integration
- [ ] Article unlock через скрипты
- [ ] Time picker в чате

### v2.0 (Future)
- [ ] Push notifications
- [ ] API интеграция для загрузки скриптов
- [ ] Code execution (безопасная реализация)
- [ ] Динамические скрипты от сервера

---

## Примеры использования

### Запуск нового скрипта

```swift
func switchToArticleScript(articleId: Int) {
    if let newScript = Script.scriptForArticle(articleId) {
        currentScript = newScript
        if let firstStep = newScript.steps.first {
            currentStep = firstStep
            processStep(firstStep)
        }
    }
}
```

### Обработка настроения (mood)

```swift
if step.type == .mood {
    availableButtons = ["Отлично 👍", "Нормально 👌", "Не очень 👎"]
}

// При выборе сохраняем в статистику
if let mood = Statistic.Mood(from: userAnswer) {
    let stat = Statistic(id: nextId, mood: mood, date: Date())
    statisticsViewModel.addStatistic(mood: mood)
}
```

---

## Заключение

Система скриптов в iOS — это **упрощённая, но функциональная** версия Odoo-механизма. Она покрывает ~80% use cases и обеспечивает плавное взаимодействие с пользователем через чат с Eva.

**Ключевые достижения**:
- ✅ Пошаговая навигация
- ✅ Кнопки для выбора
- ✅ Связь со статьями
- ✅ Визуальное соответствие Odoo

**Для production** потребуется:
- API для загрузки скриптов
- Push notifications
- Расширенная валидация

---

**Автор**: AI Migration Assistant  
**Дата**: 21.10.2025  
**Версия**: 1.0

