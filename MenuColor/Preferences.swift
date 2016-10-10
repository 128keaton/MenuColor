//
//  Preferences.swift
//  MenuColor
//
//  Created by Keaton Burleson on 10/8/16.
//  Copyright © 2016 Keaton Burleson. All rights reserved.
//

import Foundation
import Cocoa
class PreferencesWindow: NSWindowController, NSWindowDelegate {
	@IBOutlet weak var mode: NSPopUpButton?
	 var delegate: PreferencesDelegate?
	let defaults = UserDefaults.standard
	override var windowNibName: String! {
		return "PreferencesWindow"
	}
	func toFront(){
			NSApp.activate(ignoringOtherApps: true)
	}

	override func windowDidLoad() {
		super.windowDidLoad()
		self.window?.center()
		self.window?.makeKeyAndOrderFront(nil)
		if defaults.object(forKey: "colorMode") == nil || defaults.object(forKey: "colorMode") as! String == ColorMode.Swift.rawValue {
			mode?.selectItem(at: 0)
		} else if defaults.object(forKey: "colorMode") as! String == ColorMode.Hex.rawValue {
			mode?.selectItem(at: 1)
		}
		mode?.action = #selector(PreferencesWindow.valueChanged(sender:))
		mode?.target = self
		print("Window loaded")

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
			defaults.set(ColorMode.Swift.rawValue, forKey: "colorMode")
			break
		case 1:
			defaults.set(ColorMode.Hex.rawValue, forKey: "colorMode")
			break
		default:
			break
		}
		defaults.synchronize()
		self.delegate?.updated()
	}
}
protocol PreferencesDelegate {
	func updated()
}
