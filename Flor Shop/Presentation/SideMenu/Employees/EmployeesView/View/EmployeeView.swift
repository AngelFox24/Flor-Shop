import SwiftUI
import AVFoundation

struct EmployeeView: View {
    @State var employeeViewModel: EmployeeViewModel
    let showMenu: () -> Void
    init(ses: SessionContainer, showMenu: @escaping () -> Void) {
        employeeViewModel = EmployeeViewModelFactory.getEmployeeViewModel(sessionContainer: ses)
        self.showMenu = showMenu
    }
    var body: some View {
        //                ProductSearchTopBar(showMenu: $showMenu, productViewModel: $pro)
        EmployeeListController(employeeViewModel: $employeeViewModel)
            .navigationTitle("Empleados")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $employeeViewModel.searchText, placement: .toolbar)
            .searchToolbarBehavior(.minimize)
            .toolbar {
                LogoToolBar(action: showMenu)
//                ProductTopToolbar(productViewModel: $productViewModel, badge: nil)
                MainBottomToolbar(destination: .addEmployee)
            }
            .onAppear {
                employeeViewModel.lazyFetchList()
            }
    }
}

#Preview {
    EmployeeView(ses: SessionContainer.preview, showMenu: {})
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
                        CardViewTipe1(
                            imageUrl: employee.imageUrl,
                            topStatusColor: .green,
                            topStatus: "Falta de estatus",
                            mainText: employee.name + " " + (employee.lastName ?? ""),
                            secondaryText: "Falta",
                            size: 80
                        )
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
                        .listRowBackground(Color.background)
                    }
                }
                .scrollIndicators(ScrollIndicatorVisibility.hidden)
                .listStyle(PlainListStyle())
            }
        }
        .padding(.horizontal, 10)
    }
}

