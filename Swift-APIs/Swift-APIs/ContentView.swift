//
//  ContentView.swift
//  Swift-APIs
//
//  Created by Enrique Carvalho on 17/08/23.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(sortDescriptors: [SortDescriptor(\.login, order: .reverse)]) var GHuser: FetchedResults<GHUser>
    
    @State private var user: GitHubUser?
//    @State private var user: GitHubUser? = GitHubUser(login: "enrique-sem-h", avatarUrl: "https://avatars.githubusercontent.com/u/111439330?v=4", bio: nil)
    @State private var username: String = ""
    @State private var isShowing = false
    
    var body: some View { // the main view
        VStack { /// the whole view
            HStack { /// top's hstack
                ZStack { // the textfield with the rectangle
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(.gray)
                            .opacity(0.3)
                            .frame(width: 250, height: 50)
                            .padding([.leading, .bottom, .top])
                    TextField("Search", text: $username)
                        .autocapitalization(.none)
                        .frame(width: 200)
                        .onSubmit { // when pressing return
                            callAPI() // call the task which retrieves the user info from GitHub
                        }
                }
                
                Button { // the search button, which calls the api
                    callAPI()
                } label: {
                    Image(systemName: "magnifyingglass")
                        .frame(height: 35)
                }.buttonStyle(.borderedProminent)
                Button {
                    if user != nil{
                        DataController().addUser(login: user!.login, avatarUrl: user!.avatarUrl, bio: user?.bio ?? "bio not found 😔", context: managedObjectContext)
                        print("User saved")
                    } else {
                        print("user nil")
                    }
                } label: {
                    Image(systemName: "star")
                }
            } /// end of the top's hstack
            
            HStack { /// the horizontal stack in which the user's info is displayed
                AsyncImage(url: URL(string: user?.avatarUrl ?? "")) { img in // user's image with placeholder in case of nil
                    img
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(Circle())
                } placeholder: {
                    Circle()
                        .foregroundColor(.secondary)
                        
                }.frame(width: 150)
                    .padding()
                    
                VStack { // user's username and bio if not nil
                    Text(user?.login ?? "Username")
                        .bold()
                    Text((user?.bio ?? ""))
                        .lineLimit(3)
                }
            }
            .padding()
            Spacer()
            
            
            Button {
                isShowing.toggle()
            } label: {
                Image(systemName: "square.and.arrow.up")
            }.sheet(isPresented: $isShowing) {
                UsersView(user: $user)
            }
            Spacer()
        }
    }
    
    func callAPI(){ // sets a task which sets the user's attributes to match API's response
        Task{
            do{
                user = try await getUser()
            } catch GHError.invalidURL {
                print("invalidURL")
            } catch GHError.invalidData {
                print("invalidData")
            } catch GHError.invalidResponse {
                print("invalidResponse")
            } catch {
                print("Something happened, not sure why :(")
            }
            username = "" // resets the textfield
        }
    }
    
    func getUser() async throws -> GitHubUser{ // returns a decoded user
        let endpoint = "https://api.github.com/users/\(username)"
        
        guard let url = URL(string: endpoint) else { throw GHError.invalidURL }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else { throw GHError.invalidResponse }
    
    do{
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(GitHubUser.self, from: data)
    } catch {
        throw GHError.invalidData
    }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


