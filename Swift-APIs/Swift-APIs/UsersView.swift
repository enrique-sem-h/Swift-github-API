//
//  UsersView.swift
//  Swift-APIs
//
//  Created by Enrique Carvalho on 18/08/23.
//

import SwiftUI

struct UsersView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.dismiss) var dismiss
    @FetchRequest(sortDescriptors: [SortDescriptor(\.login)]) var GHuser: FetchedResults<GHUser>
    
    @Binding var user: GitHubUser?
    
    var body: some View {
        List {
            ForEach(GHuser) { GHuser in
                HStack {
                    AsyncImage(url: URL(string: GHuser.avatarUrl ?? "")) { img in // user's image with placeholder in case of nil
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
                        Text(GHuser.login!)
                            .bold()
                        Text(GHuser.bio!)
                            .lineLimit(1)
                            .fontWeight(.light)
                    }
                }.onTapGesture {
                    user = GitHubUser(login: GHuser.login!, avatarUrl: GHuser.avatarUrl!, bio: GHuser.bio)
                    dismiss()
                }
            }
            .onDelete(perform: deleteUser)
        }
    }
    
    private func deleteUser(offsets: IndexSet){
        withAnimation {
            offsets.map { GHuser[$0] }.forEach(managedObjectContext.delete)
            DataController().save(context: managedObjectContext)
        }
    }
}
