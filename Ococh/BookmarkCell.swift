//
//  BookmarkCell.swift
//  Ococh
//
//  Created by Kristofer Younger on 8/29/22.
//

import SwiftUI

struct BookmarkCell: View {
    @StateObject var bookmark: Bookmark

    var body: some View {
        Text("\(bookmark.title ?? "empty")")
    }
}

struct BookmarkCell_Previews: PreviewProvider {
    static var previews: some View {
        BookmarkCell(bookmark: Bookmark.emptyBookmark())
    }
}
