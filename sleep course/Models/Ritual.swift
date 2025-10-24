import Foundation
import SwiftData

@Model
final class Ritual {
    @Attribute(.unique) var id: Int
    var name: String
    var userId: Int
    var sequence: Int
    
    @Relationship(deleteRule: .cascade, inverse: \RitualLine.ritual)
    var lines: [RitualLine] = []
    
    init(id: Int, name: String, userId: Int, sequence: Int = 0) {
        self.id = id
        self.name = name
        self.userId = userId
        self.sequence = sequence
    }
    
    // Computed property
    var isCheck: Bool {
        !lines.isEmpty && lines.allSatisfy { $0.isCheck }
    }
    
    // Активные (видимые) линии
    var activeLines: [RitualLine] {
        lines.filter { $0.isActive }.sorted { $0.sequence < $1.sequence }
    }
    
    // Неактивные базовые линии (для восстановления)
    var inactiveBaseLines: [RitualLine] {
        lines.filter { !$0.isActive && $0.isBase }.sorted { $0.sequence < $1.sequence }
    }
}

@Model
final class RitualLine {
    @Attribute(.unique) var id: Int
    var name: String
    var sequence: Int
    var isCheck: Bool
    var isBase: Bool
    var isActive: Bool // true = показывается, false = удалена (скрыта)
    
    var ritual: Ritual?
    
    // Полный инициализатор (для миграции данных из БД)
    init(id: Int, name: String, sequence: Int, isCheck: Bool, isBase: Bool = false, isActive: Bool = true, ritual: Ritual? = nil) {
        self.id = id
        self.name = name
        self.sequence = sequence
        self.isCheck = isCheck
        self.isBase = isBase
        self.isActive = isActive
        self.ritual = ritual
    }
    
    // Упрощенный инициализатор (для создания новых линий) - ID генерируется автоматически
    convenience init(name: String, ritual: Ritual? = nil) {
        self.init(
            id: Int(Date().timeIntervalSince1970 * 1000), // Уникальный ID на основе timestamp
            name: name,
            sequence: 0,
            isCheck: false,
            isBase: false,
            isActive: true,
            ritual: ritual
        )
    }
}

// Mock data for development (based on real PostgreSQL data)
extension Ritual {
    static func createMockRitual() -> Ritual {
        let ritual = Ritual(id: 1, name: "Вечерний ритуал", userId: 1, sequence: 0)
        let lines = [
            RitualLine(id: 54, name: "Медитация 🧘", sequence: 0, isCheck: false, isBase: true, isActive: true, ritual: ritual),
            RitualLine(id: 89, name: "Скушать киви 🥝", sequence: 1, isCheck: false, isBase: true, isActive: true, ritual: ritual),
            RitualLine(id: 88, name: "Проветрить комнату 💨", sequence: 2, isCheck: false, isBase: true, isActive: true, ritual: ritual),
            RitualLine(id: 87, name: "Приглушить свет 💡", sequence: 3, isCheck: false, isBase: true, isActive: true, ritual: ritual),
            RitualLine(id: 86, name: "Тёплая ванна 🛁", sequence: 4, isCheck: false, isBase: true, isActive: true, ritual: ritual),
            RitualLine(id: 85, name: "Надеть носки 🧦", sequence: 5, isCheck: false, isBase: true, isActive: true, ritual: ritual),
            RitualLine(id: 84, name: "Закончить дела ✅", sequence: 6, isCheck: false, isBase: true, isActive: true, ritual: ritual),
        ]
        ritual.lines = lines
        return ritual
    }
}

