import FlorShopDTOs

extension RegisterCompanyRequest {
    init?(from registerStuff: RegisterStuffs, provider: AuthProvider, role: UserSubsidiaryRole) {
        self = .init(
            company: registerStuff.company.toCompanyDTO(),
            subsidiary: registerStuff.subsidiary.toSubsidiaryDTO(),
            role: role
        )
    }
}
