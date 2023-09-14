//
//  SecondScreen.swift
//  Fetch_Project
//
//  Created by Cobra Curtis on 9/10/23.
//

import UIKit

/**
 Displays a table of recipes to the user in alphabetical order 
 */
class RecipeTableView: UIViewController, UITableViewDataSource, UITableViewDelegate {
    let tableView = UITableView()
    private let recipeAPICaller = RecipeAPI()
    
    //An array of (strMeals, idMeals) that is used to populate the tableView
    private var recipes: [(String, String)]?

    

    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Network Call
        Task {
            //Call get recipe names and IDs
            await fetchRecipes()
        }
        
        //Fill in the cells of the tableView
        setUpUI()
        
        //Accessibility
        tableView.accessibilityIdentifier = "recipeTableView"
        
        
    }
    
    //TODO: Create popup and have error sent to remote database for tracking
    /**
     This method makes a call to the dedicated network layer and populates self.recipes.
     
     - Note: This method runs async and is making network calls.
     
    - Catches:

       - `NTError.invalidURL`: If the API URL is invalid.
       - `NTError.invalidResponse`: If the API response is not as expected.
       - `NTError.invalidData`: If the data received from the API is invalid.
       - `NTError.badRequest`: If the API request is malformed or incorrect.
       - `NTError.decodingError`: If there is an error decoding the JSON from the API.
       - Any other unexpected errors.
     */
    private func fetchRecipes() async {
        do {
            self.recipes = try await recipeAPICaller.getRecipes()
            // Update the table view with the fetched data on the main thread
            DispatchQueue.main.async {
                //Reload the table with the data that was fetched from our API calls.
                self.tableView.reloadData()
            }
        } catch NTError.invalidURL {
            print("Invalid URL")
        } catch NTError.invalidResponse {
            print("Invalid Response")
        } catch NTError.invalidData {
            print("Invalid data")
        } catch NTError.badRequest {
            print("Bad Request")
        } catch NTError.decodingError {
            print("Decoding Error")
        } catch {
            print("An unexpected error occurred: \(error)")
        }
    }
    

    //TODO: Add in a small transition/loading screen between the loading of data and the population of the UI. Or store recipe data locally
    /**
     Setup the different UI elements of the recipeTableView.
     Also registers and creates and setups the cells of the tableView
     - seealso: setUpTableView()
     - Modifies: TableView, view, and cells
     
     */
    func setUpUI() {
        // View
        view.backgroundColor = .systemBackground
        navigationItem.largeTitleDisplayMode = .never

        // TableView
        tableView.separatorColor = .systemGray
        tableView.backgroundColor = .systemBackground
        tableView.dataSource = self
        tableView.delegate = self // Set the delegate to keep track of cell selection
        view.addSubview(tableView)
        setUpTableView() //creates and design the tableView
        
        //Register cells of tableView for reuse
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "recipeCell")
    }

    
    /**
     Programmatically setup the Auto Layout constraints for the tableView
     - Note: called by setUpUI.
     */
    func setUpTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])

    }

    /**
     Programmatically determine the number of rows in the UI. It is either the number of recipes found in the network call or set to 0.
     Must be set to 0 to handle the case where the recipes array may be empty or if the network call takes longer than expected.
     Future improvements could be related to local storage.
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of recipes, or 0 if recipes is nil
        return self.recipes?.count ?? 0
    }

    /**
     Programmatically set the information inside of the tableView cell.
     Adds in the cell's recipe name from self.recipes and assigns it. If no name is available then replaces it with "Recipe Not Available", though recipes should have already been checked before reaching this point.
     Assigns cells for reusability for built in queue.
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recipeCell", for: indexPath)
        
        if let recipe = self.recipes?[indexPath.row] {
            cell.textLabel?.text = recipe.0.capitalized
            
            // Set accessibility identifier for the cell
            cell.accessibilityIdentifier = "\(recipe.0.capitalized)"
        } else {
            cell.textLabel?.text = "Recipe Not Available"
            
            // Set accessibility identifier for the cell
            cell.accessibilityIdentifier = "Recipe Not Found"
        }
        
         

        
        return cell
    }


    /**
     Allows the user to select the desired recipe from the tableViewCell and then cause a transition from this view to the DetailedRecipeView class.
     This method relies on
     */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true) // Deselect the cell

        // Navigate to the detail page (RecipeDetailViewController)
        let recipeDetailVC = DetailedRecipeView(selectedRecipe: recipes![indexPath.row].1) // Initialize your detail view controller with the mealID
        self.navigationController?.pushViewController(recipeDetailVC, animated: true)
    }
}



