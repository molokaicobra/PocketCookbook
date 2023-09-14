//
//  Fetch_ProjectUITests.swift
//  Fetch_ProjectUITests
//
//  Created by Cobra Curtis on 9/14/23.
//

import XCTest

final class Fetch_ProjectUITests: XCTestCase {

    override func setUpWithError() throws {
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        
        let device = XCUIDevice.shared
        device.orientation = .portrait

    }

    /**
     A automated walk through of the app that checks that the UI elements exist, and contain the right values
     */
    func testWholeWalkThrough() throws {
        //Launch app
        let app = XCUIApplication()
        app.launch()
        
        //Open main menu
        XCTAssertTrue(app.buttons["nextButton"].exists) // assert home scren is real
        XCTAssertTrue(app.staticTexts["titleLabel"].exists)
        app.buttons["nextButton"].tap() //Move to next screen
        
        
        let recipetableviewTable = app.tables["recipeTableView"]
        XCTAssertTrue(app.tables["recipeTableView"].exists) // is the tableView real
        
        XCTAssertTrue(recipetableviewTable.cells["Apam balik"].exists)
        recipetableviewTable.cells["Apam balik"].tap()

        //Test that the right meal was actually selected
        var nameLabel = app.staticTexts["mealLabel"]
        XCTAssertTrue(nameLabel.exists)
        var actualText = nameLabel.label
        var expectedText = "Apam balik"
        XCTAssertEqual(actualText, expectedText)


        //Exist to the recipe view and scroll the page
        app.scrollViews.containing(.staticText, identifier:"Apam balik").element.swipeUp()
        app.navigationBars["Fetch_Project.DetailedRecipeView"].buttons["Dessert Recipes"].tap()
        recipetableviewTable.cells["Chinon Apple Tarts"].swipeUp()
        recipetableviewTable.cells["Strawberry Rhubarb Pie"].tap()
        
        
        //Test that the new right recipe was selected
        nameLabel = app.staticTexts["mealLabel"]
        XCTAssertTrue(nameLabel.exists)
        actualText = nameLabel.label
        expectedText = "Strawberry Rhubarb Pie"
        XCTAssertEqual(actualText, expectedText)
        
        //Assert that the elements of the Strawberry Rhubarb recipe exist
        let instructionsTextView = app.textViews["Instructions"]
        XCTAssertTrue(instructionsTextView.exists)
        
        let imageView = app.images["picture of dessert"]
        XCTAssertTrue(imageView.exists)
        
        let ingredientsAndMeasurementsTextView = app.textViews["IngredientsAndMeasurements"]
        XCTAssertTrue(ingredientsAndMeasurementsTextView.exists)                
}

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
