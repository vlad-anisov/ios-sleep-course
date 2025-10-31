import Foundation
import SwiftData

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

    var requiresUserInteraction: Bool {
        switch type {
        case .nextStepName, .mood:
            return true
        default:
            return false
        }
    }
}

