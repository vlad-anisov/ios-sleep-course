# 🏗️ Архитектура интеграции Exyte/Chat

## 📊 Визуальная схема

```
┌─────────────────────────────────────────────────────────┐
│                    ChatView.swift                       │
│                                                         │
│  ┌────────────────────────────────────────────────┐    │
│  │          NavigationStack                       │    │
│  │  ┌──────────────────────────────────────────┐  │    │
│  │  │         ZStack (alignment: .bottom)      │  │    │
│  │  │                                          │  │    │
│  │  │  ╔═══════════════════════════════════╗  │  │    │
│  │  │  ║   ExyteChat.ChatView              ║  │  │    │
│  │  │  ║                                   ║  │  │    │
│  │  │  ║  • Список сообщений               ║  │  │    │
│  │  │  ║  • Поле ввода                     ║  │  │    │
│  │  │  ║  • Кнопка отправки                ║  │  │    │
│  │  │  ║  • Автоскролл                     ║  │  │    │
│  │  │  ║  • Анимации                       ║  │  │    │
│  │  │  ╚═══════════════════════════════════╝  │  │    │
│  │  │                                          │  │    │
│  │  │  ┌────────────────────────────────────┐ │  │    │
│  │  │  │    Overlay VStack                  │ │  │    │
│  │  │  │  ┌──────────────────────────────┐  │ │  │    │
│  │  │  │  │  if isTyping:                │  │ │  │    │
│  │  │  │  │    TypingDots() ●●●          │  │ │  │    │
│  │  │  │  └──────────────────────────────┘  │ │  │    │
│  │  │  │  ┌──────────────────────────────┐  │ │  │    │
│  │  │  │  │  if !buttons.isEmpty:        │  │ │  │    │
│  │  │  │  │    [Кнопка 1]                │  │ │  │    │
│  │  │  │  │    [Кнопка 2]                │  │ │  │    │
│  │  │  │  │    [Кнопка 3]                │  │ │  │    │
│  │  │  │  └──────────────────────────────┘  │ │  │    │
│  │  │  └────────────────────────────────────┘ │  │    │
│  │  └──────────────────────────────────────────┘  │    │
│  └────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────┘
         │
         │ конвертация через
         │
         ▼
┌─────────────────────────────────────────────────────────┐
│            ChatMessageAdapter.swift                     │
│                                                         │
│  toExyteChatMessage()                                   │
│  ├─ ChatMessage → ExyteChat.Message                     │
│  └─ Маппинг полей:                                      │
│     • id → String(id)                                   │
│     • body → text                                       │
│     • isFromUser → user.isCurrentUser                   │
│     • date → createdAt                                  │
│                                                         │
│  fromDraft()                                            │
│  ├─ ExyteChat.DraftMessage → ChatMessage                │
│  └─ Создание нового сообщения                           │
│                                                         │
│  toExyteChatMessages()                                  │
│  └─ [ChatMessage] → [ExyteChat.Message]                 │
└─────────────────────────────────────────────────────────┘
         │
         │ работа с данными
         │
         ▼
┌─────────────────────────────────────────────────────────┐
│              ChatMessage.swift                          │
│                   (@Model SwiftData)                    │
│                                                         │
│  Properties:                                            │
│  • id: Int                                              │
│  • body: String                                         │
│  • authorName: String                                   │
│  • date: Date                                           │
│  • isFromUser: Bool                                     │
│                                                         │
│  Methods:                                               │
│  • createMessage(body:isFromUser:in:)                   │
│  • generateEvaResponse(for:)                            │
└─────────────────────────────────────────────────────────┘
         │
         │ связь с логикой
         │
         ▼
┌─────────────────────────────────────────────────────────┐
│               Script.swift & ScriptStep.swift           │
│                   (@Model SwiftData)                    │
│                                                         │
│  Script:                                                │
│  • steps: [ScriptStep]                                  │
│  • state: ScriptState                                   │
│  • isMain: Bool                                         │
│                                                         │
│  ScriptStep:                                            │
│  • name, message, sequence                              │
│  • type: StepType (nextStepName, mood, etc.)            │
│  • nextStepIds: [Int]                                   │
└─────────────────────────────────────────────────────────┘
```

## 🔄 Поток данных

### 1️⃣ Отображение сообщений

```
SwiftData Store
     │
     ├─ @Query → messages: [ChatMessage]
     │
     ├─ .toExyteChatMessages()
     │
     ├─ exyteChatMessages: [ExyteChat.Message]
     │
     └─ ExyteChat.ChatView(messages: exyteChatMessages)
            │
            └─ Отображение в UI
```

### 2️⃣ Отправка сообщения

```
User Input
     │
     ├─ ExyteChat.ChatView { draft in ... }
     │
     ├─ handleUserMessage(draft.text)
     │
     ├─ ChatMessage.createMessage(body: text, ...)
     │
     ├─ context.insert(message)
     │
     ├─ context.save()
     │
     └─ @Query автоматически обновляет UI
```

### 3️⃣ Логика скриптов

```
initScript()
     │
     ├─ Проверка активного Script
     │
     ├─ Поиск текущего ScriptStep
     │
     ├─ showStep(step)
     │     │
     │     ├─ isTyping = true
     │     ├─ Задержка 3 сек
     │     ├─ Создание сообщения
     │     └─ Определение кнопок
     │
     ├─ handleUserMessage(text)
     │     │
     │     ├─ Сохранение ответа
     │     └─ moveToNext(from: step)
     │
     └─ Продолжение диалога
```

## 🎨 Тема и стилизация

### Цветовая схема

```swift
ChatTheme(
    colors: .init(
        mainBackground: Color("BackgroundColor"),      // Фон приложения
        myMessageBackground: Color.blue,               // Сообщения пользователя
        friendMessageBackground: Color("MessageColor"),// Сообщения Евы
        sendButtonBackground: Color.blue,              // Кнопка отправки
        textColor: .primary                            // Цвет текста
    )
)
```

### Компоненты UI

```
┌─────────────────────────────────┐
│         Toolbar                 │
│  ┌──┐                           │
│  │ E│  Ева            [Сброс]   │
│  └──┘                           │
├─────────────────────────────────┤
│                                 │
│  ┌─────────────────┐            │
│  │ Сообщение Евы   │            │
│  └─────────────────┘            │
│                                 │
│            ┌────────────────┐   │
│            │ Мое сообщение  │   │
│            └────────────────┘   │
│                                 │
│  ●●● (печатает...)              │
│                                 │
│  ┌─────────────────────────┐   │
│  │     [Кнопка выбора 1]   │   │
│  │     [Кнопка выбора 2]   │   │
│  └─────────────────────────┘   │
├─────────────────────────────────┤
│  [Поле ввода...]       [Send]  │
└─────────────────────────────────┘
```

## 📦 Зависимости

```
sleep course (iOS App)
    │
    ├── SwiftUI
    ├── SwiftData
    └── ExyteChat (SPM)
            │
            ├── Chat UI Components
            ├── Input View
            ├── Message Cells
            ├── Media Picker
            └── Themes & Styling
```

## 🔧 Настройки и модификаторы

```swift
ExyteChat.ChatView(...)
    .setAvailableInput(.textOnly)        // Только текст
    .chatTheme(customTheme)              // Кастомная тема
    .enableLoadMore(offset: 10) { ... }  // Пагинация
```

## 🎯 Ключевые преимущества архитектуры

1. **Разделение ответственности:**
   - ExyteChat → UI и взаимодействие
   - ChatMessageAdapter → Конвертация данных
   - ChatMessage → Модель данных
   - Script/ScriptStep → Бизнес-логика

2. **Гибкость:**
   - Легко заменить UI библиотеку
   - Легко изменить модель данных
   - Легко добавить новые функции

3. **Поддерживаемость:**
   - Чистый код
   - Четкие границы между компонентами
   - Простое тестирование

4. **Расширяемость:**
   - Готово к медиа-вложениям
   - Готово к голосовым сообщениям
   - Готово к свайп-действиям

## 🚀 Будущие возможности

- [ ] Медиа-вложения (фото, видео)
- [ ] Голосовые сообщения
- [ ] Ответы на сообщения (reply)
- [ ] Редактирование сообщений
- [ ] Удаление сообщений (swipe actions)
- [ ] Поиск по истории
- [ ] Экспорт переписки
- [ ] Push-уведомления

---

**Архитектура:** Clean Architecture + MVVM  
**Паттерны:** Adapter, Observer (SwiftData), Dependency Injection  
**Дата:** 28 октября 2025

