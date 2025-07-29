import Foundation
import Foundation

class CompanyViewModel: ObservableObject {
    @Published var company: Company?
    @Published var subsidiary: Subsidiary?
    let companyRepository: CompanyRepository
    let subsidiaryRepository: SubsidiaryRepository
    init(companyRepository: CompanyRepository, subsidiaryRepository: SubsidiaryRepository) {
        self.companyRepository = companyRepository
        self.subsidiaryRepository = subsidiaryRepository
        /*
        self.company = companyRepository.getCompany()
        if self.company == nil {
            companyRepository.addCompany(company: Company(id: UUID(uuidString: "CO001") ?? UUID(), companyName: "Cindy", ruc: "Jarpi Menestra"))
            self.company = companyRepository.getCompany()
            if self.company == nil {
                print("Error al crear Compañia")
            }
        }
        guard let companyLocal = company else {
            print("Error al crear Subsidiaria, no hay Compañia")
            return
        }
        self.subsidiary = self.subsidiaryRepository.getSubsidiary()
        if self.subsidiary == nil {
            //Creamos una sucursal
            companyRepository.addSubsidiary(subsidiary: Subsidiary(id: UUID(uuidString: "SU001") ?? UUID(), name: "Tienda Flor", image: ImageUrl(id: UUID(uuidString: "IM001") ?? UUID(), imageUrl: "https://img.freepik.com/vector-premium/ilustracion-vector-fachada-tienda-abarrotes-escaparate-edificio-tienda-vista-frontal-fachada-tienda-dibujos-animados-plana-eps-10_505557-737.jpg?w=2000")))
            self.subsidiary = subsidiaryRepository.getSubsidiary()
            if self.subsidiary == nil {
                print("Error al crear Subsidiaria")
            }
            //Si la sucursal recien se ha creado hay que crear el primer empleado
        }
         */
    }
}
