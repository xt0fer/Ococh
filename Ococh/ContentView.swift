//
//  ContentView.swift
//  Ococh
//
//  Created by Kristofer Younger on 8/29/22.
//

import SwiftUI
import CoreData
import CloudKit

struct ContentView: View {
    //@Environment(\.managedObjectContext) private var viewContext

    private var bookmarks = Bookmark.getAll()
    @State var statusString = "status?"

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
    
    func checkStatus() {
        CKContainer.default().accountStatus { status, error in
            if let error = error {
              // some error occurred (probably a failed connection, try again)
                statusString = "error \(error.localizedDescription)"
            } else {
                switch status {
                case .available:
                  // the user is logged in
                    statusString =  "User Logged in"
                case .noAccount:
                  // the user is NOT logged in
                    statusString =  "User NOT Logged in"

                case .couldNotDetermine:
                  // for some reason, the status could not be determined (try again)
                    statusString =  "Could Not Determine"

                case .restricted:
                  // iCloud settings are restricted by parental controls or a configuration profile
                    statusString =  "Settings are Restricted"
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
        ContentView().environment(\.managedObjectContext, Storage.preview.container.viewContext)
    }
}
