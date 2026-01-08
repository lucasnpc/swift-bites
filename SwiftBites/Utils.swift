import SwiftUI
import SwiftData

extension View {
  func alert(error: Binding<Error?>) -> some View {
    self.alert(isPresented: Binding<Bool>(
      get: { error.wrappedValue != nil },
      set: { if !$0 { error.wrappedValue = nil } }
    )) {
      Alert(
        title: Text("Error"),
        message: Text(error.wrappedValue?.localizedDescription ?? "An unknown error occurred."),
        dismissButton: .default(Text("Dismiss"))
      )
    }
  }
}

// MARK: - SwiftData Validation Helpers

func safeCategoryName(_ category: Category?) -> String? {
  guard let category = category else { return nil }
  guard let context = category.modelContext else { return nil }
  let id = category.persistentModelID
  let descriptor = FetchDescriptor<Category>(
    predicate: #Predicate { $0.persistentModelID == id }
  )
  guard let found = try? context.fetch(descriptor).first else { return nil }
  return found.name
}

func safeCategoryID(_ category: Category?, in context: ModelContext) -> PersistentIdentifier? {
  guard let category = category else { return nil }
  let id = category.persistentModelID
  let descriptor = FetchDescriptor<Category>(
    predicate: #Predicate { $0.persistentModelID == id }
  )
  guard let _ = try? context.fetch(descriptor).first else { return nil }
  return id
}
func safeCategoryID(_ category: Category?) -> PersistentIdentifier? {
  guard let category = category else { return nil }
  guard let context = category.modelContext else { return nil }
  return safeCategoryID(category, in: context)
}

func safeCategory(_ category: Category?, in context: ModelContext) -> Category? {
  guard let category = category else { return nil }
  let id = category.persistentModelID
  let descriptor = FetchDescriptor<Category>(
    predicate: #Predicate { $0.persistentModelID == id }
  )
  return try? context.fetch(descriptor).first
}
func safeCategory(_ category: Category?) -> Category? {
  guard let category = category else { return nil }
  guard let context = category.modelContext else { return nil }
  return safeCategory(category, in: context)
}

func safeIngredientName(_ ingredient: Ingredient?) -> String? {
  guard let ingredient = ingredient else { return nil }
  guard let context = ingredient.modelContext else { return nil }
  let id = ingredient.persistentModelID
  let descriptor = FetchDescriptor<Ingredient>(
    predicate: #Predicate { $0.persistentModelID == id }
  )
  guard let found = try? context.fetch(descriptor).first else { return nil }
  return found.name
}

func safeIngredientValue(_ ingredient: Ingredient?, in context: ModelContext) -> Ingredient? {
  guard let ingredient = ingredient else { return nil }
  let id = ingredient.persistentModelID
  let descriptor = FetchDescriptor<Ingredient>(
    predicate: #Predicate { $0.persistentModelID == id }
  )
  return try? context.fetch(descriptor).first
}
func safeIngredientValue(_ ingredient: Ingredient?) -> Ingredient? {
  guard let ingredient = ingredient else { return nil }
  guard let context = ingredient.modelContext else { return nil }
  return safeIngredientValue(ingredient, in: context)
}
