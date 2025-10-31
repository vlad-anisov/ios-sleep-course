import SwiftUI
import SwiftData
import Combine

struct ChatView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \ChatMessage.date) private var messages: [ChatMessage]
    @Query private var scripts: [Script]
    @State private var isTyping = false
    @State private var currentStep: ScriptStep?
    @State private var buttons: [String] = []
    private let chatAnim = Animation.spring(response: 0.35, dampingFraction: 0.9)
    private let chatDelay: TimeInterval = 3.0
    private let typingAppearDelay: TimeInterval = 1.0
    private let buttonsAppearDelay: TimeInterval = 1.0
    
    private var script: Script? { Script.mainRunningScript(in: scripts) }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                let items = Array(messages)
                ForEach(Array(items.enumerated()), id: \.element.id) { index, message in
                    let next = index + 1 < items.count ? items[index + 1] : nil
                    let nextSameBot = !message.isFromUser && (next?.isFromUser == false)

                    ChatRow(
                        alignment: message.isFromUser ? .trailing : .leading,
                        padding: nextSameBot ? 0 : 5
                    ) {
                        Text(message.body)
                            .contentTransition(.opacity)
                            .padding()
                            .background(message.isFromUser ? Color.blue : Color("MessageColor"))
                            .clipShape(
                                .rect(
                                    topLeadingRadius: 31,
                                    bottomLeadingRadius: message.isFromUser ? 31 : (nextSameBot ? 31 : 5),
                                    bottomTrailingRadius: message.isFromUser ? 5 : 31,
                                    topTrailingRadius: 31
                                )
                            )
                    }
                }
                if isTyping {
                    ChatRow(alignment: .leading) {
                        TypingDots()
                    }
                }
                ForEach(buttons, id: \.self) { text in
                    ChatRow(alignment: .center) {
                        Button {
                            handleUserMessage(text)
                        } label: {
                            Text(text).foregroundStyle(.white)
                        }
                        .padding()
                        .glassEffect(.clear.tint(.blue).interactive())
                    }
                }
            }
            .defaultScrollAnchor(.bottom)
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 1)
            }
            .scrollBounceBehavior(.basedOnSize)
            .background(Color("BackgroundColor"))
            .scrollIndicators(.hidden)
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
            .task {
                initScript()
            }
        }
    }
    
    private struct ChatRow<Content: View>: View {
        let alignment: Alignment
        let padding: CGFloat
        @ViewBuilder let content: () -> Content

        init(alignment: Alignment, padding: CGFloat = 5, @ViewBuilder content: @escaping () -> Content) {
            self.alignment = alignment
            self.padding = padding
            self.content = content
        }

        var body: some View {
            content()
                .frame(maxWidth: .infinity, alignment: alignment)
                .padding(.horizontal, 20)
                .padding(.bottom, padding)
                .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }

    private struct TypingDots: View {
        @State private var phase = 0
        private let timer = Timer.publish(every: 0.3, on: .main, in: .common).autoconnect()

        var body: some View {
            HStack(spacing: 4) {
                ForEach(0..<3) { i in
                    Circle()
                        .fill(Color.gray.opacity(0.6))
                        .frame(width: 8, height: 8)
                        .scaleEffect(i == phase ? 1.2 : 0.8)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .onReceive(timer) { _ in
                withAnimation(.easeInOut(duration: 0.25)) {
                    phase = (phase + 1) % 3
                }
            }
        }
    }
    
    private func initScript() {
        let script = Script.ensureMainScript(in: context, scripts: scripts, messages: messages)
        guard let step = script.nextPendingStep else { return }
        currentStep = step
        if messages.isEmpty {
            showStep(step, in: script)
        } else {
            configureButtons(for: step, in: script)
            scheduleAutoAdvanceIfNeeded(for: step, in: script)
        }
    }
    
    private func showStep(_ step: ScriptStep, in script: Script) {
        let message = step.plainMessage
        DispatchQueue.main.asyncAfter(deadline: .now() + typingAppearDelay) {
            withAnimation(chatAnim) { isTyping = true }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + typingAppearDelay + chatDelay) {
            withAnimation(chatAnim) {
                self.isTyping = false
                _ = ChatMessage.createMessage(body: message, isFromUser: false, in: self.context)
            }
            configureButtons(for: step, in: script)
            scheduleAutoAdvanceIfNeeded(for: step, in: script)
        }
    }
    
    private func configureButtons(for step: ScriptStep, in script: Script) {
        let titles = script.buttonTitles(for: step)
        DispatchQueue.main.asyncAfter(deadline: .now() + buttonsAppearDelay) {
            withAnimation(chatAnim) {
                self.buttons = titles
            }
        }
    }
    
    private func scheduleAutoAdvanceIfNeeded(for step: ScriptStep, in script: Script) {
        guard script.shouldAutoAdvance(from: step), let next = script.autoAdvanceTarget(from: step) else {
            if step.requiresUserInteraction == false {
                withAnimation(chatAnim) { buttons = [] }
            }
            return
        }
        withAnimation(chatAnim) { buttons = [] }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.currentStep = next
            self.showStep(next, in: script)
        }
    }
    
    private func handleUserMessage(_ text: String) {
        withAnimation(chatAnim) { _ = ChatMessage.createMessage(body: text, isFromUser: true, in: context) }
        guard let step = currentStep, let script else {
            respondToFreeText(text)
            return
        }
        withAnimation(chatAnim) { buttons = [] }
        moveToNext(from: step, in: script, userAnswer: text)
    }
    
    private func moveToNext(from step: ScriptStep, in script: Script, userAnswer: String?) {
        DispatchQueue.main.asyncAfter(deadline: .now() + typingAppearDelay) {
            withAnimation(chatAnim) { isTyping = true }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + typingAppearDelay + chatDelay) {
            guard let next = script.nextStep(from: step, userAnswer: userAnswer) else {
                withAnimation(chatAnim) {
                    self.isTyping = false
                    _ = ChatMessage.createMessage(body: "Отлично! Мы завершили этот этап. Продолжай изучать материалы в разделе Статьи! 🎉", isFromUser: false, in: self.context)
                }
                return
            }
            self.currentStep = next
            self.showStep(next, in: script)
        }
    }
    
    private func respondToFreeText(_ msg: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + typingAppearDelay) {
            withAnimation(chatAnim) { isTyping = true }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + typingAppearDelay + chatDelay) {
            withAnimation(chatAnim) {
                isTyping = false
                _ = ChatMessage.createMessage(body: ChatMessage.generateEvaResponse(for: msg), isFromUser: false, in: context)
            }
        }
    }
    
    private func resetChat() {
        ChatMessage.resetChat(messages: messages, scripts: scripts, in: context)
        buttons = []
        currentStep = nil
        isTyping = false
        initScript()
    }
}

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
