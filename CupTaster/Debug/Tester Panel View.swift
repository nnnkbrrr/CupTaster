//
//  Tester Panel View.swift
//  CupTaster
//
//  Created by Nikita on 1/9/25.
//

import SwiftUI
import CoreData

struct TesterPanelView: View {
    @Environment(\.managedObjectContext) private var moc
    @FetchRequest(entity: SampleGeneralInfo.entity(), sortDescriptors: []) var generalInfoFields: FetchedResults<SampleGeneralInfo>
    
    @ObservedObject var testingManager: TestingManager = .shared
    @ObservedObject var samplesControllerModel: SamplesControllerModel = .shared
    @ObservedObject var locationManager: LocationManager = .shared
    
    let appVersion: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "???"
    let buildVersion: String = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "???"
    let systemVersion: String = UIDevice.current.systemVersion
    let languageCode: String = Locale.current.languageCode ?? "-"
    
    @AppStorage("default-cupping-form-description") private(set) var defaultCFDescription: String = ""
    @AppStorage("onboarding-is-completed") private var onboardingIsCompleted: Bool = false
    @State private var stopwatchModalIsActive: Bool = false
    
    @Binding var isPresented: Bool
    @State var opacity: CGFloat = 1
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                Section("Primary") {
                    TesterButton(
                        title: testingManager.allowSaves ? "Saves allowed" : "Saves blocked",
                        systemImageName: testingManager.allowSaves ? "hand.raised.slash" : "hand.raised.fill"
                    ) {
                        testingManager.allowSaves.toggle()
                    }
                    
                    TesterButton(title: testingManager.showRecipesTab ? "Hide recipes tab" : "Show recipes tab", systemImageName: "list.clipboard") {
                        testingManager.showRecipesTab.toggle()
                    }
                    TesterButton(title: "Cupping date selector", systemImageName: testingManager.cuppingDatePickerIsVisible ? "eye.fill" : "eye.slash.fill") {
                        testingManager.cuppingDatePickerIsVisible.toggle()
                    }
                    TesterButton(title: "Empty State", systemImageName: testingManager.showMainPageEmptyState ? "eye.slash.fill" : "eye.fill") {
                        testingManager.showMainPageEmptyState.toggle()
                    }
                    TesterButton(title: "Sample Overlay", systemImageName: testingManager.hideSampleOverlay ? "eye.slash.fill" : "eye.fill") {
                        testingManager.hideSampleOverlay.toggle()
                    }
                    TesterButton(title: "Lock", systemImageName: samplesControllerModel.isTogglingVisibility ? "lock" : "lock.open") {
                        samplesControllerModel.isTogglingVisibility.toggle()
                    }
                    TesterButton(title: "Stopwatch", systemImageName: "stopwatch") {
                        stopwatchModalIsActive = true
                    }
                    .adaptiveSizeSheet(isPresented: $stopwatchModalIsActive) {
                        StopwatchTimeSelectorView()
                    }
                    TesterButton(title: "Reset Default Cupping Form", systemImageName: "arrow.clockwise") {
                        defaultCFDescription = ""
                    }
                }
                
                Section("Cupping") {
                    if let cupping = samplesControllerModel.cupping {
                        VStack(alignment: .leading) {
                            Text("Cupping: \(cupping.name)")
                            Text("Samples: \(cupping.samples.count)")
                            Text("Selected Sample Index: \(samplesControllerModel.selectedSampleIndex)")
                        }
                        .foregroundStyle(.gray)
                        
                        Spacer()
                        
                        TesterButton(title: "Randomly Fill", systemImageName: "wand.and.stars") {
                            for sample in cupping.samples {
                                randomlyFillSample(sample)
                            }
                        }
                    } else {
                        Text("Select sample to show its cupping testing page")
                            .foregroundStyle(.gray)
                    }
                }
                
                Section("Sample") {
                    if let sample: Sample = samplesControllerModel.selectedSample {
                        VStack(alignment: .leading) {
                            Text("Sample: \(sample.name)")
                            Text("General Info: \((sample.generalInfo.map { $0.title } ).description)")
                                .resizableText(initialSize: 12)
                        }
                        .foregroundStyle(.gray)
                        
                        Spacer()
                        
                        TesterButton(title: "Randomly Fill", systemImageName: "wand.and.stars") {
                            randomlyFillSample(sample)
                        }
                    } else {
                        Text("Select sample to show sample testing page")
                            .foregroundStyle(.gray)
                    }
                }
                
                Section("Onboarding") {
                    Spacer()
                    
                    TesterButton(
                        title: "Skip pages",
                        systemImageName: testingManager.skipFilledOnboardingPages ? "arrowshape.bounce.right" : "arrowshape.right"
                    ) {
                        testingManager.skipFilledOnboardingPages.toggle()
                    }
                    
                    TesterButton(title: testingManager.showOnboarding ? "Hide" : "Show", systemImageName: testingManager.showOnboarding ? "eye.slash.fill" : "eye.fill") {
                        testingManager.showOnboarding.toggle()
                    }
                    
                    TesterButton(title: "Reset page", systemImageName: "arrow.clockwise") {
                        OnboardingModel.CurrentPageModel.shared.page = .greetings
                    }
                }
                
                Section("Location") {
                    let locationStatus: String =
                    switch locationManager.authorizationStatus {
                        case .notDetermined: "not determined"
                        case .restricted: "restricted"
                        case .denied: "denied"
                        case .authorizedAlways: "authorized always"
                        case .authorizedWhenInUse: "authorized when in use"
                        case .authorized: "authorized"
                        @unknown default: "unknown"
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Location ") + Text(Image(systemName: locationManager.authorized ? "location.fill" : "location.slash"))
                        Text("\(locationStatus)")
                    }
                    .foregroundStyle(.gray)
                    
                    Spacer()
                    
                    TesterButton(title: "Get", systemImageName: "location.magnifyingglass") {
                        Task {
                            let location: String = await locationManager.getLocationAddress() ?? "Undefined"
                            showAlert(title: "Your Location is", message: location)
                        }
                    }
                    
                    TesterButton(title: "Authorize", systemImageName: "location.viewfinder") {
                        locationManager.requestAuthorization()
                    }
                }
            }
            .padding()
        }
        .navigationToolbar {
            HStack(spacing: .small) {
                ZStack {
                    HStack {
                        Button("Done") { isPresented = false }
                        
                        Spacer()
                        
                        Image(systemName: "square.on.square.intersection.dashed")
                            .foregroundStyle(.accent)
                            .onLongPressGesture(minimumDuration: 0, maximumDistance: 100) {
                                withAnimation(.easeInOut(duration: 0.1)) {
                                    self.opacity = 0
                                }
                            } onPressingChanged: { isPressing in
                                withAnimation(.easeInOut(duration: 0.1)) {
                                    self.opacity = isPressing ? 0 : 1
                                }
                            }
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 2) {
                        Text("CupTaster Testing Panel")
                        Text("\(appVersion) (\(buildVersion)) / iOS \(systemVersion) / \(languageCode)")
                    }
                    .font(.system(size: 8))
                }
            }
            .padding(.horizontal, .regular)
            .frame(height: 35)
        }
        .background(Color.backgroundPrimary.opacity(0.5))
        .opacity(opacity)
    }
        
    func randomlyFillSample(_ sample: Sample) {
        sample.name = sampleNames.randomElement() ?? ""
        
        for qcGroup in sample.qualityCriteriaGroups {
            for criterion in qcGroup.qualityCriteria {
                let configuration = criterion.configuration
                switch configuration.unwrappedEvaluation {
                    case is CupsCheckboxesEvaluation:
                        let cupsCount: Int = Int(qcGroup.sample.cupping.cupsCount)
                        let checkboxes: [Int] = Array(1...cupsCount)
                        criterion.value = 0
                        
                        for checkbox in checkboxes {
                            if (0...2).randomElement() == 0 {
                                let power: Double = Double(cupsCount - checkbox)
                                criterion.value += pow(10, power)
                            }
                        }
                    case is SliderEvaluation, is RadioEvaluation:
                        criterion.value = Array(stride(
                            from: configuration.lowerBound,
                            through: configuration.upperBound,
                            by: configuration.step
                        )).randomElement() ?? 0
                    default:
                        return
                }
            }
            qcGroup.isCompleted = true
        }
        
        sample.calculateFinalScore()
        
        save(moc)
    }
}

private let sampleNames = [
    "Ethiopian Yirgacheffe", "Colombian Supremo", "Brazilian Santos", "Kenyan AA", "Guatemalan Antigua",
    "Costa Rican Tarrazu", "Mexican Chiapas", "Honduran Marcala", "Peruvian Cajamarca", "Nicaraguan Jinotega",
    "Panamanian Boquete", "Tanzanian Peaberry", "Indonesian Sumatra", "Ugandan Bugisu", "Vietnamese Robusta",
    "Hawaiian Kona", "Jamaican Blue Mountain", "Puerto Rican Yauco", "Ecuadorian Loja", "Bolivian Caranavi",
    "Ethiopian Harrar", "Colombian Excelso", "Brazilian Cerrado", "Kenyan Peaberry", "Guatemalan Huehuetenango",
    "Costa Rican Tres Rios", "Mexican Oaxaca", "Honduran Copan", "Peruvian Puno", "Nicaraguan Matagalpa",
    "Panamanian Volcan Baru", "Tanzanian AA", "Indonesian Java", "Ugandan Sipi Falls", "Vietnamese Arabica",
    "Hawaiian Maui", "Jamaican Wallenford", "Puerto Rican Adjuntas", "Ecuadorian Zamora", "Bolivian Yungas",
    "Ethiopian Sidamo", "Colombian Caturra", "Brazilian Mogiana", "Kenyan SL28", "Guatemalan San Marcos",
    "Costa Rican Dota", "Mexican Veracruz", "Honduran Comayagua", "Peruvian La Libertad", "Nicaraguan Esteli",
    "Panamanian Geisha", "Tanzanian Peaberries", "Indonesian Bali Kintamani"
]
