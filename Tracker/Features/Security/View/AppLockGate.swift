//
//  AppLockGate.swift
//  Tracker
//

import SwiftUI

struct AppLockGate<Content: View>: View {
    @StateObject private var viewModel: AppLockViewModel
    @Environment(\.scenePhase) private var scenePhase
    let content: () -> Content

    init(
        viewModel: @autoclosure @escaping () -> AppLockViewModel,
        @ViewBuilder content: @escaping () -> Content
    ) {
        _viewModel = StateObject(wrappedValue: viewModel())
        self.content = content
    }

    var body: some View {
        ZStack {
            content()

            if viewModel.state != .unlocked && viewModel.isEnabled {
                lockCover
            }
        }
        .onChange(of: scenePhase) { _, phase in
            switch phase {
            case .background, .inactive:
                viewModel.didEnterBackground()
            case .active:
                viewModel.didBecomeActive()
                if case .locked = viewModel.state {
                    Task { await viewModel.authenticate() }
                }
            @unknown default:
                break
            }
        }
    }

    private var lockCover: some View {
        VStack(spacing: Theme.Spacing.l) {
            Image(systemName: "lock.shield")
                .font(.system(size: 56))
                .foregroundStyle(Theme.Palette.accent)
            Text("Tracker is locked")
                .font(.title3.weight(.semibold))
            if case .failed(let message) = viewModel.state {
                Text(message)
                    .font(.footnote)
                    .foregroundStyle(Theme.Palette.subtleText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Theme.Spacing.l)
            }
            Button {
                Task { await viewModel.authenticate() }
            } label: {
                Label("Unlock", systemImage: "faceid")
                    .font(.body.weight(.semibold))
                    .padding(.horizontal, Theme.Spacing.l)
                    .padding(.vertical, Theme.Spacing.s + 4)
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.state == .authenticating)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.Palette.background.ignoresSafeArea())
    }
}
