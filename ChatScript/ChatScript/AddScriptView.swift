// AddScriptView.swift

import SwiftUI

struct AddScriptView: View {
    @ObservedObject var viewModel: PresetScriptsViewModel
    @Environment(\.presentationMode) var presentationMode

    @State private var scriptName: String = ""
    @State private var scriptContent: String = ""
    @State private var selectedCategory: String = ""
    @State private var newCategoryName: String = ""

    var body: some View {
        VStack(alignment: .leading) {
            Text("Add New Script")
                .font(.title)
                .padding(.bottom)

            TextField("Script Name", text: $scriptName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.bottom)

            Text("Category")
                .font(.headline)
            Picker("Select Category", selection: $selectedCategory) {
                ForEach(viewModel.categories, id: \.self) { category in
                    Text(category).tag(category)
                }
                Text("Add New Category").tag("Add New Category")
            }
            .pickerStyle(MenuPickerStyle())
            .padding(.bottom)

            if selectedCategory == "Add New Category" {
                TextField("New Category Name", text: $newCategoryName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.bottom)
            }

            Text("Script Content")
                .font(.headline)
            TextEditor(text: $scriptContent)
                .font(.system(.body, design: .monospaced))
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray))
                .padding(.bottom)

            HStack {
                Spacer()
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .padding()

                Button("Add Script") {
                    let category = selectedCategory == "Add New Category" ? newCategoryName : selectedCategory
                    viewModel.addScript(name: scriptName, content: scriptContent, category: category)
                    presentationMode.wrappedValue.dismiss()
                }
                .disabled(scriptName.isEmpty || scriptContent.isEmpty || (selectedCategory == "Add New Category" && newCategoryName.isEmpty))
                .padding()
            }
        }
        .padding()
        .frame(width: 500, height: 600)
        .onAppear {
            viewModel.fetchCategories()
        }
    }
}
