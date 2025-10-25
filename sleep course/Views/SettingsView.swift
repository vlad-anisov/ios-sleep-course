import SwiftUI
import SwiftData

struct SettingsView: View {
    @Bindable var settings: Settings
    
    var body: some View {
        NavigationStack {
            Form {
                DatePicker("Время уведомления", selection: $settings.notificationTime, displayedComponents: .hourAndMinute)
            }
            .scrollContentBackground(.hidden)
            .background(Color("BackgroundColor"))
            .navigationTitle("Настройки")
        }
    }
}
