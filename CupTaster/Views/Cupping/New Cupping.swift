//
//  New Cupping.swift
//  CupTaster
//
//  Created by Никита on 16.08.2022.
//

import SwiftUI

struct NewCuppingView: View {
    @Environment(\.managedObjectContext) private var moc
    @State var cupping: Cupping?
    
    @FocusState private var cuppingNameFieldFocused: Bool
    @AppStorage("selected-cupping-form") var selectedCuppingForm: String = ""
    @State var cuppingName: String = ""
    
    var body: some View {
        if let cupping = cupping {
            CuppingView(cupping: cupping)
                .transition(.opacity)
        } else {
            ScrollView {
                InsetFormSection("Cupping Name") {
                    TextField("", text: $cuppingName) {
                        let newCupping: Cupping = Cupping(context: moc)
                        newCupping.name = cuppingName
                        newCupping.date = Date()
                        
                        withAnimation { self.cupping = newCupping }
                        self.cuppingNameFieldFocused = false
                        try? moc.save()
                    }
//                    .autocorrectionDisabled()
                    .submitLabel(.done)
                    .focused($cuppingNameFieldFocused, equals: true)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.cuppingNameFieldFocused = true
                        }
                    }
                }
            }
            .background(Color(uiColor: .systemGroupedBackground), ignoresSafeAreaEdges: .all)
            .toolbar {
                StopwatchToolbarItem()
            }
            .transition(.opacity)
        }
    }
}
