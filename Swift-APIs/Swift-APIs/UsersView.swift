//
//  UsersView.swift
//  Swift-APIs
//
//  Created by Enrique Carvalho on 18/08/23.
//

import SwiftUI
import CloudKit

struct UsersView: View {
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var vm = GHUserViewModel(container: CKContainer.default())
    @Binding var mainViewUser: GitHubUserLocal?

//    init(vm: GHUserViewModel) {
//        _vm = StateObject(wrappedValue: vm)
//    }

    var body: some View {
        VStack{
            List{
                ForEach(vm.users, id: \.self){ user in
                    HStack {
                        AsyncImage(url: URL(string: user.avatarUrl)) { img in // user's image with placeholder in case of nil
                            img
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .clipShape(Circle())
                        } placeholder: {
                            Circle()
                                .foregroundColor(.secondary)
                            
                        }.frame(width: 80)
                            .padding()
                        VStack {
                            Text(user.login)
                                .bold()
                            Text(user.bio!)
                                .lineLimit(1)
                                .fontWeight(.light)
                        }
                    }.onTapGesture {
                        mainViewUser = GitHubUserLocal(login: user.login, avatarUrl: user.avatarUrl, bio: user.bio)
                        dismiss()
                    }
                }.onDelete(perform: vm.del)
            }
        }.onAppear{
            vm.fetchItems()
        }
    }
}

//struct UsersView: View {
//    @StateObject private var vm: GHUserViewModel
//
//    init(vm: GHUserViewModel) {
//        _vm = StateObject(wrappedValue: vm)
//    }
//
//    var body: some View {
//        VStack{
//            List{
//                ForEach(0..<vm.users.count) { index in
//                    Text(vm.users[index].login)
//                }
//            }
//        }.onAppear{
//            vm.fetch()
//        }
//    }
//}

//struct UsersView_Previews: PreviewProvider {
//    static var previews: some View {
//        UsersView()
//    }
//}
