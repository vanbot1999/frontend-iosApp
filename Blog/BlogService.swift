//
//  BlogService.swift
//  Blog
//
//  Created by wyf on 01/04/2024.
//

import Foundation

class BlogService {
    static func fetchBlogs(completion: @escaping ([BlogPost]) -> Void) {
        let urlString = "http://localhost:3000/api/blogs" // 替换为你的API地址
        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else { return }

            do {
                let blogs = try JSONDecoder().decode([BlogPost].self, from: data)
                DispatchQueue.main.async {
                    completion(blogs)
                }
            } catch {
                print("Error decoding blogs: \(error)")
            }
        }.resume()
    }
}
