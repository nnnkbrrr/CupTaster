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
    
    var body: some View {
        NavigationView {
            if let cuppingsGroupedByMonth {
                List {
                    Section { } header: { AllCuppingHeaderView() }
                        .font(.body)
                        .listRowInsets(EdgeInsets(top: .large, leading: -.large, bottom: .zero, trailing: -.large))
                        .headerProminence(.increased)
                    
                    ForEach(cuppingsGroupedByMonth.sorted(by: { $0.key > $1.key }), id: \.key) { date, cuppings in
                        Section {
                            ForEach(cuppings) { cupping in
                                cuppingPreview(cupping)
                            }
                            .onDelete { offsets in
                                for index in offsets {
                                    moc.delete(cuppings[index])
                                    try? moc.save()
                                }
                            }
                        } header: {
                            HStack {
                                Text(date)
                                Spacer()
                                Text("Cuppings: \(cuppings.count)")
                            }
                            .listRowInsets(EdgeInsets(top: .zero, leading: .large, bottom: .zero, trailing: .large))
                        }
                    }
                }
                .navigationBarTitle("All Cuppings", displayMode: .inline)
                .stopwatchToolbarItem()
            } else {
                isEmpty
            }
        }
    }
}

extension AllCuppingsTabView {
    @ViewBuilder
    func cuppingPreview(_ cupping: Cupping) -> some View {
        NavigationLink(destination: CuppingView(cupping)) {
#warning("navigation destination: cupping")
            HStack(spacing: .regular) {
                ZStack {
#warning("cupping color")
                    Rectangle()
                        .frame(width: .extraLarge, height: .extraLarge)
                        .foregroundColor(.accentColor)
                        .cornerRadius()
                    
#warning("cupping image")
                    Image(systemName: "star.fill")
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading) {
                    Text(cupping.name == "" ? "New Cupping" : cupping.name)
                        .font(.callout)
                        .lineLimit(1)
                    
                    let cuppingSamplesCount: Int = cupping.samples.count
                    
                    if cuppingSamplesCount > 0 {
#warning("cases: sample(s), cup(s)")
                        Text("\(cupping.samples.count) Samples • \(cupping.cupsCount) Cups")
                            .font(.caption)
                            .foregroundColor(.gray)
                    } else {
                        Text("Draft")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
            }
            .badge(
                Text(DateFormatter.short.string(from: cupping.date))
                    .font(.caption)
            )
        }
    }
}

extension AllCuppingsTabView {
    var cuppingsGroupedByMonth: [String: [Cupping]]? {
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
        return groupedCuppings
    }
}
