//
//  RegisterView.swift
//  Blog
//
//  Created by wyf on 02/04/2024.
//

import SwiftUI

struct RegisterView: View {
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("用户名", text: $username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                TextField("电子邮箱", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                SecureField("密码", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button(action: registerUser) {
                    Text("注册")
                        .foregroundColor(.white)
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(40)
                }
                .padding()
            }
            .padding()
            .navigationBarTitle("注册")
        }
    }
    
    func registerUser(username: String, email: String, password: String) {
        guard let url = URL(string: "http://localhost:3000/api/register") else { return }
        
        let body: [String: String] = ["username": username, "email": email, "password": password]
        let finalBody = try? JSONSerialization.data(withJSONObject: body)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = finalBody
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Registration error: \(error.localizedDescription)")
                return
            }
            
            if let data = data,
               let response = response as? HTTPURLResponse,
               response.statusCode == 201 {
                
                let responseString = String(data: data, encoding: .utf8) ?? ""
                print("Registration successful: \(responseString)")
            } else {
                print("Registration failed")
            }
        }.resume()
    }
    func registerUser() {
        guard let url = URL(string: "http://localhost:3000/api/register") else { return }

        let body: [String: String] = ["username": username, "email": email, "password": password]
        let finalBody = try? JSONSerialization.data(withJSONObject: body)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = finalBody
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Registration error: \(error.localizedDescription)")
                return
            }

            if let data = data,
               let response = response as? HTTPURLResponse,
               response.statusCode == 201 {

                let responseString = String(data: data, encoding: .utf8) ?? ""
                print("Registration successful: \(responseString)")
            } else {
                print("Registration failed")
            }
        }.resume()
    }

}
