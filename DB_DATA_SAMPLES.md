# Примеры данных из PostgreSQL (sleep20)

## Дата извлечения: 21.10.2025

### Articles (статьи)

Извлечено из таблицы `article`:

| ID | Name (ru_RU) | Short Name | Description | Emoji | First Color |
|----|--------------|------------|-------------|-------|-------------|
| 64 | Мелатонин 💊 | Мелатонин | Влияние утяжеленных одеял на качество сна | 💊 | 220, 53, 69 |
| 66 | Физическая активность 🏃 | Физическая активность | Влияние утяжеленных одеял на качество сна | 🏃 | 253, 126, 20 |
| 46 | Ванна 🛁 | Ванна | Как тёплая ванна и душ помогают улучшить сон | 🛁 | 13,202,240 |
| 47 | Свет 💡 | Свет | О важности приглушения света для улучшения качества сна | 💡 | 253,126,20 |
| 53 | Кофе и чай ☕️ | Кофе и чай | Как кофе и чай влияют на здоровье и сон | ☕️ | 160, 82, 45 |

**Наблюдения:**
- Все статьи на русском языке
- Используются эмодзи в названиях
- Цвета в RGB формате (разделены запятыми)
- Описания краткие и понятные

---

### Ritual Lines (элементы ритуалов)

Извлечено из таблицы `ritual_line`:

| ID | Name | Sequence | Is Check |
|----|------|----------|----------|
| 75 | Легкая тренировка 🏃 | 7 | false |
| 54 | Медитация 🧘 | 6 | false |
| 53 | Тёплая ванна 🛁 | 13 | false |
| 84 | Закончить дела ✅ | 15 | false |
| 86 | Тёплая ванна 🛁 | 13 | false |
| 87 | Приглушить свет 💡 | 12 | false |
| 88 | Проветрить комнату 💨 | 11 | false |
| 89 | Скушать киви 🥝 | 10 | false |
| 85 | Надеть носки 🧦 | 14 | false |
| 4 | Проветрить комнату 💨 | 10 | false |

**Наблюдения:**
- Все элементы ритуала используют эмодзи
- Sequence определяет порядок отображения
- Все элементы текущей выборки не отмечены (is_check = false)
- Есть дубликаты (например, "Тёплая ванна" и "Проветрить комнату")

**Типичный вечерний ритуал (по sequence):**
1. Скушать киви 🥝 (seq 10)
2. Проветрить комнату 💨 (seq 11)
3. Приглушить свет 💡 (seq 12)
4. Тёплая ванна 🛁 (seq 13)
5. Надеть носки 🧦 (seq 14)
6. Закончить дела ✅ (seq 15)

---

### Rituals

Извлечено из таблицы `ritual`:

| ID | Name (JSON) |
|----|-------------|
| 3 | {"en_US": "Ritual"} |
| 14 | {"en_US": "Ritual"} |
| 4 | {"en_US": "Ritual"} |

**Наблюдения:**
- Названия хранятся в JSON формате (мультиязычность)
- Стандартное название "Ritual"
- Каждому пользователю принадлежит свой ритуал

---

### Statistics (статистика настроения)

Запрос: `SELECT mood, COUNT(*) FROM statistic GROUP BY mood;`

**Результат:** Пустая таблица (данных нет)

**Возможные причины:**
- Функционал статистики не используется активно
- Данные могут быть удалены
- Меню статистики закомментировано в `statistic_views.xml`

---

## Обновлённые Mock данные для iOS

На основе реальных данных обновляю mock-данные:

### Article.swift (обновление)

```swift
static let mockArticles: [Article] = [
    Article(
        id: 64,
        name: "Мелатонин 💊",
        text: "<h1>Мелатонин</h1><p>Влияние мелатонина на качество сна...</p>",
        shortName: "Мелатонин",
        description: "Влияние утяжеленных одеял на качество сна",
        emoji: "💊",
        firstColor: "220, 53, 69",
        secondColor: nil,
        isAvailable: true
    ),
    Article(
        id: 66,
        name: "Физическая активность 🏃",
        text: "<h1>Физическая активность</h1><p>Как спорт влияет на сон...</p>",
        shortName: "Физическая активность",
        description: "Влияние утяжеленных одеял на качество сна",
        emoji: "🏃",
        firstColor: "253, 126, 20",
        secondColor: nil,
        isAvailable: true
    ),
    Article(
        id: 46,
        name: "Ванна 🛁",
        text: "<h1>Тёплая ванна</h1><p>Как тёплая ванна и душ помогают...</p>",
        shortName: "Ванна",
        description: "Как тёплая ванна и душ помогают улучшить сон",
        emoji: "🛁",
        firstColor: "13, 202, 240",
        secondColor: nil,
        isAvailable: true
    ),
    Article(
        id: 47,
        name: "Свет 💡",
        text: "<h1>Свет и сон</h1><p>О важности приглушения света...</p>",
        shortName: "Свет",
        description: "О важности приглушения света для улучшения качества сна",
        emoji: "💡",
        firstColor: "253, 126, 20",
        secondColor: nil,
        isAvailable: true
    ),
    Article(
        id: 53,
        name: "Кофе и чай ☕️",
        text: "<h1>Кофеин и сон</h1><p>Как кофе и чай влияют на здоровье...</p>",
        shortName: "Кофе и чай",
        description: "Как кофе и чай влияют на здоровье и сон",
        emoji: "☕️",
        firstColor: "160, 82, 45",
        secondColor: nil,
        isAvailable: true
    )
]
```

### Ritual.swift (обновление)

```swift
static let mockRitual = Ritual(
    id: 1,
    name: "Вечерний ритуал",
    lines: [
        RitualLine(id: 89, name: "Скушать киви 🥝", sequence: 10, isCheck: false),
        RitualLine(id: 88, name: "Проветрить комнату 💨", sequence: 11, isCheck: false),
        RitualLine(id: 87, name: "Приглушить свет 💡", sequence: 12, isCheck: false),
        RitualLine(id: 86, name: "Тёплая ванна 🛁", sequence: 13, isCheck: false),
        RitualLine(id: 85, name: "Надеть носки 🧦", sequence: 14, isCheck: false),
        RitualLine(id: 84, name: "Закончить дела ✅", sequence: 15, isCheck: false),
        RitualLine(id: 54, name: "Медитация 🧘", sequence: 6, isCheck: false),
    ],
    userId: 1
)
```

---

## Анализ для UI/UX

### Цветовая палитра (из first_color)

1. **Красно-розовый**: RGB(220, 53, 69) - Мелатонин
2. **Оранжевый**: RGB(253, 126, 20) - Физическая активность, Свет
3. **Голубой**: RGB(13, 202, 240) - Ванна
4. **Коричневый**: RGB(160, 82, 45) - Кофе и чай

**Вывод**: Используется яркая, контрастная палитра для привлечения внимания к карточкам.

### Эмодзи паттерны

- Все элементы UI содержат эмодзи
- Эмодзи интегрированы в название (не отдельное поле)
- Используется для визуальной идентификации без чтения текста

### Локализация

- Основной язык: Русский (ru_RU)
- Также поддерживается English (en_US)
- Данные хранятся в JSON формате: `{"en_US": "...", "ru_RU": "..."}`

---

## SQL Queries для дальнейшей работы

### Полная структура Article

```sql
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'article'
ORDER BY ordinal_position;
```

### Связь Ritual ↔ Ritual Lines

```sql
SELECT r.id as ritual_id, r.name, rl.id as line_id, rl.name as line_name, rl.sequence
FROM ritual r
JOIN ritual_ritual_line_rel rel ON r.id = rel.ritual_id
JOIN ritual_line rl ON rel.ritual_line_id = rl.id
WHERE r.id = 3
ORDER BY rl.sequence;
```

### Пользовательские данные

```sql
SELECT id, login, name, lang, tz, time
FROM res_users
WHERE active = true
LIMIT 5;
```

---

**Следующие шаги:**
1. ✅ Обновить mock данные в iOS на реальные
2. ⏳ Получить скриншоты веб-версии
3. ⏳ Сравнить с iOS скриншотами


