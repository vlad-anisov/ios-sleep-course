import SwiftUI

struct MainTabView: View {

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
                SettingsView()
            }
        }
//        .accentColor(Color(red: 0/255, green: 120/255, blue: 255/255))
//        .background(Color(red: 0/255, green: 120/255, blue: 255/255))
    }
}

#Preview {
    MainTabView()
}

