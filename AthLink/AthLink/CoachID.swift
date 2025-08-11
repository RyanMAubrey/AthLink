//
//  CoachID.swift
//  AthLink
//
//  Created by RyanAubrey on 12/20/24.
//

import Foundation
import SwiftUI

struct Coach: Identifiable {
    let id = UUID()
    var name: String
    var message: String
    var date: String
    var imageName: String
    var rating : Float = 0.0
    var ratings : Int = 0
    let sport : [String]
    let cost : (String, String)
}
