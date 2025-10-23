import Foundation
import SwiftData

@Model
final class ChatMessage {
    @Attribute(.unique) var id: Int
    var body: String
    var authorName: String
    var date: Date
    var isFromUser: Bool
    
    init(id: Int, body: String, authorName: String, date: Date, isFromUser: Bool) {
        self.id = id
        self.body = body
        self.authorName = authorName
        self.date = date
        self.isFromUser = isFromUser
    }
    
    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

// Chat business logic
extension ChatMessage {
    @MainActor
    static func createMessage(body: String, isFromUser: Bool, in context: ModelContext) -> ChatMessage {
        let descriptor = FetchDescriptor<ChatMessage>()
        let existingMessages = (try? context.fetch(descriptor)) ?? []
        let newId = (existingMessages.map { $0.id }.max() ?? 0) + 1
        
        let message = ChatMessage(
            id: newId,
            body: body,
            authorName: isFromUser ? "User" : "Eva",
            date: Date(),
            isFromUser: isFromUser
        )
        
        context.insert(message)
        try? context.save()
        return message
    }
    
    @MainActor
    static func generateEvaResponse(for userMessage: String) -> String {
        let lowercased = userMessage.lowercased()
        
        if lowercased.contains("sleep") || lowercased.contains("сон") {
            return "Хороший сон важен для здоровья. Ты уже проверил свой вечерний ритуал сегодня?"
        } else if lowercased.contains("ritual") || lowercased.contains("ритуал") {
            return "Твой ритуал помогает подготовить тело и разум к качественному сну. Не забывай выполнять все шаги!"
        } else if lowercased.contains("article") || lowercased.contains("статья") || lowercased.contains("статьи") {
            return "Рекомендую заглянуть в раздел Статьи. Там много полезной информации об улучшении сна!"
        } else if lowercased.contains("help") || lowercased.contains("помощь") || lowercased.contains("помоги") {
            return "Я здесь, чтобы помочь тебе улучшить качество сна. Можешь спросить меня о советах по сну, ритуалах или почитать наши статьи."
        } else if lowercased.contains("привет") || lowercased.contains("hello") || lowercased.contains("hi") {
            return "Привет! 👋 Я Ева, твой персональный ассистент по улучшению сна. Чем могу помочь?"
        } else {
            return "Я получила твоё сообщение. Чем могу помочь сегодня в улучшении твоего сна?"
        }
    }
}

// Mock data for development
extension ChatMessage {
    static let mockMessages: [ChatMessage] = [
        ChatMessage(id: 1, body: "Hello! I'm Eva, your sleep assistant. How are you feeling today?", authorName: "Eva", date: Date().addingTimeInterval(-3600), isFromUser: false),
        ChatMessage(id: 2, body: "Hi Eva! I'm feeling a bit tired today.", authorName: "User", date: Date().addingTimeInterval(-3500), isFromUser: true),
        ChatMessage(id: 3, body: "I understand. Let's work on improving your sleep quality. Have you completed your evening ritual?", authorName: "Eva", date: Date().addingTimeInterval(-3400), isFromUser: false),
        ChatMessage(id: 4, body: "Not yet, I'll do it now.", authorName: "User", date: Date().addingTimeInterval(-3300), isFromUser: true),
        ChatMessage(id: 5, body: "Great! Don't forget to check off each step. I'll be here if you need any guidance.", authorName: "Eva", date: Date().addingTimeInterval(-3200), isFromUser: false),
    ]
}

