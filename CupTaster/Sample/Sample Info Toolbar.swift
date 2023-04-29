//
//  Sample Info Toolbar.swift
//  CupTaster
//
//  Created by Никита Баранов on 20.03.2023.
//

import SwiftUI
import CodeScanner

struct SampleInfoToolbar: View {
	@Environment(\.managedObjectContext) private var moc
	@ObservedObject var cuppingModel: CuppingModel
	@ObservedObject var sample: Sample
	
	@State private var newSGIFieldTitle: String = ""
	@State private var newSGIFieldVisible: Bool = false
	@FocusState private var newSGIFieldFocused: Bool
	
	@State private var newLinkFieldValue: String = ""
	@State private var newLinkFieldVisible: Bool = false
	@FocusState private var newLinkFieldFocused: Bool
	
	@State var cameraPickerIsActive: Bool = false
	@State var photoLibraryPickerIsActive: Bool = false
	@State var fileImporterIsActive: Bool = false
	@State var qrScannerIsActive: Bool = false
	@State var qrFlashlightIsActive: Bool = false
	@State var qrViewfinderZoomedIn: Bool = false
	@State var qrImagePickerIsActive: Bool = false
	
	var body: some View {
		Group {
			if newSGIFieldVisible {
				HStack(spacing: 10) {
					TextField("Additional field", text: $newSGIFieldTitle) { addNewGIField() }
						.submitLabel(.done)
						.focused($newSGIFieldFocused, equals: true)
					
					Button {
						newSGIFieldTitle = ""
						withAnimation { newSGIFieldVisible = false }
					} label: {
						Text("Cancel").contentShape(Rectangle())
					}
				}
				.onAppear { newSGIFieldFocused = true }
				.transition(.move(edge: .trailing))
			} else if newLinkFieldVisible {
				HStack(spacing: 10) {
					Button {
						qrScannerIsActive = true
					} label: {
						Image(systemName: "qrcode.viewfinder")
							.font(.title3)
							.contentShape(Rectangle())
					}
					.font(.headline)
					
					Divider().frame(height: 15)
					
					TextField("URL", text: $newLinkFieldValue) {
						addNewLinkField()
					}
					.keyboardType(.URL)
					.submitLabel(.done)
					.focused($newLinkFieldFocused, equals: true)
					
					Button {
						newLinkFieldValue = ""
						withAnimation { newLinkFieldVisible = false }
					} label: {
						Text("Cancel").contentShape(Rectangle())
					}
				}
				.onAppear { newLinkFieldFocused = true }
				.transition(.move(edge: .trailing))
				.fullScreenCover(isPresented: $qrScannerIsActive) {
					ZStack {
						CodeScannerView(
							codeTypes: [.qr],
							isTorchOn: qrFlashlightIsActive,
							isGalleryPresented: $qrImagePickerIsActive
						) { response in
							switch response {
								case .success(let result):
									newLinkFieldValue = result.string
									qrFlashlightIsActive = false
									qrScannerIsActive = false
								case .failure(_):
									newLinkFieldValue = "Error"
									qrFlashlightIsActive = false
									qrScannerIsActive = false
							}
						}
						.ignoresSafeArea()
						
						Image(systemName: "viewfinder")
							.resizable()
							.aspectRatio(contentMode: .fit)
							.font(.body.weight(.ultraLight))
							.frame(maxWidth: .infinity, maxHeight: .infinity)
							.scaleEffect(qrViewfinderZoomedIn ? 0.8 : 0.7)
							.onAppear {
								withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
									qrViewfinderZoomedIn.toggle()
								}
							}
						
						HStack(spacing: 20) {
							Button {
								qrFlashlightIsActive.toggle()
							} label: {
								Image(systemName: "flashlight.\(qrFlashlightIsActive ? "on" : "off").fill")
							}
							
							Capsule().frame(width: 2, height: 20)
							
							Button {
								qrImagePickerIsActive = true
							} label: {
								Image(systemName: "photo.fill.on.rectangle.fill")
							}
							
							Capsule().frame(width: 2, height: 20)
							
							Button("Cancel") {
								qrFlashlightIsActive = false
								qrScannerIsActive = false
							}
						}
						.padding()
						.padding(.horizontal)
						.background(.bar)
						.clipShape(Capsule())
						.padding(.bottom)
						.frame(maxHeight: .infinity, alignment: .bottom)
					}
				}
			} else {
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
						newSGIField.ordinalNumber = Int16((sample.generalInfo.map({ $0.ordinalNumber }).max() ?? 0) + 1)
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
						withAnimation { newLinkFieldVisible = true }
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
				.transition(.move(edge: .top).combined(with: .opacity))
			}
		}
		.padding(.horizontal)
		.frame(height: 45)
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
		print(sample.generalInfo.map({
			$0.ordinalNumber
		}))
		
		let newSGIField: SampleGeneralInfo = SampleGeneralInfo(context: moc)
		newSGIField.title = newSGIFieldTitle
		newSGIField.ordinalNumber = Int16((sample.generalInfo.map({ $0.ordinalNumber }).max() ?? 0) + 1)
		newSGIField.sample = sample
		
		try? moc.save()
		
		withAnimation {
			newSGIFieldTitle = ""
			newSGIFieldFocused = false
			newSGIFieldVisible = false
		}
	}
	
	func addNewLinkField() {
		let newLinkField: SampleGeneralInfo = SampleGeneralInfo(context: moc)
		newLinkField.title = "URL"
		newLinkField.attachment = Data(newLinkFieldValue.utf8)
		newLinkField.ordinalNumber = Int16((sample.generalInfo.map({ $0.ordinalNumber }).max() ?? 0) + 1)
		newLinkField.sample = sample
		
		try? moc.save()
		
		withAnimation {
			newLinkFieldValue = ""
			newLinkFieldFocused = false
			newLinkFieldVisible = false
		}
	}
	
	func addImage(uiImage: UIImage) {
		let newSGIField: SampleGeneralInfo = SampleGeneralInfo(context: moc)
		newSGIField.title = "JPEG Image"
		newSGIField.ordinalNumber = Int16((sample.generalInfo.map({ $0.ordinalNumber }).max() ?? 0) + 1)
		newSGIField.sample = sample
		newSGIField.attachment = uiImage.encodeToData() ?? Data()
		try? moc.save()
	}
}
