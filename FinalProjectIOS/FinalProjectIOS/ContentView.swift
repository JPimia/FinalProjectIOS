//
//  ContentView.swift
//  FinalProjectIOS
//
//  Created by Jari Pimiä on 10.5.2023.
//

import SwiftUI
import Alamofire
import SDWebImageSwiftUI

/// Represents a user with various properties.
struct User: Decodable {
    /// The unique identifier of the user.
    let id: Int
    
    /// The first name of the user.
    let firstName: String
    
    /// The last name of the user.
    let lastName: String
    
    /// The age of the user.
    let age: Int
    
    /// The email address of the user.
    let email: String
    
    /// The URL of the user's profile image.
    let image: String
}

/// Represents the data model containing an array of users.
struct Data: Decodable {
    /// The array of users.
    var users: Array<User>
}

/// A view model for managing the user data.
class UserViewModel: ObservableObject {
    /// The array of users, published as an observable property.
    @Published var userArray: [User] = []
    
    /// Fetches users from a remote server.
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

/// A view representing an individual user item in the list.
struct UserItem: View {
    let user: User
    var onDelete: () -> Void
    
    var body: some View {
        HStack {
            
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
            Spacer()
                        
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
                .padding(.trailing)
        }
    }
}

/// A view representing the search bar component.
struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            TextField("Search", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Button(action: {
                text = ""
            }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.gray)
                    .padding(.trailing, 16)
                    .opacity(text.isEmpty ? 0 : 1)
            }
        }
        .padding(.horizontal)
    }
}

/// The main view of the app.
struct ContentView: View {
    @StateObject var userViewModel = UserViewModel()
    @State private var searchBar = ""
    @State private var isAddingUser = false
    @State private var userFirstName = ""
    @State private var userLastName = ""
    @State private var userAge = ""
    @State private var userEmail = ""
    
    /// The list of users filtered based on the search query.
    var filteredUsers: [User] {
        if(searchBar.isEmpty) {
            return userViewModel.userArray
        } else {
            return userViewModel.userArray.filter { user in
                
                let ageString = String(user.age)
                
                return user.firstName.localizedCaseInsensitiveContains(searchBar) ||
                user.lastName.localizedCaseInsensitiveContains(searchBar) ||
                user.email.localizedCaseInsensitiveContains(searchBar) ||
                ageString.localizedCaseInsensitiveContains(searchBar)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                
                SearchBar(text: $searchBar)
                
                ScrollView {
                    LazyVStack {
                        ForEach(filteredUsers, id: \.id) { user in
                            
                            UserItem(user: user) {
                                deleteUser(user)
                            }
                        }
                    }
                    .padding(.vertical)
                }
                Button(action: {
                    isAddingUser = true
                }) {
                    Text("Add User")
                        .font(.headline)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            }
            .navigationTitle("Users")
            .sheet(isPresented: $isAddingUser) {
                
                addUserView()
                    .presentationDetents([.fraction(0.5)])
            }
        }
        .onAppear {
            userViewModel.fetchUsers()
        }
    }
    
    /// Returns a view for adding a new user.
    func addUserView() -> some View {
        VStack {
            TextField("firstname", text: $userFirstName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            TextField("lastname", text: $userLastName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            TextField("age", text: $userAge)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            TextField("email", text: $userEmail)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            HStack {
                Button(action: {
                    addUser(firstName: userFirstName, lastName: userLastName, age: userAge, email: userEmail)
                    isAddingUser = false
                }) {
                    Text("Add")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Button(action: {
                    isAddingUser = false
                }) {
                    Text("Cancel")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal)
        }
        .padding(.horizontal)
            .background(Color.white)
            .cornerRadius(10)
    }
    
    /// Adds a new user to the server and updates the user array.
    func addUser(firstName: String, lastName: String, age: String, email: String) {
        let parameters: [String: Any] = [
            "firstName": firstName,
            "lastName": lastName,
            "age": age,
            "email": email
        ]
        
        AF.request("https://dummyjson.com/users", method: .post, parameters: parameters, encoding: JSONEncoding.default).response { response in
            switch response.result {
            case .success:
                let newUser = User(
                    id: userViewModel.userArray.count + 1,
                    firstName: userFirstName,
                    lastName: userLastName,
                    age: Int(userAge)!,
                    email: userEmail,
                    image: "https://robohash.org/\(userFirstName + userLastName)"
                )
                userViewModel.userArray.append(newUser)
                userFirstName = ""
                userLastName = ""
                userAge = ""
                userEmail = ""
                print(parameters)
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    /// Deletes a user from the server and updates the user array.
    func deleteUser(_ user: User) {
        let url = "https://dummyjson.com/users/\(user.id)"
        
        AF.request(url, method: .delete).response { response in
            switch response.result {
            case .success:
                let updatedUsers = userViewModel.userArray.filter { user.id != $0.id }
                userViewModel.userArray = updatedUsers
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        }
    }
}

/// A preview provider for the `ContentView` view.
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
