//
//  New Cupping Modal.swift
//  CupTaster
//
//  Created by Nikita on 11.01.2024.
//

import SwiftUI

struct NewCuppingModalView: View {
    @Environment(\.managedObjectContext) private var moc
    @FetchRequest(
        entity: CuppingForm.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \CuppingForm.title, ascending: false)]
    ) var cuppingForms: FetchedResults<CuppingForm>
    
    @ObservedObject var locationManager: LocationManager = .shared
    
    @Binding var isPresented: Bool
    
    private let nameLengthLimit = 50
    @State var name: String = ""
    @State var cupsCount: Int = 5
    @State var samplesCount: Int = 10
    
    @State var loadingAddress: Bool = true
    @State var address: String = "Location unavailable"
    @State var horizontalAccuracy: Double?
    @State var latitude: Double?
    @State var longitude: Double?
    
    var body: some View {
        VStack(spacing: .extraSmall) {
            TextField("Cupping Name", text: $name)
                .resizableText(weight: .light)
                .submitLabel(.done)
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
                .padding(.vertical, .regular)
                .onChange(of: name) { name in
                    if name.count > nameLengthLimit {
                        self.name = String(name.prefix(nameLengthLimit))
                    }
                }
                .bottomSheetBlock()
            
            HStack(spacing: 0) {
                Group {
                    if let cuppingForm: CuppingForm = CFManager.shared.getDefaultCuppingForm(from: cuppingForms) {
                        Text(cuppingForm.title)
                    }
                    
                    if !loadingAddress {
                        Text(" • ")
                        Text(address)
                    }
                    
                    Text(" • ")
                    Text(Date().short)
                }
                .font(.caption)
                .foregroundStyle(.gray)
            }
            .frame(height: .large)
            
            VStack(spacing: .small) {
                Text("Cups")
                    .font(.subheadline)
                    .foregroundStyle(.gray)
                
                TargetHorizontalScrollView(
                    1...5, selection: $cupsCount,
                    elementWidth: .smallElement, height: 18, spacing: .regular
                ) { cupsNum in
                    Text("\(cupsNum)")
                        .foregroundStyle(cupsNum == cupsCount ? Color.primary : .gray)
                        .frame(width: .smallElement)
                }
                .mask(
                    LinearGradient(
                        gradient: Gradient(colors: [.clear, .black, .clear]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            }
            .bottomSheetBlock()
            
            VStack(spacing: .small) {
                Text("Samples")
                    .font(.subheadline)
                    .foregroundStyle(.gray)
                
                TargetHorizontalScrollView(
                    1...20, selection: $samplesCount,
                    elementWidth: .smallElement, height: 18, spacing: .regular
                ) { samplesNum in
                    Text("\(samplesNum)")
                        .foregroundStyle(samplesNum == samplesCount ? Color.primary : .gray)
                        .frame(width: .smallElement)
                }
                .mask(
                    LinearGradient(
                        gradient: Gradient(colors: [.clear, .black, .clear]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            }
            .bottomSheetBlock()
            
            HStack(spacing: .extraSmall) {
                Button("Cancel") { isPresented = false }
                    .buttonStyle(.bottomSheetBlock)
                
                Button {
                    if let defaultCuppingForm: CuppingForm = CFManager.shared.getDefaultCuppingForm(from: cuppingForms) {
                        let cupping: Cupping = .init(context: moc)
                        cupping.name = name
                        cupping.setup(
                            moc: moc,
                            date: Date(),
                            cuppingForm: defaultCuppingForm,
                            cupsCount: cupsCount,
                            samplesCount: samplesCount
                        )
                        
                        if let horizontalAccuracy, let latitude, let longitude {
                            let location: Location = .init(context: moc)
                            location.address = address
                            location.horizontalAccuracy = horizontalAccuracy
                            location.latitude = latitude
                            location.longitude = longitude
                            cupping.location = location
                        }
                        
                        try? moc.save()
                    } else {
                        #warning("не выбрана форма по умолчанию")
                    }
                    
                    isPresented = false
                } label: {
                    HStack(spacing: .small) {
                        Text("Continue")
                        Image(systemName: "arrow.right")
                    }
                }
                .buttonStyle(.accentBottomSheetBlock)
            }
        }
        .padding([.horizontal, .bottom], .small)
        .onAppear {
            Task {
                if locationManager.attachLocation {
                    if let locationData = await locationManager.getLocationData() {
                        (self.address, self.horizontalAccuracy, self.latitude, self.longitude) = locationData
                    }
                }
                withAnimation {
                    loadingAddress = false
                }
            }
        }
    }
}
