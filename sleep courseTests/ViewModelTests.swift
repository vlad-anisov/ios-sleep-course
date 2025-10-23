//
//  ViewModelTests.swift
//  sleep courseTests
//
//  Created by Migration Assistant on 21.10.25.
//

import XCTest
@testable import sleep_course

@MainActor
final class ViewModelTests: XCTestCase {
    
    // MARK: - ArticlesViewModel Tests
    
    func testArticlesViewModelLoadArticles() async {
        let viewModel = ArticlesViewModel()
        
        // Wait for async loading
        try? await Task.sleep(nanoseconds: 600_000_000) // 0.6s
        
        XCTAssertFalse(viewModel.articles.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
    }
    
    func testArticlesViewModelAvailableArticles() {
        let viewModel = ArticlesViewModel()
        viewModel.articles = Article.mockArticles
        
        let available = viewModel.availableArticles
        XCTAssertTrue(available.allSatisfy { $0.isAvailable })
    }
    
    // MARK: - RitualViewModel Tests
    
    func testRitualViewModelToggleLine() {
        let viewModel = RitualViewModel()
        let firstLineId = viewModel.ritual.lines.first!.id
        let initialState = viewModel.ritual.lines.first!.isCheck
        
        viewModel.toggleLine(firstLineId)
        
        let newState = viewModel.ritual.lines.first!.isCheck
        XCTAssertNotEqual(initialState, newState)
    }
    
    func testRitualViewModelResetRitual() {
        let viewModel = RitualViewModel()
        
        // Check all lines
        for line in viewModel.ritual.lines {
            viewModel.toggleLine(line.id)
        }
        
        XCTAssertTrue(viewModel.ritual.isCheck)
        
        // Reset
        viewModel.resetRitual()
        
        XCTAssertFalse(viewModel.ritual.isCheck)
        XCTAssertTrue(viewModel.ritual.lines.allSatisfy { !$0.isCheck })
    }
    
    func testRitualViewModelAddLine() {
        let viewModel = RitualViewModel()
        let initialCount = viewModel.ritual.lines.count
        
        viewModel.addLine(name: "New Task")
        
        XCTAssertEqual(viewModel.ritual.lines.count, initialCount + 1)
        XCTAssertTrue(viewModel.ritual.lines.contains { $0.name == "New Task" })
    }
    
    func testRitualViewModelRemoveLine() {
        let viewModel = RitualViewModel()
        let lineToRemove = viewModel.ritual.lines.first!
        let initialCount = viewModel.ritual.lines.count
        
        viewModel.removeLine(lineToRemove.id)
        
        XCTAssertEqual(viewModel.ritual.lines.count, initialCount - 1)
        XCTAssertFalse(viewModel.ritual.lines.contains { $0.id == lineToRemove.id })
    }
    
    // MARK: - ChatViewModel Tests
    
    func testChatViewModelSendMessage() async {
        let viewModel = ChatViewModel()
        let initialCount = viewModel.messages.count
        
        viewModel.sendMessage("Hello")
        
        XCTAssertEqual(viewModel.messages.count, initialCount + 1)
        XCTAssertEqual(viewModel.messages.last?.body, "Hello")
        XCTAssertTrue(viewModel.messages.last?.isFromUser ?? false)
        
        // Wait for Eva's response
        try? await Task.sleep(nanoseconds: 2_000_000_000) // 2s
        
        XCTAssertGreaterThan(viewModel.messages.count, initialCount + 1)
        XCTAssertFalse(viewModel.isTyping)
    }
    
    func testChatViewModelEmptyMessage() {
        let viewModel = ChatViewModel()
        let initialCount = viewModel.messages.count
        
        viewModel.sendMessage("")
        
        XCTAssertEqual(viewModel.messages.count, initialCount)
    }
    
    func testChatViewModelClearMessages() {
        let viewModel = ChatViewModel()
        viewModel.clearMessages()
        
        XCTAssertTrue(viewModel.messages.isEmpty)
    }
    
    // MARK: - StatisticsViewModel Tests
    
    func testStatisticsViewModelLoadStatistics() async {
        let viewModel = StatisticsViewModel()
        
        try? await Task.sleep(nanoseconds: 400_000_000) // 0.4s
        
        XCTAssertFalse(viewModel.statistics.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
    }
    
    func testStatisticsViewModelAddStatistic() {
        let viewModel = StatisticsViewModel()
        viewModel.statistics = []
        
        viewModel.addStatistic(mood: .good)
        
        XCTAssertEqual(viewModel.statistics.count, 1)
        XCTAssertEqual(viewModel.statistics.first?.mood, .good)
    }
    
    func testStatisticsViewModelAverageMood() {
        let viewModel = StatisticsViewModel()
        viewModel.statistics = [
            Statistic(id: 1, mood: .good, date: Date()),    // +1
            Statistic(id: 2, mood: .neutral, date: Date()), // 0
            Statistic(id: 3, mood: .bad, date: Date())      // -1
        ]
        
        let average = viewModel.averageMood
        XCTAssertEqual(average, 0.0, accuracy: 0.01)
    }
    
    func testStatisticsViewModelLastWeekStats() {
        let viewModel = StatisticsViewModel()
        let calendar = Calendar.current
        
        viewModel.statistics = [
            Statistic(id: 1, mood: .good, date: Date()),
            Statistic(id: 2, mood: .good, date: calendar.date(byAdding: .day, value: -3, to: Date())!),
            Statistic(id: 3, mood: .good, date: calendar.date(byAdding: .day, value: -10, to: Date())!)
        ]
        
        let lastWeek = viewModel.lastWeekStats
        XCTAssertEqual(lastWeek.count, 2) // Only last 7 days
    }
    
    // MARK: - SettingsViewModel Tests
    
    func testSettingsViewModelSaveAndLoad() {
        let viewModel = SettingsViewModel()
        
        viewModel.updateLanguage("ru_RU")
        viewModel.updateTimezone("Europe/Moscow")
        
        // Create new instance to test persistence
        let newViewModel = SettingsViewModel()
        
        XCTAssertEqual(newViewModel.settings.language, "ru_RU")
        XCTAssertEqual(newViewModel.settings.timezone, "Europe/Moscow")
    }
    
    func testSettingsViewModelResetToDefaults() {
        let viewModel = SettingsViewModel()
        
        viewModel.updateLanguage("ru_RU")
        viewModel.resetToDefaults()
        
        XCTAssertEqual(viewModel.settings.language, "en_US")
        XCTAssertEqual(viewModel.settings.colorScheme, .light)
    }
}

