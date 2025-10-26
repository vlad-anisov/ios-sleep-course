import SwiftUI
import SwiftData

struct ChatView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \ChatMessage.date) private var messages: [ChatMessage]
    @Query private var scripts: [Script]
    @State private var isTyping = false
    @State private var currentStep: ScriptStep?
    @State private var buttons: [String] = []
    
    private var script: Script? { scripts.first { $0.isMain && $0.state == .running } }
    
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
                    .id(message.id)
                }
                if isTyping {
                    HStack {
                        TypingDots()
                        Spacer()
                    }
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
                    }
                }
            }
            .background(Color("BackgroundColor"))
            .defaultScrollAnchor(.bottom)
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
        let stepId = step.id
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

struct MessageRow: View {
    let message: ChatMessage
    let showAvatar: Bool
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
//            if !message.isFromUser {
//                if showAvatar {
//                    Circle().fill(LinearGradient(colors: [.blue.opacity(0.8), .purple.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing))
//                        .frame(width: 30, height: 30)
//                        .overlay(Text("E").font(.system(size: 14, weight: .semibold)).foregroundStyle(.white))
//                } else {
//                    Color.clear.frame(width: 30, height: 30)
//                }
//            }
            
            if message.isFromUser { Spacer(minLength: 60) }
            
            Text(message.body)
                .foregroundStyle(message.isFromUser ? .white : .primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    UnevenRoundedRectangle(cornerRadii: .init(
                        topLeading: 18,
                        bottomLeading: message.isFromUser ? 18 : 0,
                        bottomTrailing: message.isFromUser ? 0 : 18,
                        topTrailing: 18
                    ))
                    .fill(message.isFromUser ? Color.blue : Color.gray)
                )
            
            if !message.isFromUser { Spacer(minLength: 60) }
        }
        .padding()
    }
}

extension Array where Element == ChatMessage {
    func before(_ message: ChatMessage) -> ChatMessage? {
        guard let i = firstIndex(where: { $0.id == message.id }), i > 0 else { return nil }
        return self[i - 1]
    }
}

#Preview {
    ChatView()
}
