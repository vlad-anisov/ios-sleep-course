import SwiftUI
import SwiftData

@main
struct sleep_courseApp: App {
    
    let modelContainer: ModelContainer
    
    init() {
        do {
            // Настройка SwiftData ModelContainer со всеми моделями
            let schema = Schema([
                ChatMessage.self,
                Ritual.self,
                RitualLine.self,
                Article.self,
                Statistic.self,
                AppSettings.self,
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
                    AppSettings.self,
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
            
            // Добавляем настройки по умолчанию
            let settings = AppSettings(
                colorScheme: .light,
                language: "ru_RU",
                timezone: "Europe/Moscow",
                notificationTime: "22:00"
            )
            context.insert(settings)
            
            // Сохраняем все изменения
            try? context.save()
        }
    }
}
