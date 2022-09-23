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

    @StateObject var viewModel = BookmarkListViewModel()
    @State var statusString = ""
    
    var body: some View {
        VStack{
            Text(statusString)
        
        NavigationView {
            List {
                ForEach(viewModel.bookmarks) { item in
                    NavigationLink {
                        BookmarkView(bookmark: item)
                    } label: {
                        BookmarkCell(bookmark: item)
                    }
                }
                .onDelete { indexSet in
                    viewModel.delete(at: indexSet)
                }
            }

            }
        .safeAreaInset(edge: .bottom) {
            Button {
                viewModel.showEditor = true
            } label: {
                Label("New", systemImage: "plus")
            }
            .buttonStyle(.borderedProminent)
        }
        .sheet(isPresented: $viewModel.showEditor) {
            BookmarkEditorView(bookmark: nil)
        }
        .onAppear(){
            withAnimation{
                viewModel.fetchTodos()
            }
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
        EmptyView()
    }
}
