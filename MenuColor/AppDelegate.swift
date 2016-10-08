//
//  AppDelegate.swift
//  MenuColor
//
//  Created by Keaton Burleson on 10/8/16.
//  Copyright © 2016 Keaton Burleson. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

	@IBOutlet var statusMenu: NSMenu!
	let statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
	@IBAction func didClickQuit(_ sender: AnyObject) {
		NSApplication.shared().terminate(self)
	}
	let screenHeight = NSHeight((NSScreen.screens()?.first?.frame)!)
	var active = false
	var currentColor: NSColor?
	var currentImage: NSImage?
	func applicationDidFinishLaunching(_ aNotification: Notification) {


		statusItem.menu = statusMenu
		statusItem.image = self.roundCorners(image: NSImage.swatchWithColor(color: NSColor.white, size: NSSize(width: 10, height: 10)), width: 10, height: 10)

		NSEvent.addGlobalMonitorForEvents(matching: NSEventMask.mouseMoved) { ( event) in
			if self.active == true {
				guard let image = self.getColor() else {
					print("Whoops, no color!")
					return
				}



				self.statusItem.view?.layer?.borderColor = NSColor.white.cgColor
				self.statusItem.view?.layer?.cornerRadius = 8

			


				self.statusItem.image = self.roundCorners(image: NSImage.swatchWithColor(color: self.currentColor!, size: NSSize(width: 10, height: 10)), width: 10, height: 10)
				self.currentImage = self.statusItem.image
				let mouseLoc = NSEvent.mouseLocation()
				let actualImage2 = NSImage(cgImage: image, size: NSSize(width: 60, height: 60))
				let cur = NSCursor.init(image: actualImage2, hotSpot: mouseLoc)
				cur.push()
				cur.pop()
			}
		}

		NSEvent.addGlobalMonitorForEvents(matching: NSEventMask.leftMouseDown) { (event) in
			if self.active == true {
				if self.currentColor != nil {
					if self.statusMenu.items.count != 6 {
						let item = NSMenuItem(title: "UIColor(red: \( self.currentColor!.redComponent.roundTo(places: 3)), green: \( self.currentColor!.greenComponent.roundTo(places: 3)), blue: \( self.currentColor!.blueComponent.roundTo(places: 3)), alpha: \(self.currentColor!.alphaComponent.roundTo(places: 3))) ", action: #selector(AppDelegate.copyToClipboard(sender:)), keyEquivalent: "color")
						item.image = self.currentImage
						self.statusMenu.insertItem(item, at: 3)

					} else {
						self.statusMenu.removeItem(at: 3)
					}
				}

				self.active = false
			}
		}
		// Insert code here to initialize your application
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
		NSColor.white.set()
		let imageFrame = NSRect(x: 0, y: 0, width: width, height: height)
		let clipPath = NSBezierPath(roundedRect: imageFrame, xRadius: xRad, yRadius: yRad)

		clipPath.windingRule = NSWindingRule.evenOddWindingRule
		clipPath.addClip()
		clipPath.appendRoundedRect(NSRect(x: 0, y: 0, width: width, height: height), xRadius: xRad, yRadius: yRad)
		clipPath.lineWidth = 2
		clipPath.stroke()

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

	func getColor() -> CGImage? {
		let mouseLoc = NSEvent.mouseLocation()



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
		print("\(displayCount) displays:")
		for i in 0..<displayCount {
			print("[\(i)] - \(activeDisplays[Int(i)])")
		}
		activeDisplays.deallocate(capacity: allocated)

		var displayID: CGDirectDisplayID = 0

		let point = CGGetDisplaysWithPoint(mouseLoc, 1, &displayID, &displayCount)

		if point != CGError.success {

		}


		guard let image = CGDisplayCreateImage(CGMainDisplayID(), rect: CGRect(x: mouseLoc.x, y: screenHeight - mouseLoc.y, width: 0, height: 0)) else {
			print("woops")
			return nil
		}
		let bitmap = NSBitmapImageRep.init(cgImage: image)

		let color = bitmap.colorAt(x: 0, y: 0)
		if color != nil {


			currentColor = color
			print("UIColor(red: \( color!.redComponent.roundTo(places: 3)), green: \( color!.greenComponent.roundTo(places: 3)), blue: \( color!.blueComponent.roundTo(places: 3)), alpha: \(color!.alphaComponent.roundTo(places: 3))) ")
		}

		return image
	}

	@IBAction func copyToClipboard(sender: NSMenuItem) {
		let pasteboard = NSPasteboard.general()
		pasteboard.clearContents()
		pasteboard.writeObjects([sender.title as NSPasteboardWriting])
	}

	func applicationWillTerminate(_ aNotification: Notification) {
		// Insert code here to tear down your application
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
	func roundTo(places:Int) -> CGFloat {
		let divisor = pow(10.0, CGFloat(places))
		return (self * divisor).rounded() / divisor
	}
}
