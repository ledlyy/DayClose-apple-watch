//
//  DayCloseUITests.swift
//  DayClose Watch App UI Tests
//
//  UI tests for main user flows
//

import XCTest

final class DayCloseUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    func testAppLaunch() throws {
        // Verify app launches successfully
        XCTAssertTrue(app.state == .runningForeground)
    }
    
    func testMoodSelectionFlow() throws {
        // Wait for main view to appear
        let checkInButton = app.buttons["Check In"]
        XCTAssertTrue(checkInButton.waitForExistence(timeout: 5))
        
        // Tap check-in button
        checkInButton.tap()
        
        // Wait for mood selection view
        sleep(1)
        
        // Select a mood (good mood)
        let goodMoodButton = app.buttons.containing(NSPredicate(format: "label CONTAINS '😊'")).firstMatch
        if goodMoodButton.exists {
            goodMoodButton.tap()
            
            // Confirm selection
            let confirmButton = app.buttons["Confirm"]
            if confirmButton.exists {
                confirmButton.tap()
                
                // Wait for feedback view
                sleep(2)
                
                // Tap done
                let doneButton = app.buttons["Done"]
                if doneButton.exists {
                    doneButton.tap()
                }
            }
        }
    }
    
    func testNavigationToTrends() throws {
        // Swipe up to navigate to trends tab
        app.swipeUp()
        
        // Verify trends view elements
        let trendsTitle = app.staticTexts["Your Week"]
        XCTAssertTrue(trendsTitle.waitForExistence(timeout: 3))
    }
    
    func testNavigationToSettings() throws {
        // Swipe up twice to navigate to settings tab
        app.swipeUp()
        app.swipeUp()
        
        // Verify settings view elements
        let settingsTitle = app.staticTexts["Settings"]
        XCTAssertTrue(settingsTitle.waitForExistence(timeout: 3))
        
        // Verify key settings exist
        let reminderToggle = app.switches["Evening Reminder"]
        XCTAssertTrue(reminderToggle.exists)
    }
    
    func testAccessibilityLabels() throws {
        // Verify key elements have accessibility labels
        let checkInButton = app.buttons["Check In"]
        XCTAssertTrue(checkInButton.waitForExistence(timeout: 5))
        XCTAssertFalse(checkInButton.label.isEmpty)
    }
}
