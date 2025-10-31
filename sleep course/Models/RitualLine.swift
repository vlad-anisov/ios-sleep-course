import Foundation
import SwiftData

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

    // Упрощенный инициализатор (для создания новых линий)
    convenience init(name: String, ritual: Ritual? = nil) {
        self.init(
            id: Int(Date().timeIntervalSince1970 * 1000),
            name: name,
            sequence: 0,
            isCheck: false,
            isBase: false,
            isActive: true,
            ritual: ritual
        )
    }

    func toggleCheck() {
        isCheck.toggle()
    }
}

