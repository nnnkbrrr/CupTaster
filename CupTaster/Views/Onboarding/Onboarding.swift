//
//  Onboarding.swift
//  CupTaster
//
//  Created by Nikita on 09.03.2024.
//

import SwiftUI
import CoreData
import CloudKit

class OnboardingModel: ObservableObject {
    @ObservedObject var testingManager: TestingManager = .shared
    @ObservedObject var locationManager: LocationManager = .shared
    let generalInfoFields: FetchedResults<SampleGeneralInfo>
    
    @Binding var onboardingIsCompleted: Bool
    @ObservedObject var currentPageModel: CurrentPageModel = .shared
    @PublishedAppStorage("purchase-identifier") var purchaseIdentifier: String = ""
    
    enum Page {
        case greetings, formPicker, additionalFields, location
        nonisolated(unsafe) static var allCases: [Self] = [.greetings, .formPicker, .additionalFields, .location]
    }
    
    @MainActor
    init(onboardingIsCompleted: Binding<Bool>, generalInfoFields: FetchedResults<SampleGeneralInfo>) {
        self._onboardingIsCompleted = onboardingIsCompleted
        self.generalInfoFields = generalInfoFields
        self.testingManager = TestingManager.shared
        self.locationManager = LocationManager.shared
    }
    
    @MainActor func nextPage() {
        if currentPageModel.page == .greetings {
            currentPageModel.page = .formPicker
            if CFManager.shared.defaultCFDescription == "" || !testingManager.skipFilledOnboardingPages { return }
        }
        
        if currentPageModel.page == .formPicker {
            currentPageModel.page = .additionalFields
            if generalInfoFields.isEmpty || !testingManager.skipFilledOnboardingPages { return }
        }
        
        if currentPageModel.page == .additionalFields {
            currentPageModel.page = .location
            if locationManager.authorizationStatus == .notDetermined || !testingManager.skipFilledOnboardingPages { return }
        }
        
        onboardingIsCompleted = true
        testingManager.showOnboarding = false
        purchaseIdentifier = UUID().uuidString
    }
    
    class CurrentPageModel: ObservableObject {
        @MainActor static let shared: CurrentPageModel = .init()
        @Published var page: OnboardingModel.Page = .greetings
        private init() { }
    }
}

struct OnboardingView: View {
    @ObservedObject var onboardingModel: OnboardingModel
    @ObservedObject var currentPageModel: OnboardingModel.CurrentPageModel = OnboardingModel.CurrentPageModel.shared
    
    init(onboardingIsCompleted: Binding<Bool>, generalInfoFields: FetchedResults<SampleGeneralInfo>) {
        self.onboardingModel = .init(onboardingIsCompleted: onboardingIsCompleted, generalInfoFields: generalInfoFields)
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: .large) {
                if currentPageModel.page != .greetings {
                    Image("Logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .matchedGeometryEffect(id: "onboarding-logo", in: NamespaceControllerModel.shared.namespace)
                        .frame(width: 50, height: 50)
                }
                
                switch currentPageModel.page {
                    case .greetings: Onboarding_GreetingsView(onboardingModel: onboardingModel)
                    case .formPicker: Onboarding_FormPickerPage(onboardingModel: onboardingModel)
                    case .additionalFields: Onboarding_AdditionalFieldsPage(onboardingModel: onboardingModel)
                    case .location: Onboarding_LocationPage(onboardingModel: onboardingModel)
                }
                
                HStack(spacing: .small) {
                    ForEach(OnboardingModel.Page.allCases, id: \.self) { page in
                        Circle()
                            .frame(width: 5, height: 5)
                            .foregroundStyle(Color.primary.opacity(currentPageModel.page == page ? 1 : 0))
                            .overlay {
                                Circle()
                                    .stroke(Color.primary, lineWidth: 1)
                                    .frame(width: 5, height: 5)
                            }
                    }
                }
            }
            .padding(.horizontal, .extraLarge)
            .padding(.top, .large)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            OnboardingBackgroundView()
                .edgesIgnoringSafeArea(.all)
        }
    }
}

extension OnboardingView {
    struct iCloudLoadingView: View {
        @Environment(\.managedObjectContext) private var moc
        @FetchRequest(entity: Cupping.entity(), sortDescriptors: []) var cuppings: FetchedResults<Cupping>
        @FetchRequest(entity: Sample.entity(), sortDescriptors: []) var samples: FetchedResults<Sample>
        
        let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
        
        let date: Date = Date()
        
        @State var totalSamplesCount: Double = 1
        @State var importedSamplesCount: Double = 0
        
        @State var importedObjects: Set<NSManagedObject> = []
        @State var newImportedObjects: [String] = Array(repeating: "", count: 15)
        
        var body: some View {
            VStack(spacing: .regular) {
                Text(date, style: .timer)
                
                ProgressView(value: Double(samples.count), total: totalSamplesCount)
                
                Spacer()
                    .frame(maxHeight: .infinity)
                
                ProgressView()
                
                Text("Loading data from iCloud...")
                
                VStack(spacing: .small) {
                    ForEach(Array(newImportedObjects.enumerated()), id: \.offset) { index, object in
                        Text(object)
                            .font(.caption)
                            .opacity(1.0 - Double(index) / 15.0)
                            .scaleEffect(1.0 - Double(index) / 15.0)
                    }
                }
                .frame(maxHeight: .infinity, alignment: .top)
                .clipped()
            }
            .background {
                OnboardingView.OnboardingBackgroundView()
                    .edgesIgnoringSafeArea(.all)
            }
            .onAppear {
                let queryOperation = CKQueryOperation(query: .init(recordType: "CD_Sample", predicate: NSPredicate(value: true)))
                queryOperation.resultsLimit = CKQueryOperation.maximumResults
                queryOperation.recordMatchedBlock = { _, _ in totalSamplesCount += 1 }
                
                let cloudContainer = CKContainer.init(identifier: "iCloud.CupTaster")
                let privateDatabase = cloudContainer.privateCloudDatabase
                
                privateDatabase.add(queryOperation)
            }
            .onReceive(timer) { time in
                subscribeToChanges()
            }
        }
        
        func subscribeToChanges() {
            for obj in moc.registeredObjects {
                if !importedObjects.contains(obj) {
                    if let sample = obj as? Sample {
                        DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 0...15)) {
                            newImportedObjects.insert("Sample: \(sample.name)", at: 0)
                            newImportedObjects.removeLast()
                        }
                    } else if let cupping = obj as? Cupping {
                        DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 0...15)) {
                            newImportedObjects.insert("Cupping: \(cupping.name)", at: 0)
                            newImportedObjects.removeLast()
                        }
                    }
                }
            }
            
            importedObjects = moc.registeredObjects
        }
    }
}

extension OnboardingView {
    private struct OnboardingBackgroundView: View {
        @Environment(\.colorScheme) var colorScheme
        
        static let screenHeight: CGFloat = UIScreen.main.bounds.size.height
        static let screenWidth: CGFloat = UIScreen.main.bounds.size.width
        
        var noiseImage: UIImage {
            let randomFilter: CIFilter = CIFilter(name: "CIRandomGenerator")!
            let coloredNoiseImage: CIImage = randomFilter.outputImage!.cropped(
                to: (CGRect(x: 0, y: 0, width: Self.screenWidth, height: Self.screenHeight))
            )
            
            let monochromeFilter: CIFilter = CIFilter(name: "CIColorMonochrome")!
            monochromeFilter.setValue(coloredNoiseImage, forKey: "inputImage")
            
            let monochromeNoiseImage: CIImage = monochromeFilter.outputImage!
            let cgImage: CGImage = CIContext().createCGImage(monochromeNoiseImage, from: monochromeNoiseImage.extent)!
            
            return UIImage(cgImage: cgImage)
        }
        
        var body: some View {
            ZStack {
                Color.accentColor.opacity(0.2)
                
                ZStack {
                    ForEach(0..<3) { _ in BackgroundShape() }
                }
                .blur(radius: 100)
                
                Image(uiImage: noiseImage)
                    .resizable()
                    .frame(width: Self.screenWidth, height: Self.screenHeight)
                    .opacity(colorScheme == .dark ? 0.075 : 0.35)
                    .blendMode(colorScheme == .dark ? .screen : .overlay)
            }
        }
        
        private struct BackgroundShape: View {
            @State var scale: CGFloat = CGFloat.random(in: 0.0...1)
            @State var offset: CGSize = CGSize(
                width: CGFloat.random(in: -OnboardingBackgroundView.screenWidth...OnboardingBackgroundView.screenWidth)/2,
                height: CGFloat.random(in: -OnboardingBackgroundView.screenHeight...OnboardingBackgroundView.screenHeight)/2
            )
            @State var angle: Angle = Angle(degrees: Double.random(in: 0...360))
            @State var opacity: CGFloat = CGFloat.random(in: 0.3...0.8)
            
            let speed: CGFloat = 3
            
            var body: some View {
                Ellipse()
                    .foregroundColor(.accentColor)
                    .scaleEffect(scale)
                    .offset(offset)
                    .rotationEffect(angle)
                    .opacity(opacity)
                    .onAppear {
                        randomize()
                    }
            }
            
            func randomize() {
                withAnimation(.easeInOut(duration: speed)) {
                    scale = CGFloat.random(in: 0...1)
                    offset = CGSize(
                        width: CGFloat.random(in: -screenWidth...screenWidth)/2,
                        height: CGFloat.random(in: -screenHeight...screenHeight)/2
                    )
                    angle = Angle(degrees: Double.random(in: 0...360))
                    opacity = CGFloat.random(in: 0.3...0.6)
                }
                
                DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + speed/2, execute: {
                    Task { await randomize() }
                })
            }
        }
    }
}
