//
//  ConferencesApp.swift
//  Conferences
//
//  Created by Binns, Oliver on 04/01/2023.
//

import SwiftUI

@main
struct ConferencesApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            TabView {
                NavigationView {
                    ConferenceList()
                        .navigationTitle("Conferences")
                }
                .tabItem {
                    Label("Conferences", systemImage: "airplane.departure")
                }
                
                NavigationView {
                    IdeasList()
                        .navigationTitle("Brainstorm")
                }
                .tabItem {
                    Label("Brainstorm", systemImage: "lightbulb.fill")
                }
            }
            .environment(\.managedObjectContext,
                          persistenceController.container.viewContext)
            .onAppear {
                let encoder = JSONEncoder()
                encoder.dateEncodingStrategy = .iso8601
                let data = try! encoder.encode(Conference.all)
                print(String(data: data, encoding: .utf8)!)
            }
        }
    }
}
