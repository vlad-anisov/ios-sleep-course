import SwiftUI
import SwiftData

struct MainTabView: View {
    @Query private var allSettings: [Settings]
    @Query private var allRituals: [Ritual]
    private var primarySettings: Settings? { Settings.primary(from: allSettings) }
    private var primaryRitual: Ritual? { Ritual.primaryRitual(from: allRituals) }

    var body: some View {
        TabView {
            Tab("Чат", systemImage: "message"){
                ChatView()
            }
            Tab("Статьи", systemImage: "newspaper"){
                ArticlesView()
            }
            Tab("Ритуал", systemImage: "checkmark.circle"){
                if let ritual = primaryRitual {
                    RitualView(ritual: ritual)
                }
            }
            Tab("Настройки", systemImage: "gear"){
                if let settings = primarySettings {
                    SettingsView(settings: settings)
                }
            }
        }
    }
}
