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
        if let item = extensionContext?.inputItems.first as? NSExtensionItem {
            if let attachments = item.attachments {
                for attachment: NSItemProvider in attachments {
                    printProvider(prov: attachment)
                    if attachment.hasItemConformingToTypeIdentifier("public.text") {
                        attachment.loadItem(forTypeIdentifier: "public.text", options: nil, completionHandler: { text, _ in

                            print("KKYY text url? \(text)")
                            self.extensionContext?.completeRequest(returningItems: [], completionHandler:nil)

                        })
                    }
                    if attachment.hasItemConformingToTypeIdentifier("public.url") {
                        attachment.loadItem(forTypeIdentifier: "public.url", options: nil, completionHandler: { (url, error) in
                            if let shareURL = url as? URL {
                                // do what you want to do with shareURL
                                self.saveURLtoCoreData(shareURL)
                            }
                            self.extensionContext?.completeRequest(returningItems: [], completionHandler:nil)
                        })
                    }
                    if attachment.hasItemConformingToTypeIdentifier("com.adobe.pdf") {
                        attachment.loadItem(forTypeIdentifier: "com.adobe.pdf", options: nil, completionHandler: { (url, error) in
                            print("KKYY pdf url \(url)")
                            if let shareURL = url as? URL {
                                // do what you want to do with shareURL
                                self.saveURLtoCoreData(shareURL)
                            }
                            self.extensionContext?.completeRequest(returningItems: [], completionHandler:nil)
                        })
                    }
                }
            }
        }
//        if let item = extensionContext?.inputItems.first as? NSExtensionItem,
//            let itemProvider = item.attachments?.first as? NSItemProvider,
//            itemProvider.hasItemConformingToTypeIdentifier("public.url") {
//            itemProvider.loadItem(forTypeIdentifier: "public.url", options: nil) { (url, error) in
//                if let shareURL = url as? URL {
//                    // do what you want to do with shareURL
//                    self.saveURLtoCoreData(shareURL)
//                }
//                self.extensionContext?.completeRequest(returningItems: [], completionHandler:nil)
//            }
//        } else {
//            self.extensionContext?.completeRequest(returningItems: [], completionHandler:nil)
//        }
    }

    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        return []
    }
    
    func saveURLtoCoreData(_ url: URL) {
        let dm = DataManager.shared
        let bm = Bookmark(title: self.contentText,
                          link: url.absoluteString,
                          date: Date(),
                          blob: Data())
        Foundation.NSLog("KKYY add: [\(self.contentText)](\(url.absoluteString)")
        dm.updateAndSave(bookmark: bm)
        
        dm.saveData()
    }
    
    private func printProvider(prov: NSItemProvider) {
        // print out all the type IDs in the Provider.
        //
        let f = prov.registeredTypeIdentifiers;
        // what could I send in for fileOptions:?
        //let g = prov.registeredTypeIdentifiers(fileOptions: NSItemProviderFileOptions)
        for s in f {
            print("KKYY registeredTypeIdentifier \(s)")
        }
    }


}
