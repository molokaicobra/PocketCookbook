//
//  Recipe.swift
//  Fetch_Project
//
//  Created by Cobra Curtis on 9/10/23.
//

import Foundation


//Used for detailed recipe
struct RecipeWrapper: Codable {
    let meals: [[String:String?]]?
}

//Used for tableView
struct ShortHandResponse: Codable {
    let meals: [Meal]
}

struct Meal: Codable {
    let strMeal: String
    let idMeal: String
}

