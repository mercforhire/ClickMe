//
//  SKCountryPickerCountry+Extensions.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-09-16.
//

import Foundation
import SKCountryPicker

extension SKCountryPicker.Country {
    var englishName: String {
        let locale = Locale(identifier: "en_US_POSIX")
        guard let localisedCountryName = locale.localizedString(forRegionCode: self.countryCode) else {
            let message = "Failed to localised country name for Country Code:- \(self.countryCode)"
            fatalError(message)
        }
        return localisedCountryName
    }
}

