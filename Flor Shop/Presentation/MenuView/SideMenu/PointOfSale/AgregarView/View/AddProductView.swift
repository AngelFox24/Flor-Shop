import SwiftUI
import PhotosUI

struct AddProductView: View {
    private let className: StaticString = #filePath
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
                await self.loadProduct(productCic: productCic)
            }
    }
    private func loadProduct(productCic: String) async {
        let loadingId = self.overlayViewModel.showLoading(origin: "\(className)")
        do {
            try await agregarViewModel.loadProduct(productCic: productCic)
            self.overlayViewModel.endLoading(id: loadingId, origin: "\(className)")
        } catch {
            print("[AddProductView] Ha ocurrido un error: \(error)")
            self.overlayViewModel.showAlert(
                title: "Error",
                message: "Ha ocurrido un error al cargar un producto.",
                primary: ConfirmAction(
                    title: "Aceptar",
                    action: {
                        self.overlayViewModel.endLoading(id: loadingId, origin: "\(className)")
                    }
                )
            )
        }
    }
    private func saveProduct() {
        let loadingId = self.overlayViewModel.showLoading(origin: "\(className)")
        Task {
            do {
                try await agregarViewModel.addProduct()
                self.overlayViewModel.endLoading(id: loadingId, origin: "\(className)")
            } catch {
                print("[AddProductView] Ha ocurrido un error: \(error)")
                self.overlayViewModel.showAlert(
                    title: "Error",
                    message: "Ha ocurrido un error al guardar.",
                    primary: ConfirmAction(
                        title: "Aceptar",
                        action: {
                            self.overlayViewModel.endLoading(id: loadingId, origin: "\(className)")
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
    @Environment(FlorShopRouter.self) private var router
    @Binding var agregarViewModel: AgregarViewModel
    var sizeCampo: CGFloat = 150
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack {
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
                        Button(action: pasteFromInternet) {
                            Text("Pegar Imagen")
                                .foregroundColor(.black)
                                .font(.custom("Artifika-Regular", size: 16))
                                .padding(.vertical, 6)
                                .padding(.horizontal, 5)
                                .background(Color.secondary)
                                .cornerRadius(10)
                        }
                    }
                    if agregarViewModel.agregarFields.imageURLError != "" {
                        ErrorMessageText(message: agregarViewModel.agregarFields.imageURLError)
                            .padding(.top, 6)
                    }
                }
                VStack {
                    HStack {
                        CustomTextField(title: "Código de barras", value: $agregarViewModel.agregarFields.scannedCode, edited: .constant(false))
                        NavigationButton(sheet: .barcodeScanner(action: BarcodeAction(action: { code in
                            agregarViewModel.agregarFields.scannedCode = code
                            self.router.dismissSheet()
                        }))) {
                            Image(systemName: "barcode.viewfinder")
                                .font(.largeTitle)
                                .foregroundStyle(Color.accentColor)
                                .padding(.horizontal, 5)
                        }
                    }
                }
                VStack {
                    HStack {
                        // El texto hace que tenga una separacion mayor del elemento
                        HStack {
                            CustomTextField(title: "Nombre del producto" ,value: $agregarViewModel.agregarFields.productName, edited: $agregarViewModel.agregarFields.productEdited)
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
                    HStack(spacing: 10) {
                        CustomNumberField(title: "Cantidad", userInput: $agregarViewModel.agregarFields.quantityStock, edited: $agregarViewModel.agregarFields.quantityEdited, numberOfDecimals: agregarViewModel.agregarFields.unitType == .kilo ? 3 : 0)
                        CustomNumberField(title: "Costo unitario", userInput: $agregarViewModel.agregarFields.unitCost, edited: $agregarViewModel.agregarFields.unitCostEdited)
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
                    HStack(spacing: 10) {
                        CustomTextField(title: "Margen de ganancia" ,value: .constant(agregarViewModel.agregarFields.profitMargin), edited: .constant(false), disable: true)
                        CustomNumberField(title: "Precio de venta", userInput: $agregarViewModel.agregarFields.unitPrice, edited: $agregarViewModel.agregarFields.unitPriceEdited)
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
