//
//  AppDelegate.swift
//  AirConnect
//
//  Created by Connor Williams on 10/26/24.
//

import Cocoa
import Foundation
import Darwin // Import Darwin for kill function

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    var processID: pid_t?
    var statusItem: NSStatusItem!

    func applicationDidFinishLaunching(_ aNotification: Notification) {

        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "airplayaudio", accessibilityDescription: "AirConnect App")
            button.action = #selector(statusItemClicked)
        }

        // Create the menu
        let menu = NSMenu()
        let titleItem = NSMenuItem(title: "AirConnect", action: nil, keyEquivalent: "")
        titleItem.isEnabled = false // Disable interaction
        let titleColor = NSColor.systemTeal
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: titleColor,
            .font: NSFont.boldSystemFont(ofSize: 13)
        ]
        titleItem.attributedTitle = NSAttributedString(string: "AirConnect", attributes: attributes)
        menu.addItem(titleItem)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate), keyEquivalent: "q"))
        statusItem.menu = menu
        runExecutable(with: ["-Z", "&"])
    }
    @objc func statusItemClicked() {
        statusItem.menu?.popUp(positioning: nil, at: NSPoint.zero, in: nil)
    }

    func runExecutable(with arguments: [String]) {
        // Set the path to the executable
            guard let executablePath = Bundle.main.path(forResource: "Aircast", ofType: nil) else {
                print("Executable not found")
                return
            }

            let process = Process()
            process.executableURL = URL(fileURLWithPath: executablePath)
            
            // Set the arguments
            process.arguments = arguments

            // Set up input/output
            let outputPipe = Pipe()
            process.standardOutput = outputPipe

            do {
                try process.run()
                processID = process.processIdentifier
                print("Started process with PID: \(processID)")
            } catch {
                print("Failed to run executable: \(error)")
            }
            // Capture output
            outputPipe.fileHandleForReading.readabilityHandler = { handle in
                let data = handle.availableData
                if let output = String(data: data, encoding: .utf8) {
                    print(output)
                }
            }
        }
    func killProcess() {
            guard let pid = processID else {
                print("No process to kill.")
                return
            }
            
            // Kill the process using SIGTERM signal
            let result = kill(pid, SIGTERM)
            
            if result == 0 {
                print("Successfully killed process with PID: \(pid)")
            } else {
                print("Failed to kill process with PID: \(pid). Error: \(String(describing: strerror(errno)))")
            }
        }
    func applicationWillTerminate(_ aNotification: Notification) {
        killProcess()
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }


}

