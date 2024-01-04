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
    @State var cupping: Cupping
    
    init(_ cupping: Cupping) {
        self.cupping = cupping
    }
    
    var body: some View {
        Group {
            if cupping.samples.isEmpty {
                CuppingSetupView(cupping: cupping)
            } else {
                ScrollView {
                    LazyVGrid(
                        columns: [
                            GridItem(
                                .adaptive(minimum: 150, maximum: 200),
                                spacing: .regular,
                                alignment: .top
                            )
                        ],
                        spacing: .regular
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
#warning("or to reorder!")
                            Text("Hold sample to show options")
                                .font(.caption2)
                                .textCase(.uppercase)
                                .foregroundStyle(.gray)
                        }
                    }
                    .padding(.regular)
                }
                .background(Color.background)
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack {
#warning("ui: cupping icon")
                    Rectangle()
                        .foregroundColor(.accentColor)
                        .frame(width: .large, height: .large)
                        .cornerRadius(.extraSmall)
                    
                    let showTemplate: Bool = cupping.name == ""
                    
                    Text(showTemplate ? "New Cupping" : cupping.name)
                        .foregroundStyle(showTemplate ? .gray : .primary)
                    
#warning("name in all cuppings + foregroundColor gray")
                    
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

