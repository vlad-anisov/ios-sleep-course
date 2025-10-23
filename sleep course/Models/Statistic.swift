import Foundation
import SwiftData

@Model
final class Statistic {
    @Attribute(.unique) var id: Int
    var moodValue: String // Хранится как String для SwiftData
    var date: Date
    
    init(id: Int, mood: Mood, date: Date) {
        self.id = id
        self.moodValue = mood.rawValue
        self.date = date
    }
    
    // Computed property для доступа к enum
    var mood: Mood {
        get { Mood(rawValue: moodValue) ?? .neutral }
        set { moodValue = newValue.rawValue }
    }
    
    // Computed property
    var count: Int {
        switch mood {
        case .good: return 1
        case .neutral: return 0
        case .bad: return -1
        }
    }
    
    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy HH:mm"
        return formatter.string(from: date)
    }
    
    enum Mood: String, Codable, CaseIterable {
        case good = "👍"
        case neutral = "👌"
        case bad = "👎"
    }
}

// Mock data for development
extension Statistic {
    static let mockStatistics: [Statistic] = {
        var stats: [Statistic] = []
        let calendar = Calendar.current
        let now = Date()
        
        for i in 0..<30 {
            if let date = calendar.date(byAdding: .day, value: -i, to: now) {
                let moods = Statistic.Mood.allCases
                let randomMood = moods.randomElement() ?? .neutral
                stats.append(Statistic(id: i + 1, mood: randomMood, date: date))
            }
        }
        return stats.sorted { $0.date < $1.date }
    }()
}

