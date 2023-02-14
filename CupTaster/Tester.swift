//
//  Tester View.swift
//  CupTaster
//
//  Created by Никита Баранов on 09.10.2022.
//

import SwiftUI

struct TesterView: View {
    @AppStorage("tester-tab-visible") var testerTabVisible: Bool = false
    
    @AppStorage("onboarding-completed") var onboardingCompleted: Bool = false
    @AppStorage("tester-show-cuppings-date-picker") var showCuppingsDatePicker: Bool = false
    
    @FetchRequest(entity: Cupping.entity(), sortDescriptors: []) var cuppings: FetchedResults<Cupping>
    @State var addingBlankForm: Bool = false
    
    var body: some View {
        Form {
            Section("") {
                Button("Show onboarding on next launch") {
                    onboardingCompleted = false
                }
                
                Menu("Set stopwatch time") {
                    ForEach(1..<60) { min in
                        Button("\(min):00") {
                            StopwatchView().timeSince = Date(timeIntervalSince1970: 0)
                            StopwatchView().timeTill = Date(timeIntervalSince1970: TimeInterval(min*60))
                        }
                    }
                }
                
                Button("Add blank form") { addingBlankForm = true }
            }
            
            Section("") {
                Toggle("Show cuppings date picker", isOn: $showCuppingsDatePicker)
            }
            
            let samPerCpg: [Int] = cuppings.map { $0.samples.count }
            let minSamPerCpg: Int? = samPerCpg.min()
            let avgSamPerCpg: Int? = samPerCpg.min() != nil ? Int(CGFloat(samPerCpg.reduce(0, +))/CGFloat(cuppings.count)) : nil
            let maxSamPerCpg: Int? = samPerCpg.max()
            
            Section("Stats") {
                Text("Cuppings count: \(cuppings.count)")
                Text("Samples total count: \(samPerCpg.reduce(0, +))")
                Text("Min samples: \(minSamPerCpg ?? 0)")
                Text("Avg samples: \(avgSamPerCpg ?? 0)")
                Text("Max samples: \(maxSamPerCpg ?? 0)")
            }
            
            Section {
                Button("Hide tester tab") {
                    testerTabVisible = false
                }
            }
        }
        .sheet(isPresented: $addingBlankForm) { NewBlankFormView() }
    }
}

fileprivate struct NewBlankFormView: View {
    @Environment(\.managedObjectContext) private var moc
    @State var title: String = ""
    @State var version: String = ""
    @State var langCode: String = "en"
    
    var body: some View {
        Form {
            TextField("Title", text: $title)
            TextField("Version", text: $version)
            TextField("Language code", text: $langCode)
            
            Button("Добавить") {
                let newCF: CuppingForm = CuppingForm(context: moc)
                newCF.title = title
                newCF.version = version
                newCF.languageCode = langCode
                newCF.finalScoreFormula = ""
                
                try? moc.save()
                
                title = ""
                version = ""
                langCode = "en"
            }
        }
    }
}
