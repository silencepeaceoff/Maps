//
//  PhoneNumberExt.swift
//  Maps
//
//  Created by Dmitrii Tikhomirov on 2/23/23.
//

import Foundation

extension String {
    var formatPhoneNumber: String {
        self.replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")
            .replacingOccurrences(of: "+", with: "")
            .replacingOccurrences(of: "-", with: "")
    }
}
