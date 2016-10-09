//
//  Preferences.swift
//  MenuColor
//
//  Created by Keaton Burleson on 10/8/16.
//  Copyright © 2016 Keaton Burleson. All rights reserved.
//

import Foundation
import Cocoa
class PreferencesWindow: NSWindowController {
	@IBOutlet weak var mode: NSPopUpButton?
	let defaults = UserDefaults.standard
	override var windowNibName: String! {
		return "PreferencesWindow"
	}

	override func windowDidLoad() {
		super.windowDidLoad()
		self.window?.center()
		self.window?.makeKeyAndOrderFront(nil)
		if defaults.object(forKey: "swiftColor") == nil || defaults.bool(forKey: "swiftColor") == true {
			mode?.selectItem(at: 0)
		} else {
			mode?.selectItem(at: 2)
		}

		NSApp.activate(ignoringOtherApps: true)
	}

	@IBAction func goToGithub(sender: NSButton) {
		let url = NSURL(string: "https://github.com/128keaton/MenuColor/issues/new")!
		let browserBundleIdentifier = "com.apple.Safari"

		NSWorkspace.shared().open([url as URL],
		                          withAppBundleIdentifier: browserBundleIdentifier,
		                          options: [],
		                          additionalEventParamDescriptor: nil,
		                          launchIdentifiers: nil)
	}
	@IBAction func goToMyWebsite(sender: NSButton) {
		let url = NSURL(string: "http://128keaton.com")!
		let browserBundleIdentifier = "com.apple.Safari"

		NSWorkspace.shared().open([url as URL],
		                          withAppBundleIdentifier: browserBundleIdentifier,
		                          options: [],
		                          additionalEventParamDescriptor: nil,
		                          launchIdentifiers: nil)
	}
	@IBAction func valueChanged(sender: NSPopUpButton) {

		switch sender.index(of: sender.selectedItem!) {
		case 0:
			defaults.set(true, forKey: "swiftColor")
			break
		case 1:
			defaults.set(false, forKey: "swiftColor")
			break
		default:
			break
		}
		defaults.synchronize()
	}
}
