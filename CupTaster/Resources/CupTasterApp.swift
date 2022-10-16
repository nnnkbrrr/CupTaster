//
//  CupTasterApp.swift
//  CupTaster
//
//  Created by Никита on 09.04.2022.
//

import SwiftUI

@main
struct CupTasterApp: App {
    #warning("хуйня с сохранением")
    @AppStorage("default-cupping-form-description") private(set) var defaultCFDescription: String = ""
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .onChange(of: defaultCFDescription) { newValue in
                    print(newValue)
                }
        }
    }
}
