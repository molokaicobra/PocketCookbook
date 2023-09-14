//
//  RecipeAPITest.swift
//  Fetch_ProjectTests
//
//  Created by Cobra Curtis on 9/13/23.
//

import XCTest
@testable import Fetch_Project

final class RecipeAPITest: XCTestCase {
    
    var recipeAPI: RecipeAPI = RecipeAPI()
    var goodRecipeID: String = "53049"
    var badRecipeID: String = "1"
    
    var originalRecipe: RecipeWrapper? = nil
    var wholeTestURL: String = "https://www.themealdb.com/api/json/v1/1/lookup.php?i=\(53049)"
    var brokenTestURL: String = "com/api/json/v1/1/lookup.php?i=\(53049)"
    
    
    override func setUpWithError() throws {
        
        //Decode the recipeWrapperTestRecipe into our RecipeWrapper class for testing against others. Loaded JSON is known to be good.
        if let jsonData = self.originalTestRecipe.data(using: .utf8) {
            do {
                let decoder = JSONDecoder()
                self.recipeWrapperTestRecipe = try decoder.decode(RecipeWrapper.self, from: jsonData)
            } catch {
                print("Error parsing JSON during startup: \(error)")
                throw NTError.decodingError
            }
        }
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
        
    /**
     check that getDataFromURL is working properly.
     
     - Pass conditions:
        - It can properly decode and format a JSON file
        - It can properly throw an error if something goes wrong (a bad idMeal is passed, or a brokenURL was passed in)
     */
    func testGetRecipe() async{
        
        do {
            // Handle the successful result here
            let result = try await recipeAPI.getAndFormatRecipe(recipeID: self.goodRecipeID)
            // Handle the successful result here
            XCTAssertNotNil(result)
            XCTAssertTrue(NSDictionary(dictionary: self.formatedTestRecipe).isEqual(to: result))
        } catch NTError.invalidResponse {
            // Handle the specific error of invalid response
            XCTFail("An error was encountered when accessing the URL for a single recipe. NTError.invalidResponse")
        } catch NTError.invalidURL {
            // Handle the specific error of invalid URL
            XCTFail("An error was encountered when processing the URL for a single recipe. NTError.invalidURL")
        } catch NTError.decodingError {
            // Handle the specific error of decoding error
            XCTFail("An error was encountered when decoding the JSON for a single recipe. NTError.decodingError")
        } catch NTError.invalidData{
            XCTFail("an error occurred after the JSON was read, the meal list was empty. NTError.invalidData")
        } catch {
            XCTFail("An unknown error occurred \(error)")
        }

        //Test for throws
        do {
            // Handle the successful result here
            var result = try await recipeAPI.getAndFormatRecipe(recipeID: self.badRecipeID)
            // Handle the successful result here
            XCTAssertNil(result, "Result from a bad recipe call was not nil")

            result = try await recipeAPI.getAndFormatRecipe(recipeID: self.brokenTestURL)
        } catch NTError.invalidResponse {
            // Handle the specific error of invalid response
            XCTAssertTrue(true, "NTError.invalidResponse positively detected")
        } catch NTError.invalidURL {
            // Handle the specific error of invalid URL
            XCTAssertTrue(true, "NTError.invalidURL positively detected")
        } catch NTError.decodingError {
            // Handle the specific error of decoding error
            XCTAssertTrue(true, "NTError.decodingError positively detected")
        } catch NTError.invalidData{
            XCTAssertTrue(true, "NTError.invalidData positively detected")
        } catch {
            XCTFail("An unknown error occurred \(error)")
        }
        
    }
    
    /**
     check that getDataFromURL is working properly.
     
     - Pass conditions:
        - It can properly decode a RecipeWrapper class and have it's meals match the known good one.
        - It can properly throw an error if something goes wrong (a broken URL is passed)
     */
    func testGetDataFromURL() async{

        //No Error Pass Through
        do {

            let result = try await recipeAPI.getDataFromURL(from: self.wholeTestURL)
            let decoder = JSONDecoder()
            let decodedResult = try decoder.decode(RecipeWrapper.self, from: result)

            XCTAssertEqual(decodedResult.meals, self.recipeWrapperTestRecipe?.meals)
        } catch NTError.invalidResponse {
            // Handle the specific error of invalid response
            XCTFail("An error was encountered when accessing the URL for getDataFromURL. NTError.invalidResponse")
        } catch NTError.invalidURL {
            // Handle the specific error of invalid URL
            XCTFail("An error was encountered when processing the URL for getDataFromURL. NTError.invalidURL")
        }catch NTError.unsupportedURL{
            XCTFail("Unsupported URL was passed when processing the URL for getDataFromURL")
        } catch {
            XCTFail("An unknown error occurred \(error)")
        }

        
        // Check that the Errors worked and that the getDataFromURL returns nil when it can not get the data.
        do{
            let result = try await recipeAPI.getDataFromURL(from: self.brokenTestURL)
            XCTAssertNil(result)
        } catch NTError.invalidResponse {
            // Handle the specific error of invalid response
            XCTAssertTrue(true, "An error was encountered when accessing the URL for getDataFromURL. NTError.invalidResponse")
        } catch NTError.invalidURL {
            // Handle the specific error of invalid URL
            XCTAssertTrue(true, "An error was encountered when processing the URL for getDataFromURL. NTError.invalidURL")
        } catch NTError.unsupportedURL{
            XCTAssertTrue(true, "Unsupported URL was caught")
        } catch{
            XCTFail("An unknown error occurred \(error)")
        }
    }
    
    /**
     a test case for GetRecipes() network call.
     
     Ensures that the recipe is in alphabetical order and matches the hand made list.
     
     Failure conditions: fails if an error occurs when the code is running or when the arrays do no match
     */
    func testGetRecipes() async{
        
        do{
            let result = try await recipeAPI.getRecipes()
            for (index, dessertName)  in self.dessertNamesandIds.enumerated(){
                if dessertName.0 != result[index].0 || dessertName.1 != result[index].1{
                    XCTFail("The order of the dessertNamesAndIds does not match the order in testing")
                }
            }
            
        } catch NTError.decodingError {
            XCTFail("Encountered an encoding error when fetching recipes list")
        } catch{
            XCTFail("An unknown error occurred \(error)")
        }
        
    }
    
    
    //MARK: Helper Functions 
    /**
     helper method that ensures that two arrays of [(String, String)] are of equal length. This has to be done because
     the (String, String) type can not be compared by default.
     */
    func areArraysEqual(_ array1: [(String, String)], _ array2: [(String, String)]) -> Bool {
        // Check if both arrays have the same count
        if array1.count != array2.count {
            return false
        }
        
        // Iterate through both arrays and compare each element
        for (element1, element2) in zip(array1, array2) {
            if element1 != element2 {
                return false
            }
        }
        
        // If all elements are equal, the arrays are the same
        return true
    }
    
    
    
    //MARK: Large properties used for testing expected returns
    
    //Test Recipe Valid
    var recipeWrapperTestRecipe : RecipeWrapper?
    var originalTestRecipe: String = """
    {
       "meals":[
          {
             "idMeal":"53049",
             "strMeal":"Apam balik",
             "strDrinkAlternate":null,
             "strCategory":"Dessert",
             "strArea":"Malaysian",
             "strInstructions":"Mix milk, oil and egg together. Sift flour, baking powder and salt into the mixture. Stir well until all ingredients are combined evenly.\\r\\n\\r\\nSpread some batter onto the pan. Spread a thin layer of batter to the side of the pan. Cover the pan for 30-60 seconds until small air bubbles appear.\\r\\n\\r\\nAdd butter, cream corn, crushed peanuts and sugar onto the pancake. Fold the pancake into half once the bottom surface is browned.\\r\\n\\r\\nCut into wedges and best eaten when it is warm.",
             "strMealThumb":"https:\\/\\/www.themealdb.com\\/images\\/media\\/meals\\/adxcbq1619787919.jpg",
             "strTags":null,
             "strYoutube":"https:\\/\\/www.youtube.com\\/watch?v=6R8ffRRJcrg",
             "strIngredient1":"Milk",
             "strIngredient2":"Oil",
             "strIngredient3":"Eggs",
             "strIngredient4":"Flour",
             "strIngredient5":"Baking Powder",
             "strIngredient6":"Salt",
             "strIngredient7":"Unsalted Butter",
             "strIngredient8":"Sugar",
             "strIngredient9":"Peanut Butter",
             "strIngredient10":"",
             "strIngredient11":"",
             "strIngredient12":"",
             "strIngredient13":"",
             "strIngredient14":"",
             "strIngredient15":"",
             "strIngredient16":"",
             "strIngredient17":"",
             "strIngredient18":"",
             "strIngredient19":"",
             "strIngredient20":"",
             "strMeasure1":"200ml",
             "strMeasure2":"60ml",
             "strMeasure3":"2",
             "strMeasure4":"1600g",
             "strMeasure5":"3 tsp",
             "strMeasure6":"1\\/2 tsp",
             "strMeasure7":"25g",
             "strMeasure8":"45g",
             "strMeasure9":"3 tbs",
             "strMeasure10":" ",
             "strMeasure11":" ",
             "strMeasure12":" ",
             "strMeasure13":" ",
             "strMeasure14":" ",
             "strMeasure15":" ",
             "strMeasure16":" ",
             "strMeasure17":" ",
             "strMeasure18":" ",
             "strMeasure19":" ",
             "strMeasure20":" ",
             "strSource":"https:\\/\\/www.nyonyacooking.com\\/recipes\\/apam-balik~SJ5WuvsDf9WQ",
             "strImageSource":null,
             "strCreativeCommonsConfirmed":null,
             "dateModified":null
          }
       ]
    }
    """



    var formatedTestRecipe: [String:Any] = [

         "idMeal":"53049",
         "strMeal":"Apam balik",
         "strCategory":"Dessert",
         "strArea":"Malaysian",
         "strInstructions":"Mix milk, oil and egg together. Sift flour, baking powder and salt into the mixture. Stir well until all ingredients are combined evenly.\r\n\r\nSpread some batter onto the pan. Spread a thin layer of batter to the side of the pan. Cover the pan for 30-60 seconds until small air bubbles appear.\r\n\r\nAdd butter, cream corn, crushed peanuts and sugar onto the pancake. Fold the pancake into half once the bottom surface is browned.\r\n\r\nCut into wedges and best eaten when it is warm.",
         "strMealThumb":"https://www.themealdb.com/images/media/meals/adxcbq1619787919.jpg",
         "strYoutube":"https://www.youtube.com/watch?v=6R8ffRRJcrg",
         "ingredients":["Milk", "Oil", "Eggs", "Flour", "Baking Powder", "Salt", "Unsalted Butter", "Sugar", "Peanut Butter"],
         "measurements": ["200ml", "60ml", "2", "1600g", "3 tsp", "1/2 tsp", "25g", "45g", "3 tbs"],
         "combinedIngredientsAndMeasurements" : ["• 200ml Milk\n", "• 60ml Oil\n", "• 2 Eggs\n", "• 1600g Flour\n", "• 3 tsp Baking Powder\n", "• 1/2 tsp Salt\n", "• 25g Unsalted Butter\n", "• 45g Sugar\n", "• 3 tbs Peanut Butter\n"],
         "strSource":"https://www.nyonyacooking.com/recipes/apam-balik~SJ5WuvsDf9WQ"
   ]
//
    var dessertNamesandIds: [(String, String)] = [("Apam balik", "53049"), ("Apple & Blackberry Crumble", "52893"), ("Apple Frangipan Tart", "52768"), ("Bakewell tart", "52767"), ("Banana Pancakes", "52855"), ("Battenberg Cake", "52894"), ("BeaverTails", "52928"), ("Blackberry Fool", "52891"), ("Bread and Butter Pudding", "52792"), ("Budino Di Ricotta", "52961"), ("Canadian Butter Tarts", "52923"), ("Carrot Cake", "52897"), ("Cashew Ghoriba Biscuits", "52976"), ("Chelsea Buns", "52898"), ("Chinon Apple Tarts", "52910"), ("Choc Chip Pecan Pie", "52856"), ("Chocolate Avocado Mousse", "52853"), ("Chocolate Caramel Crispy", "52966"), ("Chocolate Gateau", "52776"), ("Chocolate Raspberry Brownies", "52860"), ("Chocolate Souffle", "52905"), ("Christmas Pudding Flapjack", "52788"), ("Christmas Pudding Trifle", "52989"), ("Christmas cake", "52990"), ("Classic Christmas pudding", "52988"), ("Dundee cake", "52899"), ("Eccles Cakes", "52888"), ("Eton Mess", "52791"), ("Honey Yogurt Cheesecake", "53007"), ("Hot Chocolate Fudge", "52787"), ("Jam Roly-Poly", "52890"), ("Key Lime Pie", "52859"), ("Krispy Kreme Donut", "53015"), ("Madeira Cake", "52900"), ("Mince Pies", "52991"), ("Nanaimo Bars", "52924"), ("New York cheesecake", "52858"), ("Pancakes", "52854"), ("Parkin Cake", "52902"), ("Peach & Blueberry Grunt", "52862"), ("Peanut Butter Cheesecake", "52861"), ("Peanut Butter Cookies", "52958"), ("Pear Tarte Tatin", "52916"), ("Polskie Naleśniki (Polish Pancakes)", "53022"), ("Portuguese custard tarts", "53046"), ("Pouding chomeur", "52932"), ("Pumpkin Pie", "52857"), ("Rock Cakes", "52901"), ("Rocky Road Fudge", "52786"), ("Rogaliki (Polish Croissant Cookies)", "53024"), ("Salted Caramel Cheescake", "52833"), ("Seri muka kuih", "53054"), ("Spotted Dick", "52886"), ("Sticky Toffee Pudding", "52883"), ("Sticky Toffee Pudding Ultimate", "52793"), ("Strawberry Rhubarb Pie", "53005"), ("Sugar Pie", "52931"), ("Summer Pudding", "52889"), ("Tarte Tatin", "52909"), ("Timbits", "52929"), ("Treacle Tart", "52892"), ("Tunisian Orange Cake", "52970"), ("Walnut Roll Gužvara", "53062"), ("White chocolate creme brulee", "52917")]

    
    
    
    
}

    


