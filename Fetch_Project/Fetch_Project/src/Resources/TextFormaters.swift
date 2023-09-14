//
//  textFormaters.swift
//  Fetch_Project
//
//  Created by Cobra Curtis on 9/12/23.
//

import Foundation


//TODO: Add in a method that allows for the better parsing and formatting of the instructions from our formatted recipe
/**
 Helper class that can format our text for us
 */
class textFormatters{
    
    /**
     Formats an array of ingredients and measurements so that they are one array that is in the string "\u{2022} (a bullet point) measurement ingredient" (Example: * 3 eggs).
     This method also removes some extra white space as some of the recipes had inconsistent white space usage after their measurements. This should now remove extra spaces and white space.
     
     - Parameter ingredients: [String] of the ingredients pulled straight from the JSON decoder. This is expected to be just a singular item per entry
     - Parameter measurements: [String] of measurements pulled straight from JSON decoder. This is expected to be just a singular item per entry. It can have special characters.
     
     - Warning: ensure that the arrays that you want to combine are in the order (i.e. if you want 1 cup of super make sure that both are in the same index)
     
     - Returns: [String] a combination of matching indexes of each array so that they are ready to be placed into the DetailedRecipeView (example: * 1/2 cup sugar)
     
     */
    static func combineIngredientsAndMeasurements(ingredients: [String], measurements: [String]) -> [String]{
        var results = [String]()
        for (index, ingredientValue) in ingredients.enumerated(){
            let measurementValue = measurements[index]
            results.append("\u{2022} \(measurementValue.trimmingCharacters(in: .whitespacesAndNewlines)) \(ingredientValue.trimmingCharacters(in: .whitespacesAndNewlines).lowercased())\n")
        }
        return results
    }
}
