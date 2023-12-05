//
//  Cupping Setup.swift
//  CupTaster
//
//  Created by Никита Баранов on 07.07.2023.
//

import SwiftUI

struct CuppingSetupView: View {
    @Environment(\.managedObjectContext) private var moc
    @FetchRequest(
        entity: CuppingForm.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \CuppingForm.title, ascending: false)]
    ) var cuppingForms: FetchedResults<CuppingForm>
    
    @ObservedObject var cupping: Cupping
    
    @State var selectedCuppingForm: CuppingForm?
    @State var selectedSamplesCount: Int = 1
    @State var selectedCupsCount: Int = 5
    
    var body: some View {
        List {
#warning("add cupping form settings")
            Section("Cupping Form") {
                Picker("Cupping Form", selection: $selectedCuppingForm) {
                    ForEach(cuppingForms) { cuppingForm in
                        Text(
                            cuppingForm.isDeprecated ?
                            "\(cuppingForm.shortDescription) (deprecated)" : cuppingForm.title
                        )
                        .tag(Optional(cuppingForm))
                    }
                }
            }
            
            Section("Cups Count") {
                HStack {
                    ForEach(1..<6, id: \.self) { cupsCount in
                        let isHighlighted: Bool = cupsCount <= cupping.cupsCount
                        
                        Image(systemName: "cup.and.saucer" + (isHighlighted ? ".fill" : ""))
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: .large)
                            .scaleEffect(isHighlighted ? 1 : 0.8)
                            .frame(maxWidth: 100)
                            .foregroundStyle(isHighlighted ? Color.accentColor : Color.gray)
                            .opacity(isHighlighted ? 1 : 0.5)
                            .contentShape(Rectangle())
                            .onTapGesture { selectedCupsCount = cupsCount }
                    }
                }
                .animation(.default, value: cupping.cupsCount)
            }
            
            Section("Initial Samples Count") {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 50, maximum: 70))]) {
                    ForEach(1..<16, id: \.self) { samplesCount in
                        let isSelected: Bool = selectedSamplesCount == samplesCount
                        Text("\(samplesCount)")
                            .fontWeight(isSelected ? .bold : .regular)
                            .foregroundStyle(isSelected ? Color.accentColor : .primary)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .onTapGesture { selectedSamplesCount = samplesCount }
                    }
                }
            }
            
            Button("Continue") {
                if let selectedCuppingForm {
                    cupping.setup(moc: moc, date: Date(), cuppingForm: selectedCuppingForm, cupsCount: selectedCupsCount, samplesCount: selectedSamplesCount)
                }
#warning("action: continue")
            }
            .buttonStyle(.primary)
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
#warning("on appear show cupping name settings")
        }
        .environment(\.defaultMinListRowHeight, 50)
    }
}
