//
//  BookmarkCell.swift
//  Ococh
//
//  Created by Kristofer Younger on 8/29/22.
//

import SwiftUI

struct BookmarkCell: View {
    var bookmark: Bookmark

    var body: some View {
        Text("\(bookmark.title )")
    }
}

struct BookmarkCell_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
    }
}
