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
        VStack {
            HStack(spacing: 10, content: {
                Button(action: {
                    withAnimation(.spring()){
                        showMenu.toggle()
                    }
                }, label: {
                    HStack {
                        Image("logo")
                            .resizable()
                            .scaledToFit()
                    }
                    .background(Color("colorlaunchbackground"))
                    .cornerRadius(10)
                    .frame(width: 40, height: 40)
                })
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
                    }
                })
                .background(.white)
                .cornerRadius(15)
                Menu {
                    Picker("", selection: $salesCoreDataViewModel.order) {
                        ForEach(SalesOrder.allValues, id: \.self) {
                            Text($0.longDescription)
                        }
                    }
                    Divider()
                    Picker("", selection: $salesCoreDataViewModel.filterAttribute) {
                        ForEach(SalesFilterAttributes.allValues, id: \.self) {
                            Text($0.description)
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
                .onChange(of: salesCoreDataViewModel.filterAttribute, perform: { item in
                    salesCoreDataViewModel.fetchSalesDetailsList()
                })
            })
            .padding(.horizontal, 10)
            HStack(content: {
                Image(systemName: "chevron.backward")
                    .frame(width: 50, height: 30)
                    .foregroundColor(Color("color_accent"))
                    .font(.custom("Artifika-Regular", size: 20))
                    .onTapGesture {
                        previousDate()
                    }
                Spacer()
                switch salesCoreDataViewModel.salesDateInterval {
                case .diary:
                    HStack(content: {
                        Text(salesCoreDataViewModel.salesCurrentDateFilter.getShortNameComponent(dateStringNameComponent: .day) + ".")
                        Text(String(salesCoreDataViewModel.salesCurrentDateFilter.getDateComponent(dateComponent: .day)))
                        Text(salesCoreDataViewModel.salesCurrentDateFilter.getShortNameComponent(dateStringNameComponent: .month).capitalized + ".")
                    })
                    .foregroundColor(Color("color_accent"))
                    .font(.custom("Artifika-Regular", size: 15))
                case .monthly:
                    HStack(content: {
                        Text(salesCoreDataViewModel.salesCurrentDateFilter.getShortNameComponent(dateStringNameComponent: .month).capitalized + ".")
                        Text(String(salesCoreDataViewModel.salesCurrentDateFilter.getDateComponent(dateComponent: .year)))
                    })
                    .foregroundColor(Color("color_accent"))
                    .font(.custom("Artifika-Regular", size: 15))
                case .yearly:
                    HStack(content: {
                        Text(String(salesCoreDataViewModel.salesCurrentDateFilter.getDateComponent(dateComponent: .year)))
                    })
                    .foregroundColor(Color("color_accent"))
                    .font(.custom("Artifika-Regular", size: 15))
                }
                Spacer()
                Image(systemName: "chevron.backward")
                    .frame(width: 50, height: 30)
                    .rotationEffect(.degrees(180))
                    .foregroundColor(Color("color_accent"))
                    .font(.custom("Artifika-Regular", size: 20))
                    .onTapGesture {
                        nextDate()
                    }
            })
            .padding(.horizontal, 10)
            HStack(content: {
                VStack(spacing: 2, content: {
                    Text("Ventas")
                        .font(.custom("Artifika-Regular", size: 13))
                        .foregroundColor(Color("color_primary"))
                    Text(String(salesCoreDataViewModel.salesAmount))
                        .font(.custom("Artifika-Regular", size: 16))
                        .foregroundColor(Color.blue)
                })
                .frame(maxWidth: .infinity, alignment: .center)
                VStack(spacing: 2, content: {
                    Text("Costo")
                        .font(.custom("Artifika-Regular", size: 13))
                        .foregroundColor(Color("color_primary"))
                    Text(String(salesCoreDataViewModel.costAmount))
                        .font(.custom("Artifika-Regular", size: 16))
                        .foregroundColor(Color.red)
                })
                .frame(maxWidth: .infinity, alignment: .center)
                VStack(spacing: 2, content: {
                    Text("Ganancia")
                        .font(.custom("Artifika-Regular", size: 13))
                        .foregroundColor(Color("color_primary"))
                    Text(String(salesCoreDataViewModel.revenueAmount))
                        .font(.custom("Artifika-Regular", size: 16))
                        .foregroundColor(Color.black)
                })
                .frame(maxWidth: .infinity, alignment: .center)
            })
            .padding(.top, 2)
            .padding(.bottom, 5)
            .background(Color("color_secondary"))
        }
        .background(Color("color_primary"))
    }
    func nextDate() {
        salesCoreDataViewModel.nextDate()
        salesCoreDataViewModel.updateAmountsBar()
    }
    func previousDate() {
        salesCoreDataViewModel.previousDate()
        salesCoreDataViewModel.updateAmountsBar()
    }
}

struct SalesTopBar_Previews: PreviewProvider {
    static var previews: some View {
        let dependencies = Dependencies()
        @State var showMenu: Bool = false
        SalesTopBar(showMenu: $showMenu)
            .environmentObject(dependencies.salesViewModel)
    }
}
