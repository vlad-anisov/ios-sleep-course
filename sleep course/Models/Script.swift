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
}

@Model
final class ScriptStep {
    @Attribute(.unique) var id: Int
    var name: String
    var message: String // HTML message
    var sequence: Int
    var stateValue: String
    var typeValue: String
    var nextStepIds: [Int]
    var userAnswer: String?
    var code: String?
    
    var script: Script?
    
    init(id: Int, name: String, message: String, sequence: Int, state: StepState, type: StepType, nextStepIds: [Int], userAnswer: String? = nil, code: String? = nil, script: Script? = nil) {
        self.id = id
        self.name = name
        self.message = message
        self.sequence = sequence
        self.stateValue = state.rawValue
        self.typeValue = type.rawValue
        self.nextStepIds = nextStepIds
        self.userAnswer = userAnswer
        self.code = code
        self.script = script
    }
    
    var state: StepState {
        get { StepState(rawValue: stateValue) ?? .notRunning }
        set { stateValue = newValue.rawValue }
    }
    
    var type: StepType {
        get { StepType(rawValue: typeValue) ?? .nothing }
        set { typeValue = newValue.rawValue }
    }
    
    enum StepState: String, Codable {
        case notRunning = "not_running"
        case preProcessing = "pre_processing"
        case waiting = "waiting"
        case postProcessing = "post_processing"
        case done = "done"
        case failed = "failed"
    }
    
    enum StepType: String, Codable {
        case nothing = "nothing"
        case nextStepName = "next_step_name"
        case email = "email"
        case time = "time"
        case article = "article"
        case mood = "mood"
        case ritualLine = "ritual_line"
        case ritual = "ritual"
        case push = "push"
    }
    
    // Parse HTML to plain text for display
    var plainMessage: String {
        message.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
    }
}

// Mock scripts data based on PostgreSQL
extension Script {
    @MainActor
    static func createStartScript(in context: ModelContext) -> Script {
        let script = Script(
            id: 1,
            name: "Start",
            state: .running,
            isMain: true,
            nextScriptId: 239
        )
        
        let steps: [(id: Int, name: String, message: String, sequence: Int, state: ScriptStep.StepState, type: ScriptStep.StepType, nextStepIds: [Int])] = [
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
        
        script.steps = steps.map { stepData in
            ScriptStep(
                id: stepData.id,
                name: stepData.name,
                message: stepData.message,
                sequence: stepData.sequence,
                state: stepData.state,
                type: stepData.type,
                nextStepIds: stepData.nextStepIds,
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

