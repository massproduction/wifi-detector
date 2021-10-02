//
//  AppDelegate.swift
//  wifi detector
//

import Cocoa
import CoreWLAN
import AppKit
import IOKit.pwr_mgt
import SystemConfiguration

func wifiChanged() {
    print("nyt vaihtui")
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var SSID = ""
    var noSleepAssertionID: IOPMAssertionID = 0
    var noSleepReturn: IOReturn? // Could probably be replaced by a boolean value, for example 'isBlockingSleep', just make sure 'IOPMAssertionRelease' do
    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)
    
    func getWifiSSID() -> String {
        let interface = CWWiFiClient.shared().interface()
        return interface?.ssid() ?? "no interface found"
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        var context = SCDynamicStoreContext(version: 0, info: nil, retain: nil, release: nil, copyDescription: nil)
        let dcAddress = withUnsafeMutablePointer(&context, {UnsafeMutablePointer<SCDynamicStoreContext>($0)})
        let store = SCDynamicStoreCreate(
            nil, "Name of your App" as CFString,
            { ( _, _, info ) in
                let mySelf = Unmanaged<AppDelegate>.fromOpaque(info!).takeUnretainedValue()
                mySelf.wifiChanged()
            }, dcAddress)!
        SCDynamicStoreSetNotificationKeys(
            store, [ "State:/Network/Global/IPv4" ] as CFArray, nil)
        SCDynamicStoreSetDispatchQueue(store, DispatchQueue.main)
        
        if let button = statusItem.button {
            button.image = NSImage(named:NSImage.Name("StatusBarButtonImage"))
        }
        constructMenu()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        enableScreenSleep()
    }
    
    func disableScreenSleep(reason: String = "Unknown reason") -> Bool? {
        guard noSleepReturn == nil else { return nil }
        noSleepReturn = IOPMAssertionCreateWithName(kIOPMAssertionTypeNoDisplaySleep as CFString,
                                                IOPMAssertionLevel(kIOPMAssertionLevelOn),
                                                reason as CFString,
                                                &noSleepAssertionID)
        return noSleepReturn == kIOReturnSuccess
    }
    
    func enableScreenSleep() -> Bool {
        if noSleepReturn != nil {
            _ = IOPMAssertionRelease(noSleepAssertionID) == kIOReturnSuccess
            noSleepReturn = nil
            return true
        }
        return false
    }
    
    @objc func saveWifiSSID(_ sender: Any?) {
        // Declare Alert message
        let msg = NSAlert()
        msg.addButton(withTitle: "OK")
        msg.addButton(withTitle: "Cancel")
        msg.messageText = "Wifi Detector"
        msg.informativeText = "Add your SSID here"
        
        let txt = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
        txt.stringValue = SSID

        msg.accessoryView = txt
        let response: NSApplication.ModalResponse = msg.runModal()

        if (response == NSApplication.ModalResponse.alertFirstButtonReturn) {
            SSID = txt.stringValue
            if (SSID == getWifiSSID()) {
                print("wtf")
                disableScreenSleep(reason: "SSID matches the current one!")
            } else {
                enableScreenSleep()
            }
        }
        
        print("SSID saved as " + SSID)
    }
    
    
    func constructMenu() {
        let menu = NSMenu()
        
        menu.addItem(NSMenuItem(title: "Add your SSID", action: #selector(AppDelegate.saveWifiSSID(_:)), keyEquivalent: "S"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit Wifi detector", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        statusItem.menu = menu
    }
    

}

