# Инструкция по добавлению библиотеки Exyte/Chat

## Шаг 1: Добавление пакета в Xcode

1. Откройте проект `sleep course.xcodeproj` в Xcode
2. В меню выберите `File` → `Add Package Dependencies...`
3. В поле поиска вставьте URL: `https://github.com/exyte/Chat.git`
4. Нажмите `Add Package`
5. Убедитесь, что пакет `ExyteChat` добавлен к цели `sleep course`

## Шаг 2: Проверка установки

После добавления пакета в вашем проекте должна появиться возможность импортировать:

```swift
import ExyteChat
```

## Шаг 3: Сборка проекта

Выполните чистую сборку проекта:
- `Product` → `Clean Build Folder` (⇧⌘K)
- `Product` → `Build` (⌘B)

## Альтернативный способ (через Package.swift)

Если вы хотите использовать Package.swift, добавьте зависимость:

```swift
dependencies: [
    .package(url: "https://github.com/exyte/Chat.git", from: "1.0.0")
]
```

## Что было изменено в проекте

1. Создан файл `ChatMessageAdapter.swift` - адаптер для интеграции ChatMessage с ExyteChat
2. Переписан `ChatView.swift` с использованием библиотеки Exyte/Chat
3. Сохранена вся существующая логика работы со скриптами и состоянием

## Возможные проблемы

Если возникнут ошибки компиляции:
- Убедитесь, что пакет правильно добавлен
- Проверьте, что import ExyteChat присутствует в файлах
- Выполните чистую сборку проекта

