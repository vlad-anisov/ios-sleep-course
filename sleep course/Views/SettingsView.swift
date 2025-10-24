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
            .background(Color(red: 20/255, green: 30/255, blue: 54/255))
            .navigationTitle("Настройки")
        }
    }
}
