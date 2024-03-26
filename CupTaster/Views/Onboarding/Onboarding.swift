//
//  Onboarding.swift
//  CupTaster
//
//  Created by Nikita on 09.03.2024.
//

import SwiftUI
import CoreData
import CloudKit

struct OnboardingView: View {
    @Binding var onboardingIsCompleted: Bool
    
    @Namespace var namespace
    enum OnboardingPage {
        case greetings, formPicker, additionalFields, location
        static var allCases: [Self] = [.greetings, .formPicker, .additionalFields, .location]
        mutating func nextPage() {
            switch self {
                case .greetings: self = .formPicker
                case .formPicker: self = .additionalFields
                case .additionalFields: self = .location
                case .location: return
            }
        }
    }
    @State var currentPage: OnboardingPage = .greetings
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: .large) {
                if currentPage != .greetings {
                    Image("Logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .matchedGeometryEffect(id: "onboarding-logo", in: namespace)
                        .frame(width: 50, height: 50)
                }
                
                switch currentPage {
                    case .greetings: Onboarding_GreetingsView(namespace: namespace, currentPage: $currentPage)
                    case .formPicker: Onboarding_FormPickerPage(currentPage: $currentPage)
                    case .additionalFields: Onboarding_AdditionalFieldsPage(currentPage: $currentPage)
                    case .location: Onboarding_LocationPage(currentPage: $currentPage, onboardingIsCompleted: $onboardingIsCompleted)
                }
                
                HStack(spacing: .small) {
                    ForEach(OnboardingPage.allCases, id: \.self) { page in
                        Circle()
                            .frame(width: 5, height: 5)
                            .foregroundStyle(Color.primary.opacity(currentPage == page ? 1 : 0))
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
                
                DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + speed/2, execute: { randomize() })
            }
        }
    }
}
