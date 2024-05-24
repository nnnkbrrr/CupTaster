//
//  QR Scanner.swift
//  CupTaster
//
//  Created by Nikita on 25.02.2024.
//

import SwiftUI
import CodeScanner

struct QRScannerView: View {
    @Binding var isActive: Bool
    let response: (Result<ScanResult, ScanError>) -> ()
    
    init(isActive: Binding<Bool>, response: @escaping (Result<ScanResult, ScanError>) -> Void) {
        self._isActive = isActive
        self.response = response
    }
    
    @State var isGalleryPresented: Bool = false
    @State var flashLightIsActive: Bool = false
    @State var viewfinderOverlayIsZoomedIn: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack {
                CodeScannerView(
                    codeTypes: [.qr],
                    isTorchOn: flashLightIsActive,
                    isGalleryPresented: $isGalleryPresented
                ) { response in
                    isActive = false
                    isGalleryPresented = false
                    flashLightIsActive = false
                    
                    self.response(response)
                }
                .ignoresSafeArea()
                
                Image(systemName: "viewfinder")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .font(.body.weight(.ultraLight))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .scaleEffect(viewfinderOverlayIsZoomedIn ? 0.8 : 0.7)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                            viewfinderOverlayIsZoomedIn.toggle()
                        }
                    }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Select...") {
                        isGalleryPresented = true
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Button {
                        flashLightIsActive.toggle()
                    } label: {
                        Image(systemName: "flashlight.\(flashLightIsActive ? "on" : "off").fill")
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") {
                        isGalleryPresented = false
                        flashLightIsActive = false
                        isActive = false
                    }
                }
            }
            .navigationBarTitle("", displayMode: .inline)
            .defaultNavigationBar()
        }
    }
}
