//
//  SalesTopBar.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 10/02/24.
//

import SwiftUI

struct SalesTopBar: View {
    @EnvironmentObject var salesCoreDataViewModel: SalesViewModel
    @Binding var showMenu: Bool
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 10, content: {
//                Button(action: {
//                    withAnimation(.spring()){
//                        isShowMenu.toggle()
//                    }
//                }, label: {
//                    HStack {
//                        Image("logo")
//                            .resizable()
//                            .scaledToFit()
//                    }
//                    .background(Color("colorlaunchbackground"))
//                    .cornerRadius(10)
//                    .frame(width: 40, height: 40)
//                })
                CustomButton5(showMenu: $showMenu)
                HStack(spacing: 0, content: {
                    HStack(spacing: 0, content: {
                        Text(SalesDateInterval.diary.description)
                            .padding(.vertical, 10)
                            .font(.custom("Artifika-Regular", size: 16))
                            .foregroundColor(salesCoreDataViewModel.salesDateInterval == .diary ? Color.white : Color("color_primary"))
                            .frame(maxWidth: .infinity, alignment: .center)
                    })
                    .background(salesCoreDataViewModel.salesDateInterval == .diary ? Color("color_accent") : Color.clear)
                    .cornerRadius(15)
                    .onTapGesture {
                        salesCoreDataViewModel.salesDateInterval = .diary
                        salesCoreDataViewModel.updateAmountsBar()
                        salesCoreDataViewModel.fetchSalesDetailsList()
                    }
                    HStack(spacing: 0, content: {
                        Text(SalesDateInterval.monthly.description)
                            .padding(.vertical, 10)
                            .font(.custom("Artifika-Regular", size: 16))
                            .foregroundColor(salesCoreDataViewModel.salesDateInterval == .monthly ? Color.white : Color("color_primary"))
                            .frame(maxWidth: .infinity, alignment: .center)
                    })
                    .background(salesCoreDataViewModel.salesDateInterval == .monthly ? Color("color_accent") : Color.clear)
                    .cornerRadius(15)
                    .onTapGesture {
                        salesCoreDataViewModel.salesDateInterval = .monthly
                        salesCoreDataViewModel.updateAmountsBar()
                        salesCoreDataViewModel.fetchSalesDetailsList()
                    }
                    HStack(spacing: 0, content: {
                        Text(SalesDateInterval.yearly.description)
                            .padding(.vertical, 10)
                            .font(.custom("Artifika-Regular", size: 16))
                            .foregroundColor(salesCoreDataViewModel.salesDateInterval == .yearly ? Color.white : Color("color_primary"))
                            .frame(maxWidth: .infinity, alignment: .center)
                    })
                    .background(salesCoreDataViewModel.salesDateInterval == .yearly ? Color("color_accent") : Color.clear)
                    .cornerRadius(15)
                    .onTapGesture {
                        salesCoreDataViewModel.salesDateInterval = .yearly
                        salesCoreDataViewModel.updateAmountsBar()
                        salesCoreDataViewModel.fetchSalesDetailsList()
                    }
                })
                .background(.white)
                .cornerRadius(15)
                Menu {
                    Section("Ordenamiento") {
                        ForEach(SalesOrder.allValues, id: \.self) { orden in
                            Button {
                                salesCoreDataViewModel.order = orden
                            } label: {
                                Label(orden.longDescription, systemImage: salesCoreDataViewModel.order == orden ? "checkmark" : "")
                            }
                        }
                    }
                    Section("Agrupamiento") {
                        ForEach(SalesGrouperAttributes.allValues, id: \.self) { grouper in
                            Button {
                                salesCoreDataViewModel.grouper = grouper
                            } label: {
                                Label(grouper.description, systemImage: salesCoreDataViewModel.grouper == grouper ? "checkmark" : "")
                            }
                        }
                    }
                } label: {
                    Button(action: {}, label: {
                        CustomButton3(simbol: "slider.horizontal.3")
                    })
                }
                .onChange(of: salesCoreDataViewModel.order, perform: { item in
                    salesCoreDataViewModel.fetchSalesDetailsList()
                })
                .onChange(of: salesCoreDataViewModel.grouper, perform: { item in
                    salesCoreDataViewModel.fetchSalesDetailsList()
                })
            })
            .padding(.horizontal, 10)
            HStack(content: {
                HStack(spacing: 0, content: {
                    Text("Hoy")
                        .foregroundColor(Color("color_accent"))
                        .font(.custom("Artifika-Regular", size: 13))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 6)
                        .background {
                            Color(.white)
                        }
                        .clipShape(RoundedRectangle(cornerSize: CGSize(width: 10, height: 10)))
                })
                .opacity(0)
                .disabled(true)
                Spacer()
                Image(systemName: "chevron.backward")
                    .frame(width: 50, height: 30)
                    .foregroundColor(Color("color_accent"))
                    .font(.custom("Artifika-Regular", size: 24))
                    .padding(.vertical, 5)
                    .onTapGesture {
                        previousDate()
                    }
                switch salesCoreDataViewModel.salesDateInterval {
                case .diary:
                    HStack(content: {
                        Text(salesCoreDataViewModel.salesCurrentDateFilter.getShortNameComponent(dateStringNameComponent: .day) + ".")
                        Text(String(salesCoreDataViewModel.salesCurrentDateFilter.getDateComponent(dateComponent: .day)))
                        Text(salesCoreDataViewModel.salesCurrentDateFilter.getShortNameComponent(dateStringNameComponent: .month).capitalized + ".")
                    })
                    .foregroundColor(Color("color_accent"))
                    .font(.custom("Artifika-Regular", size: 16))
                case .monthly:
                    HStack(content: {
                        Text(salesCoreDataViewModel.salesCurrentDateFilter.getShortNameComponent(dateStringNameComponent: .month).capitalized + ".")
                        Text(String(salesCoreDataViewModel.salesCurrentDateFilter.getDateComponent(dateComponent: .year)))
                    })
                    .foregroundColor(Color("color_accent"))
                    .font(.custom("Artifika-Regular", size: 16))
                case .yearly:
                    HStack(content: {
                        Text(String(salesCoreDataViewModel.salesCurrentDateFilter.getDateComponent(dateComponent: .year)))
                    })
                    .foregroundColor(Color("color_accent"))
                    .font(.custom("Artifika-Regular", size: 16))
                }
                Image(systemName: "chevron.backward")
                    .frame(width: 50, height: 30)
                    .rotationEffect(.degrees(180))
                    .foregroundColor(Color("color_accent"))
                    .font(.custom("Artifika-Regular", size: 24))
                    .padding(.vertical, 5)
                    .onTapGesture {
                        nextDate()
                    }
                Spacer()
                HStack(spacing: 0, content: {
                    Text("Hoy")
                        .foregroundColor(Color("color_accent"))
                        .font(.custom("Artifika-Regular", size: 16))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 6)
                        .background {
                            Color(.white)
                        }
                        .clipShape(RoundedRectangle(cornerSize: CGSize(width: 10, height: 10)))
                })
                .onTapGesture(perform: {
                    salesCoreDataViewModel.salesCurrentDateFilter = Date()
                    salesCoreDataViewModel.updateAmountsBar()
                    salesCoreDataViewModel.fetchSalesDetailsList()
                })
            })
            .padding(.horizontal, 10)
            HStack(spacing: 0, content: {
                VStack(spacing: 2, content: {
                    Text("Ventas")
                        .font(.custom("Artifika-Regular", size: 13))
                        .foregroundColor(Color("color_primary"))
                    Text(salesCoreDataViewModel.salesAmount.solesString)
                        .font(.custom("Artifika-Regular", size: 16))
                        .foregroundColor(Color.blue)
                })
                .frame(maxWidth: .infinity, alignment: .center)
                VStack(spacing: 2, content: {
                    Text("Costo")
                        .font(.custom("Artifika-Regular", size: 13))
                        .foregroundColor(Color("color_primary"))
                    Text(salesCoreDataViewModel.costAmount.solesString)
                        .font(.custom("Artifika-Regular", size: 16))
                        .foregroundColor(Color.red)
                })
                .frame(maxWidth: .infinity, alignment: .center)
                VStack(spacing: 2, content: {
                    Text("Ganancia")
                        .font(.custom("Artifika-Regular", size: 13))
                        .foregroundColor(Color("color_primary"))
                    Text(salesCoreDataViewModel.revenueAmount.solesString)
                        .font(.custom("Artifika-Regular", size: 16))
                        .foregroundColor(Color.black)
                })
                .frame(maxWidth: .infinity, alignment: .center)
            })
            .padding(.top, 2)
            .padding(.bottom, 5)
            .background(Color("color_secondary"))
        }
        .padding(.top, showMenu ? 15 : 0)
        .background(Color("color_primary"))
    }
    func nextDate() {
        salesCoreDataViewModel.nextDate()
        salesCoreDataViewModel.updateAmountsBar()
        salesCoreDataViewModel.fetchSalesDetailsList()
    }
    func previousDate() {
        salesCoreDataViewModel.previousDate()
        salesCoreDataViewModel.updateAmountsBar()
        salesCoreDataViewModel.fetchSalesDetailsList()
    }
}

struct SalesTopBar_Previews: PreviewProvider {
    static var previews: some View {
        let ses = SessionConfig(companyId: UUID(), subsidiaryId: UUID(), employeeId: UUID())
        let dependencies = BusinessDependencies(sessionConfig: ses)
        @State var showMenu: Bool = false
        VStack(spacing: 0, content: {
            SalesTopBar(showMenu: $showMenu)
                .environmentObject(dependencies.salesViewModel)
            Spacer()
        })
    }
}
