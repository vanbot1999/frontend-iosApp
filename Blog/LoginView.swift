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
    @EnvironmentObject var userAuth: UserAuth
    @Binding var activeView: ActiveView
    
    var body: some View {
        VStack {
            TextField("用户名", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .autocapitalization(.none)

            SecureField("密码", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button("登录", action: loginUser)
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
                    return
                }

                guard let data = data, let response = response as? HTTPURLResponse else {
                    print("Invalid response or data")
                    return
                }

                if response.statusCode == 200 {
                    // Attempt to parse the JSON data
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                            if let token = json["token"] as? String, let username = json["username"] as? String {
                                // Here you might want to save the token securely, e.g., in Keychain
                                print("Received token: \(token)")

                                // Update your UserAuth object
                                self.userAuth.username = username
                                self.userAuth.isLoggedIn = true
                            } else {
                                print("Username or token missing in response")
                            }
                        }
                    } catch {
                        print("Failed to parse JSON: \(error.localizedDescription)")
                    }
                } else {
                    // Handle non-200 responses
                    print("Login failed with status code: \(response.statusCode)")
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
