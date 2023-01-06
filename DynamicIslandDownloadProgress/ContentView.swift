//
//  ContentView.swift
//  DynamicIslandDownloadProgress
//
//  Created by Abdullah Karaboğa on 5.01.2023.
//

import SwiftUI

struct ContentView: View {
    var body: some View {

        Home()
    }

}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
