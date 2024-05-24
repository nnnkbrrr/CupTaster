//
//  Integer To Digits.swift
//  CupTaster
//
//  Created by Никита Баранов on 03.07.2023.
//

import Foundation

extension BinaryInteger {
    var digits: [Int] {
        return String(describing: self).compactMap { Int(String($0)) }
    }
}
