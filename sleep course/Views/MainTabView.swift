import SwiftUI
import SwiftData

struct MainTabView: View {
    @Query private var allSettings: [Settings]
    @Query private var allRituals: [Ritual]

    var body: some View {
        TabView {
            Tab("Чат", systemImage: "message"){
                ChatView()
            }
            Tab("Статьи", systemImage: "newspaper"){
                ArticlesView()
            }
            Tab("Ритуал", systemImage: "checkmark.circle"){
                if let ritual = Ritual.primaryRitual(from: allRituals) {
                    RitualView(ritual: ritual)
                }
            }
            Tab("Настройки", systemImage: "gear"){
                if let settings = Settings.primary(from: allSettings) {
                    SettingsView(settings: settings)
                }
            }
        }
    }
}
