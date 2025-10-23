import Foundation
import SwiftData

@Model
final class AppSettings {
    var colorSchemeValue: String // Хранится как String
    var language: String
    var timezone: String
    var notificationTime: String
    
    init(colorScheme: ColorSchemeType, language: String, timezone: String, notificationTime: String) {
        self.colorSchemeValue = colorScheme.rawValue
        self.language = language
        self.timezone = timezone
        self.notificationTime = notificationTime
    }
    
    // Computed property для доступа к enum
    var colorScheme: ColorSchemeType {
        get { ColorSchemeType(rawValue: colorSchemeValue) ?? .light }
        set { colorSchemeValue = newValue.rawValue }
    }
    
    enum ColorSchemeType: String, Codable, CaseIterable {
        case light = "Light"
        case dark = "Dark"
        
        var displayName: String { rawValue }
    }
    
    static let `default` = AppSettings(
        colorScheme: .light,
        language: "en_US",
        timezone: "UTC",
        notificationTime: "22:00"
    )
}

// Available languages (from Odoo _lang_get)
struct Language: Identifiable {
    let id: String
    let name: String
    
    static let available = [
        Language(id: "en_US", name: "English"),
        Language(id: "ru_RU", name: "Русский"),
        Language(id: "es_ES", name: "Español"),
        Language(id: "de_DE", name: "Deutsch"),
        Language(id: "fr_FR", name: "Français"),
    ]
}

