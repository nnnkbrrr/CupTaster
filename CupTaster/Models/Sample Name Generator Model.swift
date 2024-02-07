//
//  Sample Name Generator.swift
//  CupTaster
//
//  Created by Никита Баранов on 02.12.2023.
//

import SwiftUI

class SampleNameGeneratorModel {
    enum GenerationMethod: RawRepresentable {
        case alphabetical, numerical
        
        public var rawValue: String {
            switch self {
                case .alphabetical: return "alphabetical"
                case .numerical: return "numerical"
            }
        }
        
        public init?(rawValue: String) {
            switch rawValue {
                case "numerical": self = .numerical
                default: self = .alphabetical
            }
        }
    }
    
    @AppStorage("sample-name-generator-method") static var generationMethod: GenerationMethod = .alphabetical
    
    static func generateSampleDefaultName(usedNames: [String]) -> String {
        if Self.generationMethod == .alphabetical {
            let letters: [String] = (65..<91).map(UnicodeScalar.init).map { String($0) }
            
            for letter in letters {
                if !usedNames.contains(where: { $0 == letter }) {
                    return letter
                }
            }
        }
        
        var number: Int = 1
        while usedNames.contains(where: { $0 == "\(number)" }) { number += 1 }
        return "\(number)"
    }
}
