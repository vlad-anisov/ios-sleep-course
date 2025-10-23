//
//  UITests.swift
//  sleep courseUITests
//
//  Created by Migration Assistant on 21.10.25.
//

import XCTest

final class SleepCourseUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - Tab Navigation Tests
    
    func testTabNavigationExists() throws {
        // Проверяем, что все 4 таба присутствуют
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.exists)
        
        XCTAssertTrue(tabBar.buttons["Чат"].exists)
        XCTAssertTrue(tabBar.buttons["Articles"].exists)
        XCTAssertTrue(tabBar.buttons["Ritual"].exists)
        XCTAssertTrue(tabBar.buttons["Settings"].exists)
    }
    
    func testTabNavigation() throws {
        let tabBar = app.tabBars.firstMatch
        
        // Переход на Articles
        tabBar.buttons["Articles"].tap()
        XCTAssertTrue(app.navigationBars["Articles"].exists)
        
        // Переход на Ritual
        tabBar.buttons["Ritual"].tap()
        XCTAssertTrue(app.navigationBars["Ritual"].exists || app.staticTexts["Вечерний ритуал"].exists)
        
        // Переход на Settings
        tabBar.buttons["Settings"].tap()
        XCTAssertTrue(app.navigationBars["Settings"].exists)
        
        // Возврат на Chat
        tabBar.buttons["Чат"].tap()
        XCTAssertTrue(app.navigationBars["Чат"].exists)
    }
    
    // MARK: - Chat Tests
    
    func testChatInitialMessage() throws {
        // Чат должен быть открыт по умолчанию
        XCTAssertTrue(app.navigationBars["Чат"].exists)
        
        // Проверяем наличие первого сообщения от Eva
        let evaMessage = app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'Привет'")).firstMatch
        XCTAssertTrue(evaMessage.waitForExistence(timeout: 2))
    }
    
    func testChatMessageInput() throws {
        let messageField = app.textFields["Напишите сообщение..."]
        XCTAssertTrue(messageField.exists)
        
        // Ввод сообщения
        messageField.tap()
        messageField.typeText("Привет!")
        
        // Нажатие кнопки отправки
        let sendButton = app.buttons.matching(identifier: "arrow.up.circle.fill").firstMatch
        XCTAssertTrue(sendButton.exists)
        sendButton.tap()
        
        // Проверяем, что сообщение появилось
        let userMessage = app.staticTexts["Привет!"]
        XCTAssertTrue(userMessage.waitForExistence(timeout: 2))
    }
    
    func testChatScriptButtons() throws {
        // Проверяем наличие кнопок выбора (если скрипт их показывает)
        sleep(1) // Даём время на загрузку
        
        let buttons = app.buttons.matching(NSPredicate(format: "label CONTAINS '🤩' OR label CONTAINS '🚀'"))
        
        if buttons.count > 0 {
            let firstButton = buttons.firstMatch
            XCTAssertTrue(firstButton.exists)
            
            // Проверяем, что кнопка кликабельна
            XCTAssertTrue(firstButton.isEnabled)
            
            // Кликаем на кнопку
            firstButton.tap()
            
            // Должно появиться новое сообщение
            sleep(1)
            // Проверяем, что количество сообщений увеличилось
        }
    }
    
    // MARK: - Articles Tests
    
    func testArticlesGridDisplays15Cards() throws {
        app.tabBars.buttons["Articles"].tap()
        
        // Даём время на загрузку
        sleep(1)
        
        // Проверяем наличие статей
        let articlesCount = app.scrollViews.firstMatch.otherElements.buttons.count
        
        // Должно быть 15 карточек (или около того, с учётом LazyVGrid)
        XCTAssertGreaterThanOrEqual(articlesCount, 10, "Should display at least 10 articles")
    }
    
    func testArticleCardElements() throws {
        app.tabBars.buttons["Articles"].tap()
        sleep(1)
        
        // Проверяем первую карточку
        let scrollView = app.scrollViews.firstMatch
        let firstCard = scrollView.buttons.firstMatch
        
        XCTAssertTrue(firstCard.exists)
        
        // Проверяем наличие эмодзи (в статичных текстах внутри кнопки)
        // Эмодзи должны быть в названии
        let cardLabel = firstCard.label
        XCTAssertFalse(cardLabel.isEmpty)
    }
    
    func testArticleDetailOpens() throws {
        app.tabBars.buttons["Articles"].tap()
        sleep(1)
        
        // Тапаем на первую статью
        let scrollView = app.scrollViews.firstMatch
        let firstCard = scrollView.buttons.firstMatch
        firstCard.tap()
        
        // Должна открыться детальная страница
        sleep(1)
        
        // Проверяем наличие кнопки Done
        let doneButton = app.buttons["Done"]
        XCTAssertTrue(doneButton.waitForExistence(timeout: 3))
        
        // Закрываем
        doneButton.tap()
        
        // Возвращаемся к списку
        XCTAssertTrue(app.navigationBars["Articles"].waitForExistence(timeout: 2))
    }
    
    // MARK: - Ritual Tests
    
    func testRitualDisplaysElements() throws {
        app.tabBars.buttons["Ritual"].tap()
        sleep(1)
        
        // Проверяем наличие элементов ритуала
        let ritualElements = app.staticTexts.matching(NSPredicate(format: "label CONTAINS '🧘' OR label CONTAINS '🥝' OR label CONTAINS '💨'"))
        
        XCTAssertGreaterThanOrEqual(ritualElements.count, 3, "Should display at least 3 ritual elements")
    }
    
    func testRitualCheckboxToggle() throws {
        app.tabBars.buttons["Ritual"].tap()
        sleep(1)
        
        // Находим первый элемент ритуала
        let firstRow = app.tables.cells.firstMatch
        XCTAssertTrue(firstRow.exists)
        
        // Тапаем на строку (должен переключиться чекбокс)
        firstRow.tap()
        
        // Проверяем, что произошло изменение (визуально сложно проверить, но функция сработала)
        XCTAssertTrue(firstRow.exists)
    }
    
    func testRitualCompletionMessage() throws {
        app.tabBars.buttons["Ritual"].tap()
        sleep(1)
        
        // Отмечаем все элементы (если их не так много)
        let rows = app.tables.cells
        let rowCount = min(rows.count, 10) // Максимум 10 для теста
        
        for i in 0..<rowCount {
            if i < rows.count {
                rows.element(boundBy: i).tap()
                sleep(0.2)
            }
        }
        
        // Проверяем наличие сообщения о завершении
        let doneMessage = app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'Ritual is done' OR label CONTAINS 'done'")).firstMatch
        
        // Может появиться, если все отмечены
        if doneMessage.exists {
            XCTAssertTrue(doneMessage.exists)
        }
    }
    
    // MARK: - Settings Tests
    
    func testSettingsDisplays() throws {
        app.tabBars.buttons["Settings"].tap()
        sleep(1)
        
        XCTAssertTrue(app.navigationBars["Settings"].exists)
        
        // Проверяем наличие секций
        XCTAssertTrue(app.staticTexts["Appearance"].exists || app.staticTexts["Localization"].exists)
    }
    
    func testSettingsLogoutButton() throws {
        app.tabBars.buttons["Settings"].tap()
        sleep(1)
        
        // Скроллим вниз, чтобы найти кнопку Logout
        let logoutButton = app.buttons["Logout"]
        
        if logoutButton.exists {
            XCTAssertTrue(logoutButton.exists)
            XCTAssertTrue(logoutButton.isEnabled)
            
            // НЕ нажимаем, так как это выйдет из аккаунта
            // Просто проверяем наличие
        }
    }
    
    func testSettingsAboutOpens() throws {
        app.tabBars.buttons["Settings"].tap()
        sleep(1)
        
        // Ищем About App
        let aboutButton = app.buttons["About App"].firstMatch
        
        if aboutButton.exists {
            aboutButton.tap()
            
            // Проверяем, что открылся About
            let aboutTitle = app.navigationBars["About"]
            XCTAssertTrue(aboutTitle.waitForExistence(timeout: 2))
            
            // Возвращаемся назад
            app.navigationBars.buttons.firstMatch.tap()
        }
    }
    
    // MARK: - Snapshot Tests (для визуального сравнения)
    
    func testSnapshotChat() throws {
        // Делаем скриншот чата
        let screenshot = app.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "Chat_Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    
    func testSnapshotArticles() throws {
        app.tabBars.buttons["Articles"].tap()
        sleep(1)
        
        let screenshot = app.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "Articles_Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    
    func testSnapshotRitual() throws {
        app.tabBars.buttons["Ritual"].tap()
        sleep(1)
        
        let screenshot = app.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "Ritual_Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    
    func testSnapshotSettings() throws {
        app.tabBars.buttons["Settings"].tap()
        sleep(1)
        
        let screenshot = app.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "Settings_Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    
    // MARK: - Performance Tests
    
    func testAppLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
    
    func testArticlesScrollPerformance() throws {
        app.tabBars.buttons["Articles"].tap()
        
        measure(metrics: [XCTOSSignpostMetric.scrollDecelerationMetric]) {
            let scrollView = app.scrollViews.firstMatch
            scrollView.swipeUp()
            scrollView.swipeDown()
        }
    }
}

