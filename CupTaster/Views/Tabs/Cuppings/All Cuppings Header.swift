//
//  All Cuppings Header.swift
//  CupTaster
//
//  Created by Никита Баранов on 04.07.2023.
//

import SwiftUI

struct AllCuppingHeaderView: View {
    @Environment(\.managedObjectContext) private var moc
    @FetchRequest(
        entity: Folder.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Folder.lastModifiedDate, ascending: false)]
    ) var folders: FetchedResults<Folder>
    
    @State var newCupping: Cupping? = nil
    @State var newCuppingDestinationIsActive: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: .small) {
            VStack(alignment: .leading, spacing: .extraSmall) {
                Text("Folders")
                    .font(.subheadline.bold())
                    .textCase(.uppercase)
                    .padding(.horizontal, .extraLarge)
                
                if folders.isEmpty {
                    Text("Create folders to sort you samples")
                        .foregroundColor(.gray)
                        .font(.subheadline)
                        .padding(.horizontal, .extraLarge)
                } else {
                    #warning("show folders")
                }
            }
            
            if folders.isEmpty {
                Button("New Folder") {
#warning("создать новую папку")
                }
                .buttonStyle(.secondary)
                .padding(.horizontal, .large)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 0) {
                        ForEach(0..<5, id: \.self) { i in
                            Rectangle()
                                .foregroundColor(Color(uiColor: .secondarySystemGroupedBackground))
                                .frame(width: 60 * CGFloat(i), height: 60)
                                .cornerRadius()
                                .padding(.trailing, .small)
                        }
                    }
                    .padding(.horizontal, .small)
                }
                .padding(.bottom, .small)
            }
            
            Text("Cuppings")
                .font(.subheadline.bold())
                .textCase(.uppercase)
                .padding(.horizontal, .extraLarge)
            
            Button("New Cupping") {
                let newCupping: Cupping = Cupping(context: moc)
                newCupping.cupsCount = 5
                newCupping.date = Date()
                newCupping.name = ""
                try? moc.save()
                
                self.newCupping = newCupping
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.newCuppingDestinationIsActive = true
                }
            }
            .buttonStyle(.primary)
            .background (
                ZStack {
                    if let newCupping {
                        NavigationLink(
                            destination: CuppingView(newCupping),
                            isActive: $newCuppingDestinationIsActive,
                            label: { EmptyView() }
                        )
                    }
                }
            )
            .padding(.horizontal, .large)
        }
    }
}
