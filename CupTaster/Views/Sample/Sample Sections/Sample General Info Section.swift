//
//  Sample General Info Section.swift
//  CupTaster
//
//  Created by Nikita on 04.01.2024.
//

import SwiftUI

extension SampleView {
    struct GeneralInfoSection: View {
        @ObservedObject var samplesControllerModel: SamplesControllerModel = .shared
        let gridCellSize: CGFloat
        
        var body: some View {
            if let sample: Sample = samplesControllerModel.selectedSample {
                WrappedGeneralInfoSection(sample: sample)
            }
        }
        
        fileprivate struct WrappedGeneralInfoSection: View {
            @Environment(\.managedObjectContext) private var moc
            @FetchRequest(
                entity: SampleGeneralInfo.entity(),
                sortDescriptors: [NSSortDescriptor(keyPath: \SampleGeneralInfo.title, ascending: false)]
            ) var generalInfoFields: FetchedResults<SampleGeneralInfo>
            @ObservedObject var sample: Sample
            
            var body: some View {
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
                    let sgiTemplates: [SampleGeneralInfo] = generalInfoFields.filter { $0.sample == nil }
                    let sortedSGITemplates: [SampleGeneralInfo] = sgiTemplates.sorted(by: { $0.ordinalNumber < $1.ordinalNumber })
                    let uniqueSGITemplates: [SampleGeneralInfo] = sortedSGITemplates.filter { template in
                        return !sample.generalInfo.map { $0.title }.contains(template.title)
                    }
                    
                    ForEach(uniqueSGITemplates) { sgiTemplate in
                        SampleGeneralInfoFieldView.TemplateView(sgiTemplate: sgiTemplate)
                    }
                    
                    ForEach(sample.generalInfo.sorted(by: { $0.ordinalNumber < $1.ordinalNumber })) {
                        SampleGeneralInfoFieldView(generalInfo: $0)
                    }
                }
            }
        }
    }
}

struct SampleGeneralInfoFieldView: View {
    @Environment(\.managedObjectContext) private var moc
    @ObservedObject var generalInfo: SampleGeneralInfo
    
    @State var thumbnail: UIImage = UIImage(systemName: "doc")!
    @State var quickLookItem: URL? = nil
    @State var websiteURL: URL? = nil
    
    var body: some View {
        HStack(spacing: .small) {
            let attachment: Data = generalInfo.attachment
            if attachment != Data() {
                if attachment == Data("error".utf8) {
                    AttachmentPreview {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.red)
                    }
                } else if generalInfo.title == "Image" || generalInfo.title == "JPEG Image" {
                    let image: UIImage = attachment.decodeToUIImage() ?? UIImage(systemName: "exclamationmark.triangle.fill")!
                    AttachmentPreview {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } action: {
                        let docDirPath = NSSearchPathForDirectoriesInDomains(
                            .documentDirectory, .userDomainMask, true
                        )[0] as NSString
                        let filePath = docDirPath.appendingPathComponent("image.jpeg")
                        try? attachment.write(to: URL(fileURLWithPath: filePath), options: .atomic)
                        quickLookItem = URL(fileURLWithPath: filePath)
                    }
                } else if generalInfo.title == "URL" {
                    AttachmentPreview {
                        Image(systemName: "safari")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                    } action: {
                        let sampleURL: String = String(decoding: generalInfo.attachment, as: UTF8.self)
                        
                        if sampleURL.starts(with: "http") { websiteURL = URL(string: sampleURL) }
                        else { websiteURL = URL(string: "http://" + sampleURL) }
                    }
                } else {
                    AttachmentPreview {
                        Text(generalInfo.title.components(separatedBy: ".").last!.uppercased())
                            .resizableText()
                            .padding(7)
                    } action: {
                        let docDirPath = NSSearchPathForDirectoriesInDomains(
                            .documentDirectory, .userDomainMask, true
                        )[0] as NSString
                        let filePath = docDirPath.appendingPathComponent(generalInfo.title)
                        try? attachment.write(to: URL(fileURLWithPath: filePath), options: .atomic)
                        quickLookItem = URL(fileURLWithPath: filePath)
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 2) {
                let title: String = generalInfo.title == "URL" ? String(decoding: generalInfo.attachment, as: UTF8.self) : generalInfo.title
                let textFieldPrompt: String = generalInfo.attachment == Data() ? generalInfo.title : "Notes"
                
                Text(title)
                    .resizableText(initialSize: 12)
                    .frame(height: 12, alignment: .top)
                    .foregroundStyle(.gray)
                
                TextField(textFieldPrompt, text: $generalInfo.value, onCommit: {
                    save(moc)
                })
                .submitLabel(.done)
                .resizableText(initialSize: 15)
                .onChange(of: generalInfo.value) { note in
                    if note.count > 25 { generalInfo.value = String(note.prefix(25)) }
                    save(moc)
                }
            }
        }
        .padding(.leading, .regular)
        .padding(.trailing, .extraSmall)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: .smallElementContainer)
        .background(Color.backgroundSecondary)
        .cornerRadius()
        .quickLook(item: $quickLookItem)
        .previewInSafari(url: $websiteURL)
        .contextMenu {
            Section {
                Button(role: .destructive) {
                    withAnimation {
                        let deletedGeneralInfoOrdinalNumber: Int16 = generalInfo.ordinalNumber
                        let sortedGeneralInfo: [SampleGeneralInfo] = generalInfo.sample?.generalInfo
                            .filter { $0 != generalInfo }
                            .sorted(by: { $0.ordinalNumber < $1.ordinalNumber }) ?? []
                        
                        moc.delete(generalInfo)
                        
                        for generalInfo in sortedGeneralInfo {
                            if generalInfo.ordinalNumber > deletedGeneralInfoOrdinalNumber {
                                generalInfo.ordinalNumber -= 1
                            }
                        }
                        
                        save(moc)
                    }
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
    }
    
    struct AttachmentPreview<Content: View>: View {
        let content: () -> Content
        let action: () -> ()
        
        init(content: @escaping () -> Content, action: @escaping () -> () = { }) {
            self.content = content
            self.action = action
        }
        
        var body: some View {
            content()
                .foregroundColor(.accentColor)
                .frame(width: 40, height: 40)
                .background(Color.backgroundTertiary)
                .cornerRadius(5)
                .onTapGesture { action() }
        }
    }
    
    struct TemplateView: View {
        @Environment(\.managedObjectContext) private var moc
        let sgiTemplate: SampleGeneralInfo
        
        var body: some View {
            HStack(spacing: .small) {
                Image(systemName: "plus")
                    .foregroundColor(.gray)
                
                Text(sgiTemplate.title)
                    .resizableText(initialSize: 15)
                    .frame(height: 15, alignment: .top)
                    .foregroundStyle(.gray)
            }
            .padding(.leading, .regular)
            .padding(.trailing, .extraSmall)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: .smallElementContainer)
            .background(Color.backgroundSecondary)
            .cornerRadius()
            .onTapGesture {
                guard let sample: Sample = SamplesControllerModel.shared.selectedSample else { return }
                let newSGIField: SampleGeneralInfo = SampleGeneralInfo(context: moc)
                newSGIField.title = sgiTemplate.title
                newSGIField.value = ""
                newSGIField.ordinalNumber = Int16((sample.generalInfo.map({ $0.ordinalNumber }).max() ?? 0) + 1)
                newSGIField.sample = sample
                save(moc)
            }
        }
    }
}
