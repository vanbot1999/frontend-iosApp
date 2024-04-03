//
//  Post.swift
//  Blog
//
//  Created by wyf on 03/04/2024.
//

import Foundation

struct Post: Identifiable, Decodable {
    var id: String
    var title: String
    var content: String
    var imageUrl: String
    var date: String
    var author: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case title
        case content
        case imageUrl
        case date
        case author
    }
}
