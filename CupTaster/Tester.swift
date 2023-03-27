//
//  Tester View.swift
//  CupTaster
//
//  Created by Никита Баранов on 09.10.2022.
//

import SwiftUI
import PhotosUI

struct TesterView: View {
    @AppStorage("tester-tab-visible") var testerTabVisible: Bool = false
    @AppStorage("tester-show-cuppings-date-picker") var showCuppingsDatePicker: Bool = false
    
    @State var onboardingIsActive: Bool = false
    @State var onboardingImagePickerIsActive: Bool = false
    @AppStorage("tester-onboarding-image") var onboardingImage: Data = Data()
    
    @FetchRequest(entity: Cupping.entity(), sortDescriptors: []) var cuppings: FetchedResults<Cupping>
    @State var addingBlankForm: Bool = false
    
    var body: some View {
        Form {
            Section("") {
                Button("Show onboarding") {
                    onboardingIsActive = true
                }
                .fullScreenCover(isPresented: $onboardingIsActive) {
                    OnboardingView (
                        onboardingCompleted: .constant(false),
                        isActive: $onboardingIsActive
                    )
                }
                
                Button("Onboarding background image") {
                    onboardingImagePickerIsActive = true
                }
                .fullScreenCover(isPresented: $onboardingImagePickerIsActive) {
					ImagePicker(sourceType: .photoLibrary) { image  in
						onboardingImage = image.encodeToData() ?? Data()
                    }
                }
                
                Button("Reset OB Image") {
                    onboardingImage = Data()
                }
            }
            
            Section("") {
                Menu("Set stopwatch time") {
                    ForEach(1..<60) { min in
                        Button("\(min):00") {
                            StopwatchView().timeSince = Date(timeIntervalSince1970: 0)
                            StopwatchView().timeTill = Date(timeIntervalSince1970: TimeInterval(min*60))
                        }
                    }
                }
                
                Button("Add blank form") {
                    addingBlankForm = true
                }
                .sheet(isPresented: $addingBlankForm) { NewBlankFormView() }
            }
            
            Section {
                Toggle("Show cuppings date picker", isOn: $showCuppingsDatePicker)
            }
            
            Section {
                Button("Hide tester tab") {
                    testerTabVisible = false
                }
            }
        }
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
            
            Button("Add") {
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
