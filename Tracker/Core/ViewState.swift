//
//  ViewState.swift
//  Tracker
//

import Foundation

enum ViewState<T> {
    case idle
    case loading
    case success(T)
    case error(String)
}

extension ViewState {
    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }
}
