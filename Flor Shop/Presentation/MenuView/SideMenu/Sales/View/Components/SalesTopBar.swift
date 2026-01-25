import SwiftUI

struct SalesTopBar: View {
    @Binding var salesCoreDataViewModel: SalesViewModel
    let backAction: () -> Void
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 10, content: {
                FlorShopButton(backAction: backAction)
                HStack(spacing: 0, content: {
                    HStack(spacing: 0, content: {
                        Text(SalesDateInterval.diary.description)
                            .padding(.vertical, 10)
                            .font(.custom("Artifika-Regular", size: 16))
                            .foregroundColor(salesCoreDataViewModel.salesDateInterval == .diary ? Color.white : Color("color_primary"))
                            .frame(maxWidth: .infinity, alignment: .center)
                    })
                    .background(salesCoreDataViewModel.salesDateInterval == .diary ? Color.accentColor : Color.clear)
                    .cornerRadius(15)
                    .onTapGesture {
                        salesCoreDataViewModel.salesDateInterval = .diary
                    }
                    HStack(spacing: 0, content: {
                        Text(SalesDateInterval.monthly.description)
                            .padding(.vertical, 10)
                            .font(.custom("Artifika-Regular", size: 16))
                            .foregroundColor(salesCoreDataViewModel.salesDateInterval == .monthly ? Color.white : Color("color_primary"))
                            .frame(maxWidth: .infinity, alignment: .center)
                    })
                    .background(salesCoreDataViewModel.salesDateInterval == .monthly ? Color.accentColor : Color.clear)
                    .cornerRadius(15)
                    .onTapGesture {
                        salesCoreDataViewModel.salesDateInterval = .monthly
                    }
                    HStack(spacing: 0, content: {
                        Text(SalesDateInterval.yearly.description)
                            .padding(.vertical, 10)
                            .font(.custom("Artifika-Regular", size: 16))
                            .foregroundColor(salesCoreDataViewModel.salesDateInterval == .yearly ? Color.white : Color("color_primary"))
                            .frame(maxWidth: .infinity, alignment: .center)
                    })
                    .background(salesCoreDataViewModel.salesDateInterval == .yearly ? Color.accentColor : Color.clear)
                    .cornerRadius(15)
                    .onTapGesture {
                        salesCoreDataViewModel.salesDateInterval = .yearly
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
                    FilterButton()
                }
            })
            .padding(.horizontal, 10)
            HStack(content: {
                HStack(spacing: 0, content: {
                    Text("Hoy")
                        .foregroundColor(Color.accentColor)
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
                    .foregroundColor(Color.accentColor)
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
                    .foregroundColor(Color.accentColor)
                    .font(.custom("Artifika-Regular", size: 16))
                case .monthly:
                    HStack(content: {
                        Text(salesCoreDataViewModel.salesCurrentDateFilter.getShortNameComponent(dateStringNameComponent: .month).capitalized + ".")
                        Text(String(salesCoreDataViewModel.salesCurrentDateFilter.getDateComponent(dateComponent: .year)))
                    })
                    .foregroundColor(Color.accentColor)
                    .font(.custom("Artifika-Regular", size: 16))
                case .yearly:
                    HStack(content: {
                        Text(String(salesCoreDataViewModel.salesCurrentDateFilter.getDateComponent(dateComponent: .year)))
                    })
                    .foregroundColor(Color.accentColor)
                    .font(.custom("Artifika-Regular", size: 16))
                }
                Image(systemName: "chevron.backward")
                    .frame(width: 50, height: 30)
                    .rotationEffect(.degrees(180))
                    .foregroundColor(Color.accentColor)
                    .font(.custom("Artifika-Regular", size: 24))
                    .padding(.vertical, 5)
                    .onTapGesture {
                        nextDate()
                    }
                Spacer()
                HStack(spacing: 0, content: {
                    Text("Hoy")
                        .foregroundColor(Color.accentColor)
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
                })
            })
            .padding(.horizontal, 10)
        }
        .background(Color("color_primary"))
    }
    func nextDate() {
        salesCoreDataViewModel.nextDate()
    }
    func previousDate() {
        salesCoreDataViewModel.previousDate()
    }
}

#Preview {
    @Previewable @State var salesViewModel = SalesViewModelFactory.getSalesViewModel(sessionContainer: SessionContainer.preview)
    SalesTopBar(salesCoreDataViewModel: $salesViewModel, backAction: {})
}
