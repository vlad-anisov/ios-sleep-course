import SwiftUI
import SwiftData

struct SettingsView: View {
    @Bindable var settings: Settings
    
    var body: some View {
        NavigationStack {
            Form {
                DatePicker("Время уведомления", selection: $settings.notificationTime, displayedComponents: .hourAndMinute)
                .listRowBackground(Color("MessageColor"))
            }
            .appScreenStyle(title: "Настройки")
        }
    }
}
