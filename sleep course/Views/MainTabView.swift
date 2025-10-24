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
                RitualView(ritual: allRituals.first!)
            }
            Tab("Настройки", systemImage: "gear"){
                SettingsView(settings: allSettings.first!)
            }
        }
    }
}
