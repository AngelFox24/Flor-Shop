import SwiftUI

extension Customer {
    var secondaryIndicator: String? {
        guard !self.isDateLimitActive else { return nil }
        guard let dateLimit else { return nil }
        return dateLimit.formatted(.dateTime.day())
    }
    var secondaryIndicatorSuffix: String? {
        guard !self.isDateLimitActive else { return nil }
        guard let dateLimit else { return nil }
        return dateLimit.formatted(.dateTime.month(.abbreviated))
    }
    var mainText: String {
        if let lastName {
            return "\(self.name) \(lastName)"
        } else {
            return self.name
        }
    }
}
