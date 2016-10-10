//
//  MenuController.swift
//  MenuColor
//
//  Created by Keaton Burleson on 10/10/16.
//  Copyright © 2016 Keaton Burleson. All rights reserved.
//

import Foundation
import Cocoa
class MenuController: NSObject, PreferencesDelegate {
	

	@IBOutlet var statusMenu: NSMenu!
	
	var preferencesWindow: PreferencesWindow!
	let statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)

	let screenHeight = NSHeight((NSScreen.screens()?.first?.frame)!)
	var active = false
	var currentColor: NSColor?
	var currentImage: NSImage?


	var history = [[String: AnyObject]]()
	var mode: ColorMode!


	override func awakeFromNib() {
		preferencesWindow = PreferencesWindow()
		preferencesWindow.delegate = self

		statusItem.menu = statusMenu
		statusItem.image = self.roundCorners(image: NSImage.swatchWithColor(color: NSColor.white, size: NSSize(width: 10, height: 10)), width: 10, height: 10)
		statusItem.image?.isTemplate = true
		setupLoop()

		guard let colorMode = UserDefaults.standard.object(forKey: "colorMode")
			else {
			mode = ColorMode.Swift
			return
		}
		mode = ColorMode(rawValue: colorMode as! String)

	}
	
	@IBAction func didClickQuit(_ sender: AnyObject) {
		NSApplication.shared().terminate(self)
	}
	@IBAction func settings(_ sender: AnyObject) {
		print("open settings")
		preferencesWindow.window?.makeKeyAndOrderFront(self)
		preferencesWindow.toFront()
	}
	
	
	func updated() {
		let colorMode = UserDefaults.standard.object(forKey: "colorMode") as! String
		print("Updated: " + colorMode)
		self.mode = ColorMode(rawValue: colorMode)

		self.rewriteHistory()
	}
	
	
	func setupLoop() {

		NSEvent.addGlobalMonitorForEvents(matching: NSEventMask.mouseMoved) { (event) in

			let mouseLoc = NSEvent.mouseLocation()
			if self.active == true {
				self.getColor(point: mouseLoc)

				self.statusItem.view?.layer?.borderColor = NSColor.black.cgColor
				self.statusItem.view?.layer?.borderWidth = 4
				self.statusItem.view?.layer?.cornerRadius = 8


				self.statusItem.image =  self.roundCorners(image: NSImage.swatchWithColor(color: self.currentColor!, size: NSSize(width: 10, height: 10)), width: 10, height: 10)
				self.currentImage = self.statusItem.image


			}
		}


		NSEvent.addGlobalMonitorForEvents(matching: NSEventMask.leftMouseDown) { (event) in
			if self.active == true {
				guard let color = self.currentColor
					else {

					return
				}
				if self.history.count > 4 {
					self.history.removeLast()
				}


				self.history.append(["color": color, "mode": self.mode as AnyObject])


				self.refreshHistory()
				self.active = false
			}
		}


	}


	



	func rewriteHistory() {


		//Why Apple doesn't let me iterate and remove I have no idea, but this works..
			for item in self.statusMenu.items {
				if item.image != nil {
					self.statusMenu.removeItem(item)
				}
			}

		refreshHistory()
	}
	func refreshHistory() {
		print("refreshing history \(self.history.count)")
		

		var newItem: NSMenuItem?

		for item in history {
			guard let color = item["color"] as? NSColor
				else {
				print("No color value \(item)")
				return
			}
			if self.mode == ColorMode.Swift {
				let colorFormatted = self.getUIColor(color: color)
				newItem = NSMenuItem(title: colorFormatted, action: #selector(MenuController.copyToClipboard(sender:)), keyEquivalent: "color")
				
				newItem?.image = NSImage.swatchWithColor(color: color, size: NSSize(width: 10, height: 10))
				print("Swift mode")
			} else if self.mode == ColorMode.Hex {
				let colorFormatted = self.getHex(color: color)
				newItem = NSMenuItem(title: colorFormatted, action: #selector(MenuController.copyToClipboard(sender:)), keyEquivalent: "color")
				newItem?.image = NSImage.swatchWithColor(color: color, size: NSSize(width: 10, height: 10))

			}
			if newItem != nil {
				newItem?.action = #selector(MenuController.copyToClipboard(sender:))
				newItem?.isEnabled = true
				newItem?.target = self
				self.statusMenu.addItem(newItem!)
			}
		}
	


	}

	func roundCorners(image: NSImage, width: CGFloat = 192, height: CGFloat = 192) -> NSImage {
		let xRad = width / 2
		let yRad = height / 2
		let existing = image
		let esize = existing.size
		let newSize = NSMakeSize(esize.width, esize.height)
		let composedImage = NSImage(size: newSize)

		composedImage.lockFocus()
		let ctx = NSGraphicsContext.current()
		ctx?.imageInterpolation = NSImageInterpolation.high
		NSColor.gray.setStroke()
		currentColor?.setFill()
		
		let imageFrame = NSRect(x: 0, y: 0, width: width, height: height)
		let clipPath = NSBezierPath(roundedRect: imageFrame, xRadius: xRad, yRadius: yRad)
		clipPath.windingRule = NSWindingRule.evenOddWindingRule
		clipPath.lineWidth = 10
		clipPath.addClip()
		clipPath.stroke()
		
		clipPath.appendRoundedRect(NSRect(x: 0, y: 0, width: width, height: height), xRadius: xRad, yRadius: yRad)




		let rect = NSRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
		image.draw(at: NSZeroPoint, from: rect, operation: NSCompositingOperation.sourceOver, fraction: 1)
		composedImage.unlockFocus()

		return composedImage
	}


	@IBAction func setActive(sender: NSMenuItem) {
		if active == false {
			let cur = NSCursor.crosshair()
			cur.push()
			cur.pop()
			active = true
		}
	}

	func getColor(point: NSPoint) {
		let mouseLoc = point



		var displayCount: UInt32 = 0;
		var result = CGGetActiveDisplayList(0, nil, &displayCount)
		if (result != .success) {
			print("error: \(result)")

		}

		let allocated = Int(displayCount)
		let activeDisplays = UnsafeMutablePointer<CGDirectDisplayID>.allocate(capacity: allocated)
		result = CGGetActiveDisplayList(displayCount, activeDisplays, &displayCount)
		if (result != .success) {
			print("error: \(result)")

		}

		activeDisplays.deallocate(capacity: allocated)

		var displayID: CGDirectDisplayID = 0

		let point = CGGetDisplaysWithPoint(mouseLoc, 1, &displayID, &displayCount)

		if point != CGError.success {

		}


		guard let image = CGDisplayCreateImage(CGMainDisplayID(), rect: CGRect(x: mouseLoc.x, y: screenHeight - mouseLoc.y, width: 1, height: 1)) else {
			print("woops")
			return
		}
		let bitmap = NSBitmapImageRep.init(cgImage: image)

		let color = bitmap.colorAt(x: 0, y: 0)
		if color != nil {
			currentColor = color



		} else {
			print("Color is invalid")
		}


	}

	@IBAction func copyToClipboard(sender: NSMenuItem) {
		let pasteboard = NSPasteboard.general()
		pasteboard.clearContents()
		pasteboard.writeObjects([sender.title as NSPasteboardWriting])
	}

	func getAppropriateString(color: NSColor) -> String {
		if (UserDefaults.standard.object(forKey: "colorMode") == nil) || UserDefaults.standard.object(forKey: "colorMode") as! String == ColorMode.Swift.rawValue {
			return self.getUIColor(color: color)
		} else if UserDefaults.standard.object(forKey: "colorMode") as! String == ColorMode.Hex.rawValue {
			return self.getHex(color: color)
		}
		return "Error"
	}
	func getHex(color: NSColor) -> String {
		return color.hexadecimalValue()
	}
	func getUIColor(color: NSColor) -> String {
		return "UIColor(red: \( color.redComponent.roundTo(places: 3)), green: \( color.greenComponent.roundTo(places: 3)), blue: \( color.blueComponent.roundTo(places: 3)), alpha: \(color.alphaComponent.roundTo(places: 3))) "
	}


}

extension NSImage {
	class func swatchWithColor(color: NSColor, size: NSSize) -> NSImage {
		let image = NSImage(size: size)
		image.lockFocus()
		color.drawSwatch(in: NSMakeRect(0, 0, size.width, size.height))
		image.unlockFocus()
		return image
	}
}
extension CGFloat {
	/// Rounds the double to decimal places value
	func roundTo(places: Int) -> CGFloat {
		let divisor = pow(10.0, CGFloat(places))
		return (self * divisor).rounded() / divisor
	}
}

