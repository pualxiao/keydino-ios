//
//  Constants.swift
//  breadwallet
//
//  Created by Adrian Corscadden on 2016-10-24.
//  Copyright © 2016 breadwallet LLC. All rights reserved.
//

// File Decription:
// - Just a repository for constants
// - Padding, animatino duration and aesthetic constants
// - Ports and URLs

import UIKit

let π: CGFloat = .pi

struct Padding {
    subscript(multiplier: Int) -> CGFloat {
        get {
            return CGFloat(multiplier) * 8.0
        }
    }
}

struct C {
    static let padding = Padding()
    struct Sizes {
        static let buttonHeight: CGFloat = 48.0
        static let headerHeight: CGFloat = 48.0
        static let largeHeaderHeight: CGFloat = 220.0
        static let logoAspectRatio: CGFloat = 125.0/417.0
    }
    static var defaultTintColor: UIColor = {
        return UIView().tintColor
    }()
    static let animationDuration: TimeInterval = 0.3
    static let secondsInDay: TimeInterval = 86400
    static let maxMoney: UInt64 = 21000000*100000000
    static let satoshis: UInt64 = 100000000
    static let walletQueue = "com.keydino.walletqueue"
    //updated currency code
    //static let btcCurrencyCode = "BTC"
    static let bchCurrencyCode = "BCH"
    static let null = "(null)"
    static let maxMemoLength = 250
    static let feedbackEmail = "feedback@keydino.com"
    static let reviewLink = "https://itunes.apple.com/us/app/keydino-bitcoin-cash-wallet/id1342373573?action=write-review"
    static var standardPort: Int {
        return E.isTestnet ? 18333 : 8333
    }
}
