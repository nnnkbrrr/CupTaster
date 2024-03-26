//
//  Cupping.swift
//  CupTaster
//
//  Created by Никита Баранов on 06.07.2023.
//

import SwiftUI
import CoreData

struct CuppingView: View {
    @Environment(\.dismiss) var dismiss
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
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .onAppear {
                        dismiss()
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            withAnimation {
                                moc.delete(cupping)
                                try? moc.save()
                            }
                        }
                    }
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
                            SamplePreview(sample)
                        }
                    }
                    .padding(.small)
                }
            }
        }
        .background(Color.backgroundPrimary, ignoresSafeAreaEdges: .all)
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
        .defaultNavigationBar()
        .adaptiveSizeSheet(isPresented: $settingsModalIsActive) {
            CuppingSettingsView(
                cupping: cupping,
                isActive: $settingsModalIsActive,
                onDelete: {
                    dismiss()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        withAnimation {
                            moc.delete(cupping)
                            try? moc.save()
                        }
                    }
                }
            )
        }
#warning("add new sample navigation tool")
    }
}
