import SwiftUI
import SwiftData

struct ShoppingListView: View {
  @Query(filter: #Predicate<Ingredient> { !$0.isAvailable })
  private var missingIngredients: [Ingredient]
  
  @Environment(\.modelContext) private var modelContext

  // MARK: - Body

  var body: some View {
    NavigationStack {
      content
        .navigationTitle("Shopping List")
        .toolbar {
          if !missingIngredients.isEmpty {
            ToolbarItem(placement: .topBarTrailing) {
              Button("Mark All Available") {
                markAllAvailable()
              }
            }
          }
        }
    }
  }

  // MARK: - Views

  @ViewBuilder
  private var content: some View {
    if missingIngredients.isEmpty {
      empty
    } else {
      list
    }
  }

  private var empty: some View {
    ContentUnavailableView(
      label: {
        Label("All Ingredients Available", systemImage: "checkmark.circle.fill")
      },
      description: {
        Text("You have all the ingredients you need!")
      }
    )
  }

  private var list: some View {
    List {
      ForEach(missingIngredients) { ingredient in
        HStack {
          Text(ingredient.name)
            .font(.title3)
          Spacer()
          Button(action: {
            markAsAvailable(ingredient: ingredient)
          }) {
            Image(systemName: "checkmark.circle")
              .foregroundColor(.green)
          }
        }
      }
    }
    .listStyle(.plain)
  }

  // MARK: - Data

  private func markAsAvailable(ingredient: Ingredient) {
    ingredient.isAvailable = true
    try? modelContext.save()
  }

  private func markAllAvailable() {
    for ingredient in missingIngredients {
      ingredient.isAvailable = true
    }
      try? modelContext.save()
  }
}



