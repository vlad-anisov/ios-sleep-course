import Foundation
import SwiftData
import ExyteChat

// Расширение для ChatMessage, чтобы адаптировать его к формату ExyteChat.Message
extension ChatMessage {
    /// Конвертирует ChatMessage в формат ExyteChat.Message
    func toExyteChatMessage() -> ExyteChat.Message {
        let user = ExyteChat.User(
            id: isFromUser ? "user" : "eva",
            name: authorName,
            avatarURL: nil,
            isCurrentUser: isFromUser
        )
        
        return ExyteChat.Message(
            id: String(id),
            user: user,
            status: .sent,
            createdAt: date,
            text: body,
            attachments: [],
            recording: nil,
            replyMessage: nil
        )
    }
    
    /// Создает ChatMessage из ExyteChat.DraftMessage
    @MainActor
    static func fromDraft(_ draft: ExyteChat.DraftMessage, isFromUser: Bool, in context: ModelContext) -> ChatMessage {
        return createMessage(body: draft.text, isFromUser: isFromUser, in: context)
    }
}

// Вспомогательные функции для конвертации массивов
extension Array where Element == ChatMessage {
    /// Конвертирует массив ChatMessage в массив ExyteChat.Message
    func toExyteChatMessages() -> [ExyteChat.Message] {
        return self.map { $0.toExyteChatMessage() }
    }
}

