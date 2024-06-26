//
//  OnboardingView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 06.09.2023.
//  https://www.avanderlee.com/swiftui/dynamic-pager-view-onboarding/

import SwiftUI
import FirebaseAnalytics

struct OnboardingView: View {
    
    @Environment(\.dismiss)
    var dismiss
    
    @Environment(\.openWindow)
    var openWindow
    
    @State private var currentPage: OnboardingPage = .welcome
    private let pages: [OnboardingPage]
    
    @AppStorage(DefaultsKeys.showOverview)
    var showOverview: Bool = true
    
    @State private var isNextPage: Bool = true
    
    init(pages: [OnboardingPage]) {
        self.pages = pages
    }
    
    var body: some View {
        VStack {
            ForEach(pages, id: \.self) { page in
                if page == currentPage {
                    page.view(action: showNextPage)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .transition(
                            isNextPage ? transition(for: .next) : transition(for: .previews)
                        )
                        .animation(.default, value: pages)
                }
            }
            
            HStack {
                ForEach(pages, id: \.self) { page in
                    Button {
                        withAnimation {
                            isNextPage = isNextPage(nextPage: page)
                            currentPage = page
                        }
                    } label: {
                        Capsule()
                            .fill(page == currentPage ? .purple : .gray)
                            .frame(width: AppGrid.pt8, height: AppGrid.pt8)
                    }
                    .buttonStyle(.plain)
                }
            }
            
            if currentPage.shouldShowNextButton {
                Button(action: showNextPage, label: {
                    Text("Next")
                        .fontWeight(.semibold)
                        .padding(.horizontal, AppGrid.pt16)
                        .frame(width: AppGrid.pt128, height: AppGrid.pt32)
                        .foregroundColor(.white)
                        .background(.purple)
                        .cornerRadius(AppGrid.pt24)
                })
                .keyboardShortcut(.defaultAction)
                .buttonStyle(.plain)
                .padding()
                .padding(.bottom, AppGrid.pt64)
                .transition(.opacity)
                .animation(.default, value: pages)
            } else {
                Button(action: closeWindow, label: {
                    Text("Get started")
                        .fontWeight(.semibold)
                        .padding(.horizontal, AppGrid.pt16)
                        .frame(width: AppGrid.pt128, height: AppGrid.pt32)
                        .foregroundColor(.white)
                        .background(.purple)
                        .cornerRadius(AppGrid.pt24)
                })
                .keyboardShortcut(.defaultAction)
                .buttonStyle(.plain)
                .padding()
                .padding(.bottom, AppGrid.pt64)
                .transition(.opacity)
                .animation(.default, value: pages)
            }
        }
        .onAppear {
            self.currentPage = pages.first!
        }
        .analyticsScreen(name: "\(type(of: self))")
    }
    
    private func closeWindow() {
        dismiss()
        showOverview = false
    }
    
    private func showNextPage() {
        isNextPage = true
        guard
            let currentIndex = pages.firstIndex(of: currentPage),
            pages.count > currentIndex + 1
        else {
            return
        }
        withAnimation {
            currentPage = pages[currentIndex + 1]
        }
    }
    
    private func showPreviewsPage() {
        guard
            let currentIndex = pages.firstIndex(of: currentPage),
            currentIndex - 1 >= .zero
        else {
            return
        }
        withAnimation {
            currentPage = pages[currentIndex - 1]
        }
    }
    
    private func isNextPage(nextPage: OnboardingPage) -> Bool {
        guard
            let nextIndex = pages.firstIndex(of: nextPage),
            let currentIndex = pages.firstIndex(of: currentPage)
        else { return true }
        return nextIndex > currentIndex
    }
    
    private func transition(for transition: TransitionPage) -> AnyTransition {
        switch transition {
        case .next:
            return .asymmetric(
                insertion: .move(edge: .trailing),
                removal: .move(edge: .leading)
            )
        case .previews:
            return .asymmetric(
                insertion: .move(edge: .leading),
                removal: .move(edge: .trailing)
            )
        }
    }
    
    enum TransitionPage {
        case previews, next
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(pages: [.welcome, .interface, .importVideo, .grab, .importImage])
    }
}
