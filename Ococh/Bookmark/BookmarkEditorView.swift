//
//  BookmarkEditorView.swift
//  Ococh
//
//  Created by Kristofer Younger on 9/22/22.
//

import SwiftUI

struct BookmarkEditorView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var viewModel: BookmarkEditorViewModel
    
    init(bookmark: Bookmark?, dataManager: DataManager = DataManager.shared) {
        self.viewModel = BookmarkEditorViewModel(bookmark: bookmark, dataManager: dataManager)
    }
    
    var body: some View {
        Form {
            Section {
                TextField("Title", text: $viewModel.editingBookmark.title)
                    .autocapitalization(.none)
                TextField("Link", text: $viewModel.editingBookmark.link)
                    .autocapitalization(.none)
                DatePicker("Date", selection: $viewModel.editingBookmark.timestamp)
            }

        }
        .safeAreaInset(edge: .bottom) {
            Button {
                presentationMode.wrappedValue.dismiss()
                withAnimation {
                    viewModel.saveBookmark()
                }
            } label: {
                Label("Save", systemImage: "checkmark.circle")
            }
            .buttonStyle(.borderedProminent)
            .padding(.bottom)
        }
        .navigationTitle("Edit Bookmark")
    }
}

struct BookmarkEditorView_Previews: PreviewProvider {
    static var previews: some View {
        BookmarkEditorView(bookmark: Bookmark(), dataManager: DataManager.preview)
    }
}
