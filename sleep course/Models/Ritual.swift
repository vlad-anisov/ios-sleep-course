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
    
    // Вычисляемые свойства
    var isCheck: Bool {
        !lines.isEmpty && lines.allSatisfy { $0.isCheck }
    }
    
    var activeLines: [RitualLine] {
        lines.filter { $0.isActive }.sorted { $0.sequence < $1.sequence }
    }
    
    var inactiveBaseLines: [RitualLine] {
        lines.filter { !$0.isActive && $0.isBase }.sorted { $0.sequence < $1.sequence }
    }
    
    private var nextSequenceIndex: Int {
        (lines.map { $0.sequence }.max() ?? -1) + 1
    }
    
    // Управление линиями
    func toggleCheck(for line: RitualLine) {
        guard lines.contains(where: { $0.id == line.id }) else { return }
        line.toggleCheck()
    }
    
    func moveLines(fromOffsets: IndexSet, toOffset: Int) {
        var ordered = activeLines
        let sortedOffsets = fromOffsets.sorted(by: >)
        let movingLines = sortedOffsets.map { ordered.remove(at: $0) }.reversed()
        let targetIndex = max(0, min(toOffset - fromOffsets.filter { $0 < toOffset }.count, ordered.count))
        ordered.insert(contentsOf: movingLines, at: targetIndex)
        ordered.enumerated().forEach { index, line in
            line.sequence = index
        }
    }
    
    func removeLines(at offsets: IndexSet, in context: ModelContext) {
        let ordered = activeLines
        offsets.forEach { index in
            guard ordered.indices.contains(index) else { return }
            let line = ordered[index]
            line.ritual = nil
            line.isActive = false
        }
        try? context.save()
    }
    
    func attachExistingLine(_ line: RitualLine, in context: ModelContext) {
        line.ritual = self
        line.isActive = true
        line.sequence = nextSequenceIndex
        try? context.save()
    }
    
    func addCustomLine(named name: String, in context: ModelContext) -> RitualLine {
        let line = RitualLine(name: name, ritual: self)
        line.sequence = nextSequenceIndex
        context.insert(line)
        try? context.save()
        return line
    }
    
    func availableLines(from collection: [RitualLine]) -> [RitualLine] {
        collection.filter { $0.ritual?.id != id }
    }
    
    static func primaryRitual(from collection: [Ritual]) -> Ritual? {
        collection.sorted { $0.sequence < $1.sequence }.first
    }
    
    // Mock data for development (based on real PostgreSQL data)
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

