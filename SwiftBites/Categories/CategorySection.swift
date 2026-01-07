import SwiftUI
import SwiftData

struct CategorySection: View {
  let category: Category
  
  @Query private var allRecipes: [Recipe]
  
  private var categoryRecipes: [Recipe] {
    allRecipes.filter { recipe in
      recipe.category?.persistentModelID == category.persistentModelID
    }
  }

  // MARK: - Body

  var body: some View {
    Section(
      content: {
        if categoryRecipes.isEmpty {
          empty
        } else {
          list
        }
      },
      header: {
        HStack(alignment: .center) {
          Text(category.name)
            .font(.title)
            .bold()
          Spacer()
          NavigationLink("Edit", value: CategoryForm.Mode.edit(category))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
      }
    )
  }

  // MARK: - Views

  var list: some View {
    ScrollView(.horizontal) {
      LazyHStack(spacing: 0) {
        ForEach(categoryRecipes) { recipe in
          RecipeCell(recipe: recipe)
            .containerRelativeFrame(.horizontal, count: 12, span: 11, spacing: 0)
        }
      }
      .scrollTargetLayout()
    }
    .scrollTargetBehavior(.viewAligned)
    .scrollIndicators(.hidden)
  }

  var empty: some View {
    ContentUnavailableView(
      label: {
        Label("No Recipes", systemImage: "list.clipboard")
      },
      description: {
        Text("Recipes you add will appear here.")
      },
      actions: {
        NavigationLink("Add Recipe", value: RecipeForm.Mode.add)
          .buttonBorderShape(.roundedRectangle)
          .buttonStyle(.bordered)
      }
    )
  }
}
