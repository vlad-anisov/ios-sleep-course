import SwiftUI
import SwiftData

struct ChatView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ChatMessage.date) private var messages: [ChatMessage]
    @Query private var scripts: [Script]
    
    @State private var isTyping = false
    @State private var currentStep: ScriptStep?
    @State private var availableButtons: [String] = []
    @State private var messageCount = 0
    
    private var currentScript: Script? {
        scripts.first { $0.isMain && $0.state == .running }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Messages list
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 4) {
                            ForEach(messages) { message in
                                MessageBubble(message: message, 
                                            previousMessage: messages.before(message))
                                    .id(message.id)
                            }
                            
                            if isTyping {
                                HStack {
                                    TypingIndicator()
                                        .padding(.leading, 12)
                                    Spacer()
                                }
                                .padding(.top, 8)
                            }
                            
                            // Display buttons if available
                            if !availableButtons.isEmpty {
                                VStack(spacing: 10) {
                                    ForEach(availableButtons, id: \.self) { buttonText in
                                        Button(action: {
                                            sendMessage(buttonText)
                                        }) {
                                            Text(buttonText)
                                                .font(.body)
                                                .foregroundColor(.white)
                                                .frame(maxWidth: .infinity)
                                                .padding(.vertical, 14)
                                                .background(
                                                    LinearGradient(
                                                        gradient: Gradient(colors: [Color(red: 0/255, green: 120/255, blue: 255/255).opacity(0.8), Color(red: 0/255, green: 120/255, blue: 255/255)]),
                                                        startPoint: .leading,
                                                        endPoint: .trailing
                                                    )
                                                )
                                                .cornerRadius(25)
                                                .shadow(color: Color(red: 0/255, green: 120/255, blue: 255/255).opacity(0.6), radius: 10, x: 0, y: 3)
                                        }
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.top, 12)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    .onChange(of: messages.count) { _, newCount in
                        if let lastMessage = messages.last {
                            withAnimation {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }
            }
            .background(Color.appBackground)
            .navigationTitle("")
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 12) {
                        // Eva's avatar
                        ZStack {
                            Circle()
                                .fill(LinearGradient(
                                    gradient: Gradient(colors: [Color(red: 0/255, green: 120/255, blue: 255/255), Color.purple]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                                .frame(width: 40, height: 40)
                            
                            Text("E")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        
                        Text("Eva")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                }
            }
            .onAppear {
                startScriptIfNeeded()
            }
        }
    }
    
    private func startScriptIfNeeded() {
        guard messages.isEmpty, currentScript == nil else { return }
        
        // Create start script if it doesn't exist
        let startScript = Script.createStartScript(in: modelContext)
        modelContext.insert(startScript)
        try? modelContext.save()
        
        // Find first incomplete step
        if let firstStep = startScript.steps.first(where: { $0.state != .done }) {
            currentStep = firstStep
            processStep(firstStep)
        }
    }
    
    private func processStep(_ step: ScriptStep) {
        isTyping = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            isTyping = false
            
            _ = ChatMessage.createMessage(body: step.plainMessage, isFromUser: false, in: modelContext)
            
            // Update available buttons based on step type
            if step.type == .nextStepName, let script = currentScript {
                availableButtons = script.steps
                    .filter { step.nextStepIds.contains($0.id) }
                    .map { $0.name }
            } else if step.type == .mood {
                availableButtons = ["Отлично 👍", "Нормально 👌", "Не очень 👎"]
            } else {
                availableButtons = []
            }
        }
    }
    
    private func sendMessage(_ text: String) {
        guard !text.isEmpty else { return }
        
        _ = ChatMessage.createMessage(body: text, isFromUser: true, in: modelContext)
        
        if let step = currentStep {
            handleStepResponse(step: step, userAnswer: text)
        } else {
            simulateEvaResponse(to: text)
        }
    }
    
    private func handleStepResponse(step: ScriptStep, userAnswer: String) {
        availableButtons = []
        isTyping = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            guard let script = currentScript else { return }
            
            var nextStep: ScriptStep?
            
            if step.type == .nextStepName {
                nextStep = script.steps.first { nextStepCandidate in
                    step.nextStepIds.contains(nextStepCandidate.id) &&
                    nextStepCandidate.name == userAnswer
                }
            } else {
                nextStep = script.steps.first { nextStepCandidate in
                    step.nextStepIds.contains(nextStepCandidate.id)
                }
            }
            
            if let nextStep = nextStep {
                currentStep = nextStep
                processStep(nextStep)
            } else {
                isTyping = false
                _ = ChatMessage.createMessage(
                    body: "Отлично! Мы завершили этот этап. Продолжай изучать материалы в разделе Статьи! 🎉",
                    isFromUser: false,
                    in: modelContext
                )
                availableButtons = []
            }
        }
    }
    
    private func simulateEvaResponse(to userMessage: String) {
        isTyping = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isTyping = false
            let response = ChatMessage.generateEvaResponse(for: userMessage)
            _ = ChatMessage.createMessage(body: response, isFromUser: false, in: modelContext)
        }
    }
}

struct TypingIndicator: View {
    @State private var animationAmount = 0.0
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(Color.gray.opacity(0.6))
                    .frame(width: 8, height: 8)
                    .scaleEffect(animationAmount == Double(index) ? 1.2 : 0.8)
                    .animation(
                        Animation.easeInOut(duration: 0.6)
                            .repeatForever()
                            .delay(Double(index) * 0.2),
                        value: animationAmount
                    )
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.gray.opacity(0.2))
        .cornerRadius(18)
        .onAppear {
            animationAmount = 1.0
        }
    }
}

struct MessageBubble: View {
    let message: ChatMessage
    let previousMessage: ChatMessage?
    
    var showAvatar: Bool {
        guard let prev = previousMessage else { return true }
        return prev.isFromUser != message.isFromUser
    }
    
    var bubbleRadius: CGFloat { 20 }
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if !message.isFromUser {
                // Eva's avatar (only show if first in sequence)
                if showAvatar {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(
                                gradient: Gradient(colors: [Color(red: 0/255, green: 120/255, blue: 255/255).opacity(0.8), Color.purple.opacity(0.8)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(width: 30, height: 30)
                        
                        Text("E")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                    }
                } else {
                    Color.clear
                        .frame(width: 30, height: 30)
                }
            }
            
            if message.isFromUser {
                Spacer(minLength: 60)
            }
            
            // Message bubble with iMessage-style corners
            Text(message.body)
                .font(.system(size: 16))
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .foregroundColor(message.isFromUser ? .white : .white)
                .background(
                    message.isFromUser
                        ? AnyView(Color(red: 0/255, green: 120/255, blue: 255/255))
                        : AnyView(Color.messageBubbleEva)
                )
                .clipShape(
                    MessageBubbleShape(
                        isFromUser: message.isFromUser,
                        showTail: showAvatar
                    )
                )
                .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
            
            if !message.isFromUser {
                Spacer(minLength: 60)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, showAvatar ? 4 : 1)
    }
}

struct MessageBubbleShape: Shape {
    let isFromUser: Bool
    let showTail: Bool
    
    func path(in rect: CGRect) -> Path {
        let radius: CGFloat = 20
        let tailSize: CGFloat = 6
        
        var path = Path()
        
        if isFromUser {
            // User message (right side)
            path.move(to: CGPoint(x: rect.minX + radius, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX - radius, y: rect.minY))
            path.addArc(center: CGPoint(x: rect.maxX - radius, y: rect.minY + radius),
                       radius: radius,
                       startAngle: Angle(degrees: -90),
                       endAngle: Angle(degrees: 0),
                       clockwise: false)
            
            if showTail {
                path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - radius - tailSize))
                path.addQuadCurve(to: CGPoint(x: rect.maxX + tailSize, y: rect.maxY),
                                 control: CGPoint(x: rect.maxX + 2, y: rect.maxY - 4))
                path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            } else {
                path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - radius))
                path.addArc(center: CGPoint(x: rect.maxX - radius, y: rect.maxY - radius),
                           radius: radius,
                           startAngle: Angle(degrees: 0),
                           endAngle: Angle(degrees: 90),
                           clockwise: false)
            }
            
            path.addLine(to: CGPoint(x: rect.minX + radius, y: rect.maxY))
            path.addArc(center: CGPoint(x: rect.minX + radius, y: rect.maxY - radius),
                       radius: radius,
                       startAngle: Angle(degrees: 90),
                       endAngle: Angle(degrees: 180),
                       clockwise: false)
            path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + radius))
            path.addArc(center: CGPoint(x: rect.minX + radius, y: rect.minY + radius),
                       radius: radius,
                       startAngle: Angle(degrees: 180),
                       endAngle: Angle(degrees: 270),
                       clockwise: false)
        } else {
            // Eva message (left side)
            if showTail {
                path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
                path.addQuadCurve(to: CGPoint(x: rect.minX, y: rect.maxY - radius - tailSize),
                                 control: CGPoint(x: rect.minX - 2, y: rect.maxY - 4))
                path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + radius))
            } else {
                path.move(to: CGPoint(x: rect.minX + radius, y: rect.maxY))
                path.addArc(center: CGPoint(x: rect.minX + radius, y: rect.maxY - radius),
                           radius: radius,
                           startAngle: Angle(degrees: 90),
                           endAngle: Angle(degrees: 180),
                           clockwise: false)
                path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + radius))
            }
            
            path.addArc(center: CGPoint(x: rect.minX + radius, y: rect.minY + radius),
                       radius: radius,
                       startAngle: Angle(degrees: 180),
                       endAngle: Angle(degrees: 270),
                       clockwise: false)
            path.addLine(to: CGPoint(x: rect.maxX - radius, y: rect.minY))
            path.addArc(center: CGPoint(x: rect.maxX - radius, y: rect.minY + radius),
                       radius: radius,
                       startAngle: Angle(degrees: -90),
                       endAngle: Angle(degrees: 0),
                       clockwise: false)
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - radius))
            path.addArc(center: CGPoint(x: rect.maxX - radius, y: rect.maxY - radius),
                       radius: radius,
                       startAngle: Angle(degrees: 0),
                       endAngle: Angle(degrees: 90),
                       clockwise: false)
            
            if showTail {
                path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            } else {
                path.addLine(to: CGPoint(x: rect.minX + radius, y: rect.maxY))
            }
        }
        
        return path
    }
}

// Extension to get previous message
extension Array where Element == ChatMessage {
    func before(_ message: ChatMessage) -> ChatMessage? {
        guard let index = firstIndex(where: { $0.id == message.id }), index > 0 else {
            return nil
        }
        return self[index - 1]
    }
}

#Preview {
    ChatView()
}


