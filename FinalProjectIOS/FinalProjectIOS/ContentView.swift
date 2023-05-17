//
//  ContentView.swift
//  FinalProjectIOS
//
//  Created by Jari Pimiä on 10.5.2023.
//

import SwiftUI
import Alamofire
import SDWebImageSwiftUI

struct User: Decodable {
    let id: Int
    let firstName: String
    let lastName: String
    let age: Int
    let email: String
    let image: String
}

struct Data: Decodable {
    var users: Array<User>
}

class UserViewModel: ObservableObject {
    @Published var userArray: [User] = []
    
    func fetchUsers() {
        AF.request("https://dummyjson.com/users").responseDecodable(of: Data.self) { response in
            switch response.result {
            case .success(let userData):
                self.userArray = userData.users
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        }
    }
}

struct UserItem: View {
    let user: User
    
    var body: some View {
        VStack {
            WebImage(url: URL(string: user.image))
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 48, height: 48)
                .clipShape(Circle())
            
            Text("Name: \(user.firstName) \(user.lastName)")
                .font(.headline)
            
            Text("Age: \(user.age)")
                .font(.body)
                .foregroundColor(.gray)
            
            Text("Email: \(user.email)")
                .font(.body)
                .foregroundColor(.gray)
        }
        .padding(8)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color.gray, lineWidth: 1)
        )
        .padding(8)
    }
}

struct ContentView: View {
    @StateObject var userViewModel = UserViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack {
                    ForEach(userViewModel.userArray, id: \.id) { user in
                        
                        UserItem(user: user)
                    }
                }
                .padding(.vertical)
            }
            
            .navigationTitle("Users")
        }
        .onAppear {
            userViewModel.fetchUsers()
        }
    }
        
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
