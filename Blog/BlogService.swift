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
    
    static func deletePost(postId: String, completion: @escaping (Bool) -> Void) {
        // 构建删除帖子的URL
        let urlString = "http://localhost:3000/api/posts/\(postId)"
        guard let url = URL(string: urlString) else {
            print("无效的URL")
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"

        // 发送请求
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("请求错误: \(error.localizedDescription)")
                completion(false)
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                print("无效的响应")
                completion(false)
                return
            }

            if httpResponse.statusCode == 200 {
                // 帖子删除成功
                completion(true)
            } else {
                // 帖子删除失败
                completion(false)
            }
        }.resume()
    }
}
