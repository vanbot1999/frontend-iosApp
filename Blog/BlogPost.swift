//
//  BlogPost.swift
//  Blog
//
//  Created by wyf on 01/04/2024.
//

import Foundation

struct BlogPost: Codable, Identifiable {
    var id: String
    var title: String
    var content: String
    var imageUrl: String
    var date: String
    var author: String

    enum CodingKeys: String, CodingKey {
        case id = "_id", title, content, imageUrl, date, author
    }
}
