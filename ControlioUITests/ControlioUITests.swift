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
        
        app.tables.cells.staticTexts["Building the Death Star"].tap()
        snapshot("1ProjectController")
        
        let houseCleaningNavigationBar = app.navigationBars["Building the Death Star"]
        houseCleaningNavigationBar.otherElements.children(matching: .button).element.tap()
        snapshot("2ProjectInfoController")
        
        let backButton = houseCleaningNavigationBar.buttons["Back"]
        backButton.tap()
        backButton.tap()
        
        let tabBarsQuery = app.tabBars
        tabBarsQuery.buttons["New Project"].tap()
        snapshot("3NewProjectController")
        
        tabBarsQuery.buttons["Support"].tap()
        snapshot("4SupportController")
    }
    
}
