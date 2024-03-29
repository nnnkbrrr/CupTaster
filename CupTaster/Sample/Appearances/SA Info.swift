//
//  SA Info.swift
//  CupTaster
//
//  Created by Никита Баранов on 01.03.2023.
//

import SwiftUI
import CoreData
import QuickLook

extension SampleView {
	var infoAppearance: some View {
		List {
			Section {
				RadarChart(sample: sample)
					.padding()
					.frame(maxWidth: 500)
					.frame(maxWidth: .infinity)
			}
			
			AdditionalFieldsView(cuppingModel: cuppingModel, sample: sample)
		}
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
    
    @State var cameraIsActive: Bool = false
    @State var photoPickerIsActive: Bool = false
	
	var body: some View {
		let addedSGIFields: [SampleGeneralInfo] =
		Array(sample.generalInfo).sorted { $0.ordinalNumber < $1.ordinalNumber }
		
		let suggestedSGIFields: [FetchedResults<SampleGeneralInfo>.Element] = sgiFields.filter {
			$0.sample == nil && !addedSGIFields.map { $0.title }.contains($0.title)
		}
		
		Section {
			ForEach(addedSGIFields) { SGIFieldView(sampleGeneralInfo: $0) }
				.onDelete { offsets in
					for index in offsets {
						moc.delete(addedSGIFields[index])
						try? moc.save()
					}
				}
		}
		
		Section {
			ForEach(suggestedSGIFields) { sgiField in
				Button {
					let newSGIField: SampleGeneralInfo = SampleGeneralInfo(context: moc)
					newSGIField.title = sgiField.title
					newSGIField.ordinalNumber = Int16((sample.generalInfo.map({ $0.ordinalNumber }).max() ?? 0) + 1)
					newSGIField.sample = sample
				} label: {
					HStack {
						Image(systemName: "plus")
							.foregroundColor(.accentColor)
						
						Text(sgiField.title)
							.foregroundColor(.gray)
							.frame(maxWidth: .infinity, alignment: .leading)
					}
				}
			}
		}
	}
}

extension AdditionalFieldsView {
    private struct SGIFieldView: View {
        @Environment(\.managedObjectContext) private var moc
		@ObservedObject var sampleGeneralInfo: SampleGeneralInfo
		@State var thumbnail: UIImage = UIImage(systemName: "doc")!
		@State var selectedFile: URL? = nil
		@State var selectedURL: URL? = nil
		@State var browserIsActive: Bool = false
		
		var body: some View {
			HStack(spacing: 10) {
				let attachment: Data = sampleGeneralInfo.attachment
				if attachment != Data() {
					if attachment == Data("error".utf8) {
						Image(systemName: "exclamationmark.t riangle.fill")
							.resizable()
							.aspectRatio(contentMode: .fit)
							.frame(width: 40, height: 40)
							.foregroundColor(.red)
					} else if sampleGeneralInfo.title == "JPEG Image" {
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
								selectedFile = URL(fileURLWithPath: filePath)
							}
							.quickLookPreview($selectedFile)
					} else if sampleGeneralInfo.title == "URL" {
						Image(systemName: "link")
							.resizable()
							.aspectRatio(contentMode: .fit)
							.frame(width: 20, height: 20)
							.foregroundColor(.accentColor)
							.frame(width: 40, height: 40)
							.background(Color(uiColor: .systemGray4))
							.cornerRadius(5)
							.onTapGesture {
								let sampleURL: String = String(decoding: sampleGeneralInfo.attachment, as: UTF8.self)
								if sampleURL.starts(with: "http") {
									if let url: URL = URL(string: sampleURL) {
										selectedURL = url
									}
								} else {
									if let url: URL = URL(string: "http://" + sampleURL) {
										selectedURL = url
									}
								}
								browserIsActive = true
							}
							.fullScreenCover(isPresented: $browserIsActive) {
								SafariContent(url: $selectedURL, isActive: $browserIsActive)
							}
					} else {
						Text(sampleGeneralInfo.title.components(separatedBy: ".").last!.uppercased())
							.fontWeight(.black)
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
								let filePath = docDirPath.appendingPathComponent(sampleGeneralInfo.title)
								try? attachment.write(to: URL(fileURLWithPath: filePath), options: .atomic)
								selectedFile = URL(fileURLWithPath: filePath)
							}
							.quickLookPreview($selectedFile)
					}
				}
				
				VStack(alignment: .leading, spacing: 3) {
					Text(
						sampleGeneralInfo.title == "URL" ?
						String(decoding: sampleGeneralInfo.attachment, as: UTF8.self) : sampleGeneralInfo.title
					)
					.font(.caption)
					.foregroundColor(.accentColor)
					.lineLimit(1)
					.truncationMode(.middle)
					
					TextField(
						sampleGeneralInfo.attachment == Data() ? sampleGeneralInfo.title : "Notes",
						text: $sampleGeneralInfo.value
					) {
						try? moc.save()
					}
					.submitLabel(.done)
				}
			}
		}
	}
	
	private struct SafariContent: View {
		@Binding var url: URL?
		@Binding var isActive: Bool
		
		var body: some View {
			if let url {
				SFSafariViewWrapper(url: url).ignoresSafeArea()
			} else {
				VStack {
					Text("URL is invalid")
					Button("Done") { isActive = false }
						.buttonStyle(.bordered)
				}
			}
		}
	}
}
