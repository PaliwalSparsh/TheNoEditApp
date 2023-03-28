//
//  theNoEditAppApp.swift
//  theNoEditApp
//
//  Created by Sparsh Paliwal on 3/27/23.
//

import SwiftUI

@main
struct theNoEditAppApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                SidebarView()
                ContentView()
                    .frame(minWidth: 400, minHeight: 400)
            }
        }
    }
}
