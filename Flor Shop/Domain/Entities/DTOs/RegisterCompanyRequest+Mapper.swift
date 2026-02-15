import FlorShopDTOs

extension RegisterCompanyRequest {
    init?(from registerStuff: RegisterStuffs, provider: AuthProvider, subdomain: String) {
        self = .init(
            provider: provider,
            company: registerStuff.company.toCompanyDTO(),
            subsidiary: registerStuff.subsidiary.toSubsidiaryDTO(),
            role: registerStuff.employee.role
        )
    }
}
