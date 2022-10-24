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
    @FetchRequest(entity: Cupping.entity(), sortDescriptors: []) var cuppings: FetchedResults<Cupping>
    @State var addingBlankForm: Bool = false
    
    var body: some View {
        Form {
            Section("") {
                Button {
                    onboardingCompleted = false
                } label: {
                    Text("Показать приветствие при следующем запуске")
                }
                
                Menu("Установить время на секундомере") {
                    ForEach(1..<60) { min in
                        Button("\(min):00") {
                            StopwatchView().timeSince = Date(timeIntervalSince1970: 0)
                            StopwatchView().timeTill = Date(timeIntervalSince1970: TimeInterval(min*60))
                        }
                    }
                }
                
                Button("Добавить пустую форму") { addingBlankForm = true }
            }
            
            let samPerCpg: [Int] = cuppings.map { $0.samples.count }
            let minSamPerCpg: Int? = samPerCpg.min()
            let avgSamPerCpg: Int? = samPerCpg.min() != nil ? Int(CGFloat(samPerCpg.reduce(0, +))/CGFloat(cuppings.count)) : nil
            let maxSamPerCpg: Int? = samPerCpg.max()
            
            Section("Статистика") {
                Text("Каппингов всего: \(cuppings.count)")
                Text("Образцов всего: \(samPerCpg.reduce(0, +))")
                Text("Минимум образцов: \(minSamPerCpg ?? 0)")
                Text("В среднем образцов: \(avgSamPerCpg ?? 0)")
                Text("Максимум образцов: \(maxSamPerCpg ?? 0)")
            }
            
            Section {
                Button("Скрыть вкладку разработчика") {
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
            TextField("Название формы", text: $title)
            TextField("Версия формы", text: $version)
            TextField("код языка", text: $langCode)
            
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
