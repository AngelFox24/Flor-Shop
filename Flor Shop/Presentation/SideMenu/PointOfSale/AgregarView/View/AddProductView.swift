import SwiftUI
import PhotosUI

struct AddProductView: View {
    @Environment(FlorShopRouter.self) private var router
    @Environment(OverlayViewModel.self) private var overlayViewModel
    @State var agregarViewModel: AgregarViewModel
    let productCic: String?
    init(ses: SessionContainer) {
        agregarViewModel = AgregarViewModelFactory.getAgregarViewModel(sessionContainer: ses)
        self.productCic = nil
    }
    init(
        ses: SessionContainer,
        productCic: String
    ) {
        self.agregarViewModel = AgregarViewModelFactory.getAgregarViewModel(sessionContainer: ses)
        self.productCic = productCic
    }
    var body: some View {
        CamposProductoAgregar(agregarViewModel: $agregarViewModel)
            .navigationTitle(productCic == nil ? "Agregar" : "Editar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                MainConfirmationToolbar(disabled: false, action: saveProduct)
            }
            .background(Color.background)
            .task {
                guard let productCic else { return }
                try? await agregarViewModel.loadProduct(productCic: productCic)
            }
    }
    private func saveProduct() {
        let loadingId = self.overlayViewModel.showLoading()
        Task {
            do {
                try await agregarViewModel.addProduct()
                self.overlayViewModel.endLoading(id: loadingId)
            } catch {
                print("[AddProductView] Ha ocurrido un error: \(error)")
                self.overlayViewModel.showAlert(
                    title: "Error",
                    message: "Ha ocurrido un error al guardar.",
                    primary: AlertAction(
                        title: "Aceptar",
                        action: {
                            self.overlayViewModel.endLoading(id: loadingId)
                        }
                    )
                )
            }
        }
    }
}

#Preview {
    @Previewable @State var overlayViewModel = OverlayViewModel()
    @Previewable @State var mainRouter = FlorShopRouter.previewRouter()
    let session = SessionContainer.preview
    AddProductView(ses: SessionContainer.preview)
        .environment(mainRouter)
        .environment(session)
        .environment(overlayViewModel)
}

struct ErrorMessageText: View {
    let message: String
    var body: some View {
        Text(message)
            .foregroundColor(.red)
    }
}

struct CamposProductoAgregar: View {
    @Binding var agregarViewModel: AgregarViewModel
    var sizeCampo: CGFloat = 150
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 23) {
                HStack {
                    VStack(spacing: 0) {
                        Spacer()
                        Button(action: exportProducts) {
                            CustomButton6(simbol: "square.and.arrow.up")
                        }
                    }
                    Spacer()
                    CustomImageView(
                        uiImage: $agregarViewModel.selectedLocalImage,
                        size: sizeCampo,
                        searchFromInternet: searchFromInternet,
                        searchFromGallery: searchFromGallery,
                        takePhoto: takePhoto
                    )
                    .photosPicker(isPresented: $agregarViewModel.agregarFields.isShowingPicker, selection: $agregarViewModel.selectionImage, matching: .any(of: [.images, .screenshots]))
                    Spacer()
                    VStack(spacing: 0) {
                        Button(action: {
                            //                                router.presentSheet(.popoverAddView)
                        }, label: {
                            CustomButton6(simbol: "questionmark")
                        })
                        Spacer()
                        ImportButtonView() { result in
                            handleFileImport(result: result)
                        }
                    }
                }
                VStack {
                    HStack {
                        HStack {
                            Button(action: pasteFromInternet) {
                                Text("Pegar Imagen")
                                    .foregroundColor(.black)
                                    .font(.custom("Artifika-Regular", size: 16))
                                    .padding(.vertical, 6)
                                    .padding(.horizontal, 5)
                                    .background(Color("color_secondary"))
                                    .cornerRadius(10)
                            }
                        }
                    }
                    if agregarViewModel.agregarFields.imageURLError != "" {
                        ErrorMessageText(message: agregarViewModel.agregarFields.imageURLError)
                            .padding(.top, 6)
                    }
                }
                VStack {
                    HStack {
                        CustomTextField(placeHolder: "", title: "Código de barras" ,value: $agregarViewModel.agregarFields.scannedCode, edited: .constant(false))
                        Button {
                            agregarViewModel.agregarFields.isShowingScanner.toggle()
                        } label: {
                            Image(systemName: "barcode.viewfinder")
                                .font(.largeTitle)
                                .foregroundStyle(Color.accentColor)
                                .padding(.horizontal, 5)
                        }
                        .sheet(isPresented: $agregarViewModel.agregarFields.isShowingScanner) {
                            BarcodeScannerView { code in
                                agregarViewModel.agregarFields.scannedCode = code
                                agregarViewModel.agregarFields.isShowingScanner = false
                            }
                            .presentationDetents([.large])
                        }
                    }
                }
                VStack {
                    HStack {
                        // El texto hace que tenga una separacion mayor del elemento
                        HStack {
                            CustomTextField(title: "Nombre del Producto" ,value: $agregarViewModel.agregarFields.productName, edited: $agregarViewModel.agregarFields.productEdited)
                        }
                        Button(action: findImageOnInternet) {
                            Text("Buscar Imagen")
                                .foregroundColor(.black)
                                .font(.custom("Artifika-Regular", size: 16))
                                .padding(.vertical, 6)
                                .padding(.horizontal, 5)
                                .background(Color("color_secondary"))
                                .cornerRadius(10)
                        }
                    }
                    if agregarViewModel.agregarFields.productError != "" {
                        ErrorMessageText(message: agregarViewModel.agregarFields.productError)
                            .padding(.top, 6)
                    }
                }
                VStack {
                    HStack {
                        HStack {
                            CustomTextField(title: "Disponible" ,value: .constant(agregarViewModel.agregarFields.active ? "Activo" : "Inactivo"), edited: .constant(false), disable: true)
                        }
                        Toggle("", isOn: $agregarViewModel.agregarFields.active)
                            .labelsHidden()
                            .toggleStyle(SwitchToggleStyle(tint: Color.accentColor))
                            .padding(.horizontal, 5)
                    }
                }
                VStack {
                    TypeUnitView(value: $agregarViewModel.agregarFields.unitType)
                }
                VStack {
                    HStack {
                        CustomTextField(placeHolder: "0", title: "Cantidad" ,value: $agregarViewModel.agregarFields.quantityStock, edited: $agregarViewModel.agregarFields.quantityEdited, keyboardType: .numberPad)
                        CustomNumberField(placeHolder: "0", title: "Costo Unitario", userInput: $agregarViewModel.agregarFields.unitCost, edited: $agregarViewModel.agregarFields.unitCostEdited)
                    }
                    if agregarViewModel.agregarFields.quantityError != "" {
                        ErrorMessageText(message: agregarViewModel.agregarFields.quantityError)
                            .padding(.top, 18)
                    }
                    if agregarViewModel.agregarFields.unitCostError != "" {
                        ErrorMessageText(message: agregarViewModel.agregarFields.unitCostError)
                            .padding(.top, 6)
                    }
                }
                VStack {
                    HStack {
                        CustomTextField(title: "Margen de Ganancia" ,value: .constant(agregarViewModel.agregarFields.profitMargin), edited: .constant(false), disable: true)
                        CustomNumberField(placeHolder: "0", title: "Precio de Venta", userInput: $agregarViewModel.agregarFields.unitPrice, edited: $agregarViewModel.agregarFields.unitPriceEdited)
                    }
                    if agregarViewModel.agregarFields.unitPriceError != "" {
                        ErrorMessageText(message: agregarViewModel.agregarFields.unitPriceError)
                            .padding(.top, 6)
                    }
                }
            }
        }
        .padding(.horizontal, 10)
    }
    private func findImageOnInternet() {
        agregarViewModel.findProductNameOnInternet()
    }
    private func handleFileImport(result: Result<[URL], Error>) {
        Task {
            switch result {
            case .success(let success):
                if let url = success.first {
//                    router.isLoading = true
                    await agregarViewModel.importCSV(url: url)
//                    router.isLoading = false
                }
            case .failure(let failure):
                print("Error: \(failure)")
            }
        }
    }
    private func exportProducts() {
        Task {
//            router.isLoading = true
//            do {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyyMMdd_HHmmss"
                let currentDate = Date()
                let formattedDate = dateFormatter.string(from: currentDate)
                let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("Products BackUp \(formattedDate).csv")
                await agregarViewModel.exportCSV(url: tempURL)
//            router.isLoading = false
                showShareSheet(url: tempURL)
//            } catch {
//                await errorState.processError(error: error)
//            }
//            loading = false
        }
    }
    func pasteFromInternet() {
        Task {
//            loading = true
            do {
                try await agregarViewModel.pasteFromInternet()
            } catch {
//                router.presentAlert(.error(error.localizedDescription))
            }
//            loading = false
        }
    }
    func searchFromInternet() {
        agregarViewModel.findProductNameOnInternet()
    }
    func searchFromGallery() {
        agregarViewModel.agregarFields.isShowingPicker = true
    }
    func takePhoto() {
        
    }
}
