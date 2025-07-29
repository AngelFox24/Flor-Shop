import SwiftUI

/// A type that can serve as a navigation destination.
public protocol SimpleDestinationType: Hashable {
}
/// A type that can serve as a navigation destination.
public protocol DestinationType: Hashable {
  /// Creates a destination from a URL path component with full path context and query parameters
  /// - Parameters:
  ///   - path: The current URL path component
  ///   - fullPath: The complete array of path components for context
  ///   - parameters: Query parameters from the URL
  /// - Returns: A destination instance if the path matches, nil otherwise
  static func from(path: String, fullPath: [String], parameters: [String: String]) -> Self?
}

/// A type that can be presented as a sheet.
public protocol SheetType: Hashable, Identifiable {}

/// A type that can be presented as a sheet.
public protocol AlertType: Hashable, Identifiable {}

/// A type that can be presented as a flow.
public protocol FlowType: Hashable, Identifiable {
}

/// A type that can be presented as a flow.
public protocol SubFlowType: Hashable {
}

/// A type that can serve as a tab in a tab-based navigation system.
/// Only needed when using the full Router<Tab, Destination, Sheet> for tab-based navigation.
public protocol TabType: Hashable, CaseIterable, Identifiable, Sendable {
  /// The icon name (SF Symbol) for this tab
  var icon: String { get }
}
