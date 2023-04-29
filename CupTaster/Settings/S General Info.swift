//
//  General Info.swift
//  CupTaster
//
//  Created by Никита Баранов on 06.11.2022.
//

import SwiftUI

struct Settings_GeneralInfoView: View {
    @Environment(\.managedObjectContext) private var moc
    @FetchRequest(
        entity: SampleGeneralInfo.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \SampleGeneralInfo.ordinalNumber, ascending: false)]
    ) var sgiFields: FetchedResults<SampleGeneralInfo>
    
    @State private var newSGIFieldTitle: String = ""
    @State private var newSGIFieldVisible: Bool = false
    @FocusState private var newSGIFieldFocused: Bool
    
    var body: some View {
        Form {
            Section {
                if newSGIFieldVisible {
                    HStack {
                        Button {
                            newSGIFieldTitle = ""
                            withAnimation { newSGIFieldVisible = false }
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .contentShape(Rectangle())
                        }
                        
                        TextField("Additional field", text: $newSGIFieldTitle) { addNewGIField() }
                            .submitLabel(.done)
                            .focused($newSGIFieldFocused, equals: true)
                        
                        Button { addNewGIField() } label: {
                            Image(systemName: "checkmark.circle.fill")
                                .contentShape(Rectangle())
                        }
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    .onAppear { newSGIFieldFocused = true }
                } else {
                    Button {
                        withAnimation { newSGIFieldVisible = true }
                    } label: {
                        Label("Additional field", systemImage: "plus")
                            .submitLabel(.done)
                    }
                }
            } header: {
                Text(" ")
            } footer: {
                Text("These fields do not affect the result and can be filled in sample's «General Information» section.")
            }
            
            Section {
                let quickSGIs: [SampleGeneralInfo] =
                sgiFields.filter { $0.sample == nil }.sorted(by: { $0.ordinalNumber < $1.ordinalNumber })
                
                ForEach(quickSGIs) { SGITitleFieldView(sampleGeneralInfo: $0) }
                    .onMove { indexSet, offset in
                        var revisedItems: [SampleGeneralInfo] = quickSGIs
                        revisedItems.move(fromOffsets: indexSet, toOffset: offset)
                        
                        for reverseIndex in stride(from: revisedItems.count - 1, through: 0, by: -1) {
                            revisedItems[reverseIndex].ordinalNumber = Int16(reverseIndex)
                        }
                        
                        try? moc.save()
                    }
                    .onDelete { offsets in
                        for index in offsets {
                            moc.delete(quickSGIs[index])
                        }
                        try? moc.save()
                    }
            }
        }
        .resignKeyboardOnDragGesture() { try? moc.save() }
        .environment(\.editMode, .constant(.active))
    }
    
    private struct SGITitleFieldView: View {
        @ObservedObject var sampleGeneralInfo: SampleGeneralInfo
        var body: some View {
            TextField("Additional field", text: $sampleGeneralInfo.title)
                .submitLabel(.done)
        }
    }
    
    func addNewGIField() {
        let newSGIField: SampleGeneralInfo = SampleGeneralInfo(context: moc)
        newSGIField.title = newSGIFieldTitle
        newSGIField.ordinalNumber =
		Int16((sgiFields.filter({ $0.sample == nil }).map({ $0.ordinalNumber }).max() ?? 0) + 1)
        
        newSGIFieldTitle = ""
        newSGIFieldFocused = false
        newSGIFieldVisible = false
        try? moc.save()
    }
}
