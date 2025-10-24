import SwiftUI
import SwiftData
import UserNotifications

@main
struct sleep_courseApp: App {
    
    let modelContainer: ModelContainer
    
    init() {
        // Настраиваем delegate для показа уведомлений на переднем плане
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
        do {
            // Настройка SwiftData ModelContainer со всеми моделями
            let schema = Schema([
                ChatMessage.self,
                Ritual.self,
                RitualLine.self,
                Article.self,
                Statistic.self,
                Settings.self,
                Script.self,
                ScriptStep.self
            ])
            
            // Конфигурация с автоматической миграцией и удалением несовместимых данных
            let modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                allowsSave: true
            )
            
            modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
            
            // Инициализация начальных данных при первом запуске
            initializeDataIfNeeded()
        } catch {
            print("⚠️ Failed to load existing container: \(error)")
            print("🔄 Attempting to reset database...")
            
            // Если не удалось загрузить, пробуем удалить старую базу и создать новую
            do {
                let schema = Schema([
                    ChatMessage.self,
                    Ritual.self,
                    RitualLine.self,
                    Article.self,
                    Statistic.self,
                    Settings.self,
                    Script.self,
                    ScriptStep.self
                ])
                
                // Удаляем старую базу данных
                let url = ModelConfiguration().url
                try? FileManager.default.removeItem(at: url)
                print("✅ Old database removed")
                
                let modelConfiguration = ModelConfiguration(
                    schema: schema,
                    isStoredInMemoryOnly: false,
                    allowsSave: true
                )
                
                modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
                print("✅ New database created successfully")
                
                // Инициализация начальных данных
                initializeDataIfNeeded()
            } catch {
                fatalError("Failed to initialize ModelContainer after reset: \(error)")
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        .modelContainer(modelContainer)
    }
    
    // MARK: - Data Initialization
    
    private func initializeDataIfNeeded() {
        let context = ModelContext(modelContainer)
        
        // Проверяем и создаем настройки, если их нет
        let settingsDescriptor = FetchDescriptor<Settings>()
        let existingSettings = (try? context.fetch(settingsDescriptor)) ?? []
        
        if existingSettings.isEmpty {
            let settings = Settings()
            context.insert(settings)
            try? context.save()
            
            // Запрашиваем разрешение и создаем первое уведомление
            Task {
                let center = UNUserNotificationCenter.current()
                do {
                    let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
                    print(granted ? "✅ Уведомления разрешены" : "⚠️ Уведомления запрещены")
                    
                    if granted {
                        // Создаем первое уведомление
                        let content = UNMutableNotificationContent()
                        content.title = "Время ритуала"
                        content.body = "Пора начать вечерний ритуал для здорового сна 🌙"
                        content.sound = .default
                        
                        let components = Calendar.current.dateComponents([.hour, .minute], from: settings.notificationTime)
                        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
                        let request = UNNotificationRequest(identifier: "daily_ritual", content: content, trigger: trigger)
                        
                        try await center.add(request)
                        print("✅ Уведомление запланировано на \(components.hour!):\(String(format: "%02d", components.minute!))")
                    }
                } catch {
                    print("⚠️ Ошибка настройки уведомлений: \(error)")
                }
            }
        }
        
        // Проверяем, есть ли уже данные
        let descriptor = FetchDescriptor<Article>()
        let existingArticles = (try? context.fetch(descriptor)) ?? []
        
        if existingArticles.isEmpty {
            // Добавляем начальные статьи
            Article.mockArticles.forEach { mockArticle in
                let article = Article(
                    id: mockArticle.id,
                    name: mockArticle.name,
                    text: mockArticle.text,
                    shortName: mockArticle.shortName,
                    articleDescription: mockArticle.articleDescription,
                    emoji: mockArticle.emoji,
                    firstColor: mockArticle.firstColor,
                    secondColor: mockArticle.secondColor,
                    imageData: mockArticle.imageData,
                    isAvailable: mockArticle.isAvailable
                )
                context.insert(article)
            }
            
            // Добавляем начальный ритуал
            let ritual = Ritual(
                id: 1,
                name: "Вечерний ритуал",
                userId: 1
            )
            
            // Добавляем линии ритуала
            let mockLines = [
                RitualLine(id: 54, name: "Медитация 🧘", sequence: 6, isCheck: false, isBase: true, isActive: true, ritual: ritual),
                RitualLine(id: 89, name: "Скушать киви 🥝", sequence: 10, isCheck: false, isBase: true, isActive: true, ritual: ritual),
                RitualLine(id: 88, name: "Проветрить комнату 💨", sequence: 11, isCheck: false, isBase: true, isActive: true, ritual: ritual),
                RitualLine(id: 87, name: "Приглушить свет 💡", sequence: 12, isCheck: false, isBase: true, isActive: true, ritual: ritual),
                RitualLine(id: 86, name: "Тёплая ванна 🛁", sequence: 13, isCheck: false, isBase: true, isActive: true, ritual: ritual),
                RitualLine(id: 85, name: "Надеть носки 🧦", sequence: 14, isCheck: false, isBase: true, isActive: true, ritual: ritual),
                RitualLine(id: 84, name: "Закончить дела ✅", sequence: 15, isCheck: false, isBase: true, isActive: true, ritual: ritual),
            ]
            
            ritual.lines = mockLines
            context.insert(ritual)
            
            // Сохраняем все изменения
            try? context.save()
        }
    }
}

// MARK: - Notification Delegate для показа уведомлений на переднем плане

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationDelegate()
    
    // Показывать уведомления даже когда приложение активно
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Показываем баннер, звук и бейдж даже когда приложение на переднем плане
        completionHandler([.banner, .sound, .badge])
    }
    
    // Обработка нажатия на уведомление
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        print("📱 Пользователь нажал на уведомление")
        // Здесь можно добавить переход на нужный экран
        completionHandler()
    }
}
