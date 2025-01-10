//
//  Testing Manager.swift
//  CupTaster
//
//  Created by Nikita on 1/9/25.
//

import Foundation

class TestingManager: ObservableObject {
    @PublishedAppStorage("tester-tab-visibility") var isVisible: Bool = false
    @PublishedAppStorage("show-tester-overlay") var testerOverlayIsVisible: Bool = false
    @PublishedAppStorage("allow-saves") var allowSaves: Bool = true
    @PublishedAppStorage("show-recipes-tab") var showRecipesTab: Bool = false
    @PublishedAppStorage("cupping-date-picker-is-visible") var cuppingDatePickerIsVisible: Bool = false
    
    @Published var showMainPageEmptyState: Bool = false
    
    @Published var showOnboarding: Bool = false
    @Published var skipFilledOnboardingPages: Bool = true
    
    @Published var hideSampleOverlay: Bool = false
    
    public static let shared: TestingManager = .init()
    private init() { }
}
