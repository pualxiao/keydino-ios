//
//  PaymentRequestTests.swift
//  breadwallet
//
//  Created by Adrian Corscadden on 2017-03-26.
//  Copyright © 2017 breadwallet LLC. All rights reserved.
//

import XCTest
@testable import keydino

class PaymentRequestTests : XCTestCase {

    func testEmptyString() {
        XCTAssertNil(PaymentRequest(string: ""))
    }

    func testInvalidAddress() {
        XCTAssertNil(PaymentRequest(string: "notandaddress"), "Payment request should be nil for invalid addresses")
    }

    func testBasicExample() {
        let uri = "bitcoincash:msEJBCMWtGKzLhQq33UDfBErgghz6KPbUE"  //12A1MyfXbW6RhdRAZEqofac5jCQQjwEPBu

        let request = PaymentRequest(string: uri)
        XCTAssertNotNil(request)
        XCTAssertTrue(request?.toAddress == "msEJBCMWtGKzLhQq33UDfBErgghz6KPbUE")  //12A1MyfXbW6RhdRAZEqofac5jCQQjwEPBu

    }

    func testAmountInUri() {
        let uri = "bitcoincash:msEJBCMWtGKzLhQq33UDfBErgghz6KPbUE?amount=1.2"  //12A1MyfXbW6RhdRAZEqofac5jCQQjwEPBu

        let request = PaymentRequest(string: uri)
        XCTAssertNotNil(request)
        XCTAssertTrue(request?.toAddress == "msEJBCMWtGKzLhQq33UDfBErgghz6KPbUE")  //12A1MyfXbW6RhdRAZEqofac5jCQQjwEPBu

        XCTAssertTrue(request?.amount?.rawValue == 120000000)
    }

    func testRequestMetaData() {
        let uri = "bitcoincash:msEJBCMWtGKzLhQq33UDfBErgghz6KPbUE?amount=1.2&message=Payment&label=Satoshi"
        let request = PaymentRequest(string: uri)
        XCTAssertTrue(request?.toAddress == "msEJBCMWtGKzLhQq33UDfBErgghz6KPbUE")  //12A1MyfXbW6RhdRAZEqofac5jCQQjwEPBu

        XCTAssertTrue(request?.amount?.rawValue == 120000000)
        XCTAssertTrue(request?.message == "Payment")
        XCTAssertTrue(request?.label == "Satoshi")
    }

    func testExtraEqualSign() {
        let uri = "bitcoincash:msEJBCMWtGKzLhQq33UDfBErgghz6KPbUE?amount=1.2&message=Payment=true&label=Satoshi"  //12A1MyfXbW6RhdRAZEqofac5jCQQjwEPBu

        let request = PaymentRequest(string: uri)
        XCTAssertTrue(request?.message == "Payment=true")
    }

    func testMessageWithSpace() {
        let uri = "bitcoincash:msEJBCMWtGKzLhQq33UDfBErgghz6KPbUE?amount=1.2&message=Payment message test&label=Satoshi" //12A1MyfXbW6RhdRAZEqofac5jCQQjwEPBu
        let request = PaymentRequest(string: uri)
        XCTAssertTrue(request?.message == "Payment message test")
    }

    func testPaymentProtocol() {
        let uri = "https://www.syndicoin.co/signednoroot.paymentrequest"
        let request = PaymentRequest(string: uri)
        XCTAssertTrue(request?.type == .remote)

        let promise = expectation(description: "Fetch Request")
        request?.fetchRemoteRequest(completion: { newRequest in
            XCTAssertNotNil(newRequest)
            promise.fulfill()
        })

        waitForExpectations(timeout: 5.0) { error in
            XCTAssertNil(error)
        }
    }
}
