//
//  Main Tab Cupping Preview.swift
//  CupTaster
//
//  Created by Nikita on 04.02.2024.
//

import SwiftUI
import SwipeActions

extension MainTabView {
    struct SwipeActionView: View {
        let systemImage: String
        let title: String
        let color: Color
        let action: () -> ()
        
        init(systemImage: String, title: String, color: Color, action: @escaping () -> ()) {
            self.systemImage = systemImage
            self.title = title
            self.color = color
            self.action = action
        }
        
        var body: some View {
            SwipeAction {
                action()
            } label: { _ in
                VStack(spacing: .extraSmall) {
                    Image(systemName: systemImage)
                    Text(title)
                }
                .font(.subheadline)
                .foregroundStyle(.white)
            } background: { _ in
                color
            }
        }
    }
    
    struct CuppingPreview: View {
        @Environment(\.managedObjectContext) private var moc
        @ObservedObject var cupping: Cupping
        
        init(_ cupping: Cupping) {
            self.cupping = cupping
        }
        
        var body: some View {
            SwipeView {
                if cupping.isFault {
                    EmptyView()
                } else {
                    NavigationLink(destination: CuppingView(cupping)) {
                        HStack(spacing: .extraSmall) {
                            VStack(alignment: .leading, spacing: .extraSmall) {
                                Text(cupping.name == "" ? "New Cupping" : cupping.name)
                                    .multilineTextAlignment(.leading)
                                    .font(.callout)
                                
                                Text("\(cupping.form?.title ?? "") • \(cupping.samples.count) Samples • \(cupping.cupsCount) Cups")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            if cupping.isFavorite {
                                Image(systemName: "heart.fill")
                                    .foregroundStyle(.red)
                                    .font(.caption)
                            }
                            
                            Text(cupping.date.short)
                                .font(.caption)
                                .foregroundStyle(.gray)
                            
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.gray)
                        }
                        .padding(.regular)
                    }
                }
            } leadingActions: { context in
                if cupping.isFavorite {
                    SwipeActionView(systemImage: "heart.slash.fill", title: "Remove", color: .accentColor) {
                        cupping.isFavorite = false
                        try? moc.save()
                        context.state.wrappedValue = .closed
                    }
                } else {
                    SwipeActionView(systemImage: "heart.fill", title: "Mark", color: .accentColor) {
                        cupping.isFavorite = true
                        try? moc.save()
                        context.state.wrappedValue = .closed
                    }
                }
                
                SwipeActionView(systemImage: "folder.fill.badge.gearshape", title: "Folders", color: .indigo) {
#warning("folders")
                    context.state.wrappedValue = .closed
                }
            } trailingActions: { _ in
                SwipeActionView(systemImage: "trash.fill", title: "Delete", color: .red) {
                    withAnimation {
                        moc.delete(cupping)
                        try? moc.save()
                    }
                }
            }
            .allCuppingsActionsStyle()
            .background(Color.backgroundSecondary)
            .cornerRadius()
            .contextMenu {
                Section {
                    Button {
                        cupping.isFavorite.toggle()
                        try? moc.save()
                    } label: {
                        if cupping.isFavorite {
                            Label("Remove from Favorites", systemImage: "heart.slash.fill")
                        } else {
                            Label("Add to Favorites", systemImage: "heart")
                        }
                    }
                    
                    Button {
#warning("context menu")
                    } label: {
                        Label("Manage Folders", systemImage: "folder.badge.gearshape")
                    }
                }
                
                Section {
                    Button(role: .destructive) {
                        withAnimation {
                            moc.delete(cupping)
                            try? moc.save()
                        }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
    }
}
