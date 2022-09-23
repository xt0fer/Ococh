//
//  BookmarkView.swift
//  Ococh
//
//  Created by Kristofer Younger on 8/29/22.
//

import SwiftUI

struct BookmarkView: View {
    var bookmark: Bookmark
    
    var body: some View {
        HStack{
            VStack(alignment: .leading, spacing: 10){
                Text(bookmark.title)
                Link(destination: URL(string: bookmark.link)!) {
                    HStack {
                        Image(systemName: "link.circle.fill")
                            .font(.largeTitle)
                        Text(bookmark.link)
                            .font(.body.italic())
                    }
                }
                Text("\(bookmark.timestamp, formatter: itemFormatter)")
                Spacer()
            }
        }
    }
}

struct BookmarkView_Previews: PreviewProvider {
    static var previews: some View {
EmptyView()
        
    }
}
