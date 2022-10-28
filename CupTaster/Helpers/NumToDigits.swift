//
//  NumToDigits.swift
//  CupTaster
//
//  Created by Никита Баранов on 24.10.2022.
//

import Foundation

extension BinaryInteger {
    var digits: [Int] {
        return String(describing: self).compactMap { Int(String($0)) }
    }
}
