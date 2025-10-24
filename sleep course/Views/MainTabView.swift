import SwiftUI
import SwiftData

struct MainTabView: View {
    @Query private var allSettings: [Settings]

    var body: some View {
        TabView {
            Tab("Чат", systemImage: "message"){
                ChatView()
            }
            Tab("Статьи", systemImage: "newspaper"){
                ArticlesView()
            }
            Tab("Ритуал", systemImage: "checkmark.circle"){
                RitualView()
            }
            Tab("Настройки", systemImage: "gear"){
                SettingsView(settings: allSettings.first!)
            }
        }
    }
}
