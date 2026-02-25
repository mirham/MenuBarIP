//
//  FixedSidebarTabView.swift
//  MenuBarIP
//
//  Created by UglyGeorge on 25.02.2026.
//

import SwiftUI

struct FixedSidebarTabView: View {
    @State private var selectedTab = 0
    let tabs: [TabItem]
    
    struct TabItem {
        let title: String
        let icon: String
        let view: AnyView
        
        init(title: String, icon: String = "folder", @ViewBuilder content: () -> some View) {
            self.title = title
            self.icon = icon
            self.view = AnyView(content())
        }
    }
    
    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 2) {
                List(selection: $selectedTab) {
                    Section {
                        ForEach(0..<tabs.count, id: \.self) { index in
                            HStack {
                                Image(systemName: tabs[index].icon)
                                    .frame(width: 24)
                                    .foregroundColor(.accentColor)
                                Text(tabs[index].title)
                                    .font(.body)
                                Spacer()
                            }
                            .tag(index)
                            .padding(.vertical, 6)
                            .padding(.horizontal, 4)
                        }
                    }
                }
                .listStyle(.sidebar)
                .scrollContentBackground(.hidden)
                .scrollDisabled(true)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(NSColor.separatorColor), lineWidth: 1)
            )
            .padding(.leading, 10)
            .padding(.bottom, 10)
            .frame(minWidth: 200, maxWidth: 200)
            .layoutPriority(0)
            
            VStack(spacing: 0) {
                HStack {
                    Text(tabs[selectedTab].title.uppercased())
                        .font(.title3)
                        .opacity(0.6)
                }
                .padding(.horizontal)
                .padding(.vertical, 6)
                
                tabs[selectedTab].view
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(minWidth: 400)
            .layoutPriority(1)
        }
    }
}

@resultBuilder
struct FixedSidebarTabBuilder {
    static func buildBlock(_ components: FixedSidebarTabView.TabItem...) -> [FixedSidebarTabView.TabItem] {
        components
    }
}

extension FixedSidebarTabView {
    init(@FixedSidebarTabBuilder _ content: () -> [TabItem]) {
        self.tabs = content()
    }
}
