//
//  LaunchArguments.swift
//  Satchi
//
//  Created by carl-johan.svedin on 2021-10-16.
//

import Foundation

class LaunchArguments {
    static var shared = LaunchArguments()

    lazy var testingEnabled: Bool = {
        let arguments = ProcessInfo.processInfo.arguments
        var enabled = false
        for index in 0..<arguments.count - 1 where arguments[index] == "-CDCKDTesting" {
            enabled = arguments.count >= (index + 1) ? arguments[index + 1] == "1" : false
            break
        }
        return enabled
    }()

    lazy var allowCloudKitSync: Bool = {
        let arguments = ProcessInfo.processInfo.arguments
        var allow = true
        for index in 0..<arguments.count - 1 where arguments[index] == "-CDCKDAllowCloudKitSync" {
            allow = arguments.count >= (index + 1) ? arguments[index + 1] == "1" : true
            break
        }
        return allow
    }()

    private init() {

    }

}
