//
//  Cupping.swift
//  CupTaster
//
//  Created by Никита Баранов on 06.10.2022.
//

import SwiftUI
import CoreData

@objc(Cupping)
public class Cupping: NSManagedObject, Identifiable {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Cupping> {
        return NSFetchRequest<Cupping>(entityName: "Cupping")
    }
    
    @NSManaged public var name: String
    @NSManaged public var notes: String
    @NSManaged public var date: Date
    @NSManaged public var cupsCount: Int16
    @NSManaged public var isFavorite: Bool
    
    @NSManaged public var form: CuppingForm?
    @NSManaged public var location: Location?
    @NSManaged public var samples: Set<Sample>
    @NSManaged public var folders: Set<Folder>
}

extension Cupping {
    public var sortedSamples: [Sample] {
        self.samples.sorted(by: { $0.ordinalNumber < $1.ordinalNumber })
    }
    
    public func setup(moc: NSManagedObjectContext, date: Date, cuppingForm: CuppingForm, cupsCount: Int, samplesCount: Int) {
        self.cupsCount = Int16(cupsCount)
        self.form = cuppingForm
        self.date = date
        
        for _ in 1...samplesCount {
            let usedNames: [String] = self.samples.map { $0.name }
            let defaultName: String = SampleNameGeneratorModel.generateSampleDefaultName(usedNames: usedNames)
            
            let sample: Sample = Sample(context: moc)
            
            sample.name = defaultName
            sample.ordinalNumber = Int16(self.samples.count)
            
            if let cuppingForm = self.form {
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
            
            self.addToSamples(sample)
            sample.calculateFinalScore()
        }
        
        save(moc)
    }
}

extension Cupping {
    @objc(addSamplesObject:)
    @NSManaged public func addToSamples(_ value: Sample)

    @objc(removeSamplesObject:)
    @NSManaged public func removeFromSamples(_ value: Sample)

    @objc(addSamples:)
    @NSManaged public func addToSamples(_ values: NSSet)

    @objc(removeSamples:)
    @NSManaged public func removeFromSamples(_ values: NSSet)
}


extension Cupping {
    func shareCSV() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let viewController = window.rootViewController?.presentedViewController {
            
            // generating rows
            
            let samples: [Sample] = self.sortedSamples
            let qcConfigurations: [QCConfig] = {
                guard let cuppingForm = self.form else { return [] }
                let qualityCriteria: [Set<QCConfig>.Element] = cuppingForm.qcGroupConfigurations
                    .sorted(by: { $0.ordinalNumber < $1.ordinalNumber })
                    .flatMap { $0.qcConfigurations }
                
                return qualityCriteria == [] ? [] : qualityCriteria
            }()
            
            var rows: [[String]] = []
            
            let qualityCrieriaTitles: [String] = {
                var row: [String] = []
                for qcConfiguration in qcConfigurations {
                    row.append(qcConfiguration.title)
                }
                return [""] + row
            }()
            
            rows.append(qualityCrieriaTitles)
            
            for sample in samples {
                var row: [String] = []
                row.append(sample.name)
                
                for qualityCriteriaGroup in sample.sortedQCGroups {
                    for qualityCriterion in qualityCriteriaGroup.sortedQualityCriteria {
                        row.append(getQualityCriteriaCSVRowValue(qualityCriteria: qualityCriterion))
                    }
                }
                rows.append(row)
            }
            
            var csvText = ""
            
            for row in rows {
                let rowString = row.joined(separator: ",")
                csvText.append("\(rowString)\n")
            }
            
            // generating csv
            
            var fileURL: URL!
            
            do {
                let path = try FileManager.default.url(
                    for: .documentDirectory,
                    in: .allDomainsMask,
                    appropriateFor: nil,
                    create: false
                )
                
                fileURL = path.appendingPathComponent("\(self.name == "" ? "New cupping" : self.name).csv")
                
                try csvText.write(to: fileURL, atomically: true , encoding: .utf8)
            } catch {
                showAlert(title: "Error", message: "oops, something went wrong")
            }
            
            let activityController = UIActivityViewController(activityItems: [fileURL!], applicationActivities: nil)
            viewController.present(activityController, animated: true, completion: nil)
        } else {
            showAlert(title: "Error", message: "oops, something went wrong")
        }
    }
}

extension Cupping {
    private func getQualityCriteriaCSVRowValue(qualityCriteria: QualityCriteria) -> String {
        if qualityCriteria.configuration.unwrappedEvaluation is CupsCheckboxesEvaluation {
            let cupsCount: Int = Int(qualityCriteria.group.sample.cupping.cupsCount)
            let values: [Bool] = CupsCheckboxesEvaluation.checkboxesValues(value: qualityCriteria.value, cupsCount: Int16(cupsCount))
            
            return values.map({ $0 ? "x" : "o" }).joined(separator: " ")
        }
        
        if qualityCriteria.configuration.unwrappedEvaluation is RadioEvaluation {
            return String(format: "%.0f", qualityCriteria.value)
        }
        
        if qualityCriteria.configuration.evaluationType == "multiplePicker" {
            return getMultiplePickerRepresentableValue(qualityCriteria: qualityCriteria)
        }
        
        if qualityCriteria.configuration.evaluationType == "cups_multiplePicker" {
            return getCupsMultiplePickerRepresentableValue(qualityCriteria: qualityCriteria)
        }
        
        return String(format: "%.2f", qualityCriteria.value)
    }
}

// MARK: -Support for deprecated forms

// Multiple Picker

private func getMultiplePickerRepresentableValue(qualityCriteria: QualityCriteria) -> String {
    var allPickerValues: [Int] {
        let values: [Int] = Int(qualityCriteria.value).digits
        let pickersCount: Int = Int(qualityCriteria.configuration.upperBound).digits.count
        switch values.count {
        case let count where count < pickersCount: return (Array(repeating: 0, count: (pickersCount - values.count)) + values).reversed()
        default: return values.reversed()
        }
    }
    
    let qcLowerBound: Double = qualityCriteria.configuration.lowerBound
    let lowerBoundDigit: Int = Int(copysign(CGFloat(Int(qcLowerBound).digits.first!), qcLowerBound))
    let lowerBoundIsNegative: Bool = { qcLowerBound.sign == .minus }()
    
    return allPickerValues.map({ "\($0 + (lowerBoundIsNegative ? lowerBoundDigit : 0))" }).joined(separator: " | ")
}

// Cups Multiple Picker

public func getAllMultiplePickerShiftedValues(value: CGFloat, cuppingCupsCount: Int) -> [Int] {
    let values: [Int] = Int(value).digits
    switch values.count {
    case let count where count < cuppingCupsCount: return (Array(repeating: 0, count: (cuppingCupsCount - values.count)) + values).reversed()
    default: return Array(values.reversed().prefix(cuppingCupsCount))
    }
}

public func getAllMultiplePickerValues(value: CGFloat, cuppingCupsCount: Int, lowerBound: CGFloat) -> [Int] {
    return getAllMultiplePickerShiftedValues(value: value, cuppingCupsCount: cuppingCupsCount).map { $0 + Int(lowerBound) }
}

private func getCupsMultiplePickerRepresentableValue(qualityCriteria: QualityCriteria) -> String {
    let cupsCount: Int = Int(qualityCriteria.group.sample.cupping.cupsCount)
    let values: [Int] = getAllMultiplePickerShiftedValues(value: qualityCriteria.value, cuppingCupsCount: cupsCount).map {
        $0 + Int(qualityCriteria.configuration.lowerBound)
    }
    
    return values.map({ "\($0)" }).joined(separator: " | ")
}
