//
//  Sample Info Toolbar.swift
//  CupTaster
//
//  Created by Никита Баранов on 20.03.2023.
//

import SwiftUI

struct SampleInfoToolbar: View {
	@Environment(\.managedObjectContext) private var moc
	@ObservedObject var cuppingModel: CuppingModel
	@ObservedObject var sample: Sample
	
	@State private var newSGIFieldTitle: String = ""
	@State private var newSGIFieldVisible: Bool = false
	@FocusState private var newSGIFieldFocused: Bool
	
	@State var cameraPickerIsActive: Bool = false
	@State var photoLibraryPickerIsActive: Bool = false
	@State var fileImporterIsActive: Bool = false
	
	var body: some View {
		VStack {
			HStack {
				Button {
					withAnimation { newSGIFieldVisible = true }
				} label: {
					Image(systemName: "character.cursor.ibeam")
						.frame(maxWidth: .infinity)
						.contentShape(Rectangle())
				}
				
				Button {
					cameraPickerIsActive = true
				} label: {
					Image(systemName: "camera")
						.frame(maxWidth: .infinity)
						.contentShape(Rectangle())
				}
				.fullScreenCover(isPresented: $cameraPickerIsActive) {
					ImagePicker(sourceType: .camera) { uiImage in
						addImage(uiImage: uiImage)
					}.ignoresSafeArea()
				}
				
				Button {
					photoLibraryPickerIsActive = true
				} label: {
					Image(systemName: "photo")
						.frame(maxWidth: .infinity)
						.contentShape(Rectangle())
				}
				.fullScreenCover(isPresented: $photoLibraryPickerIsActive) {
					ImagePicker(sourceType: .photoLibrary) { uiImage in
						addImage(uiImage: uiImage)
					}.ignoresSafeArea()
				}
				
				Button {
					fileImporterIsActive = true
				} label: {
					Image(systemName: "doc")
						.frame(maxWidth: .infinity)
						.contentShape(Rectangle())
				}
				.fileImporter(
					isPresented: $fileImporterIsActive,
					allowedContentTypes: [.item]
				) { result in
					let newSGIField: SampleGeneralInfo = SampleGeneralInfo(context: moc)
					newSGIField.ordinalNumber =
					Int16(sample.generalInfo.map({ $0.ordinalNumber }).max() ?? 0 + 1)
					newSGIField.sample = sample
					
					newSGIField.title = try! result.get().lastPathComponent
					if let fileURL = try? result.get() {
						if fileURL.startAccessingSecurityScopedResource(), let fileData = try? Data(contentsOf: fileURL) {
							newSGIField.attachment = fileData
						} else {
							newSGIField.attachment = Data("error".utf8)
						}
					}
					
					try? moc.save()
				}
				
				Button {
#warning("add link")
				} label: {
					Image(systemName: "link")
						.frame(maxWidth: .infinity)
						.contentShape(Rectangle())
				}
				
				Menu {
					Button("Delete", role: .destructive) { deleteSample() }
				} label: {
					Image(systemName: "trash")
						.foregroundColor(.red)
						.frame(maxWidth: .infinity)
						.contentShape(Rectangle())
				}
			}
			.font(.title3)
			.buttonStyle(.plain)
			.padding()
			
			if newSGIFieldVisible {
				HStack(spacing: 10) {
					Button {
						newSGIFieldTitle = ""
						withAnimation { newSGIFieldVisible = false }
					} label: {
						Image(systemName: "xmark.circle.fill")
							.contentShape(Rectangle())
					}
					.font(.title3)
					
					TextField("Additional field", text: $newSGIFieldTitle) { addNewGIField() }
						.submitLabel(.done)
						.focused($newSGIFieldFocused, equals: true)
					
					Button { addNewGIField() } label: {
						Image(systemName: "checkmark.circle.fill")
							.contentShape(Rectangle())
					}
					.font(.headline)
				}
				.padding(.bottom)
				.padding(.horizontal, 30)
				.onAppear { newSGIFieldFocused = true }
			}
		}
	}
	
	func deleteSample() {
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
	
	func addNewGIField() {
		let newSGIField: SampleGeneralInfo = SampleGeneralInfo(context: moc)
		newSGIField.title = newSGIFieldTitle
		newSGIField.ordinalNumber =
		Int16(sample.generalInfo.map({ $0.ordinalNumber }).max() ?? 0 + 1)
		newSGIField.sample = sample
		
		newSGIFieldTitle = ""
		newSGIFieldFocused = false
		newSGIFieldVisible = false
		
		try? moc.save()
	}
	
	func addImage(uiImage: UIImage) {
		let newSGIField: SampleGeneralInfo = SampleGeneralInfo(context: moc)
		newSGIField.title = "JPEG Image"
		newSGIField.ordinalNumber =
		Int16(sample.generalInfo.map({ $0.ordinalNumber }).max() ?? 0 + 1)
		newSGIField.sample = sample
		newSGIField.attachment = uiImage.encodeToData() ?? Data()
		try? moc.save()
	}
}
