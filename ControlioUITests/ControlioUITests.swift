//
//  ControlioUITests.swift
//  ControlioUITests
//
//  Created by Nikita Kolmogorov on 11/03/2017.
//  Copyright © 2017 Nikita Kolmogorov. All rights reserved.
//

import XCTest

class ControlioUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        continueAfterFailure = false
        
        let app = XCUIApplication()
        app.launchArguments = ["isUITesting"]
        setupSnapshot(app)
        app.launch()
    }
    
    func testSnapshots() {
        let app = XCUIApplication()
        
        app.buttons["Want to see how Controlio works first?"].tap()
        snapshot("0ProjectsController")
        
        app.tables.staticTexts["Apartment renovation"].tap()
        snapshot("1ProjectController")
        
        app.navigationBars["Apartment renovation"].otherElements.children(matching: .button).element.tap()
        let apartmentRenovationNavigationBar = XCUIApplication().navigationBars["Apartment renovation"]
        snapshot("2ProjectInfoController")
        
        let backButton = apartmentRenovationNavigationBar.buttons["Back"]
        backButton.tap()
        backButton.tap()
        app.tabBars.buttons["New Project"].tap()
        snapshot("3NewProjectController")
        
        app.tabBars.buttons["Support"].tap()
        snapshot("4SupportController")
    }
    
}
