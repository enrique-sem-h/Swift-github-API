//
//  ContentView.swift
//  Swift-APIs
//
//  Created by Enrique Carvalho on 17/08/23.
//

import SwiftUI

struct ContentView: View {
    @State private var user: GitHubUser?
    @State private var username: String = ""
    
    var body: some View {
        VStack {
            HStack {
                ZStack {
                    HStack {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(.gray)
                            .opacity(0.3)
                            .frame(width: 250, height: 50)
                        .padding()
                    }
                    TextField("Search", text: $username)
                        .autocapitalization(.none)
                        .frame(width: 200)
                }
                Button {
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
                        username = ""
                    }
                } label: {
                    Image(systemName: "magnifyingglass")
                }.buttonStyle(.borderedProminent)

            }
            HStack {                
                AsyncImage(url: URL(string: user?.avatarUrl ?? "")) { img in
                    img
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(Circle())
                } placeholder: {
                    Circle()
                        .foregroundColor(.primary)
                        
                }.frame(width: 150)
                
                    
                VStack {
                    Text(user?.login ?? "Username")
                        .bold()
                    Text((user?.bio ?? "This is where the GitHub bio will go. Let's make it long so it spans a few lines."))
                        .lineLimit(3)
                }
            }
            .padding()
//            .task {
//                do{
//                        user = try await getUser()
//                } catch GHError.invalidURL {
//                    print("invalidURL")
//                } catch GHError.invalidData {
//                    print("invalidData")
//                } catch GHError.invalidResponse {
//                    print("invalidResponse")
//                } catch {
//                    print("Something happened, not sure why :(")
//                }
//            }
            Spacer()
        }
    }
    
    func getUser() async throws -> GitHubUser{
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

struct GitHubUser: Codable{
    let login: String
    let avatarUrl: String
    let bio: String?
    
    
}

enum GHError: Error{
    case invalidURL
    case invalidResponse
    case invalidData
}
