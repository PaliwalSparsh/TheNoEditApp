//
//  SidebarView.swift
//  theNoEditApp
//
//  Created by Sparsh Paliwal on 3/28/23.
//

import SwiftUI

struct SidebarView: View {
    var body: some View {
        List {
            Section("Volumes") {
                Label("Volume 1", systemImage: "externaldrive.fill")
                Label("Volume 2", systemImage: "externaldrive.fill")
                Text("Coming soon...")
            }
        }
    }
}

struct SidebarView_Previews: PreviewProvider {
    static var previews: some View {
        SidebarView()
    }
}
