//
//  NewSwiftUIApp.swift
//  NewSwiftUI
//
//  Created by Kesava P on 5/28/24.
//

import SwiftUI
import Singular

@main
struct NewSwiftUIApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @State private var openURL: URL?
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    openURL = url
                    // Initialize Singular from an openURL
                    if let config = self.getConfig() {
                        config.openUrl = url
                        Singular.start(config)
                    }
                }
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Deep Link Information"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }
        }
        .onChange(of: scenePhase) { newPhase in
            // The SwiftUI ScenePhases replaces the old SceneDelegate lifecycle events
            switch newPhase {
            case .background:
                print("App Scene: backgrounded")
            case .inactive:
                print("App Scene: inactive")
            case .active:
                print("App Scene: active")
                
                // Initialize Singular
                if let config = self.getConfig() {
                    Singular.start(config)
                }
            @unknown default:
                print("App Scene: unknown")
            }
        }
    }

    private func getConfig() -> SingularConfig? {
        // Create the config object with the SDK Key and SDK Secret
        guard let config = SingularConfig(apiKey: "YourSdkKey", andSecret: "YourSdkSecret") else {
            return nil
        }
        
        // Set a 300 sec delay before initialization to wait for the user's ATT response
        // Remove this if you are not displaying an ATT prompt!
        //config.waitForTrackingAuthorizationWithTimeoutInterval = 300
        
        config.singularLinksHandler = { params in
            self.handleDeeplink(params: params)
        }
        return config
    }

    private func handleDeeplink(params: SingularLinkParams?) {
        // Get Deeplink data from Singular Link
        let deeplink = params?.getDeepLink()
        let passthrough = params?.getPassthrough()
        let isDeferredDeeplink = params?.isDeferred()
        let urlParams = params?.getUrlParameters()
        
        // Add deep link handling code here
        print("Deeplink: \(deeplink ?? "none")")
        print("Passthrough: \(passthrough ?? "none")")
        print("Is Deferred Deeplink: \(isDeferredDeeplink ?? false)")
        print("URL Parameters: \(urlParams ?? [:])")
        
        // Prepare the alert message with deep link details
        alertMessage = """
        Deeplink: \(deeplink ?? "none")
        Passthrough: \(passthrough ?? "none")
        Is Deferred Deeplink: \(isDeferredDeeplink ?? false)
        URL Parameters: \(urlParams ?? [:])
        """
        
        // Show the alert
        showAlert = true
        
        // Additional deep link handling code...
    }
}
