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
    @State private var errorMessage: String = ""
    @EnvironmentObject var userAuth: UserAuth
    @Binding var activeView: ActiveView
    
    var body: some View {
        VStack {
            TextField("用户名", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .autocapitalization(.none)
            
            TextField("电子邮箱", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
            
            SecureField("密码", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
            
            Button("注册", action: registerUser)
                .foregroundColor(.white)
                .frame(minWidth: 0, maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(40)
                .padding()
            
            Button("已有账号？登录") {
                activeView = .login
            }
            .foregroundColor(.blue)
            .padding()
        }
        .padding()
        .navigationBarTitle("注册", displayMode: .inline)
        .navigationBarHidden(true)
    }
    
    func registerUser() {
        guard !username.isEmpty else {
            errorMessage = "用户名不能为空。"
            return
        }
        
        guard !email.isEmpty else {
            errorMessage = "电子邮箱不能为空。"
            return
        }
        
        guard !password.isEmpty else {
            errorMessage = "密码不能为空。"
            return
        }
        // 添加密码强度规则
        if password.count < 8 {
            errorMessage = "密码长度至少为8个字符。"
            return
        }
        
        if !containsSpecialCharacter(password) {
            errorMessage = "密码必须包含至少一个特殊字符。"
            return
        }
        
        if !containsUppercaseLetter(password) {
            errorMessage = "密码必须包含至少一个大写字母。"
            return
        }
        
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
                DispatchQueue.main.async { [self] in
                    errorMessage = "注册失败，请稍后再试。"
                }
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                if let data = data {
                    if httpResponse.statusCode == 201 {
                        DispatchQueue.main.async { [self] in
                            errorMessage = "注册成功！"
                            // 清空输入字段
                            username = ""
                            email = ""
                            password = ""
                        }
                    } else if httpResponse.statusCode == 409 {
                        do {
                            let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
                            DispatchQueue.main.async { [self] in
                                errorMessage = errorResponse.message
                            }
                        } catch {
                            DispatchQueue.main.async { [self] in
                                errorMessage = "注册失败，请稍后再试。"
                            }
                        }
                    } else {
                        DispatchQueue.main.async { [self] in
                            errorMessage = "注册失败，请稍后再试。"
                        }
                    }
                } else {
                    DispatchQueue.main.async { [self] in
                        errorMessage = "注册失败，请稍后再试。"
                    }
                }
            } else {
                DispatchQueue.main.async { [self] in
                    errorMessage = "注册失败，请稍后再试。"
                }
            }
        }.resume()
    }
    func containsSpecialCharacter(_ password: String) -> Bool {
        let specialCharacterSet = CharacterSet(charactersIn: "!@#$%^&*()-_=+[{]}\\|;:'\",<.>/?")
        return password.rangeOfCharacter(from: specialCharacterSet) != nil
    }

    func containsUppercaseLetter(_ password: String) -> Bool {
        let uppercaseLetterSet = CharacterSet.uppercaseLetters
        return password.rangeOfCharacter(from: uppercaseLetterSet) != nil
    }
}

struct ErrorResponse: Decodable {
    let message: String
}

struct RegisterView_Previews: PreviewProvider {
    @State static var activeViewPreview: ActiveView = .register
    
    static var previews: some View {
        RegisterView(activeView: $activeViewPreview).environmentObject(UserAuth())
    }
}
