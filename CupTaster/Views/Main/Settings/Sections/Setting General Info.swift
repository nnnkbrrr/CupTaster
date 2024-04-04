//
//  Setting General Info.swift
//  CupTaster
//
//  Created by Nikita Baranov on 03.04.2024.
//

import SwiftUI

let suggestedSGITemplates: [String] = ["Country", "Roast level", "Processing Method"]

struct Settings_GeneralInfoView: View {
    @Environment(\.managedObjectContext) private var moc
    @FetchRequest(
        entity: SampleGeneralInfo.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \SampleGeneralInfo.title, ascending: false)]
    ) var generalInfoFields: FetchedResults<SampleGeneralInfo>
    
    @State var sgiTitle: String = ""
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: .extraSmall) {
                let sgiTemplates: [SampleGeneralInfo] = generalInfoFields.filter { $0.sample == nil }
                
                SettingsSection {
                    SettingsTextFieldSection(text: $sgiTitle, prompt: "Title") {
                        Button {
                            if sgiTitle != "" {
                                let generalInfo: SampleGeneralInfo = .init(context: moc)
                                generalInfo.title = sgiTitle
                                generalInfo.ordinalNumber = Int16(sgiTemplates.count)
                                try? moc.save()
                                
                                sgiTitle = ""
                            }
                        } label: {
                            Image(systemName: "plus")
                                .foregroundStyle(Color.accentColor)
                                .frame(width: .extraLarge, height: .extraLarge)
                                .background(Color.backgroundTertiary)
                                .cornerRadius()
                        }
                    }
                    .onChange(of: sgiTitle) { title in
                        let noteTitleLengthLimit: Int = 50
                        if title.count > noteTitleLengthLimit {
                            sgiTitle = String(title.prefix(noteTitleLengthLimit))
                        }
                    }
                    
                    ForEach(suggestedSGITemplates, id: \.self) { suggestion in
                        if !sgiTemplates.map({ $0.title }).contains(suggestion) {
                            HStack {
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(suggestion)
                                        .multilineTextAlignment(.leading)
                                        .foregroundStyle(.gray)
                                    
                                    Text("Suggestion")
                                        .font(.caption)
                                        .foregroundStyle(.gray)
                                }
                                .padding(.horizontal, .extraSmall)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Button {
                                    let generalInfo: SampleGeneralInfo = .init(context: moc)
                                    generalInfo.title = suggestion
                                    generalInfo.ordinalNumber = Int16(sgiTemplates.count)
                                    try? moc.save()
                                } label: {
                                    Image(systemName: "plus")
                                        .foregroundStyle(Color.gray)
                                        .frame(width: .extraLarge, height: .extraLarge)
                                        .background(Color.backgroundTertiary)
                                        .cornerRadius()
                                }
                            }
                            .frame(height: 60)
                            .padding(.horizontal, .regular)
                            .background(Color.backgroundSecondary)
                            .cornerRadius()
                        }
                    }
                }
                
                let sortedSGITemplates: [SampleGeneralInfo] = sgiTemplates.sorted(by: { $0.ordinalNumber < $1.ordinalNumber })
                
                SettingsSection("Added") {
                    ForEach(sortedSGITemplates) { sgiTemplate in
                        SwipeView(gestureType: GestureType.unspecified) {
                            SettingsRow(title: sgiTemplate.title)
                        } trailingActions: { _ in
                            SwipeAction {
                                withAnimation { delete(sgiTemplate) }
                            } label: { _ in
                                VStack(spacing: .extraSmall) {
                                    Image(systemName: "trash")
                                    Text("Delete")
                                }
                                .font(.subheadline)
                                .foregroundStyle(.white)
                            } background: { _ in
                                Color.red
                            }
                        }
                        .defaultSwipeStyle()
                    }
                }
            }
            .padding(.small)
        }
        .background(Color.backgroundPrimary, ignoresSafeAreaEdges: .all)
        .defaultNavigationBar()
    }
    
    func delete(_ generalInfo: SampleGeneralInfo) {
        moc.delete(generalInfo)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let sgiTemplates: [SampleGeneralInfo] = generalInfoFields.filter { $0.sample == nil }
            let sortedSGITemplates: [SampleGeneralInfo] = sgiTemplates.sorted(by: { $0.ordinalNumber < $1.ordinalNumber })
            for (index, sgi) in sortedSGITemplates.enumerated() { sgi.ordinalNumber = Int16(index) }
            
            try? moc.save()
        }
    }
}
