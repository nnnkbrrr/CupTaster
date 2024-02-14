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
    
    @State var selectedCupping: Cupping? = nil
    
    public static let shared: TestingManager = .init()
    private init() { }
}

struct Settings_TesterView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var testingManager: TestingManager = .shared
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: .extraSmall) {
                SettingsButtonSection(title: "Toggle tester overlay") {
                    testingManager.testerOverlayIsVisible.toggle()
                }
                
                SettingsButtonSection(title: "Hide tester tab") {
                    testingManager.isVisible = false
                    dismiss()
                }
            }
            .padding(.small)
        }
        .background(Color.backgroundPrimary)
        .navigationTitle("Tester")
        .defaultNavigationBar()
    }
}

struct TesterOverlayView: View {
    @ObservedObject var testingManager: TestingManager = .shared
    @ObservedObject var samplesControllerModel: SamplesControllerModel = .shared
    
    let appVersion: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "???"
    let buildVersion: String = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "???"
    let systemVersion: String = UIDevice.current.systemVersion
    let languageCode: String = Locale.current.languageCode ?? "-"
    
    @AppStorage("tester-selected-page") var currentPage: Int = 0
    @State var showStopwatchModal: Bool = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            HStack(spacing: 5) {
                ForEach(0..<4) { index in
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
                            Text("Cupping: \(cupping.name)")
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
                            Text("Sample: \(sample.name)")
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

extension TesterOverlayView {
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
