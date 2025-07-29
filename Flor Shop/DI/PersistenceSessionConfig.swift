import Foundation

@Observable
class PersistenceSessionConfig {
    var serverURL: URL? {
        didSet {
            UserDefaults.standard.set(serverURL?.absoluteString, forKey: "serverURL")
        }
    }
    
    var companyId: UUID? {
        didSet {
            UserDefaults.standard.set(companyId?.uuidString, forKey: "companyId")
        }
    }

    var subsidiaryId: UUID? {
        didSet {
            UserDefaults.standard.set(subsidiaryId?.uuidString, forKey: "subsidiaryId")
        }
    }

    var employeeId: UUID? {
        didSet {
            UserDefaults.standard.set(employeeId?.uuidString, forKey: "employeeId")
        }
    }
    
    var session: SessionConfig? {
        guard let companyId, let subsidiaryId, let employeeId else { return nil }
        return SessionConfig(companyId: companyId, subsidiaryId: subsidiaryId, employeeId: employeeId)
    }

    init() {
        if let urlString = UserDefaults.standard.string(forKey: "serverURL") {
            self.serverURL = URL(string: urlString)
        }
        if let compId = UserDefaults.standard.string(forKey: "companyId") {
            self.companyId = UUID(uuidString: compId)
        }
        if let subId = UserDefaults.standard.string(forKey: "subsidiaryId") {
            self.subsidiaryId = UUID(uuidString: subId)
        }
        if let empId = UserDefaults.standard.string(forKey: "employeeId") {
            self.employeeId = UUID(uuidString: empId)
        }
    }
    
    func fromSession(_ session: SessionConfig) {
        self.companyId = session.companyId
        self.subsidiaryId = session.subsidiaryId
        self.employeeId = session.employeeId
    }
}
