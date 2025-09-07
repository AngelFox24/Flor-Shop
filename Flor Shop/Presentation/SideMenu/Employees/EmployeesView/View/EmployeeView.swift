import SwiftUI
import AVFoundation

struct EmployeeView: View {
    @State var employeeViewModel: EmployeeViewModel
    @Binding var showMenu: Bool
    init(ses: SessionContainer, showMenu: Binding<Bool>) {
        employeeViewModel = EmployeeViewModelFactory.getEmployeeViewModel(sessionContainer: ses)
        self._showMenu = showMenu
    }
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
//                ProductSearchTopBar(showMenu: $showMenu, productViewModel: $pro)
                EmployeeListController(employeeViewModel: $employeeViewModel)
            }
            .onAppear {
                employeeViewModel.lazyFetchList()
            }
        }
    }
}

#Preview {
    EmployeeView(ses: SessionContainer.preview, showMenu: .constant(false))
}

struct EmployeeListController: View {
    @Binding var employeeViewModel: EmployeeViewModel
    var body: some View {
        VStack(spacing: 0) {
            if employeeViewModel.employeeList.count == 0 {
                VStack {
                    Image("groundhog_finding")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 300, height: 300)
                    Text("No hay empleados aún.")
                        .foregroundColor(.black)
                        .padding(.horizontal, 20)
                        .font(.custom("Artifika-Regular", size: 18))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
            List {
                ForEach(employeeViewModel.employeeList) { employee in
                    let _ = print("Empleado: \(employee.name)")
                    CardViewTipe1(image: employee.image, topStatusColor: .green, topStatus: employee.role, mainText: employee.name + " " + employee.lastName, secondaryText: "Falta", size: 80)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
                    .listRowBackground(Color("color_background"))
                }
            }
            .listStyle(PlainListStyle())
            }
        }
        .padding(.horizontal, 10)
        .background(Color("color_background"))
    }
}

