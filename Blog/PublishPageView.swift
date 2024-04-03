//
//  PublishPageView.swift
//  Blog
//
//  Created by wyf on 01/04/2024.
//

import SwiftUI
import PhotosUI

struct PublishPageView: View {
    @EnvironmentObject var userAuth: UserAuth
    @State private var title: String = ""
    @State private var content: String = ""
    @State private var selectedImage: UIImage? = nil
    @State private var isShowingImagePicker = false
    @State private var isUploading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            VStack {
                if selectedImage != nil {
                    Image(uiImage: selectedImage!)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .padding()
                }
                
                Button("选择图片") {
                    isShowingImagePicker = true
                }
                .padding()
                .sheet(isPresented: $isShowingImagePicker) {
                    UIImagePicker(image: $selectedImage, isPresented: $isShowingImagePicker)
                }
                TextField("标题", text: $title)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                TextEditor(text: $content)
                    .border(Color.gray, width: 1)
                    .padding()
                
                if isUploading {
                    ProgressView()
                        .padding()
                } else {
                    Button("发布") {
                        uploadPost()
                    }
                    .padding()
                }
            }
            .navigationTitle("发布帖子")
            .disabled(isUploading)
            .blur(radius: isUploading ? 3 : 0)
            .sheet(isPresented: $isShowingImagePicker) {
                ImagePicker(image: $selectedImage)
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("提示"), message: Text(alertMessage), dismissButton: .default(Text("确定")))
            }
        }
    }
    
    private func uploadPost() {
        guard let url = URL(string: "http://localhost:3000/api/posts") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        body.append(convertFormField(named: "title", value: title, using: boundary))
        body.append(convertFormField(named: "content", value: content, using: boundary))
        body.append(convertFormField(named: "author", value: userAuth.username ?? "匿名", using: boundary))
        
        if let imageData = selectedImage?.jpegData(compressionQuality: 1.0) {
            body.append(convertFileData(fieldName: "image", fileName: "image.jpg", mimeType: "image/jpeg", fileData: imageData, using: boundary))
        }
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body
        
        isUploading = true
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isUploading = false
                if let error = error {
                    self.alertMessage = "上传帖子失败: \(error.localizedDescription)"
                    self.showAlert = true
                    return
                }
                
                guard let response = response as? HTTPURLResponse, response.statusCode == 201 else {
                    self.alertMessage = "服务器错误"
                    self.showAlert = true
                    return
                }
                
                self.alertMessage = "帖子上传成功"
                self.showAlert = true
                self.title = ""
                self.content = ""
                self.selectedImage = nil
            }
        }.resume()
    }
    
    private func convertFormField(named name: String, value: String, using boundary: String) -> Data {
        var fieldString = "--\(boundary)\r\n"
        fieldString += "Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n"
        fieldString += "\(value)\r\n"
        
        return fieldString.data(using: .utf8) ?? Data()
    }
    
    private func convertFileData(fieldName: String, fileName: String, mimeType: String, fileData: Data, using boundary: String) -> Data {
        var data = Data()
        data.append("--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        data.append(fileData)
        data.append("\r\n".data(using: .utf8)!)
        
        return data
    }
}

struct PublishPageView_Previews: PreviewProvider {
    static var previews: some View {
        PublishPageView().environmentObject(UserAuth())
    }
}

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
        // No need to implement this for the picker.
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            guard let provider = results.first?.itemProvider else { return }
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                    DispatchQueue.main.async {
                        if let image = image as? UIImage {
                            self?.parent.image = image
                        }
                    }
                }
            }
        }
    }
}
