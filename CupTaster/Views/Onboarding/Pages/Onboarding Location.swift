//
//  Onboarding Location.swift
//  CupTaster
//
//  Created by Nikita on 24.03.2024.
//

import SwiftUI
import CoreLocation

#warning("last page end onboarding")
struct Onboarding_LocationPage: View {
    @ObservedObject var onboardingModel: OnboardingModel
    
    @ObservedObject var locationManager: LocationManager = .shared
    @State var showLocationAuthorizationSheet: Bool = false
    
    var body: some View {
        OnboardingPageContents("Location", description: "You can turn on location services to attach location to the conducted cuppings.") {
            VStack(spacing: .large) {
                if locationManager.authorized {
                    HStack {
                        Text("Location services are enabled")
                        Image(systemName: "checkmark")
                    }
                    .font(.subheadline.bold())
                    .frame(height: .smallElement)
                    .frame(maxWidth: .infinity)
                    .overlay {
                        Capsule()
                            .stroke(Color.primary, lineWidth: 1)
                    }
                } else {
                    Button("Sure!") {
                        if locationManager.authorizationStatus == .notDetermined {
                            locationManager.requestAuthorization()
                        } else {
                            showLocationAuthorizationSheet = true
                        }
                    }
                    .buttonStyle(.capsule)
                    .adaptiveSizeSheet(isPresented: $showLocationAuthorizationSheet) {
                        VStack(spacing: .large) {
                            Text("Access denied")
                                .font(.title.bold())
                            
                            Image(systemName: "location.slash")
                                .font(.system(size: 100, weight: .light))
                                .frame(maxWidth: .infinity)
                                .foregroundStyle(.gray)
                            
                            Text("Turn on Location Services in settings to allow CupTaster determine your location.")
                                .multilineTextAlignment(.center)
                                .foregroundStyle(.gray)
                            
                            Button {
                                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    showLocationAuthorizationSheet = false
                                }
                            } label: {
                                Text("Go to settings ") + Text(Image(systemName: "arrow.right"))
                            }
                            .buttonStyle(.primary)
                        }
                        .padding([.horizontal, .bottom], .small)
                    }
                    
                    Text("or skip this step for now")
                }
            }
        } conditionIsFulfilled: {
            return true
        } action: {
            withAnimation(.smooth) {
                onboardingModel.nextPage()
            }
        }
    }
}
