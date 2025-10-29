import SwiftUI
import SwiftData
import ExyteChat

struct ChatView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \ChatMessage.date) private var messages: [ChatMessage]
    @Query private var scripts: [Script]
    @State private var isTyping = false
    @State private var currentStep: ScriptStep?
    @State private var buttons: [String] = []
    
    private var script: Script? { scripts.first { $0.isMain && $0.state == .running } }
    
    // Конвертируем наши сообщения в формат ExyteChat
    private var exyteChatMessages: [ExyteChat.Message] {
        messages.toExyteChatMessages()
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                ForEach(messages) { message in
                    HStack {
                        if message.isFromUser {
                            Spacer()
                        }
                        Text(message.body)
                            .padding()
                            .background(message.isFromUser ? Color.blue : Color("MessageColor"))
                            .clipShape(
                                .rect(
                                    topLeadingRadius: 35,
                                    bottomLeadingRadius: message.isFromUser ? 35 : 0,
                                    bottomTrailingRadius: message.isFromUser ? 0 : 35,
                                    topTrailingRadius: 35
                                )
                            )
                        if !message.isFromUser {
                            Spacer()
                        }
                    }
                    .padding()
                }
                if isTyping {
                    HStack {
                        TypingDots()
                        Spacer()
                    }
                    .padding()
                }
                if !buttons.isEmpty {
                    ForEach(buttons, id: \.self) { text in
                        HStack {
                            Spacer()
                            Button {
                                handleUserMessage(text)
                            } label: {
                                Text(text).foregroundStyle(.white)
                            }
                            .padding()
                            .glassEffect(.clear.tint(.blue).interactive())
                            Spacer()
                        }
                        .padding()
                    }
                }
            }
            .background(Color("BackgroundColor"))
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 12) {
                        Circle().frame(width: 40, height: 40).overlay(Text("E"))
                        Text("Ева")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Сброс") {
                        resetChat()
                    }
                }
            }
        }
    }
    
//    var body: some View {
//        NavigationStack {
//            ExyteChat.ChatView(messages: exyteChatMessages) { draft in
//
//            } inputViewBuilder: { textBinding, attachments, inputViewState, inputViewStyle, inputViewActionClosure, dismissKeyboardClosure in
//                Group {}
//            }
//            .avatarSize(avatarSize: 0)
//            .showMessageMenuOnLongPress(false)
//            .isListAboveInputView(true)
//            .showDateHeaders(false)
////            .betweenListAndInputViewBuilder {
////                ForEach(buttons, id: \.self) { text in
////                    HStack {
////                        Spacer()
////                        Button {
////                            handleUserMessage(text)
////                        } label: {
////                            Text(text).foregroundStyle(.white)
////                        }
////                        .padding()
////                        .glassEffect(.clear.tint(.blue).interactive())
////                        Spacer()
////                    }
////                }
////            }
//            .mainHeaderBuilder {
//                Text("TEST")
//            }
//            .chatTheme(
//                ExyteChat.ChatTheme(
//                    colors: .init(
//                        mainBG: Color("BackgroundColor"),
//                        messageMyBG: .blue,
//                        messageFriendBG: Color("MessageColor"),
//                    )
//                )
//            )
//            .background(Color("BackgroundColor"))
//            .ignoresSafeArea(.all, edges: .vertical)
//            .toolbar {
//                ToolbarItem(placement: .principal) {
//                    HStack(spacing: 12) {
//                        Circle().frame(width: 40, height: 40).overlay(Text("E"))
//                        Text("Ева")
//                    }
//                }
//                ToolbarItem(placement: .topBarTrailing) {
//                    Button("Сброс") {
//                        resetChat()
//                    }
//                }
//                ToolbarItem(){
//                    ForEach(buttons, id: \.self) { text in
//                        HStack {
//                            Spacer()
//                            Button {
//                                handleUserMessage(text)
//                            } label: {
//                                Text(text).foregroundStyle(.white)
//                            }
//                            .padding()
//                            .glassEffect(.clear.tint(.blue).interactive())
//                            Spacer()
//                        }
//                    }
//                }
//            }
//        }
//    }
    
    private func initScript() {
        // Если есть скрипт, восстанавливаем состояние
        if let s = script {
            // Находим последний незавершённый шаг
            let sortedSteps = s.steps.sorted { $0.sequence < $1.sequence }
            if let step = sortedSteps.first(where: { $0.state != .done }) {
                currentStep = step
                // Если нет сообщений - начинаем показывать
                if messages.isEmpty {
                    showStep(step)
                } else {
                    // Есть сообщения - проверяем нужны ли кнопки
                    if step.type == .nextStepName {
                        buttons = s.steps.filter { step.nextStepIds.contains($0.id) }.map { $0.name }
                    } else if step.type == .mood {
                        buttons = ["Отлично 👍", "Нормально 👌", "Не очень 👎"]
                    } else if !step.nextStepIds.isEmpty {
                        // Автопродолжение если нужно
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.currentStep = step
                            self.showStep(step)
                        }
                    }
                }
            }
            return
        }
        
        // Создаём новый скрипт только если нет вообще ничего
        guard messages.isEmpty else { return }
        let s = Script.createStartScript(in: context)
        context.insert(s)
        try? context.save()
        if let step = s.steps.sorted(by: { $0.sequence < $1.sequence }).first(where: { $0.state != .done }) {
            currentStep = step
            showStep(step)
        }
    }
    
    private func showStep(_ step: ScriptStep) {
        let nextIds = step.nextStepIds
        let stepType = step.type
        let message = step.plainMessage
        
        step.state = .done
        isTyping = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.isTyping = false
            _ = ChatMessage.createMessage(body: message, isFromUser: false, in: self.context)
            
            // Определяем кнопки
            if stepType == .nextStepName, let s = self.script {
                self.buttons = s.steps.filter { nextIds.contains($0.id) }.map { $0.name }
            } else if stepType == .mood {
                self.buttons = ["Отлично 👍", "Нормально 👌", "Не очень 👎"]
            } else {
                self.buttons = []
                // Если нет кнопок, но есть следующий шаг - автоматически продолжаем
                if !nextIds.isEmpty, let s = self.script, let nextStep = s.steps.first(where: { nextIds.contains($0.id) }) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.currentStep = nextStep
                        self.showStep(nextStep)
                    }
                }
            }
        }
    }
    
    private func handleUserMessage(_ text: String) {
        _ = ChatMessage.createMessage(body: text, isFromUser: true, in: context)
        if let step = currentStep {
            buttons = []
            moveToNext(from: step, userAnswer: text)
        } else {
            respondToFreeText(text)
        }
    }
    
    private func moveToNext(from step: ScriptStep, userAnswer: String?) {
        let nextIds = step.nextStepIds
        let stepType = step.type
        
        isTyping = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            guard let s = self.script else { return }
            
            let next: ScriptStep? = if stepType == .nextStepName, let answer = userAnswer {
                s.steps.first { nextIds.contains($0.id) && $0.name == answer }
            } else {
                s.steps.first { nextIds.contains($0.id) }
            }
            
            if let next {
                self.currentStep = next
                self.showStep(next)
            } else {
                self.isTyping = false
                _ = ChatMessage.createMessage(body: "Отлично! Мы завершили этот этап. Продолжай изучать материалы в разделе Статьи! 🎉", isFromUser: false, in: self.context)
            }
        }
    }
    
    private func respondToFreeText(_ msg: String) {
        isTyping = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            isTyping = false
            _ = ChatMessage.createMessage(body: ChatMessage.generateEvaResponse(for: msg), isFromUser: false, in: context)
        }
    }
    
    private func resetChat() {
        messages.forEach { context.delete($0) }
        scripts.forEach { context.delete($0) }
        try? context.save()
        
        buttons = []
        currentStep = nil
        isTyping = false
        
        initScript()
    }
}

// MARK: - Components
struct TypingDots: View {
    @State private var animate = 0.0
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3) { i in
                Circle().fill(Color.gray.opacity(0.6)).frame(width: 8, height: 8)
                    .scaleEffect(animate == Double(i) ? 1.2 : 0.8)
                    .animation(.easeInOut(duration: 0.6).repeatForever().delay(Double(i) * 0.2), value: animate)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.2)).clipShape(RoundedRectangle(cornerRadius: 18))
        .onAppear { animate = 1 }
    }
}
// Все компоненты теперь встроены через messageBuilder библиотеки Exyte/Chat

#Preview {
    let container = try! ModelContainer(for: ChatMessage.self, Script.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    let context = container.mainContext
    
    // Добавляем тестовые сообщения
    let msg1 = ChatMessage(id: 1, body: "Привет! Я Ева, твой ассистент по сну.", authorName: "Eva", date: Date().addingTimeInterval(-300), isFromUser: false)
    let msg2 = ChatMessage(id: 2, body: "Привет! Как начать?", authorName: "User", date: Date().addingTimeInterval(-200), isFromUser: true)
    let msg3 = ChatMessage(id: 3, body: "Давай начнем с оценки твоего сна. Как ты спал сегодня?", authorName: "Eva", date: Date().addingTimeInterval(-100), isFromUser: false)
    
    context.insert(msg1)
    context.insert(msg2)
    context.insert(msg3)
    
    return ChatView()
        .modelContainer(container)
}
