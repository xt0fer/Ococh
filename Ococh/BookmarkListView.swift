//
//  ContentView.swift
//  Ococh
//
//  Created by Kristofer Younger on 8/29/22.
//

import SwiftUI
import CoreData
import CloudKit

struct BookmarkListView: View {
    //@Environment(\.managedObjectContext) private var viewContext

    @State private var bookmarks = Bookmark.getAll()
    @State private var statusString = "status?"

    var body: some View {
        VStack{
            Text(statusString)
        
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
            .refreshable {
                refreshBookmarks()
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
        .onAppear(){
            self.checkStatus()
            Storage.shared.refresh()
        }
    }

    private func addBookmark() {
        withAnimation {
            let vc = Storage.shared.container.viewContext
            var _ = Bookmark(title: "Tioga Digital", link: "https://tioga.digital", insertIntoManagedObjectContext: vc)

            do {
                try vc.save()
                refreshBookmarks()
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
    
    func refreshBookmarks() {
        let vc = Storage.shared.container.viewContext
        vc.refreshAllObjects()
        self.bookmarks = Bookmark.getAll()
    }
    func checkStatus() {
        CKContainer.default().accountStatus { status, error in
            if let error = error {
              // some error occurred (probably a failed connection, try again)
                statusString = "error \(error.localizedDescription)"
            } else {
                switch status {
                case .available:
                  // the user is logged in
                    statusString =  "iCloud User Logged in"
                case .noAccount:
                  // the user is NOT logged in
                    statusString =  "iCloud User NOT Logged in"

                case .couldNotDetermine:
                  // for some reason, the status could not be determined (try again)
                    statusString =  "Could Not Determine User Stautus"

                case .restricted:
                  // iCloud settings are restricted by parental controls or a configuration profile
                    statusString =  "User Settings are Restricted"
                default:
                    statusString = "unknown state!"
                }
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
        BookmarkListView().environment(\.managedObjectContext, Storage.preview.container.viewContext)
    }
}
