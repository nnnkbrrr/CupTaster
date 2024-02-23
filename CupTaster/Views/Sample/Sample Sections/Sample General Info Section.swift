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
                if let sample: Sample = samplesControllerModel.selectedSample {
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
                    Image(systemName: "exclamationmark.triangle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40, height: 40)
                        .foregroundColor(.red)
                } else if generalInfo.title == "Image" || generalInfo.title == "JPEG Image" {
                    let image: UIImage = attachment.decodeToUIImage() ?? UIImage(systemName: "exclamationmark.triangle.fill")!
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 40, height: 40)
                        .cornerRadius(5)
                        .onTapGesture {
                            let docDirPath = NSSearchPathForDirectoriesInDomains(
                                .documentDirectory, .userDomainMask, true
                            )[0] as NSString
                            let filePath = docDirPath.appendingPathComponent("image.jpeg")
                            try? attachment.write(to: URL(fileURLWithPath: filePath), options: .atomic)
                            quickLookItem = URL(fileURLWithPath: filePath)
                        }
                } else if generalInfo.title == "URL" {
                    Image(systemName: "link")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                        .foregroundColor(.accentColor)
                        .frame(width: 40, height: 40)
                        .background(Color(uiColor: .systemGray4))
                        .cornerRadius(5)
                        .onTapGesture {
                            let sampleURL: String = String(decoding: generalInfo.attachment, as: UTF8.self)
                            if sampleURL.starts(with: "http") {
                                if let url: URL = URL(string: sampleURL) { websiteURL = url }
                            } else {
                                if let url: URL = URL(string: "http://" + sampleURL) { websiteURL = url }
                            }
                        }
                } else {
                    Text(generalInfo.title.components(separatedBy: ".").last!.uppercased())
                        .fontWeight(.bold)
                        .foregroundColor(.accentColor)
                        .padding(7)
                        .minimumScaleFactor(0.01)
                        .frame(width: 40, height: 40)
                        .background(Color(uiColor: .systemGray4))
                        .cornerRadius(5)
                        .onTapGesture {
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
                Text(generalInfo.title)
                    .resizableText(initialSize: 12)
                    .frame(height: 12, alignment: .top)
                    .foregroundStyle(.gray)
                
                TextField(
                    generalInfo.attachment == Data() ? generalInfo.title : "Notes",
                    text: $generalInfo.value,
                    onCommit: { try? moc.save() }
                )
                .submitLabel(.done)
                .resizableText(initialSize: 15)
                .frame(height: 15)
                .onChange(of: generalInfo.value) { note in
                    if note.count > 25 { generalInfo.value = String(note.prefix(25)) }
                    try? moc.save()
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
    }
}
