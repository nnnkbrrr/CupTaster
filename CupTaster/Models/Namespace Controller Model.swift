//
//  Namespace Controller Model.swift
//  CupTaster
//
//  Created by Nikita on 05.02.2024.
//

import SwiftUI

struct NamespaceControllerModel {
    static let shared: NamespaceControllerModel = .init()
    var namespace: Namespace.ID
    
    private init() {
        @Namespace var namespace
        self.namespace = namespace
    }
}
