import SwiftUI
import SwiftData

@main
struct SwiftBitesApp: App {
  @State private var modelContainer: ModelContainer
  
  init() {
    let schema = Schema([Ingredient.self, Category.self, Recipe.self, RecipeIngredient.self])
    let modelConfiguration = ModelConfiguration(schema: schema)
    
    do {
      modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
    } catch {
      fatalError("Could not create ModelContainer: \(error)")
    }
  }
  
  var body: some Scene {
    WindowGroup {
      ContentView()
        .modelContainer(modelContainer)
    }
  }
}
