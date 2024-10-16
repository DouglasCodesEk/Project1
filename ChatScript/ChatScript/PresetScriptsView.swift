import SwiftUI
import SwiftData

struct PresetScriptsView: View {
    @Environment(\.modelContext) private var context
    @StateObject private var viewModel = PresetScriptsViewModel()
    @State private var showingAddScriptSheet = false
    @State private var showingDeleteAlert = false
    @State private var categoryToDelete = ""

    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.categories, id: \.self) { category in
                    NavigationLink(destination: CategoryScriptsView(
                        category: category,
                        scripts: viewModel.presetScripts.filter { $0.category == category }
                    )) {
                        Text(category)
                    }
                }
                .onDelete(perform: deleteCategory)
            }
            .listStyle(SidebarListStyle())
            .navigationTitle("Preset Scripts")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        showingAddScriptSheet = true
                    }) {
                        Label("Add Script", systemImage: "plus")
                    }
                }
            }
            .alert(isPresented: $showingDeleteAlert) {
                Alert(
                    title: Text("Delete Category"),
                    message: Text("Are you sure you want to delete the category '\(categoryToDelete)' and all its scripts?"),
                    primaryButton: .destructive(Text("Delete")) {
                        viewModel.removeCategory(categoryToDelete)
                    },
                    secondaryButton: .cancel()
                )
            }
            .sheet(isPresented: $showingAddScriptSheet) {
                AddScriptView(viewModel: viewModel)
            }
        }
        .frame(minWidth: 400, minHeight: 600)
        .onAppear {
            viewModel.context = context
            viewModel.fetchPresetScripts()
            viewModel.fetchCategories()
        }
    }

    private func deleteCategory(at offsets: IndexSet) {
        if let index = offsets.first {
            categoryToDelete = viewModel.categories[index]
            showingDeleteAlert = true
        }
    }
}
