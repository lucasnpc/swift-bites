# SwiftBites

A modern recipe management app built with SwiftUI and SwiftData. SwiftBites helps you organize your recipes, manage ingredients, categorize dishes, and create shopping lists.

## Features

### 📖 Recipe Management
- Create and edit recipes with detailed information
- Add custom images to recipes
- Organize recipes by categories
- Set serving size and preparation time
- Add step-by-step cooking instructions
- Link multiple ingredients with quantities to each recipe

### 🏷️ Categories
- Organize recipes into custom categories
- View all recipes grouped by category
- Edit or delete categories with automatic nullification of relationships

### 🥕 Ingredients
- Manage your ingredient inventory
- Mark ingredients as available or unavailable
- Track which ingredients are used in recipes
- Automatic validation when ingredients are deleted

### 🛒 Shopping List
- Automatically generates a shopping list from unavailable ingredients
- Mark ingredients as available directly from the shopping list
- Quick access to ingredients you need to purchase

## Technical Details

### Architecture
- **Framework**: SwiftUI
- **Data Persistence**: SwiftData
- **Platform**: iOS
- **Language**: Swift

### Data Models
- **Recipe**: Main recipe entity with name, summary, category, serving size, time, instructions, and image
- **Ingredient**: Ingredient entity with name and availability status
- **Category**: Category entity for organizing recipes
- **RecipeIngredient**: Junction entity linking recipes to ingredients with quantities

### Key Features
- **Safe Data Handling**: Robust nullification and cascade delete rules to prevent crashes when data is deleted
- **Input Validation**: Numeric-only quantity fields with decimal support
- **Data Integrity**: Automatic filtering of invalid relationships when parent objects are deleted
- **Modern UI**: Clean, intuitive interface following iOS design guidelines

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

## Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/swift-bites.git
cd swift-bites
```

2. Open the project in Xcode:
```bash
open SwiftBites.xcodeproj
```

3. Build and run the project in Xcode (⌘R)

## Project Structure

```
SwiftBites/
├── App.swift                 # App entry point and SwiftData configuration
├── Main.swift                # Main tab view
├── Models.swift              # SwiftData model definitions
├── Utils.swift               # Helper functions and extensions
├── Recipes/
│   ├── RecipesView.swift     # Recipe list view
│   ├── RecipeForm.swift     # Recipe creation/editing form
│   └── RecipeCell.swift      # Recipe cell component
├── Categories/
│   ├── CategoriesView.swift # Category list view
│   ├── CategoryForm.swift   # Category creation/editing form
│   └── CategorySection.swift # Category section component
├── Ingredients/
│   ├── IngredientsView.swift # Ingredient list view
│   └── IngredientForm.swift  # Ingredient creation/editing form
└── ShoppingList/
    └── ShoppingListView.swift # Shopping list view
```

## Usage

### Creating a Recipe
1. Navigate to the Recipes tab
2. Tap the "+" button to add a new recipe
3. Fill in the recipe details (name, summary, category, serving size, time)
4. Add ingredients by tapping "Add Ingredient"
5. Enter quantities for each ingredient (numeric values only)
6. Add cooking instructions
7. Optionally add a recipe image
8. Tap "Save" to create the recipe

### Managing Ingredients
1. Go to the Ingredients tab
2. Tap "+" to add a new ingredient
3. Toggle availability status as needed
4. Swipe left on an ingredient to delete it

### Organizing with Categories
1. Navigate to the Categories tab
2. Tap "+" to create a new category
3. Assign categories to recipes when creating or editing them
4. View all recipes grouped by category

### Shopping List
1. Open the Shopping List tab
2. View all ingredients marked as unavailable
3. Tap the checkmark to mark ingredients as available
4. Use "Mark All Available" to clear the entire list

## Data Relationships

- **Recipe ↔ Category**: Many-to-one relationship with nullify delete rule
- **Recipe ↔ RecipeIngredient**: One-to-many relationship with cascade delete rule
- **Ingredient ↔ RecipeIngredient**: One-to-many relationship with nullify delete rule

When a category or ingredient is deleted, related recipes and recipe ingredients are safely handled through nullification, preventing crashes and maintaining data integrity.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is available for use under the MIT License.

## Authors

- Lucas NPC
- David
- Omar

---

Built with ❤️ using SwiftUI and SwiftData
