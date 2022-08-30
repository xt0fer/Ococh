//
//  ContentView.swift
//  Ococh
//
//  Created by Kristofer Younger on 8/29/22.
//

import SwiftUI
import CoreData

struct ContentView: View {
    //@Environment(\.managedObjectContext) private var viewContext

    private var bookmarks = Bookmark.getAll()
    var body: some View {
        NavigationView {
            List {
                ForEach(bookmarks) { item in
                    NavigationLink {
                        BookmarkView(bookmark: item)
                    } label: {
                        BookmarkCell(bookmark: item)
                    }
                }
                .onDelete(perform: deleteBookmarks)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: addBookmark) {
                        Label("Add Bookmark", systemImage: "plus")
                    }
                }
            }
            Text("Select an item")
        }
    }

    private func addBookmark() {
        withAnimation {
            let vc = Storage.shared.container.viewContext
            var _ = Bookmark(title: "A URL", link: "https://tioga.digital", insertIntoManagedObjectContext: vc)

            do {
                try vc.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteBookmarks(offsets: IndexSet) {
        withAnimation {
            let vc = Storage.shared.container.viewContext

            offsets.map { bookmarks[$0] }.forEach(vc.delete)

            do {
                try vc.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, Storage.preview.container.viewContext)
    }
}
