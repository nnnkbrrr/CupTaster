//
//  SA Info.swift
//  CupTaster
//
//  Created by Никита Баранов on 01.03.2023.
//

import SwiftUI
import CoreData

extension SampleView {
    var infoAppearance: some View {
        ScrollView {
            LazyVStack {
            RadarChart(sample: sample)
                .padding()
            
            AdditionalFieldsView(cuppingModel: cuppingModel, sample: sample)
                .padding(.horizontal, 20)
                .padding(.bottom)
                .padding(.bottom, 100) // toolbar
                
            }
        }
        .resignKeyboardOnDragGesture() { try? moc.save() }
    }
}

private struct AdditionalFieldsView: View {
    @Environment(\.managedObjectContext) private var moc
    @FetchRequest(
        entity: SampleGeneralInfo.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \SampleGeneralInfo.ordinalNumber, ascending: true)]
    ) var sgiFields: FetchedResults<SampleGeneralInfo>
    @ObservedObject var cuppingModel: CuppingModel
    let sample: Sample
    
    @State private var newSGIFieldTitle: String = ""
    @State private var newSGIFieldVisible: Bool = false
    @FocusState private var newSGIFieldFocused: Bool
    
    @State var cameraIsActive: Bool = false
    @State var photoPickerIsActive: Bool = false
	
    var body: some View {
        LazyVStack {
            let addedSGIFields: [SampleGeneralInfo] =
            Array(sample.generalInfo).sorted { $0.ordinalNumber < $1.ordinalNumber }
            
            let suggestedSGIFields: [FetchedResults<SampleGeneralInfo>.Element] = sgiFields.filter {
                $0.sample == nil && !addedSGIFields.map { $0.title }.contains($0.title)
            }
            
            toolbar
            
            ForEach(addedSGIFields) { SGIFieldView(sampleGeneralInfo: $0) }
            
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
                .padding()
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .cornerRadius(10)
                .onAppear { newSGIFieldFocused = true }
            }
            
            ForEach(suggestedSGIFields) { sgiField in
                Button {
                    let newSGIField: SampleGeneralInfo = SampleGeneralInfo(context: moc)
                    newSGIField.title = sgiField.title
                    newSGIField.ordinalNumber = Int16(sgiFields.filter({ $0.sample == sample }).count)
                    newSGIField.sample = sample
                    
                    newSGIFieldTitle = ""
                    newSGIFieldFocused = false
                    newSGIFieldVisible = false
                } label: {
                    HStack {
                        Image(systemName: "plus")
                            .foregroundColor(.accentColor)
                        
                        Text(sgiField.title)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding()
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .cornerRadius(10)
                }
            }
        }
    }
    
    var toolbar: some View {
        HStack(spacing: 0) {
            Button {
                withAnimation { newSGIFieldVisible = true }
            } label: {
                Image(systemName: "text.badge.plus")
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
            }
            
            Divider()
            
			#warning("add image")
            Menu {
				Text("Pass")
            } label: {
                Image(systemName: "photo")
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
            }
            
            Divider()
            
            Menu {
                Button("Delete", role: .destructive) {
                    withAnimation {
                        moc.delete(sample)
                        
                        let cupping: Cupping = sample.cupping
                        let sortedSamples: [Sample] = cupping.getSortedSamples()
                        if sortedSamples.count > 1 {
                            if cuppingModel.selectedSampleIndex != 0 {
                                self.cuppingModel.selectedSampleIndex! -= 1
                                self.cuppingModel.selectedSample = sortedSamples[cuppingModel.selectedSampleIndex!]
                            } else {
                                self.cuppingModel.selectedSample = sortedSamples[cuppingModel.selectedSampleIndex! + 1]
                            }
                        } else {
                            self.cuppingModel.selectedSampleIndex = 0
                            self.cuppingModel.selectedSample = nil
                            self.cuppingModel.sampleViewVisible = false
                        }
                        
                        try? moc.save()
                    }
                }
            } label: {
                Image(systemName: "trash")
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
            }
        }
        .font(.system(size: 17, weight: .semibold))
        .padding(.vertical)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(10)
    }
    
    func addNewGIField() {
        let newSGIField: SampleGeneralInfo = SampleGeneralInfo(context: moc)
        newSGIField.title = newSGIFieldTitle
        newSGIField.ordinalNumber = Int16(sgiFields.filter({ $0.sample == sample }).count)
        newSGIField.sample = sample
        
        newSGIFieldTitle = ""
        newSGIFieldFocused = false
        newSGIFieldVisible = false
    }
}

extension AdditionalFieldsView {
    private struct SGIFieldView: View {
        @Environment(\.managedObjectContext) private var moc
        @ObservedObject var sampleGeneralInfo: SampleGeneralInfo
        
        var body: some View {
            VStack(alignment: .leading, spacing: 15) {
                HStack {
                    Text(sampleGeneralInfo.title)
                    Spacer()
                    Button {
                        moc.delete(sampleGeneralInfo)
                        try? moc.save()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                            .padding(.horizontal, 10)
                            .contentShape(Rectangle())
                    }
                }
                Divider()
                TextField(sampleGeneralInfo.title, text: $sampleGeneralInfo.value) { try? moc.save() }
                    .submitLabel(.done)
            }
            .padding()
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .cornerRadius(10)
        }
    }
}
