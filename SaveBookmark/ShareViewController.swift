//
//  ShareViewController.swift
//  SaveBookmark
//
//  Created by Kristofer Younger on 8/29/22.
//

import UIKit
import Social

class ShareViewController: SLComposeServiceViewController {

    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        return true
    }

    override func didSelectPost() {
        if let item = extensionContext?.inputItems.first as? NSExtensionItem,
            let itemProvider = item.attachments?.first as? NSItemProvider,
            itemProvider.hasItemConformingToTypeIdentifier("public.url") {
            itemProvider.loadItem(forTypeIdentifier: "public.url", options: nil) { (url, error) in
                if let shareURL = url as? URL {
                    // do what you want to do with shareURL
                    self.saveURLtoCoreData(shareURL)
                }
                self.extensionContext?.completeRequest(returningItems: [], completionHandler:nil)
            }
        }
    }

    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        return []
    }
    
    func saveURLtoCoreData(_ url: URL) {
        let store = Storage.shared
        let b = Bookmark.getAll().count
        let vc = store.container.viewContext
        let _ = Bookmark(title: self.contentText, link: url.absoluteString, insertIntoManagedObjectContext: vc)
        store.save()
        let c = Bookmark.getAll().count
        Foundation.NSLog("KKYY b, c [\(b), \(c)]")
    }

}
