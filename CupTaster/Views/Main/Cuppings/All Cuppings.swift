//
//  All Cuppings.swift
//  CupTaster
//
//  Created by Никита Баранов on 28.06.2023.
//

import SwiftUI
import SwipeActions

struct AllCuppingsTabView: View {
    @Environment(\.managedObjectContext) private var moc
    @FetchRequest(
        entity: Cupping.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Cupping.date, ascending: false)]
    ) var cuppings: FetchedResults<Cupping>
    @FetchRequest(
        entity: Folder.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Folder.lastModifiedDate, ascending: false)]
    ) var folders: FetchedResults<Folder>
    
    @State var newCuppingModalIsActive: Bool = false
    
    init() {
        Navigation.configureWithoutBackground()
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                if let cuppingsGroupedByMonth {
                    SwipeViewGroup {
                        LazyVStack(alignment: .leading, spacing: 0) {
                            ForEach(cuppingsGroupedByMonth, id: \.key) { date, cuppings in
                                Text(date)
                                    .bold()
                                    .padding(.small)
                                    .frame(height: .smallElement)
                                
                                Divider()
                                
                                ForEach(cuppings) { cupping in
                                    SwipeView {
                                        CuppingPreview(cupping)
                                    } leadingActions: { context in
                                        SwipeActionView(systemImage: "heart.fill", title: "Favorite", color: .accentColor) {
#warning("like")
                                            context.state.wrappedValue = .closed
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
                                    .swipeActionsStyle(.cascade)
                                    .swipeActionsMaskCornerRadius(0)
                                    .swipeActionCornerRadius(0)
                                    .swipeSpacing(0)
                                    .swipeActionsVisibleStartPoint(0)
                                    .swipeActionsVisibleEndPoint(0)
                                    .swipeMinimumDistance(25)
                                    .background(Color.backgroundSecondary)
                                    .contextMenu {
                                        Section {
                                            Button {
#warning("context menu")
                                            } label: {
#warning("label depends on if is favorite")
                                                Label("Add to Favorites", systemImage: "heart")
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
                                    
                                    Divider()
                                }
                            }
                        }
                    }
                } else {
                    isEmpty
                }
            }
            .background(Color.background)
            .navigationBarTitle("All Cuppings", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink(destination: SettingsTabView()) {
                        Image(systemName: "gearshape")
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        newCuppingModalIsActive = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .navigationToolbar {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: .large) {
                        Group {
                            Image(systemName: "plus")
                                .foregroundStyle(.gray)
                                .onTapGesture {
#warning("add folder")
                                }
                            
#warning("foreground color changed if selected")
                            Text("All")
                                .foregroundStyle(Color.accentColor)
                                .onTapGesture {
#warning("go to all cuppings")
                                }
                            
                            Text("Favorites")
                                .foregroundStyle(.gray)
                                .onTapGesture {
                                    
                                }
                            
#warning("rectangle at the bottom")
                            ForEach(folders) { folder in
                                Text(folder.name)
                                    .onTapGesture {
#warning("go to folder")
                                    }
                            }
                        }
                    }
                    .padding(.horizontal, .large)
                    .frame(height: 30)
                }
            }
        }
        .adaptiveSizeSheet(isActive: $newCuppingModalIsActive) {
            NewCuppingModalView(isActive: $newCuppingModalIsActive)
        }
    }
}
 
extension AllCuppingsTabView {
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
        @ObservedObject var cupping: Cupping
        
        init(_ cupping: Cupping) {
            self.cupping = cupping
        }
        
        var body: some View {
            if cupping.isFault {
                EmptyView()
            } else {
                NavigationLink(destination: CuppingView(cupping)) {
                    HStack(spacing: .extraSmall) {
                        VStack(alignment: .leading, spacing: .extraSmall) {
                            Text(cupping.name == "" ? "New Cupping" : cupping.name)
                                .font(.callout)
                            
                            Text("\(cupping.form?.title ?? "") • \(cupping.samples.count) Samples • \(cupping.cupsCount) Cups")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        Text(cupping.date.short)
                            .font(.caption)
                            .foregroundStyle(.gray)
                        
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.gray)
                    }
                    .padding(.regular)
                }
            }
        }
    }
}

extension AllCuppingsTabView {
    var cuppingsGroupedByMonth: [Dictionary<String, [Cupping]>.Element]? {
        guard let firstCupping: Cupping = cuppings.first else { return nil }
        
        var key: String = DateFormatter.fullMonthAndYear.string(from: firstCupping.date)
        var groupedCuppings: [String: [Cupping]] = [key : [firstCupping]]
        
        let calendar: Calendar = Calendar.current
        for (prevCupping, nextCupping) in zip(cuppings, cuppings.dropFirst()) {
            if !calendar.isDate(prevCupping.date, equalTo: nextCupping.date, toGranularity: .month) {
                key = DateFormatter.fullMonthAndYear.string(from: nextCupping.date)
            }
            groupedCuppings[key, default: []].append(nextCupping)
        }
        
        return groupedCuppings.sorted(by: { $0.key > $1.key })
    }
}
