//
//  WalletCreationTests.swift
//  breadwallet
//
//  Created by Adrian Corscadden on 2017-02-26.
//  Copyright © 2017 breadwallet LLC. All rights reserved.
//

import XCTest
@testable import keydino

class WalletCreationTests: XCTestCase {

    private let walletManager: WalletManager = try! WalletManager(store: Store(), dbPath: nil)

    override func setUp() {
        super.setUp()
        clearKeychain()
    }

    override func tearDown() {
        super.tearDown()
        clearKeychain()
    }
    
    func clearWallet() {
        tearDown()
        deleteDb()
        XCTAssertNotNil(walletManager.setRandomSeedPhrase(), "Seed phrase should not be nil.")
    }

    func testWalletCreation() {
        tearDown()
        deleteDb()
        XCTAssertNotNil(walletManager.setRandomSeedPhrase(), "Seed phrase should not be nil.")
    }
}
