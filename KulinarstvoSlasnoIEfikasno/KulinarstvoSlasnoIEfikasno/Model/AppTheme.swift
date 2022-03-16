//
//  AppTheme.swift
//  KulinarstvoSlasnoIEfikasno
//
//  Created by Marko Veljkovic private on 16.3.22.
//

import Foundation
import SwiftUI

class AppTheme {
    static let backgroundUniversalGreen = UIColor(displayP3Red: 4/255, green: 110/255, blue: 75/255, alpha: 1)
    static let textUniversalGreen = UIColor(displayP3Red: 190/255, green: 255/255, blue: 249/255, alpha: 1)
    
    static func setTextColor() -> UIColor {
        return UITraitCollection.current.userInterfaceStyle == .dark ? AppTheme.textUniversalGreen : AppTheme.backgroundUniversalGreen
    }
    
    static func setBackgroundColor() -> UIColor {
        return UITraitCollection.current.userInterfaceStyle == .dark ? AppTheme.backgroundUniversalGreen : AppTheme.textUniversalGreen
    }
}
