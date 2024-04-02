//
//  LoginView.swift
//  Blog
//
//  Created by wyf on 02/04/2024.
//

import SwiftUI

struct LoginView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("用户名", text: $username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                SecureField("密码", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button(action: loginUser) {
                    Text("登录")
                        .foregroundColor(.white)
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(40)
                }
                .padding()
            }
            .padding()
            .navigationBarTitle("登录")
        }
    }
    
    func fetchBlogs() {
        guard let url = URL(string: "http://localhost:3000/api/blogs") else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("Error fetching blogs: \(error.localizedDescription)")
                return
            }
            
            if let data = data,
               let response = response as? HTTPURLResponse,
               response.statusCode == 200 {
                
                if let blogs = try? JSONDecoder().decode([BlogPost].self, from: data) {
                    // 更新 UI 以显示博客帖子
                    print("Blogs: \(blogs)")
                } else {
                    print("Unable to decode blogs")
                }
            } else {
                print("Failed to fetch blogs")
            }
        }.resume()
    }
    func loginUser() {
        guard let url = URL(string: "http://localhost:3000/api/login") else { return }

        let body: [String: String] = ["username": username, "password": password]
        let finalBody = try? JSONSerialization.data(withJSONObject: body)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = finalBody
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Login error: \(error.localizedDescription)")
                return
            }

            if let data = data,
               let response = response as? HTTPURLResponse,
               response.statusCode == 200 {

                let token = String(data: data, encoding: .utf8) ?? ""
                print("Login successful, token: \(token)")
                // 保存或处理 token
            } else {
                print("Login failed")
            }
        }.resume()
    }

    struct BlogPost: Codable {
        let title: String
        let content: String
        // 添加更多字段以匹配你的模型
    }
}
