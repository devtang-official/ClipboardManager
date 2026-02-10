//
//  ClipboardManagerApp.swift
//  ClipboardManager
//
//  Created by devtang on 2/10/26.
//

import SwiftUI

@main
struct ClipboardManagerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}
