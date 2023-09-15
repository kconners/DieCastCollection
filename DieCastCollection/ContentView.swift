//
//  ContentView.swift
//  DieCastCollection
//
//  Created by Kaylen Conners on 9/15/23.
//

import SwiftUI
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

struct ContentView: View {
    @State private var username = "";
    @State private var password = "";
    @State private var isLoggedIn = false;
    @State private var navPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navPath){
            ZStack {
                Color.blue
                    .ignoresSafeArea()
                Circle()
                    .scale(1.7)
                    .foregroundColor(.white.opacity(0.15))
                Circle()
                    .scale(1.35)
                    .foregroundColor(.white)
                VStack {
                    Text("Hot Wheels")
                        .font(.largeTitle)
                        .bold()
                        .padding()
                    TextField("Username", text:$username)
                        .padding()
                        .frame(width: 300, height: 50)
                        .background(Color.black.opacity(0.05))
                        .cornerRadius(10)
                    TextField("Password", text:$password)
                        .padding()
                        .frame(width: 300, height: 50)
                        .background(Color.black.opacity(0.05))
                        .cornerRadius(10)
                    Button("Login"){
                        authencateUser(username: username, password: password)
                    }
                    .foregroundColor(.white)
                    .frame(width: 300, height: 50)
                    .background(Color.blue)
                    .cornerRadius(10)
                    .navigationDestination(isPresented: $isLoggedIn) {
                        MyLibrary()
                             }
                    
                 //   NavigationLink(destination: MyLibrary(), isActive: $isLoggedIn) {EmptyView()}
                }
            }
        }
    }

    func authencateUser(username: String, password: String) {
        let semaphore = DispatchSemaphore(value: 0)
        let loginCredentials = loginCreds(user_name: username, password: password)
        
        var request = URLRequest(url: URL(string: "http://127.0.0.1:3000/users/login")!, timeoutInterval: Double.infinity)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        do {
            let jsonData = try JSONEncoder().encode(loginCredentials)
            request.httpBody = jsonData
        } catch let jsonErr {
            print(jsonErr)
        }
        
        let task = URLSession.shared.dataTask(with: request) {data, response, error in
            guard let data = data else {
                print(String(describing: error))
                semaphore.signal()
                return
            }
            do {
                print("here")
                let credInfo = try JSONDecoder().decode(currentUser.self, from: data)
                UserDefaults.standard.set(credInfo.token, forKey: "token")
                isLoggedIn = true
                print("there")
            }
            catch {
                print("JSONSerialization error:", error)
            }
            semaphore.signal()
        }
        task.resume()
        
        semaphore.signal()
    }
}

struct loginCreds: Codable {
    public var user_name: String
    public var password: String
}

struct currentUser: Codable {
    public var token: String
    public var id: String
    public var first_name: String
    public var last_name: String
    public var user_name: String
    public var email: String
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
