import Foundation
import SwiftUI
import SwiftData

@Model
final class Article {
    @Attribute(.unique) var id: Int
    var name: String
    var text: String // HTML content
    var shortName: String?
    var articleDescription: String? // renamed from 'description' to avoid conflicts
    var emoji: String?
    var firstColor: String // RGB "255,120,0"
    var secondColor: String?
    var imageData: Data?
    var isAvailable: Bool
    
    init(id: Int, name: String, text: String, shortName: String? = nil, 
         articleDescription: String? = nil, emoji: String? = nil, 
         firstColor: String, secondColor: String? = nil, 
         imageData: Data? = nil, isAvailable: Bool = true) {
        self.id = id
        self.name = name
        self.text = text
        self.shortName = shortName
        self.articleDescription = articleDescription
        self.emoji = emoji
        self.firstColor = firstColor
        self.secondColor = secondColor
        self.imageData = imageData
        self.isAvailable = isAvailable
    }
    
    // Computed property для цвета градиента
    var gradientColors: [Color] {
        let first = parseColor(firstColor)
        let second = secondColor.flatMap { parseColor($0) } ?? first.opacity(0.3)
        return [first, second]
    }
    
    private func parseColor(_ colorString: String) -> Color {
        let components = colorString.split(separator: ",").compactMap { Double($0.trimmingCharacters(in: .whitespaces)) }
        guard components.count >= 3 else { return Color(red: 0/255, green: 120/255, blue: 255/255) }
        return Color(
            red: components[0] / 255.0,
            green: components[1] / 255.0,
            blue: components[2] / 255.0,
            opacity: components.count > 3 ? components[3] : 1.0
        )
    }
}

// Mock data for development (ALL 15 articles available to admin from PostgreSQL)
extension Article {
    static let mockArticles: [Article] = [
        Article(
            id: 41,
            name: "Старт 🚀",
            text: "<h1>Старт 🚀</h1><p>Как наладить режим сна и создать вечерний ритуал</p>",
            shortName: "Старт",
            articleDescription: "Как наладить режим сна и создать вечерний ритуал",
            emoji: "🚀",
            firstColor: "0,123,255",
            secondColor: nil,
            isAvailable: true
        ),
        Article(
            id: 42,
            name: "Температура 🌡️",
            text: "<h1>Температура 🌡️</h1><p>Польза носков и комфортной температуры для сна</p>",
            shortName: "Температура",
            articleDescription: "Польза носков и комфортной температуры для сна",
            emoji: "🌡️",
            firstColor: "255,193,7",
            secondColor: nil,
            isAvailable: true
        ),
        Article(
            id: 46,
            name: "Ванна 🛁",
            text: "<h1>Тёплая ванна перед сном</h1><p>Как тёплая ванна и душ помогают подготовить тело ко сну...</p>",
            shortName: "Ванна",
            articleDescription: "Как тёплая ванна и душ помогают улучшить сон",
            emoji: "🛁",
            firstColor: "13,202,240",
            secondColor: nil,
            isAvailable: true
        ),
        Article(
            id: 47,
            name: "Свет 💡",
            text: "<h1>Свет и циркадные ритмы</h1><p>О важности приглушения света для улучшения качества сна...</p>",
            shortName: "Свет",
            articleDescription: "О важности приглушения света для улучшения качества сна",
            emoji: "💡",
            firstColor: "253,126,20",
            secondColor: nil,
            isAvailable: true
        ),
        Article(
            id: 48,
            name: "Подготовка к сну 🛏️",
            text: "<h1>Подготовка комнаты к сну</h1><p>Влияние растений, температуры и качества воздуха на сон</p>",
            shortName: "Подготовка к сну",
            articleDescription: "Влияние растений, температуры и качества воздуха на сон",
            emoji: "🛏️",
            firstColor: "111,66,193",
            secondColor: nil,
            isAvailable: true
        ),
        Article(
            id: 50,
            name: "Питание 🍽",
            text: "<h1>Питание и сон</h1><p>О влиянии питания на сон и продуктах для его улучшения</p>",
            shortName: "Питание",
            articleDescription: "О влиянии питания на сон и продуктах для его улучшения",
            emoji: "🍽",
            firstColor: "40,167,69",
            secondColor: nil,
            isAvailable: true
        ),
        Article(
            id: 51,
            name: "Вредные привычки 🥃",
            text: "<h1>Вредные привычки</h1><p>Про вредные привычки и их воздействие на сон</p>",
            shortName: "Вредные привычки",
            articleDescription: "Про вредные привычки и их воздействие на сон",
            emoji: "🥃",
            firstColor: "220,53,69",
            secondColor: nil,
            isAvailable: true
        ),
        Article(
            id: 53,
            name: "Кофе и чай ☕️",
            text: "<h1>Кофеин и его влияние на сон</h1><p>Как кофе и чай влияют на здоровье и качество сна...</p>",
            shortName: "Кофе и чай",
            articleDescription: "Как кофе и чай влияют на здоровье и сон",
            emoji: "☕️",
            firstColor: "160,82,45",
            secondColor: nil,
            isAvailable: true
        ),
        Article(
            id: 55,
            name: "Основы КПТ ✨",
            text: "<h1>Основы КПТ</h1><p>Польза КПТ на качество сна и скорость засыпания</p>",
            shortName: "Основы КПТ",
            articleDescription: "Польза КПТ на качество сна и скорость засыпания",
            emoji: "✨",
            firstColor: "0,123,255",
            secondColor: nil,
            isAvailable: true
        ),
        Article(
            id: 58,
            name: "Утяжеленные одеяла 😊",
            text: "<h1>Утяжеленные одеяла</h1><p>Влияние утяжеленных одеял на качество сна</p>",
            shortName: "Утяжеленные одеяла",
            articleDescription: "Влияние утяжеленных одеял на качество сна",
            emoji: "😊",
            firstColor: "230,210,181",
            secondColor: nil,
            isAvailable: true
        ),
        Article(
            id: 59,
            name: "Лаванда 🪻",
            text: "<h1>Лаванда</h1><p>Как лаванда и медитация снижают пульс и улучшают сон</p>",
            shortName: "Лаванда",
            articleDescription: "Как лаванда и медитация снижают пульс и улучшают сон",
            emoji: "🪻",
            firstColor: "102,16,242",
            secondColor: nil,
            isAvailable: true
        ),
        Article(
            id: 61,
            name: "Чтение 📖",
            text: "<h1>Чтение перед сном</h1><p>Влияние чтения перед сном на уровень стресса</p>",
            shortName: "Чтение",
            articleDescription: "Влияние чтения перед сном на уровень стресса",
            emoji: "📖",
            firstColor: "13,202,240",
            secondColor: nil,
            isAvailable: true
        ),
        Article(
            id: 62,
            name: "Темнота 🌙",
            text: "<h1>Темнота и сон</h1><p>Польза темноты на уровень мелатонина и улучшение сна</p>",
            shortName: "Темнота",
            articleDescription: "Польза темноты на уровень мелатонина и улучшение сна",
            emoji: "🌙",
            firstColor: "73,80,87",
            secondColor: nil,
            isAvailable: true
        ),
        Article(
            id: 64,
            name: "Мелатонин 💊",
            text: "<h1>Мелатонин</h1><p>Мелатонин — это гормон, который регулирует циркадные ритмы и помогает улучшить качество сна...</p>",
            shortName: "Мелатонин",
            articleDescription: "Влияние утяжеленных одеял на качество сна",
            emoji: "💊",
            firstColor: "220,53,69",
            secondColor: nil,
            isAvailable: true
        ),
        Article(
            id: 66,
            name: "Физическая активность 🏃",
            text: "<h1>Физическая активность и сон</h1><p>Регулярные тренировки положительно влияют на качество сна...</p>",
            shortName: "Физическая активность",
            articleDescription: "Влияние утяжеленных одеял на качество сна",
            emoji: "🏃",
            firstColor: "253,126,20",
            secondColor: nil,
            isAvailable: true
        )
    ]
}

