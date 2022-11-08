//
//  SampleView.swift
//  CupTaster
//
//  Created by Никита on 27.06.2022.
//

import SwiftUI

struct SampleView: View {
    @Environment(\.managedObjectContext) private var moc
    @ObservedObject var cuppingModel: CuppingModel
    @State var sample: Sample
    
    @Binding private var appearance: SampleAppearance
    
    init(cuppingModel: CuppingModel, sample: Sample, appearance: SampleAppearance = .criteria) {
        self.cuppingModel = cuppingModel
        self.sample = sample
        self._appearance = .constant(appearance)
    }
    
    init(cuppingModel: CuppingModel, sample: Sample, appearance: Binding<SampleAppearance>) {
        self.cuppingModel = cuppingModel
        self.sample = sample
        self._appearance = appearance
    }
    
    var body: some View {
        switch appearance {
        case .criteria:
            criteriaAppearance
                .padding(.bottom, 100) // toolbar
                .resignKeyboardOnDragGesture() { try? moc.save() }
        case .info:
            infoAppearance
                .padding(.bottom, 100) // toolbar
        }
    }
}

// MARK: Change appearance

enum SampleAppearance {
    case criteria, info
}

// MARK: All appearances

extension SampleView {
    private var criteriaAppearance: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                ForEach(
                    sample.qualityCriteriaGroups
                        .sorted(by: { $0.configuration.ordinalNumber < $1.configuration.ordinalNumber })
                ) { qcGroup in
                    EvaluationGroupView(cuppingModel: cuppingModel, qcGroup: qcGroup)
                }
            }
            .padding(.horizontal)
        }
    }
}

extension SampleView {
    private var infoAppearance: some View {
        Form {
            RadarChart(sample: sample)
            
            GeneralInfoSectionView(sample: sample)
            
            Section {
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
            }
        }
    }
    
    private struct GeneralInfoSectionView: View {
        @Environment(\.managedObjectContext) private var moc
        @FetchRequest(
            entity: SampleGeneralInfo.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \SampleGeneralInfo.ordinalNumber, ascending: false)]
        ) var sgiFields: FetchedResults<SampleGeneralInfo>
        let sample: Sample
        
        @State private var newSGIFieldTitle: String = ""
        @State private var newSGIFieldVisible: Bool = false
        @FocusState private var newSGIFieldFocused: Bool
        
        var body: some View {
            let addedSGIFields: [SampleGeneralInfo] = Array(sample.generalInfo)
            let suggestedSGIFields: [FetchedResults<SampleGeneralInfo>.Element] = sgiFields.filter {
                $0.sample == nil && !addedSGIFields.map { $0.title }.contains($0.title)
            }
            
            ForEach(addedSGIFields) { sgiField in
                Section(sgiField.title) {
                    SGIFieldView(sampleGeneralInfo: sgiField)
                }
            }
            .onDelete { offsets in
                for index in offsets {
                    moc.delete(addedSGIFields[index])
                }
                try? moc.save()
            }
            
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
                        
                        TextField("General Information field", text: $newSGIFieldTitle) { addNewGIField() }
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
                        Label("General Information field", systemImage: "plus")
                            .submitLabel(.done)
                    }
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
                        Label {
                            Text(sgiField.title)
                                .foregroundColor(.gray)
                        } icon: {
                            Image(systemName: "plus")
                                .foregroundColor(.accentColor)
                        }
                    }
                    .buttonStyle(.plain)
                }
            } footer: {
                if sgiFields.filter({ $0.sample == nil }).count == 0 {
                    Text("you can add quick general information templates in settings")
                }
            }
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
    
    private struct SGIFieldView: View {
        @Environment(\.managedObjectContext) private var moc
        @ObservedObject var sampleGeneralInfo: SampleGeneralInfo
        
        var body: some View {
            TextField("", text: $sampleGeneralInfo.value) { try? moc.save() }
                .submitLabel(.done)
        }
    }
}

// MARK: Extra

extension SampleView {
    public var preview: some View {
        VStack(alignment: .leading, spacing: 0) {
            RadarChart(sample: sample, useShortLabels: true)
            
            HStack {
                Group {
                    if sample.finalScore != 0 { Text(String(format: "%.1f", sample.finalScore)) }
                    else { Text("-") }
                }
                .lineLimit(1)
                .frame(width: 30)
                
                Divider()
                    .frame(height: 15)
                
                Text(sample.name)
                    .fixedSize(horizontal: true, vertical: true)
                
                if sample.isFavorite {
                    Spacer()
                    Image(systemName: "heart.fill")
                        .foregroundColor(.red)
                }
            }
            .font(.caption)
        }
        .padding(10)
        .background(.ultraThinMaterial)
        .cornerRadius(15)
    }
}

struct SampleFormRowView: View {
    @Environment(\.managedObjectContext) private var moc
    @ObservedObject var sample: Sample
    
    var body: some View {
        TextField("Sample name", text: $sample.name)
            .submitLabel(.done)
            .onSubmit { try? moc.save() }
    }
}
