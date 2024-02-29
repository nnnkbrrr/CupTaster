//
//  Setting Tester.swift
//  CupTaster
//
//  Created by Nikita on 12.02.2024.
//

import SwiftUI

class TestingManager: ObservableObject {
    @PublishedAppStorage("tester-tab-visibility") var isVisible: Bool = false
    @PublishedAppStorage("show-tester-overlay") var testerOverlayIsVisible: Bool = false
    
    @Published var hideSampleOverlay: Bool = false
    
    public static let shared: TestingManager = .init()
    private init() { }
}

struct TesterPanelView: View {
    @ObservedObject var testingManager: TestingManager = .shared
    @ObservedObject var samplesControllerModel: SamplesControllerModel = .shared
    @ObservedObject var locationManager: LocationManager = .shared
    
    let appVersion: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "???"
    let buildVersion: String = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "???"
    let systemVersion: String = UIDevice.current.systemVersion
    let languageCode: String = Locale.current.languageCode ?? "-"
    
    @AppStorage("tester-selected-page") var currentPage: Int = 0
    @State var showStopwatchModal: Bool = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            HStack(spacing: 5) {
                ForEach(0..<5) { index in
                    Circle()
                        .frame(width: 5, height: 5)
                        .foregroundColor(currentPage == index ? .white : .gray)
                }
            }
            .animation(.bouncy, value: currentPage)
            .frame(height: 5)
            .padding(.horizontal)
            .allowsHitTesting(false)
            
            TabView(selection: $currentPage) {
                Group {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("CupTaster Testing Panel")
                            Text("\(appVersion) (\(buildVersion)) / iOS \(systemVersion) / \(languageCode)")
                        }
                        .foregroundStyle(.gray)
                        
                        Spacer()
                        
                        TesterButton(title: "Hide", systemImageName: "eye.slash") {
                            testingManager.testerOverlayIsVisible = false
                        }
                    }
                    .tag(0)
                    
                    HStack {
                        TesterButton(title: "Sample Overlay", systemImageName: testingManager.hideSampleOverlay ? "eye.slash.fill" : "eye.fill") {
                            testingManager.hideSampleOverlay.toggle()
                        }
                        TesterButton(title: "Lock", systemImageName: samplesControllerModel.isTogglingVisibility ? "lock" : "lock.open") {
                            samplesControllerModel.isTogglingVisibility.toggle()
                        }
                        TesterButton(title: "Stopwatch", systemImageName: "stopwatch") {
                            showStopwatchModal = true
                        }
                        .adaptiveSizeSheet(isPresented: $showStopwatchModal) {
                            StopwatchTimeSelectorView()
                        }
                    }
                    .tag(1)
                    
                    HStack {
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
                    .tag(2)
                    
                    HStack {
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
                    .tag(3)
                    
                    HStack {
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
                                guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
                                guard let window = windowScene.windows.first else { return }
                                let location: String = await locationManager.getLocationAddress() ?? "Undefined"
                                let alert = UIAlertController(title: "Your Location is", message: location, preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "OK", style: .destructive))
                                window.rootViewController?.present(alert, animated: true)
                            }
                        }
                        
                        TesterButton(title: "Authorize", systemImageName: "location.viewfinder") {
                            locationManager.requestAuthorization()
                        }
                    }
                    .tag(4)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
            }
            .font(.caption)
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: .smallElement)
        }
        .frame(height: .smallElement)
        .clipped()
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
    }
}

extension TesterPanelView {
    struct TesterSectionView<LeadingContent: View>: View {
        let title: String
        @Binding var systemImageName: String?
        let leadingContent: () -> LeadingContent
        
        init(title: String, systemImageName: String? = nil, leadingContent: @escaping () -> LeadingContent = { EmptyView() } ) {
            self.title = title
            self._systemImageName = .constant(systemImageName)
            self.leadingContent = leadingContent
        }
        
        var body: some View {
            HStack(spacing: 5) {
                if let systemImageName {
                    Image(systemName: systemImageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 15, height: 15)
                }
                
                Text(title)
                    .multilineTextAlignment(.leading)
                
                leadingContent()
            }
            .foregroundStyle(.primary)
            .frame(height: 35)
            .padding(.horizontal, .small)
            .background(Color.gray.opacity(0.5))
            .cornerRadius(10)
        }
    }
    
    struct TesterButton: View {
        let title: String
        @Binding var systemImageName: String
        let action: () -> ()
        
        init(title: String, systemImageName: String, action: @escaping () -> ()) {
            self.title = title
            self._systemImageName = .constant(systemImageName)
            self.action = action
        }
        
        init(title: String, systemImageName: @escaping () -> String, action: @escaping () -> ()) {
            self.title = title
            self._systemImageName = Binding(get: { systemImageName() }, set: { _ in})
            self.action = action
        }
        
        var body: some View {
            Button {
                action()
            } label: {
                HStack(spacing: 5) {
                    Image(systemName: systemImageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 15, height: 15)
                    
                    Text(title)
                        .multilineTextAlignment(.leading)
                }
                .foregroundStyle(.primary)
                .frame(height: 35)
                .padding(.horizontal, .small)
                .background(Color.gray.opacity(0.5))
                .cornerRadius(10)
            }
            .buttonStyle(.plain)
        }
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
