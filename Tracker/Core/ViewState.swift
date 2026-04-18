import Foundation

enum ViewState<Value> {
    case idle
    case loading
    case success(Value)
    case failure(String)
}

extension ViewState {
    var isLoading: Bool {
        if case .loading = self {
            return true
        }
        return false
    }
}
