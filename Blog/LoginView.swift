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
    @State private var errorMessage: String? = nil  // 用于跟踪和显示错误消息的状态
    @EnvironmentObject var userAuth: UserAuth
    @Binding var activeView: ActiveView
    
    var body: some View {
        VStack {
            // 显示错误消息（如果有的话）
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
            
            TextField("用户名", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .autocapitalization(.none)
            
            SecureField("密码", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button("登录") {
                loginUser()
            }
            .foregroundColor(.white)
            .frame(minWidth: 0, maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .cornerRadius(40)
            .padding()
            
            Button("没有账号？注册") {
                activeView = .register
            }
            .foregroundColor(.blue)
            .padding()
        }
        .padding()
        .navigationBarTitle("登录", displayMode: .inline)
        .navigationBarHidden(true)
    }
    
    func loginUser() {
        guard let url = URL(string: "http://localhost:3000/api/login") else {
            print("Invalid URL")
            return
        }
        
        let body: [String: String] = ["username": username, "password": password]
        guard let finalBody = try? JSONSerialization.data(withJSONObject: body) else {
            print("Failed to serialize body")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = finalBody
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                if let error = error {
                    // Handle error case
                    print("Login error: \(error.localizedDescription)")
                    self.errorMessage = "登录错误，请稍后再试。"
                    return
                }
                
                guard let response = response as? HTTPURLResponse else {
                    print("Invalid response or data")
                    self.errorMessage = "服务器响应无效。"
                    return
                }
                
                if response.statusCode == 200 {
                    print("Login successful for user: \(username)")
                    self.errorMessage = nil
                    DispatchQueue.main.async {
                        self.userAuth.isLoggedIn = true  // 更新登录状态
                        self.userAuth.username = username  // 从登录响应中设置用户名
                    }
                    // 确保这里正确处理了登录逻辑，比如更新用户状态等
                } else if response.statusCode == 400 {
                    print("Received 400 error for user: \(username)")
                    self.errorMessage = "用户名或密码不正确。"
                } else {
                    print("Received unexpected status code \(response.statusCode) for user: \(username)")
                    self.errorMessage = "登录失败，请稍后再试。"
                }
            }
        }.resume()
    }
}

struct LoginView_Previews: PreviewProvider {
    @State static var activeView: ActiveView = .login
    
    static var previews: some View {
        LoginView(activeView: $activeView).environmentObject(UserAuth())
    }
}
