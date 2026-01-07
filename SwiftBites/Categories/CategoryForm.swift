import SwiftUI
import SwiftData

struct CategoryForm: View {
  enum Mode: Hashable {
    case add
    case edit(Category)
  }

  var mode: Mode

  init(mode: Mode) {
    self.mode = mode
    switch mode {
    case .add:
      _name = .init(initialValue: "")
      title = "Add Category"
    case .edit(let category):
      _name = .init(initialValue: category.name)
      title = "Edit \(category.name)"
    }
  }

  private let title: String
  @State private var name: String
  @State private var error: Error?
  @Environment(\.modelContext) private var modelContext
  @Environment(\.dismiss) private var dismiss
  @Query private var existingCategories: [Category]
  @FocusState private var isNameFocused: Bool

  // MARK: - Body

  var body: some View {
    Form {
      Section {
        TextField("Name", text: $name)
          .focused($isNameFocused)
      }
      if case .edit(let category) = mode {
        Button(
          role: .destructive,
          action: {
            delete(category: category)
          },
          label: {
            Text("Delete Category")
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

  private func delete(category: Category) {
    modelContext.delete(category)
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
    
    let currentCategoryID: PersistentIdentifier?
    if case .edit(let category) = mode {
      currentCategoryID = category.persistentModelID
    } else {
      currentCategoryID = nil
    }
    
    let duplicateExists = existingCategories.contains { existing in
      existing.name.lowercased() == trimmedName.lowercased() &&
      existing.persistentModelID != currentCategoryID
    }
    
    if duplicateExists {
      error = NSError(domain: "CategoryForm", code: 1, userInfo: [NSLocalizedDescriptionKey: "Category with the same name exists"])
      return
    }
    
    do {
      switch mode {
      case .add:
        let category = Category(name: trimmedName)
        modelContext.insert(category)
      case .edit(let category):
        category.name = trimmedName
      }
      try modelContext.save()
      dismiss()
    } catch {
      self.error = error
    }
  }
}
