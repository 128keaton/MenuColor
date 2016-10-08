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
	@IBOutlet weak var mode: NSSegmentedControl!
	let defaults = UserDefaults.standard
	override var windowNibName : String! {
		return "PreferencesWindow"
	}
	override func windowDidLoad() {
		super.windowDidLoad()
		self.window?.center()
		self.window?.makeKeyAndOrderFront(nil)
		NSApp.activate(ignoringOtherApps: true)
	}
	@IBAction func valueChanged(sender: NSSegmentedControl){
		switch sender.selectedSegment {
		case 0:
			defaults.set(false, forKey: "swiftColor")
			break
		case 1:
			defaults.set(true, forKey: "swiftColor")
			break
		default:
			break
		}
		defaults.synchronize()
	}
}
