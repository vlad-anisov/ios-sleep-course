import Foundation
import SwiftData

@Model
final class Script {
    @Attribute(.unique) var id: Int
    var name: String
    var stateValue: String
    var isMain: Bool
    var articleId: Int?
    var ritualLineId: Int?
    var nextScriptId: Int?
    
    @Relationship(deleteRule: .cascade, inverse: \ScriptStep.script)
    var steps: [ScriptStep] = []
    
    init(id: Int, name: String, state: ScriptState, isMain: Bool, articleId: Int? = nil, ritualLineId: Int? = nil, nextScriptId: Int? = nil) {
        self.id = id
        self.name = name
        self.stateValue = state.rawValue
        self.isMain = isMain
        self.articleId = articleId
        self.ritualLineId = ritualLineId
        self.nextScriptId = nextScriptId
    }
    
    var state: ScriptState {
        get { ScriptState(rawValue: stateValue) ?? .notRunning }
        set { stateValue = newValue.rawValue }
    }
    
    enum ScriptState: String, Codable {
        case notRunning = "not_running"
        case running = "running"
        case done = "done"
        case failed = "failed"
    }
    
    // Computed state based on steps
    var computedState: ScriptState {
        if steps.contains(where: { $0.state == .failed }) {
            return .failed
        } else if steps.contains(where: { $0.state == .waiting || $0.state == .preProcessing || $0.state == .postProcessing }) {
            return .running
        } else if steps.allSatisfy({ $0.state == .done }) {
            return .done
        } else {
            return .notRunning
        }
    }
    
    var sortedSteps: [ScriptStep] {
        steps.sorted { $0.sequence < $1.sequence }
    }
    
    var nextPendingStep: ScriptStep? {
        sortedSteps.first { $0.state != .done }
    }
    
    func buttonTitles(for step: ScriptStep) -> [String] {
        switch step.type {
        case .nextStepName:
            return sortedSteps
                .filter { step.nextStepIds.contains($0.id) }
                .map { $0.name }
        case .mood:
            return ["Отлично 👍", "Нормально 👌", "Не очень 👎"]
        default:
            return []
        }
    }
    
    func nextStep(from step: ScriptStep, userAnswer: String?) -> ScriptStep? {
        switch step.type {
        case .nextStepName:
            guard let answer = userAnswer else { return nil }
            return sortedSteps.first {
                step.nextStepIds.contains($0.id) && $0.name == answer
            }
        default:
            return sortedSteps.first { step.nextStepIds.contains($0.id) }
        }
    }
    
    func shouldAutoAdvance(from step: ScriptStep) -> Bool {
        !buttonTitles(for: step).isEmpty ? false : !step.nextStepIds.isEmpty
    }
    
    func autoAdvanceTarget(from step: ScriptStep) -> ScriptStep? {
        sortedSteps.first { step.nextStepIds.contains($0.id) }
    }
    
    static func mainRunningScript(in scripts: [Script]) -> Script? {
        scripts.first { $0.isMain && $0.state == .running }
    }
    
    @MainActor
    static func ensureMainScript(in context: ModelContext, scripts: [Script], messages: [ChatMessage]) -> Script {
        if let existing = mainRunningScript(in: scripts) {
            return existing
        }
        if let firstMain = scripts.first(where: { $0.isMain }) {
            if messages.isEmpty {
                firstMain.state = .running
                try? context.save()
            }
            return firstMain
        }
        if let anyScript = scripts.first {
            return anyScript
        }
        let script = createStartScript(in: context)
        context.insert(script)
        try? context.save()
        return script
    }
    
    // Mock scripts data based on PostgreSQL
    @MainActor
    static func createStartScript(in context: ModelContext) -> Script {
        let script = Script(
            id: 1,
            name: "Start",
            state: .running,
            isMain: true,
            nextScriptId: 239
        )
        
        let stepsData: [(id: Int, name: String, message: String, sequence: Int, state: ScriptStep.StepState, type: ScriptStep.StepType, nextStepIds: [Int])] = [
            (1, "Привет 👋", "<p>Привет 👋</p>", 0, .done, .nextStepName, [10]),
            (10, "Привет, а кто ты 🙂", "<p>Меня зовут Ева, и я являюсь лучшим специалистом в области сна 😌</p>", 9, .done, .nothing, [7234]),
            (7234, "О тебе", "<p>Я помогаю людям мягко засыпать, легче пробуждаться по утрам, побеждать дневную сонливость и чувствовать себя более энергичными ✨</p>", 10, .notRunning, .nothing, [7235]),
            (7235, "Исследования", "<p>Во мне собраны десятки самых действенных методов улучшения сна, основанных на 415 исследованиях и научных статьях 📚</p>", 11, .notRunning, .nextStepName, [12]),
            (12, "Выглядит впечатляюще 🤩", "<p>Замечательно, в таком случае я предлагаю тебе пройти мой курс по улучшению сна 🌙</p>", 13, .done, .nothing, [7353]),
            (7353, "Что классное?", "<p>Знаешь, что в этом курсе самое классное 😎</p>", 14, .notRunning, .nothing, [7236]),
            (7236, "Эффективность", "<p>Я не буду читать лекции о том, что нужно спать больше. Вместо этого я покажу, как эффективно восстанавливать силы за то время, которое ты можешь уделять сну 😴</p>", 15, .notRunning, .nextStepName, [13]),
            (13, "Запустить курс 🚀", "<p>Отлично, я буду рад работать с тобой в одной команде 😁</p>", 17, .done, .nothing, [7357]),
            (7357, "Подготовка", "<p>Нам предстоит пройти подготовку, и от этого этапа во многом будет зависеть успех нашего путешествия 🧑‍🚀</p>", 18, .notRunning, .nextStepName, [17]),
            (17, "Поехали 🧑‍🚀", "<p>Во мне собраны сотни исследований о сне, поэтому я могу легко назвать эффективные методы и развеять все мифы. Но это не гарантирует результата 😔</p>", 19, .notRunning, .nothing, [])
        ]
        
        script.steps = stepsData.map { data in
            ScriptStep(
                id: data.id,
                name: data.name,
                message: data.message,
                sequence: data.sequence,
                state: data.state,
                type: data.type,
                nextStepIds: data.nextStepIds,
                script: script
            )
        }
        
        return script
    }
    
    // Article-related scripts mapping
    static func scriptIdForArticle(_ articleId: Int) -> Int? {
        let scriptMapping: [Int: Int] = [
            41: 239,  // Старт 🚀
            42: 232,  // Температура 🌡️
            46: 186,  // Ванна 🛁
            47: 234,  // Свет 💡
            48: 484,  // Подготовка к сну 🛏️
            50: 485,  // Питание 🍽
            51: 486,  // Вредные привычки 🥃
            53: 487,  // Кофе и чай ☕️
            55: 488,  // Основы КПТ ✨
            58: 489   // Утяжеленные одеяла 😊
        ]
        return scriptMapping[articleId]
    }
}

