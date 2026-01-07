import SwiftUI
import SwiftData
import PhotosUI
import Foundation

struct RecipeForm: View {
  enum Mode: Hashable {
    case add
    case edit(Recipe)
  }

  var mode: Mode

  init(mode: Mode) {
    self.mode = mode
    switch mode {
    case .add:
      title = "Add Recipe"
      _name = .init(initialValue: "")
      _summary = .init(initialValue: "")
      _serving = .init(initialValue: 1)
      _time = .init(initialValue: 5)
      _instructions = .init(initialValue: "")
      _recipeIngredients = .init(initialValue: [])
    case .edit(let recipe):
      title = "Edit \(recipe.name)"
      _name = .init(initialValue: recipe.name)
      _summary = .init(initialValue: recipe.summary)
      _serving = .init(initialValue: recipe.serving)
      _time = .init(initialValue: recipe.time)
      _instructions = .init(initialValue: recipe.instructions)
      _selectedCategory = .init(initialValue: recipe.category)
      _recipeIngredients = .init(initialValue: recipe.ingredients)
      _imageData = .init(initialValue: recipe.imageData)
    }
  }

  private let title: String
  @State private var name: String
  @State private var summary: String
  @State private var serving: Int
  @State private var time: Int
  @State private var instructions: String
  @State private var selectedCategory: Category?
  @State private var recipeIngredients: [RecipeIngredient]
  @State private var imageItem: PhotosPickerItem?
  @State private var imageData: Data?
  @State private var isIngredientsPickerPresented = false
  @State private var error: Error?
  @Environment(\.dismiss) private var dismiss
  @Environment(\.modelContext) private var modelContext
  @Query private var availableCategories: [Category]
  @Query private var availableIngredients: [Ingredient]

  // MARK: - Body

  var body: some View {
    GeometryReader { geometry in
      Form {
        imageSection(width: geometry.size.width)
        nameSection
        summarySection
        categorySection
        servingAndTimeSection
        ingredientsSection
        instructionsSection
        deleteButton
      }
    }
    .scrollDismissesKeyboard(.interactively)
    .navigationTitle(title)
    .navigationBarTitleDisplayMode(.inline)
    .alert(error: $error)
    .toolbar {
      ToolbarItem(placement: .topBarTrailing) {
        Button("Save", action: save)
          .disabled(name.isEmpty || instructions.isEmpty)
      }
    }
    .onChange(of: imageItem) { _, _ in
      Task {
        self.imageData = try? await imageItem?.loadTransferable(type: Data.self)
      }
    }
    .sheet(isPresented: $isIngredientsPickerPresented, content: ingredientPicker)
  }

  // MARK: - Views

  private func ingredientPicker() -> some View {
    IngredientsView { selectedIngredient in
      let recipeIngredient = RecipeIngredient(ingredient: selectedIngredient, quantity: "")
      recipeIngredients.append(recipeIngredient)
    }
  }

  @ViewBuilder
  private func imageSection(width: CGFloat) -> some View {
    Section {
      imagePicker(width: width)
      removeImage
    }
  }

  @ViewBuilder
  private func imagePicker(width: CGFloat) -> some View {
    PhotosPicker(selection: $imageItem, matching: .images) {
      if let imageData, let uiImage = UIImage(data: imageData) {
        Image(uiImage: uiImage)
          .resizable()
          .scaledToFill()
          .frame(width: width)
          .clipped()
          .listRowInsets(EdgeInsets())
          .frame(maxWidth: .infinity, minHeight: 200, idealHeight: 200, maxHeight: 200, alignment: .center)
      } else {
        Label("Select Image", systemImage: "photo")
      }
    }
  }

  @ViewBuilder
  private var removeImage: some View {
    if imageData != nil {
      Button(
        role: .destructive,
        action: {
          imageData = nil
        },
        label: {
          Text("Remove Image")
            .frame(maxWidth: .infinity, alignment: .center)
        }
      )
    }
  }

  @ViewBuilder
  private var nameSection: some View {
    Section("Name") {
      TextField("Margherita Pizza", text: $name)
    }
  }

  @ViewBuilder
  private var summarySection: some View {
    Section("Summary") {
      TextField(
        "Delicious blend of fresh basil, mozzarella, and tomato on a crispy crust.",
        text: $summary,
        axis: .vertical
      )
      .lineLimit(3...5)
    }
  }

  @ViewBuilder
  private var categorySection: some View {
    Section {
      Picker("Category", selection: $selectedCategory) {
        Text("None").tag(nil as Category?)
        ForEach(availableCategories) { category in
          Text(category.name).tag(category as Category?)
        }
      }
    }
  }

  @ViewBuilder
  private var servingAndTimeSection: some View {
    Section {
      Stepper("Servings: \(serving)p", value: $serving, in: 1...100)
      Stepper("Time: \(time)m", value: $time, in: 5...300, step: 5)
    }
    .monospacedDigit()
  }

  @ViewBuilder
  private var ingredientsSection: some View {
    Section("Ingredients") {
      if recipeIngredients.isEmpty {
        ContentUnavailableView(
          label: {
            Label("No Ingredients", systemImage: "list.clipboard")
          },
          description: {
            Text("Recipe ingredients will appear here.")
          },
          actions: {
            Button("Add Ingredient") {
              isIngredientsPickerPresented = true
            }
          }
        )
      } else {
        ForEach(recipeIngredients) { recipeIngredient in
          HStack(alignment: .center) {
            Text(recipeIngredient.ingredient.name)
              .bold()
              .layoutPriority(2)
            Spacer()
            TextField("Quantity", text: Binding(
              get: {
                recipeIngredient.quantity
              },
              set: { quantity in
                recipeIngredient.quantity = quantity
              }
            ))
            .layoutPriority(1)
          }
        }
        .onDelete(perform: deleteIngredients)

        Button("Add Ingredient") {
          isIngredientsPickerPresented = true
        }
      }
    }
  }

  @ViewBuilder
  private var instructionsSection: some View {
    Section("Instructions") {
      TextField(
        """
        1. Preheat the oven to 475°F (245°C).
        2. Roll out the dough on a floured surface.
        3. ...
        """,
        text: $instructions,
        axis: .vertical
      )
      .lineLimit(8...12)
    }
  }

  @ViewBuilder
  private var deleteButton: some View {
    if case .edit = mode {
      Button(
        role: .destructive,
        action: {
          delete()
        },
        label: {
          Text("Delete Recipe")
            .frame(maxWidth: .infinity, alignment: .center)
        }
      )
    }
  }

  // MARK: - Data

  private func delete() {
    guard case .edit(let recipe) = mode else {
      fatalError("Delete unavailable in add mode")
    }
    modelContext.delete(recipe)
    do {
      try modelContext.save()
      dismiss()
    } catch {
      self.error = error
    }
  }

  private func deleteIngredients(offsets: IndexSet) {
    withAnimation {
      for index in offsets {
        let recipeIngredient = recipeIngredients[index]
        modelContext.delete(recipeIngredient)
      }
      recipeIngredients.remove(atOffsets: offsets)
    }
  }

  private func save() {
    let trimmedName = name.trimmingCharacters(in: .whitespaces)
    guard !trimmedName.isEmpty, !instructions.trimmingCharacters(in: .whitespaces).isEmpty else {
      return
    }
    
    let currentRecipeID: PersistentIdentifier?
    if case .edit(let recipe) = mode {
      currentRecipeID = recipe.persistentModelID
    } else {
      currentRecipeID = nil
    }
    
    let descriptor = FetchDescriptor<Recipe>()
    if let existingRecipes = try? modelContext.fetch(descriptor) {
      let duplicateExists = existingRecipes.contains { existing in
        existing.name.lowercased() == trimmedName.lowercased() &&
        existing.persistentModelID != currentRecipeID
      }
      
      if duplicateExists {
        error = NSError(domain: "RecipeForm", code: 1, userInfo: [NSLocalizedDescriptionKey: "Recipe with the same name exists"])
        return
      }
    }
    
    do {
      switch mode {
      case .add:
        let recipe = Recipe(
          name: trimmedName,
          summary: summary,
          category: selectedCategory,
          serving: serving,
          time: time,
          ingredients: [],
          instructions: instructions,
          imageData: imageData
        )
        modelContext.insert(recipe)
        
        for recipeIngredient in recipeIngredients {
          recipeIngredient.recipe = recipe
          modelContext.insert(recipeIngredient)
        }
        
      case .edit(let recipe):
        recipe.name = trimmedName
        recipe.summary = summary
        recipe.category = selectedCategory
        recipe.serving = serving
        recipe.time = time
        recipe.instructions = instructions
        recipe.imageData = imageData
        
        let currentIDs = Set(recipeIngredients.compactMap { $0.persistentModelID })
        
        for existingIngredient in recipe.ingredients {
            if !currentIDs.contains(existingIngredient.persistentModelID) {
                modelContext.delete(existingIngredient)
            }
        }
        
        for recipeIngredient in recipeIngredients {
          if recipeIngredient.recipe == nil {
            recipeIngredient.recipe = recipe
            modelContext.insert(recipeIngredient)
          }
        }
      }
      
      try modelContext.save()
      dismiss()
    } catch {
      self.error = error
    }
  }
}
