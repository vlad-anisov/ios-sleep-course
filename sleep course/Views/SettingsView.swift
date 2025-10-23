import SwiftUI
import SwiftData

struct SettingsView: View {
    @Query private var allSettings: [AppSettings]
    @Environment(\.modelContext) private var modelContext
    
    var settings: AppSettings? {
        allSettings.first
    }
    
    var body: some View {
        NavigationView {
            Form {
                if let settings = settings {
                    Section(header: Text("Локализация")) {
                        Picker("Язык", selection: Binding(
                            get: { settings.language },
                            set: { newValue in
                                settings.language = newValue
                                saveSettings()
                            }
                        )) {
                            ForEach(Language.available) { language in
                                Text(language.name).tag(language.id)
                            }
                        }
                    }
                    
                    Section(header: Text("Уведомления")) {
                        DatePicker(
                            "Время уведомления",
                            selection: Binding(
                                get: { parseTime(settings.notificationTime) },
                                set: { newTime in
                                    settings.notificationTime = formatTime(newTime)
                                    saveSettings()
                                }
                            ),
                            displayedComponents: .hourAndMinute
                        )
                    }
                } else {
                    Text("Загрузка настроек...")
                        .foregroundColor(.gray)
                }
                
                Section(header: Text("О приложении")) {
                    HStack {
                        Text("Версия")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.gray)
                    }
                    
                    NavigationLink("О приложении") {
                        AboutView()
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color(red: 20/255, green: 30/255, blue: 54/255))
            .navigationTitle("Настройки")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .onAppear {
                let appearance = UINavigationBarAppearance()
                appearance.configureWithTransparentBackground()
                appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
                
                let navigationBar = UINavigationBar.appearance()
                navigationBar.standardAppearance = appearance
                navigationBar.scrollEdgeAppearance = appearance
                navigationBar.compactAppearance = appearance
            }
        }
    }
    
    private func saveSettings() {
        do {
            try modelContext.save()
        } catch {
            print("Failed to save settings: \(error)")
        }
    }
    
    private func parseTime(_ timeString: String) -> Date {
        let components = timeString.split(separator: ":")
        guard components.count == 2,
              let hour = Int(components[0]),
              let minute = Int(components[1]) else {
            return Date()
        }
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        return Calendar.current.date(from: dateComponents) ?? Date()
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Image(systemName: "moon.stars.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(Color(red: 0/255, green: 120/255, blue: 255/255))
                    .padding(.top, 40)
                
                Text("Sleep Course")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Ваш персональный помощник для улучшения сна")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 12) {
                    InfoRow(label: "Версия", value: "1.0.0")
                    InfoRow(label: "Сборка", value: "1")
                    InfoRow(label: "Платформа", value: "iOS")
                }
                .padding()
                .background(Color(red: 20/255, green: 30/255, blue: 55/255))
                .cornerRadius(12)
                .padding(.horizontal)
                
                Spacer()
            }
        }
        .background(Color(red: 20/255, green: 30/255, blue: 54/255))
        .navigationTitle("О приложении")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onAppear {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithTransparentBackground()
            appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
            
            let navigationBar = UINavigationBar.appearance()
            navigationBar.standardAppearance = appearance
            navigationBar.scrollEdgeAppearance = appearance
            navigationBar.compactAppearance = appearance
        }
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .fontWeight(.medium)
                .foregroundColor(.white)
        }
    }
}

#Preview {
    SettingsView()
}

