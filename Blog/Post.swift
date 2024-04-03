//
//  Post.swift
//  Blog
//
//  Created by wyf on 03/04/2024.
//

import Foundation
extension Post {
    init(id: String, title: String, content: String, imageUrl: String, date: String, author: String) {
        self.id = id
        self.title = title
        self.content = content
        self.imageUrl = imageUrl
        self.date = date
        self.author = author
    }
}

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

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        content = try container.decode(String.self, forKey: .content)
        imageUrl = try container.decode(String.self, forKey: .imageUrl)
        author = try container.decode(String.self, forKey: .author)
        date = try container.decodeIfPresent(String.self, forKey: .date) ?? "未知日期" // 提供默认值
    }
}

