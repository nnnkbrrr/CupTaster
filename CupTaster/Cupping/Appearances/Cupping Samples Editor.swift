//
//  Cupping Samples Editor.swift
//  CupTaster
//
//  Created by Никита Баранов on 20.03.2023.
//

import SwiftUI

extension CuppingView {
	var samplesEditor: some View {
		Form {
			Section {
				TextField("Cupping name", text: $cuppingModel.cupping.name)
			}
			
			if showCuppingsDatePicker {
				Section {
					DatePicker("Date", selection: $cuppingModel.cupping.date, displayedComponents: [.date])
				}
			}
			
			Section {
				ForEach(samples) { sample in
					SampleFormRowView(sample: sample)
				}
				.onMove { indexSet, offset in
					var revisedItems: [Sample] = cuppingModel.sortedSamples
					revisedItems.move(fromOffsets: indexSet, toOffset: offset)
					
					for reverseIndex in stride(from: revisedItems.count - 1, through: 0, by: -1) {
						revisedItems[reverseIndex].ordinalNumber = Int16(reverseIndex)
					}
				}
				.onDelete { offsets in
					for index in offsets {
						moc.delete(samples[index])
					}
				}
			}
			
			Section {
				Button {
					let usedNames: [String] = cuppingModel.cupping.samples.map { $0.name }
					let defaultName: String = SampleNameGenerator().generateSampleDefaultName(usedNames: usedNames)
					
					let sample: Sample = Sample(context: moc)
					
					sample.name = defaultName
					sample.ordinalNumber = Int16(cuppingModel.cupping.samples.count)
					
					if let cuppingForm = cuppingModel.cupping.form {
						for groupConfig in cuppingForm.qcGroupConfigurations {
							let qcGroup: QCGroup = QCGroup(context: moc)
							qcGroup.sample = sample
							qcGroup.configuration = groupConfig
							for qcConfig in groupConfig.qcConfigurations {
								let qualityCriteria = QualityCriteria(context: moc)
								qualityCriteria.title = qcConfig.title
								qualityCriteria.value = qcConfig.value
								qualityCriteria.group = qcGroup
								qualityCriteria.configuration = qcConfig
							}
						}
					}
					
					cuppingModel.cupping.addToSamples(sample)
				} label: {
					Label("Add sample", systemImage: "plus")
				}
			}
		}
		.environment(\.editMode, .constant(.active))
		.resignKeyboardOnDragGesture() { try? moc.save() }
	}
}
