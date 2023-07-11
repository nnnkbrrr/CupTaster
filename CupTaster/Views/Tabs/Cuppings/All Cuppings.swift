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
            if cuppings.count > 0 {
                List {
                    Section { } header: { AllCuppingHeaderView() }
                        .font(.body)
                        .listRowInsets(EdgeInsets(top: .large, leading: -.large, bottom: .zero, trailing: -.large))
                        .headerProminence(.increased)
                    
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
#warning("gesture: delete")
                    } header: {
                        HStack {
#warning("date")
                            Text("Date")
                            Spacer()
#warning("cuppings count")
                            Text("Cuppings Count")
                        }
                        .listRowInsets(EdgeInsets(top: .zero, leading: .large, bottom: .zero, trailing: .large))
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
        NavigationLink(destination: CuppingView(cupping: cupping)) {
#warning("navigation destination: cupping")
            HStack {
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
                
                Spacer()
                
                let cuppingDate: String = DateFormatter.short.string(from: cupping.date)
                Text(cuppingDate)
                    .foregroundStyle(.gray)
                    .font(.caption)
            }
        }
    }
}
