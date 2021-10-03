//
//  AppDelegate.swift
//  wifi detector
//

import Cocoa
import CoreWLAN
import AppKit
import IOKit.pwr_mgt

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var loopRunning = false
    var assertionID: IOPMAssertionID = 0
    var sleepDisabled = false
    var timer: Timer?
    var SSID = ""

    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        if (!loopRunning) {
            startLoop()
        }
        if let button = statusItem.button {
            button.image = NSImage(named:NSImage.Name("StatusBarButtonImage"))
        }
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(AppDelegate.sleepListener(_:)), name: NSWorkspace.willSleepNotification, object: nil)
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(AppDelegate.wakeUpListener(_:)), name: NSWorkspace.didWakeNotification, object: nil)
        constructMenu()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        loopRunning = false
    }
    
    @objc func sleepListener(_ aNotification : NSNotification) {
        stopLoop()
        print("Sleep Listening");
    }

    @objc func wakeUpListener(_ aNotification : NSNotification) {
        startLoop()
        print("Wake Up Listening");
    }
    
    @objc func saveWifiSSID(_ sender: Any?) {
        // Declare Alert message
        let msg = NSAlert()
        msg.addButton(withTitle: "OK")
        msg.addButton(withTitle: "Cancel"   )
        msg.messageText = "Wifi Detector"
        msg.informativeText = "Add your SSID here"
        
        let txt = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
        txt.stringValue = SSID

        msg.accessoryView = txt
        let response: NSApplication.ModalResponse = msg.runModal()

        if (response == NSApplication.ModalResponse.alertFirstButtonReturn) {
            SSID = txt.stringValue
            if (SSID == getWifiSSID()) {
                print("SSID matches the current one!")
            }
        }
        
        print("SSID saved as " + SSID)
    }
    
    func getWifiSSID() -> String {
        let interface = CWWiFiClient.shared().interface()
        return interface?.ssid() ?? "no interface found"
    }
    
    
    func constructMenu() {
        let menu = NSMenu()
        
        menu.addItem(NSMenuItem(title: "Add your SSID", action: #selector(AppDelegate.saveWifiSSID(_:)), keyEquivalent: "S"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit Wifi detector", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        statusItem.menu = menu
    }
    
    func startLoop() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if (self.SSID == self.getWifiSSID()) {
                print("SSID matches the current one!")
                self.disableScreenSleep()
            } else {
                print("SSID does not match the current one!")
                self.enableScreenSleep()
            }
        }
        self.loopRunning = true
    }
    
    func stopLoop() {
        timer?.invalidate()
        timer = nil
    }
    
    
    func disableScreenSleep(reason: String = "Disabling Screen Sleep") {
        if !sleepDisabled {
            sleepDisabled = IOPMAssertionCreateWithName(kIOPMAssertionTypeNoDisplaySleep as CFString, IOPMAssertionLevel(kIOPMAssertionLevelOn), reason as CFString, &assertionID) == kIOReturnSuccess
        }

    }
    func enableScreenSleep() {
        if sleepDisabled {
            IOPMAssertionRelease(assertionID)
            sleepDisabled = false
        }

    }
    
    
}

