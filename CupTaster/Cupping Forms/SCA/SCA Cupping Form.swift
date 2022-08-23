//
//  SCACuppingForm.swift
//  CupTaster
//
//  Created by Никита on 14.07.2022.
//

import SwiftUI
import CoreData


// MARK: - COMPLETED FORM

#warning("make sure every criteria has different name (?)")

struct SCACuppingFormModel {
    let context: NSManagedObjectContext
    
    func createSCAForm() -> CuppingForm {
        let form = CuppingForm(context: context)
        form.title = "SCA"
        #warning("change version to 1")
        form.version = 0
        
        form.addToQcGroupConfigurations([aromaGroup, flavorGroup, aftertasteGroup, acidityGroup, bodyGroup, uniformityGroup, balanceGroup, cleanCupGroup, sweetnessGroup, overallGroup, defectsGroup])
        
        form.finalScoreFormula = "Aroma + Flavor + Aftertaste + Acidity + Body + " +
        "Uniformity + Balance + Clean_Cup + Sweetness + Overall - " +
        "(Num_of_cups * Intensity)"
        
        try? context.save()
        
        return form
    }
}

extension SCACuppingFormModel {
    // MARK: Fragrance/Aroma
    var aromaGroup: QCGroupConfig {
        let group: QCGroupConfig = QCGroupConfig(context: context)
        group.title = "Fragrance/Aroma"
        group.ordinalNumber = 1
        
        // Aroma
        group.addToQcConfigurations(QCConfig.new(context: context, title: "Aroma", sampleEvaluation: SCAGradedScale, ordinalNumber: 1))
        // Dry
        group.addToQcConfigurations(QCConfig.new(context: context, title: "Dry", sampleEvaluation: SCALadder, ordinalNumber: 2))
        // Break
        group.addToQcConfigurations(QCConfig.new(context: context, title: "Break", sampleEvaluation: SCALadder, ordinalNumber: 3))
        
        return group
    }
    
    // MARK: Flavor
    var flavorGroup: QCGroupConfig {
        let group: QCGroupConfig = QCGroupConfig(context: context)
        group.title = "Flavor"
        group.ordinalNumber = 2
        
        // Flavor
        group.addToQcConfigurations(QCConfig.new(context: context, title: "Flavor", sampleEvaluation: SCAGradedScale, ordinalNumber: 1))
        
        return group
    }
    
    // MARK: Aftertaste
    var aftertasteGroup: QCGroupConfig {
        let group: QCGroupConfig = QCGroupConfig(context: context)
        group.title = "Aftertaste"
        group.ordinalNumber = 3
        
        // Aftertaste
        group.addToQcConfigurations(QCConfig.new(context: context, title: "Aftertaste", sampleEvaluation: SCAGradedScale, ordinalNumber: 1))
        
        return group
    }
    
    // MARK: Acidity
    var acidityGroup: QCGroupConfig {
        let group: QCGroupConfig = QCGroupConfig(context: context)
        group.title = "Acidity"
        group.ordinalNumber = 4
        
        // Acidity
        group.addToQcConfigurations(QCConfig.new(context: context, title: "Acidity", sampleEvaluation: SCAGradedScale, ordinalNumber: 1))
        // Intensity
        group.addToQcConfigurations(QCConfig.new(context: context, title: "Intensity", sampleEvaluation: SCALadder, ordinalNumber: 2))
#warning("add bounds description")
        
        return group
    }
    
    // MARK: Body
    var bodyGroup: QCGroupConfig {
        let group: QCGroupConfig = QCGroupConfig(context: context)
        group.title = "Body"
        group.ordinalNumber = 5
        
        // Body
        group.addToQcConfigurations(QCConfig.new(context: context, title: "Body", sampleEvaluation: SCAGradedScale, ordinalNumber: 1))
        // Level
        group.addToQcConfigurations(QCConfig.new(context: context, title: "Level", sampleEvaluation: SCALadder, ordinalNumber: 2))
#warning("add bounds description")
        
        return group
    }
    
    // MARK: Uniformity
    var uniformityGroup: QCGroupConfig {
        let group: QCGroupConfig = QCGroupConfig(context: context)
        group.title = "Uniformity"
        group.ordinalNumber = 6
        
        // Uniformity
        group.addToQcConfigurations(QCConfig.new(context: context, title: "Uniformity", sampleEvaluation: SCACheckboxes, ordinalNumber: 1))
        
        return group
    }
    
    // MARK: Balance
    var balanceGroup: QCGroupConfig {
        let group: QCGroupConfig = QCGroupConfig(context: context)
        group.title = "Balance"
        group.ordinalNumber = 7
        
        // Balance
        group.addToQcConfigurations(QCConfig.new(context: context, title: "Balance", sampleEvaluation: SCAGradedScale, ordinalNumber: 1))
        
        return group
    }
    
    // MARK: Clean Cup
    var cleanCupGroup: QCGroupConfig {
        let group: QCGroupConfig = QCGroupConfig(context: context)
        group.title = "Clean Cup"
        group.ordinalNumber = 8
        
        // Clean Cup
        group.addToQcConfigurations(QCConfig.new(context: context, title: "Clean Cup", sampleEvaluation: SCACheckboxes, ordinalNumber: 1))
        
        return group
    }
    
    // MARK: Sweetness
    var sweetnessGroup: QCGroupConfig {
        let group: QCGroupConfig = QCGroupConfig(context: context)
        group.title = "Sweetness"
        group.ordinalNumber = 9
        
        // Sweetness
        group.addToQcConfigurations(QCConfig.new(context: context, title: "Sweetness", sampleEvaluation: SCACheckboxes, ordinalNumber: 1))
        
        return group
    }
    
    // MARK: Overall
    var overallGroup: QCGroupConfig {
        let group: QCGroupConfig = QCGroupConfig(context: context)
        group.title = "Overall"
        group.ordinalNumber = 10
        
        // Overall
        group.addToQcConfigurations(QCConfig.new(context: context, title: "Overall", sampleEvaluation: SCAGradedScale, ordinalNumber: 1))
        
        return group
    }
    
    // MARK: Defects
    var defectsGroup: QCGroupConfig {
        let group: QCGroupConfig = QCGroupConfig(context: context)
        group.title = "Defects"
        group.ordinalNumber = 11
        
        // Clean Cup
        let numOfCups: SampleEvaluation = SampleEvaluation(
            evaluationType: .radio,
            defaultValue: 0,
            bounds: 1...5
        )
        
        // Intensity
        let intensity: SampleEvaluation = SampleEvaluation(
            evaluationType: .radio,
            defaultValue: 0,
            bounds: 2...4,
            step: 2
        )
        
        group.addToQcConfigurations(QCConfig.new(context: context, title: "Num of cups", sampleEvaluation: numOfCups, ordinalNumber: 1))
        group.addToQcConfigurations(QCConfig.new(context: context, title: "Intensity", sampleEvaluation: intensity, ordinalNumber: 2))
        
        return group
    }
}
