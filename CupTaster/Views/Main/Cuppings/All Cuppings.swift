//
//  All Cuppings.swift
//  CupTaster
//
//  Created by Никита Баранов on 28.06.2023.
//

import SwiftUI

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
    
    @State var newCupping: Cupping? = nil
    
    var body: some View {
        NavigationView {
            if let cuppingsGroupedByMonth {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        ForEach(cuppingsGroupedByMonth, id: \.key) { date, cuppings in
                            Text(date)
                                .frame(height: .smallElement)
                            
                            Divider()
                            
                            ForEach(cuppings) {
                                CuppingPreview($0)
                                    .background(Color.backgroundSecondary)
                                
                                Divider()
                            }
                            .onDelete { offsets in
                                for index in offsets {
                                    moc.delete(cuppings[index])
                                    try? moc.save()
                                }
                            }
                        }
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
                            let newCupping: Cupping = Cupping(context: moc)
                            newCupping.cupsCount = 5
                            newCupping.date = Date()
                            newCupping.name = ""
                            try? moc.save()
                            
                            self.newCupping = newCupping
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
            } else {
                isEmpty
            }
        }
    }
    
    struct CuppingPreview: View {
        @ObservedObject var cupping: Cupping
        
        init(_ cupping: Cupping) {
            self.cupping = cupping
        }
        
        var body: some View {
            NavigationLink(destination: CuppingView(cupping)) {
                HStack(spacing: .regular) {
                    VStack(alignment: .leading, spacing: .extraSmall) {
                        Text(cupping.name == "" ? "New Cupping" : cupping.name)
                            .font(.callout)
                        
                        Text("\(cupping.form?.title ?? "") • \(cupping.samples.count) Samples • \(cupping.cupsCount) Cups")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Text(DateFormatter.short.string(from: cupping.date))
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
        
        return groupedCuppings.sorted(by: { $0.key < $1.key })
    }
}
