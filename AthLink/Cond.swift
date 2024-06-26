    //
    //  Cond.swift
    //  AthLink
    //
    //  Created by RyanAubrey on 6/25/24.
    //

    import Foundation
    import SwiftUI

    class Cond: ObservableObject {
        @Published var validZ : Bool = false {
            didSet {
                filled()
            }
        }
        @Published var sportVal : Int = 0 {
            didSet {
                filled()
            }
        }
        @Published var fSearch : Bool = false
        @State var zip : String = ""
        
        func filled() {
            if (sportVal != 0 && validZ) {
                fSearch = true
            } else {
                fSearch = false
            }
            print("\(fSearch)")
            print("\(zip)")
            print("\(validZ)")
            print("\(sportVal)")

        }

    }
