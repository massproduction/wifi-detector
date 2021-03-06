//
//  AppDelegate.swift
//  wifi detector
//

import Cocoa
import CoreWLAN
import AppKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var SSID = ""

    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        if let button = statusItem.button {
            button.image = NSImage(named:NSImage.Name("StatusBarButtonImage"))
        }
        constructMenu()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
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
    

}

