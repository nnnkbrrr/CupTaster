//
//  CupTasterApp.swift
//  CupTaster
//
//  Created by Никита on 09.04.2022.
//

import SwiftUI

@main
struct CupTasterApp: App {
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
