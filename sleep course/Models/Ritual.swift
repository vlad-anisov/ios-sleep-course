import Foundation
import SwiftData

@Model
final class Ritual {
    @Attribute(.unique) var id: Int
    var name: String
    var userId: Int
    
    @Relationship(deleteRule: .cascade, inverse: \RitualLine.ritual)
    var lines: [RitualLine] = []
    
    init(id: Int, name: String, userId: Int) {
        self.id = id
        self.name = name
        self.userId = userId
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
    
    init(id: Int, name: String, sequence: Int, isCheck: Bool, isBase: Bool = false, isActive: Bool = true, ritual: Ritual? = nil) {
        self.id = id
        self.name = name
        self.sequence = sequence
        self.isCheck = isCheck
        self.isBase = isBase
        self.isActive = isActive
        self.ritual = ritual
    }
}

// Mock data for development (based on real PostgreSQL data)
extension Ritual {
    static func createMockRitual() -> Ritual {
        let ritual = Ritual(id: 1, name: "Вечерний ритуал", userId: 1)
        let lines = [
            RitualLine(id: 54, name: "Медитация 🧘", sequence: 6, isCheck: false, isBase: true, isActive: true, ritual: ritual),
            RitualLine(id: 89, name: "Скушать киви 🥝", sequence: 10, isCheck: false, isBase: true, isActive: true, ritual: ritual),
            RitualLine(id: 88, name: "Проветрить комнату 💨", sequence: 11, isCheck: false, isBase: true, isActive: true, ritual: ritual),
            RitualLine(id: 87, name: "Приглушить свет 💡", sequence: 12, isCheck: false, isBase: true, isActive: true, ritual: ritual),
            RitualLine(id: 86, name: "Тёплая ванна 🛁", sequence: 13, isCheck: false, isBase: true, isActive: true, ritual: ritual),
            RitualLine(id: 85, name: "Надеть носки 🧦", sequence: 14, isCheck: false, isBase: true, isActive: true, ritual: ritual),
            RitualLine(id: 84, name: "Закончить дела ✅", sequence: 15, isCheck: false, isBase: true, isActive: true, ritual: ritual),
        ]
        ritual.lines = lines
        return ritual
    }
}

