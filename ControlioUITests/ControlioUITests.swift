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
        app.buttons.element(matching: .button, identifier: "Demo button")
        snapshot("0ProjectsController")
        
        app.tables.children(matching:.any).element(boundBy: 0).tap()
        snapshot("1ProjectController")
        
        app.navigationBars.otherElements.children(matching: .button).element.tap()
        snapshot("2ProjectInfoController")
        
        let backButton = app.navigationBars.element(boundBy: 0)
        backButton.tap()
        backButton.tap()
        
        let tabBarsQuery = app.tabBars
        tabBarsQuery.buttons.element(boundBy: 1).tap()
        snapshot("3NewProjectController")
        
        tabBarsQuery.element(boundBy: 2).tap()
        snapshot("4SupportController")
    }
    
}
