//
//  AnyTransition+Extension.swift
//  PoopDetector
//
//  Created by Gokul P on 7/15/25.
//

import SwiftUI

extension AnyTransition {
    static var slideAway: AnyTransition {
        AnyTransition.asymmetric(
            insertion: .move(edge: .trailing),
            removal: .move(edge: .leading)
        )
    }
}