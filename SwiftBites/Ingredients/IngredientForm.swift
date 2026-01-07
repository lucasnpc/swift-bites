import SwiftUI
import SwiftData

struct IngredientForm: View {
  enum Mode: Hashable {
    case add
    case edit(Ingredient)
  }

  var mode: Mode

  init(mode: Mode) {
    self.mode = mode
    switch mode {
    case .add:
      _name = .init(initialValue: "")
      _isAvailable = .init(initialValue: true)
      title = "Add Ingredient"
    case .edit(let ingredient):
      _name = .init(initialValue: ingredient.name)
      _isAvailable = .init(initialValue: ingredient.isAvailable)
      title = "Edit \(ingredient.name)"
    }
  }

  private let title: String
  @State private var name: String
  @State private var isAvailable: Bool
  @State private var error: Error?
  @Environment(\.modelContext) private var modelContext
  @Environment(\.dismiss) private var dismiss
  @Query private var existingIngredients: [Ingredient]
  @FocusState private var isNameFocused: Bool

  // MARK: - Body

  var body: some View {
    Form {
      Section {
        TextField("Name", text: $name)
          .focused($isNameFocused)
        Toggle("Available", isOn: $isAvailable)
      }
      if case .edit(let ingredient) = mode {
        Button(
          role: .destructive,
          action: {
            delete(ingredient: ingredient)
          },
          label: {
            Text("Delete Ingredient")
              .frame(maxWidth: .infinity, alignment: .center)
          }
        )
      }
    }
    .onAppear {
      isNameFocused = true
    }
    .onSubmit {
      save()
    }
    .alert(error: $error)
    .navigationTitle(title)
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .topBarTrailing) {
        Button("Save", action: save)
          .disabled(name.isEmpty)
      }
    }
  }

  // MARK: - Data

  private func delete(ingredient: Ingredient) {
    modelContext.delete(ingredient)
    do {
      try modelContext.save()
      dismiss()
    } catch {
      self.error = error
    }
  }

  private func save() {
    let trimmedName = name.trimmingCharacters(in: .whitespaces)
    guard !trimmedName.isEmpty else {
      return
    }
    
    let currentIngredientID: PersistentIdentifier?
    if case .edit(let ingredient) = mode {
      currentIngredientID = ingredient.persistentModelID
    } else {
      currentIngredientID = nil
    }
    
    let duplicateExists = existingIngredients.contains { existing in
      existing.name.lowercased() == trimmedName.lowercased() &&
      existing.persistentModelID != currentIngredientID
    }
    
    if duplicateExists {
      error = NSError(domain: "IngredientForm", code: 1, userInfo: [NSLocalizedDescriptionKey: "Ingredient with the same name exists"])
      return
    }
    
    do {
      switch mode {
      case .add:
        let ingredient = Ingredient(name: trimmedName, isAvailable: isAvailable)
        modelContext.insert(ingredient)
      case .edit(let ingredient):
        ingredient.name = trimmedName
        ingredient.isAvailable = isAvailable
      }
      try modelContext.save()
      dismiss()
    } catch {
      self.error = error
    }
  }
}
