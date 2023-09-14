//
//  RecipeNetworkLayer.swift
//  Fetch_Project
//
//  Created by Cobra Curtis on 9/10/23.
//

import Foundation

/**
 Performs all of our network calls 
 */
class RecipeAPI{
    
    
    //TODO: future improvement would be to take the thumbnail from the JSON response and use it in the RecipeTableView
    /**
     Main Function: Source the name and meal ids that are used to populate the `RecipeTableView`
     
     Calls on the API endpoint [https://www.themealdb.com/api/json/v1/1/filter.php?c=Dessert] that returns a JSON list of all
     recipes inside of the dessertCategory. Each objects in the JSON contains a strMeal (the reccipe's name), a strMealThumb (A recipe's thumbnail).
     and a idMeal (A meal id), here is an example of how one object would look:
     
     ["Meals": [{"strMeal":"Apam balik","strMealThumb":"https:\/\/www.themealdb.com\/images\/media\/meals\/adxcbq1619787919.jpg","idMeal":"53049"},  ... }]
     
     This method takes this response and decodes it into two structs defined in `RecipeStruct`. `ShortHandResponse` captures the overall "Meals" array which
     is filled with the `Meal` struct which captures the strMeal and idMeal from the JSON. Once the JSON has been decoded it becomes a dictionary of strMeals and idMeals.
     Example of how it looks:
     
     [(strMeal: "Apam balik", idMeal: "53049"), ...]
     
     For easier manipulation, referencing, and future keeping this dictionary is transformed into an array of tupled Strings [(String, String)] that gives us just the idMeals and strMeals.
     This data type is easy to modify and expand, and easier to reference. I then sort the elements of the tuple based on their strMeals to ensure that they appear in alphabetical order.
     
     - returns: [(String, String)] that contains an array of strMeals, and idMeals (example: [("Apam balik", "53049")...]
     - throws NTError.decoding:  error when there is a problem decoding from the JSON
     
     - SeeAlso: `RecipeStructs` and `getDataFromUrl(from:)`
     */
    func getRecipes() async throws -> [(String, String)] {
        
        let endpoint = "https://www.themealdb.com/api/json/v1/1/filter.php?c=Dessert"
        
        let JSONData = try await getDataFromURL(from: endpoint) //Get the JSON data
        
        do {
            //Decode the JSON
            let decoder = JSONDecoder()
            let dessertResponse = try decoder.decode(ShortHandResponse.self, from: JSONData) //Create an array filled with dictionaries of names and IDs
            
            var strMeals = dessertResponse.meals.map { ($0.strMeal, $0.idMeal) } //For each entry in the dictionary take the strMeal and idMeal and make it a tuple in the strMeal
            
            //Sort by the first element of the tuple
            strMeals.sort { $0.0 < $1.0 } //Sort the first entry of each tuple (the strMeal) by alphabetical order
            
            return strMeals
        } catch {
            throw NTError.decodingError
        }
    }
    
    
    /**
     Main Function: Source and format a specific recipe so it can be used in `DetailedRecipeView`
     
     Calls on the API endpoint"https://www.themealdb.com/api/json/v1/1/lookup.php?i=\(recipeID)" where recipeID
     is the ID of the selected Recipe. It then gets back the selected JSON data and decodes it into a custom struct that holds all of the data.
     
     The mealWrapper is an optional array of String of Optional Strings ( [[String:String?]?) because if a response fails (A bad URL, changed end point, or
     corrupted data is received) then it is possible for the API  to still pass JSON with empty data or  null data  instead of a 404 or other HTTP responses that we can track.
     The [String:String?] is because it is possible for the JSON to have missing parameters. Once this original data is received if parsed it using the `formatOriginalRecipe`
     
     After it has been formatted the recipe is returned as [String:Any]
     
    
     */
    func getAndFormatRecipe(recipeID: String) async throws -> [String: Any] {
        var formattedRecipe = [String: Any]()

        let endpoint = "https://www.themealdb.com/api/json/v1/1/lookup.php?i=\(recipeID)"
        do {
            let JSONData = try await getDataFromURL(from: endpoint)
            
            do {
                let decoder = JSONDecoder()
                let recipeList = try decoder.decode(RecipeWrapper.self, from: JSONData)
                
                if recipeList.meals?.count == nil {
                    throw NTError.invalidData
                }
                
                if recipeList.meals!.count > 1{ //Know it's not nil from previous if statement
                    throw NTError.invalidData //There should only be one meal for recipeID. This would mean that there are multiple recipes matching one ID
                }
                
                formattedRecipe = formatOriginalRecipe(originalRecipe: recipeList)
            } catch  NTError.decodingError {
                throw NTError.decodingError
            }
        } catch {
            throw error
        }
        
        return formattedRecipe
    }

    
    /**
     The method pulls all of the data from the original RecipeWrapper (The basic JSON structure) and then formats it into a [String:Any].
     [String:Any] was used as it allowed me to keep the overall style of the JSON data while allowing me to expand on what was actually being
     stored for any key. In this format I am able to store a sorted and prematched arrays of the ingredients and measurements.
     
     I decided to make a custom format for the original data for the following reasons:
        `Easy storing and sorting of ingredients and measurements` since both dictionaries and JSON decoders are not guaranteed to be ordered this has to be done to ensure that measurements and ingredients are matched and ordered as intended
        The API is inconsistent with how it identifies missing data. It is using nil, none, " ", or empty strings to identify it.
        The API JSON call always returns 20 ingredients and 20 measurements even when they are not usee. This data is unnecessary and hard to parse so we can remove it.
        We can have any amount of ingredients and measurements.
        it is easier to use my own format of just a dictionary so I can easily reference the sections I actually need and want
        I can write helper classes that allow for the easier parsing of data that can lead to easier UI creation (I.E. I get to put ingredients and recipes into one object that can be called as one in DetailedRecipeView)
     
     - parameter originalRecipe: the original RecipeWrapper struct that has all of the necessary JSON data
     
     - returns: [String:Any] of the formatted recipe
     */
    func formatOriginalRecipe(originalRecipe: RecipeWrapper) -> [String: Any] {
        var formattedRecipe = [String: Any]()
        var ingredients = [String]()
        var measurements = [String]()
        
        
        if let meals = originalRecipe.meals {
            for mealDictionary in meals { //There should only be one meal for the meals
                //Sort keys so we can go through the list
                let sortedKeys = Array(mealDictionary.keys).sorted(using: .localizedStandard) //Sort the keys so that ingredients and measurements appear in their correct order
                
                for key in sortedKeys {
                    if let dictValue = mealDictionary[key], dictValue != nil && dictValue != " " && dictValue != "nil" && dictValue != "" { //Account for the ways in which API shows nil
                        if key.contains("strIngredient") {
                            ingredients.append(dictValue!)
                        } else if key.contains("strMeasure") {
                            measurements.append(dictValue!)
                        } else {
                            formattedRecipe[key] = dictValue
                        }
                    }
                }
            }
        }
        
        formattedRecipe["ingredients"] = ingredients
        formattedRecipe["measurements"] = measurements
        formattedRecipe["combinedIngredientsAndMeasurements"] = textFormatters.combineIngredientsAndMeasurements(ingredients: ingredients, measurements: measurements) //Format into one usable array of strings
        return formattedRecipe
    }
    
    /**
    Helper function that gets JSON data from a provided String endPoint and return it as a Data type for use by the caller.
     
     - Throws:
        - NtError.invalidResponse (received a non 200 response from the API)
        - NTError.unsupportedURL: the URL is of an unsupported type and failed to load.
     
     */
    func getDataFromURL(from endpoint: String) async throws -> Data{
        
        guard let url = URL(string: endpoint) else {
            throw NTError.invalidURL
        }
        
        
        do {
            let (JSONData, response) = try await URLSession.shared.data(from: url)
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                throw NTError.invalidResponse
            }
            
            return JSONData
        } catch NTError.invalidResponse {
            throw NTError.invalidResponse
        } catch {
            throw NTError.unsupportedURL
        }
        

        
        
    }
    
}
