//
//  ContentView.swift
//  FinalProjectIOS
//
//  Created by Jari Pimiä on 10.5.2023.
//

import SwiftUI
import Alamofire

struct User: Decodable {
    let id: Int
    let firstName: String
    let lastName: String
    let age: Int
    let email: String
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

struct ContentView: View {
    @StateObject var userViewModel = UserViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                ForEach(userViewModel.userArray, id: \.id) { user in
                    
                    Text("Name: \(user.firstName) \(user.lastName)")
                }
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
