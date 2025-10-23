//
//  ModelTests.swift
//  sleep courseTests
//
//  Created by Migration Assistant on 21.10.25.
//

import XCTest
@testable import sleep_course

final class ModelTests: XCTestCase {
    
    // MARK: - Article Tests
    
    func testArticleGradientColors() {
        let article = Article(
            id: 1,
            name: "Test",
            text: "",
            firstColor: "255,120,0",
            secondColor: "85,40,0",
            isAvailable: true
        )
        
        XCTAssertEqual(article.gradientColors.count, 2)
        // Colors should be parsed correctly
        XCTAssertNotNil(article.gradientColors.first)
    }
    
    func testArticleMockData() {
        let articles = Article.mockArticles
        XCTAssertFalse(articles.isEmpty)
        XCTAssertGreaterThanOrEqual(articles.count, 4)
        
        // Check structure
        let firstArticle = articles[0]
        XCTAssertEqual(firstArticle.id, 1)
        XCTAssertFalse(firstArticle.name.isEmpty)
        XCTAssertNotNil(firstArticle.emoji)
    }
    
    // MARK: - Ritual Tests
    
    func testRitualIsCheckComputed() {
        var ritual = Ritual.mockRitual
        
        // Initially not checked
        XCTAssertFalse(ritual.isCheck)
        
        // Check all lines
        for index in ritual.lines.indices {
            ritual.lines[index].isCheck = true
        }
        
        // Should be checked now
        XCTAssertTrue(ritual.isCheck)
    }
    
    func testRitualLinesSorting() {
        let ritual = Ritual.mockRitual
        let sortedLines = ritual.lines.sorted { $0.sequence < $1.sequence }
        
        XCTAssertEqual(sortedLines.count, ritual.lines.count)
        
        // Check sequences are in order
        for i in 0..<(sortedLines.count - 1) {
            XCTAssertLessThanOrEqual(sortedLines[i].sequence, sortedLines[i+1].sequence)
        }
    }
    
    // MARK: - Statistic Tests
    
    func testStatisticMoodCounts() {
        let goodStat = Statistic(id: 1, mood: .good, date: Date())
        XCTAssertEqual(goodStat.count, 1)
        
        let neutralStat = Statistic(id: 2, mood: .neutral, date: Date())
        XCTAssertEqual(neutralStat.count, 0)
        
        let badStat = Statistic(id: 3, mood: .bad, date: Date())
        XCTAssertEqual(badStat.count, -1)
    }
    
    func testStatisticDateString() {
        let date = Date()
        let statistic = Statistic(id: 1, mood: .good, date: date)
        
        XCTAssertFalse(statistic.dateString.isEmpty)
        XCTAssertTrue(statistic.dateString.contains("/"))
    }
    
    func testStatisticMockData() {
        let stats = Statistic.mockStatistics
        XCTAssertEqual(stats.count, 30)
        
        // Should be sorted by date
        for i in 0..<(stats.count - 1) {
            XCTAssertLessThanOrEqual(stats[i].date, stats[i+1].date)
        }
    }
    
    // MARK: - Settings Tests
    
    func testSettingsDefault() {
        let settings = AppSettings.default
        
        XCTAssertEqual(settings.colorScheme, .light)
        XCTAssertEqual(settings.language, "en_US")
        XCTAssertEqual(settings.timezone, "UTC")
        XCTAssertEqual(settings.notificationTime, "22:00")
    }
    
    func testSettingsEncodeDecode() throws {
        let settings = AppSettings.default
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(settings)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(AppSettings.self, from: data)
        
        XCTAssertEqual(settings.colorScheme, decoded.colorScheme)
        XCTAssertEqual(settings.language, decoded.language)
        XCTAssertEqual(settings.timezone, decoded.timezone)
    }
    
    // MARK: - ChatMessage Tests
    
    func testChatMessageTimeFormat() {
        let message = ChatMessage(
            id: 1,
            body: "Test",
            authorName: "Eva",
            date: Date(),
            isFromUser: false
        )
        
        XCTAssertFalse(message.dateString.isEmpty)
        XCTAssertTrue(message.dateString.contains(":"))
    }
    
    func testChatMessageMockData() {
        let messages = ChatMessage.mockMessages
        XCTAssertGreaterThanOrEqual(messages.count, 3)
        
        // Should have messages from both user and Eva
        let userMessages = messages.filter { $0.isFromUser }
        let evaMessages = messages.filter { !$0.isFromUser }
        
        XCTAssertFalse(userMessages.isEmpty)
        XCTAssertFalse(evaMessages.isEmpty)
    }
}

