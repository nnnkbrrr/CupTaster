//
//  Onboarding.swift
//  CupTaster
//
//  Created by Никита on 29.07.2022.
//

import SwiftUI

struct OnboardingView: View {
    @Binding var onboardingCompleted: Bool
    @Binding var isActive: Bool
    
    @Namespace var namespace
    
    @State var currentPage: OnboardingPages = .greetings
    enum OnboardingPages { case greetings, forms, generalInfo }
    
    @State var headlineGradientAnimation: Bool = false
    
    @State var selectedCuppingForm: String = "SCA"
    @Environment(\.managedObjectContext) private var moc
    @FetchRequest(
        entity: CuppingForm.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \CuppingForm.title, ascending: false)]
    ) var cuppingForms: FetchedResults<CuppingForm>
    @StateObject var cfManager = CFManager.shared
    
    @State var selectedSGIFields: [String] = []
    @FetchRequest(
        entity: SampleGeneralInfo.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \SampleGeneralInfo.ordinalNumber, ascending: false)]
    ) var sgiFields: FetchedResults<SampleGeneralInfo>
    
    var body: some View {
        ZStack(alignment: .bottom) {
            greetings
            
            Group {
                if currentPage == .forms {
                    OnboardingFormsView(currentPage: $currentPage, selectedCuppingForm: $selectedCuppingForm)
                } else if currentPage == .generalInfo {
                    OnboardingGeneralInfoView(currentPage: $currentPage, selectedSGIFields: $selectedSGIFields)
                }
            }
            .transition(
                .asymmetric(
                    insertion: .scale(scale: 0, anchor: .bottom)
                        .combined(with: .opacity),
                    removal: .move(edge: .top)
                        .combined(with: .opacity)
                        .combined(with: .scale(scale: 0, anchor: .bottom))
                )
            )

            button
        }
        .background(
            Image("onboarding-background")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .overlay {
                    LinearGradient(
                        colors: [.black.opacity(0.8), .black.opacity(0.5), .black.opacity(0)],
                        startPoint: .top,
                        endPoint: .center
                    )
                }
                .ignoresSafeArea()
        )
    }
    
    var button: some View {
        Button {
            withAnimation(.interpolatingSpring(stiffness: 75, damping: 12)) {
                switch currentPage {
                case .greetings: currentPage = .forms
                case .forms:
                    currentPage = .generalInfo
                    if !cuppingForms.map({ $0.title }).contains(selectedCuppingForm) {
                        let cfModel = cfManager.allCFModels.first(where: { $0.title == selectedCuppingForm })
                        
                        if let addedForm = cfModel?.createCuppingForm(context: moc) {
                            cfManager.setDefaultCuppingForm(cuppingForm: addedForm)
                        }
                    }
                case .generalInfo:
                    for selectedSGIField in selectedSGIFields {
                        let newSGIField: SampleGeneralInfo = SampleGeneralInfo(context: moc)
                        newSGIField.title = NSLocalizedString(selectedSGIField, comment: "")
                        newSGIField.ordinalNumber = Int16(sgiFields.filter({ $0.sample == nil }).count)
                        
                        try? moc.save()
                    }
                    
                    onboardingCompleted = true
                    isActive = false
                }
            }
        } label: {
            HStack {
                switch currentPage {
                case .greetings:
                    Text("Taste, analyze, take notes")
                        .matchedGeometryEffect(id: "button-text", in: namespace)
                case .forms:
                    Text("Continue")
                        .matchedGeometryEffect(id: "button-text", in: namespace)
                case .generalInfo:
                    Text("Finish")
                        .matchedGeometryEffect(id: "button-text", in: namespace)
                }
                Spacer()
                Image(systemName: "arrow.right")
            }
        }
        .padding()
        .padding(.horizontal, 5)
        .foregroundColor(.white)
        .font(.subheadline.bold())
        .background(Color.accentColor)
        .clipShape(Capsule())
        .frame(height: 50)
        .shadow(color: .black.opacity(0.15), radius: 15)
        .padding(30)
        .padding(currentPage == .greetings ? 0 : 30)
        .animation(.linear(duration: 0.25), value: currentPage)
    }
    
    var greetings: some View {
        VStack {
            Group {
                Text("Welcome to")
                    .foregroundColor(.white)
                
                Text("CupTaster")
                    .foregroundColor(.accentColor)
                    .frame(maxWidth: .infinity)
                    .overlay (
                        LinearGradient(
                            colors: [.accentColor.opacity(0), .orange, .accentColor.opacity(0)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .frame(width: 50)
                        .frame(
                            maxWidth: .infinity,
                            alignment: headlineGradientAnimation ? .trailing : .leading
                        )
                        .mask( Text("CupTaster") )
                    )
                    .onAppear {
                        withAnimation(.easeInOut(duration: 4.0).repeatForever(autoreverses: false)) {
                            headlineGradientAnimation.toggle()
                        }
                    }
            }
            .font(.title.weight(.heavy))
        }
        .padding(.top, 25)
        .frame(maxHeight: .infinity, alignment: .top)
    }
}
