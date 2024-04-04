//
//  Post.swift
//  Blog
//
//  Created by wyf on 03/04/2024.
//

import Foundation

extension Post {
    init(id: String, title: String, content: String, imageUrl: String, date: String, author: String, comments: [Comment]) {
        self.id = id
        self.title = title
        self.content = content
        self.imageUrl = imageUrl
        self.date = date
        self.author = author
        self.comments = comments
    }
}

struct Comment: Identifiable, Decodable {
    var id: String
    var content: String
    var author: String
    var date: String
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case content
        case author
        case date
    }
}

struct Post: Identifiable, Decodable {
    var id: String
    var title: String
    var content: String
    var imageUrl: String
    var date: String
    var author: String
    var comments: [Comment]

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case title
        case content
        case imageUrl
        case date
        case author
        case comments
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        content = try container.decode(String.self, forKey: .content)
        imageUrl = try container.decode(String.self, forKey: .imageUrl)
        author = try container.decode(String.self, forKey: .author)
        date = try container.decodeIfPresent(String.self, forKey: .date) ?? "未知日期"
        comments = try container.decodeIfPresent([Comment].self, forKey: .comments) ?? []
    }
}
