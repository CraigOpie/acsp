//
//  Apple_Certified_Support_Professional_Practice_ExamUITestsLaunchTests.swift
//  Apple Certified Support Professional Practice ExamUITests
//
//  Created by Craig on 8/10/23.
//

import XCTest

final class Apple_Certified_Support_Professional_Practice_ExamUITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        // Insert steps here to perform after app launch but before taking a screenshot,
        // such as logging into a test account or navigating somewhere in the app

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
