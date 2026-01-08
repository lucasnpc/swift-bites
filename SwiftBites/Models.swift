import Foundation
import SwiftData

@Model
final class Ingredient {
  @Attribute(.unique) var name: String
  var isAvailable: Bool
  
  init(name: String = "", isAvailable: Bool = true) {
    self.name = name
    self.isAvailable = isAvailable
  }
}

@Model
final class Category {
  @Attribute(.unique) var name: String
  
  init(name: String = "") {
    self.name = name
  }
}

@Model
final class RecipeIngredient {
  @Relationship(deleteRule: .nullify)
  var ingredient: Ingredient?
  
  var quantity: String
  
  @Relationship(deleteRule: .nullify)
  var recipe: Recipe?
  
  init(ingredient: Ingredient? = nil, quantity: String = "", recipe: Recipe? = nil) {
    self.ingredient = ingredient
    self.quantity = quantity
    self.recipe = recipe
  }
}

@Model
final class Recipe {
  @Attribute(.unique) var name: String
  var summary: String
  
  @Relationship(deleteRule: .nullify)
  var category: Category?
  
  var serving: Int
  var time: Int
  
  @Relationship(deleteRule: .cascade)
  var ingredients: [RecipeIngredient]
  
  var instructions: String
  var imageData: Data?
  
  init(
    name: String = "",
    summary: String = "",
    category: Category? = nil,
    serving: Int = 1,
    time: Int = 5,
    ingredients: [RecipeIngredient] = [],
    instructions: String = "",
    imageData: Data? = nil
  ) {
    self.name = name
    self.summary = summary
    self.category = category
    self.serving = serving
    self.time = time
    self.ingredients = ingredients
    self.instructions = instructions
    self.imageData = imageData
  }
}
