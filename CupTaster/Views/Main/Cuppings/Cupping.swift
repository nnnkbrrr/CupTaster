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
    
    @State private var settingsModalIsActive: Bool = false
    
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
                        ForEach(cupping.sortedSamples) { sample in
                            if samplesControllerModel.selectedSample != sample {
                                SamplePreview(sample)
                            } else {
                                Color.clear
                            }
                        }
                    }
                    .padding(.small)
                }
                .background(Color.backgroundPrimary)
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                    HStack {
                        let showTemplate: Bool = cupping.name == ""
                        
                        Text(showTemplate ? "New Cupping" : cupping.name)
                            .multilineTextAlignment(.center)
                            .resizableText()
                            .foregroundStyle(showTemplate ? .gray : .primary)
                        
                        Image(systemName: "chevron.down.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: .regular, height: .regular)
                            .foregroundColor(.gray)
                    }
                    .frame(height: .large)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        settingsModalIsActive = true
                    }
            }
        }
        .stopwatchToolbarItem()
        .standardNavigation()
        .adaptiveSizeSheet(isActive: $settingsModalIsActive) {
            CuppingSettingsView(cupping: cupping, isActive: $settingsModalIsActive)
        }
    }
}

extension CuppingView {
    struct CuppingSettingsView: View {
        @ObservedObject var cupping: Cupping
        @Binding var isActive: Bool
        
        private let nameLengthLimit = 50
        
        var body: some View {
            VStack(spacing: .extraSmall) {
                TextField("Cupping Name", text: $cupping.name)
                    .resizableText(weight: .light)
                    .submitLabel(.done)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                    .padding(.vertical, .regular)
                    .onChange(of: cupping.name) { name in
                        if cupping.name.count > nameLengthLimit {
                            cupping.name = String(cupping.name.prefix(nameLengthLimit))
                        }
                    }
                    .bottomSheetBlock()
                
                Text("\(cupping.form?.title ?? "") • \(cupping.samples.count) Samples • \(cupping.cupsCount) Cups")
                    .font(.caption)
                    .foregroundStyle(.gray)
                    .padding(.vertical, .extraSmall)
                
                HStack(spacing: .extraSmall) {
                    Button {
#warning("action")
                    } label: {
                        HStack(spacing: .extraSmall) {
                            Image(systemName: "folder")
                            Text("Folders")
                        }
                    }
                    .buttonStyle(.bottomSheetBlock)
                    
                    Button {
#warning("action")
                    } label: {
                        HStack(spacing: .extraSmall) {
                            Image(systemName: "square.and.arrow.up")
                            Text("Share")
                        }
                    }
                    .buttonStyle(.bottomSheetBlock)
                }
                
#warning("location block")
                VStack { }.bottomSheetBlock()
                
                HStack(spacing: .extraSmall) {
                    Button {
#warning("action")
                    } label: {
                        Text("Delete")
                            .foregroundStyle(.red)
                    }
                    .buttonStyle(.bottomSheetBlock)
                    
                    Button {
#warning("action")
                        isActive = false
                    } label: {
                        HStack(spacing: .small) {
                            Text("Continue")
                            Image(systemName: "arrow.right")
                        }
                    }
                    .buttonStyle(.accentBottomSheetBlock)
                }
            }
            .padding([.horizontal, .bottom], .small)
        }
    }
}
