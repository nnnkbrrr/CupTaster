//
//  Cupping.swift
//  CupTaster
//
//  Created by Никита Баранов on 06.10.2022.
//

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
    @NSManaged public var samples: Set<Sample>
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
            let defaultName: String = SampleNameGenerator().generateSampleDefaultName(usedNames: usedNames)
            
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
        
        try? moc.save()
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
