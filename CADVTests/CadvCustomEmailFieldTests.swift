//
//  CadvCustomEmailFieldTests.swift
//  CADV
//
//  Created by Misha Vakhrushin on 21.01.2025.
//

import XCTest
@testable import CADV

class LoginViewTests: XCTestCase {

    func testValidEmail() {
        let loginView = LoginView(urlElements: .constant(nil))
        XCTAssertTrue(loginView.isValidEmail("test@example.com"))
        XCTAssertTrue(loginView.isValidEmail("user.name+tag+sorting@example.com"))
        XCTAssertTrue(loginView.isValidEmail("user@sub.example.com"))
    }

    func testInvalidEmail() {
        let loginView = LoginView(urlElements: .constant(nil))
        XCTAssertFalse(loginView.isValidEmail("test@example"))
        XCTAssertFalse(loginView.isValidEmail("test@.com"))
        XCTAssertFalse(loginView.isValidEmail("test@com"))
        XCTAssertFalse(loginView.isValidEmail("testexample.com"))
        XCTAssertFalse(loginView.isValidEmail(""))
    }
}
