//
//  Sample Controller.swift
//  CupTaster
//
//  Created by Никита Баранов on 23.07.2023.
//

import SwiftUI

struct SampleControllerView: View {
    @ObservedObject var sampleControllerModel: SampleControllerModel = .shared
    
    var body: some View {
        Text("SampleController")
    }
}
