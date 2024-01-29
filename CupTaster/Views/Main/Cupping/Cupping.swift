//
//  Cupping.swift
//  CupTaster
//
//  Created by Никита Баранов on 06.07.2023.
//

import SwiftUI
import CoreData

struct CuppingView: View {
    @Environment(\.managedObjectContext) private var moc
    @ObservedObject var samplesControllerModel: SamplesControllerModel = .shared
    @ObservedObject var cupping: Cupping
    
    init(_ cupping: Cupping) {
        self.cupping = cupping
    }
    
    var body: some View {
        Group {
            if cupping.samples.isEmpty {
                #warning("Empty Cupping")
            } else {
                ScrollView {
                    LazyVGrid(
                        columns: [
                            GridItem(
                                .adaptive(minimum: 150, maximum: 200),
                                spacing: .extraSmall,
                                alignment: .top
                            )
                        ],
                        spacing: .extraSmall
                    ) {
                        Section {
                            ForEach(cupping.sortedSamples) { sample in
                                if samplesControllerModel.selectedSample != sample {
                                    SamplePreview(sample)
                                } else {
                                    Color.clear
                                }
                            }
                        } header: {
                            Text("\(cupping.form?.title ?? "") • \(cupping.samples.count) Samples • \(cupping.cupsCount) Cups")
                                .font(.caption)
                                .foregroundStyle(.gray)
                                .padding(.vertical, .extraSmall)
                        }
                    }
                    .padding(.extraSmall)
                }
                .background(Color.backgroundPrimary)
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack {
                    let showTemplate: Bool = cupping.name == ""
                    
                    Text(showTemplate ? "New Cupping" : cupping.name)
                        .foregroundStyle(showTemplate ? .gray : .primary)
                    
                    Image(systemName: "chevron.down.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: .regular, height: .regular)
                        .foregroundColor(.gray)
                }
            }
        }
        .stopwatchToolbarItem()
        .standardNavigation()
    }
}

