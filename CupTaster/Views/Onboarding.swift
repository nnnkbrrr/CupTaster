//
//  Onboarding.swift
//  CupTaster
//
//  Created by Никита on 29.07.2022.
//

import SwiftUI

#warning("change version to 1")
struct Features {
    static public let currentVersion: Int = 0
}

#warning("r u a beginner? turn on hints")
struct OnboardingSheet: ViewModifier {
    @State var isActive: Bool = false
    
    @Environment(\.managedObjectContext) private var moc
    @FetchRequest(
        entity: CuppingForm.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \CuppingForm.title, ascending: true)]
    ) var cuppingForms: FetchedResults<CuppingForm>
    
#warning("change features version to 1")
    @AppStorage("onboarding-features-version") var featuresVersion: Int = 0
    @AppStorage("selected-cupping-form") var selectedCuppingForm: String = ""
    
    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isActive) {
                sheetContent
                    .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
                    .interactiveDismissDisabled()
            }
            .onAppear {
                if cuppingForms.count < 1 {
                    isActive = true
                }
            }
    }
    
    private var sheetContent: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                Group {
                    if cuppingForms.count == 0 {
                        #warning("something important")
                        OnboardingFeaturesView(featuresVersion: featuresVersion)
                        //            } else if featuresVersion != Features.currentVersion {
                        //
                        //            } else if selectedCuppingForm == "" || !cuppingForms.map{ $0.title }.contains(selectedCuppingForm) {
                        //
                        //            }
                    }
                }
                .padding(50)
            }
            
            Button(action: {
                isActive = false
                CuppingFormsModel().createSCACuppingForm(context: moc)
                try? moc.save()
            }, label: {
                Text("Get Started")
                    .padding(.vertical)
                    .foregroundColor(.white)
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .background(Color.accentColor)
                    .cornerRadius(15)
            })
            .padding(50)
            .background(
                LinearGradient(
                    colors: [
                        Color(uiColor: .systemGroupedBackground),
                        Color(uiColor: .systemGroupedBackground).opacity(0)
                    ],
                    startPoint: .bottom,
                    endPoint: .top)
            )
        }
    }
}

struct OnboardingView: View {
    @Binding var isActive: Bool
    
    let onboardingCurrentVersion: Int = 1
    
    @State var formsSelectionActive: Bool = false
    
    // onboarding / false / true
    // new version / false / true
    // cupping forms / false / true
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                if !formsSelectionActive {
                    
                } else {
                    OnboardingFormsSelectionView()
                }
            }
            .transition(
                .asymmetric(
                    insertion: .move(edge: .trailing),
                    removal: .move(edge: .leading)
                )
            )
        }
        .frame(maxWidth: .infinity)
        .background(Color(UIColor.systemGroupedBackground))
    }
}

struct OnboardingFeaturesView: View {
    let featuresVersion: Int
    @State var headlineGradientAnimation: Bool = false
    
    var body: some View {
        VStack {
            Group {
                if featuresVersion == 0 {
                    Text("Welcome to")
                        .fontWeight(.heavy)
                    
                    Text("CupTaster")
                        .fontWeight(.heavy)
                        .foregroundColor(.accentColor)
                        .frame(maxWidth: .infinity)
                        .overlay (
                            LinearGradient(
                                colors: [.orange.opacity(0), .orange, .orange.opacity(0)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                            .frame(width: 50)
                            .frame(
                                maxWidth: .infinity,
                                alignment: headlineGradientAnimation ? .trailing : .leading
                            )
                            .mask(
                                Text("CupTaster")
                                    .fontWeight(.heavy)
                            )
                        )
                        .onAppear {
                            withAnimation(
                                .easeInOut(duration: 4.0)
                                .repeatForever(autoreverses: false)
                            ) {
                                headlineGradientAnimation.toggle()
                            }
                        }
                } else {
                    Text("What's New")
                        .fontWeight(.heavy)
                }
            }
            .font(.largeTitle)
            
            
            #warning("icloud sync between devices")
            feature(
                image: Image(systemName: "doc.on.clipboard"),
                title: "Cuppings",
                description: "Store all your cupping sessions in just one app."
            )
            feature(
                image: Image(systemName: "stopwatch.fill"),
                title: "Stopwatch",
                description: "Track brewing time with stopwatch."
            )
            feature(
                image: Image(systemName: "lightbulb.fill"),
                title: "Hints",
                description: "Use hints to fully understand quality criteria scale."
            )
        }
    }
    
    func feature(image: Image, title: String, description: String) -> some View {
        HStack {
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.accentColor)
                .frame(width: 50, height: 50)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .fontWeight(.heavy)
                    .foregroundColor(.accentColor)

                Text(description)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical)
    }
}

struct OnboardingFormsSelectionView: View {
    @Environment(\.managedObjectContext) private var moc
    @FetchRequest(
        entity: CuppingForm.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \CuppingForm.title, ascending: true)]
    ) var forms: FetchedResults<CuppingForm>
    
    var body: some View {
        VStack(alignment: .leading) {
            Group {
                Text("Please pick all forms for cupping you are going to use")
                    .padding(.bottom)
            }
            .multilineTextAlignment(.leading)
            .padding(.horizontal, 35)
            
            List {
                Section {
                    Button("SCA") { }
//                    AboutCuppingFormView(currentCuppingForm: $currentCuppingForm, title: "SCA").preview
                } header: {
                    Text("Global Standart")
                }
                Section {
                    Button("SCI") { }
                    Button("COE") { }
//                    AboutCuppingFormView(currentCuppingForm: $currentCuppingForm, title: "SCI").preview
//                    AboutCuppingFormView(currentCuppingForm: $currentCuppingForm, title: "COE").preview
                } header: {
                    Text("Based on SCA")
                }
                
                Section {
                    Text("Available soon")
                        .foregroundColor(.gray)
                } header: {
                    Text("User created")
                }
            }
            
            Group {
                Text("You can manage you forms anytime later")
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 20)
        }
        .padding()
    }
}
