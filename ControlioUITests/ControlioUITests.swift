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
        
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
    }
    
    func testSnapshots() {
        let app = XCUIApplication()
        app.buttons.element(matching: .button, identifier: "Demo button").tap()
        let firstCell = app.tables.children(matching: .cell).element(boundBy: 0)
        let start = firstCell.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0))
        let finish = firstCell.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: -6))
            start.press(forDuration: 0, thenDragTo: finish)
        snapshot("0ProjectsController")
        
        app.tables.children(matching: .cell).element(boundBy: 0).tap()
        snapshot("1ProjectController")
        
        app.navigationBars.otherElements.children(matching: .button).element.tap()
        snapshot("2ProjectInfoController")
        
        let backButton = app.navigationBars.buttons.element(boundBy: 0)
        backButton.tap()
        backButton.tap()
        
        let tabBarsQuery = app.tabBars
        tabBarsQuery.buttons.element(boundBy: 1).tap()
        snapshot("3NewProjectController")
        
        tabBarsQuery.buttons.element(boundBy: 2).tap()
        snapshot("4SupportController")
    }
    
}
