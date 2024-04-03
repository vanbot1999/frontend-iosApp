//
//  BlogService.swift
//  Blog
//
//  Created by wyf on 01/04/2024.
//

import Foundation

class BlogService {
    static func fetchBlogs(excludeAuthor: String? = nil, completion: @escaping ([Post]) -> Void) {
        var urlString = "http://localhost:3000/api/blogs"
        
        if let excludeAuthor = excludeAuthor, !excludeAuthor.isEmpty {
            urlString += "?excludeAuthor=\(excludeAuthor)"
        }
        
        guard let url = URL(string: urlString) else {
            print("无效的URL")
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("请求错误: \(error.localizedDescription)")
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("无效的响应")
                return
            }

            guard let data = data else {
                print("无数据返回")
                return
            }

            do {
                let posts = try JSONDecoder().decode([Post].self, from: data)
                DispatchQueue.main.async {
                    completion(posts)
                }
            } catch {
                print("解码错误: \(error)")
            }
        }.resume()
    }
}
