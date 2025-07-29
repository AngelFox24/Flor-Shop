import SwiftUI
import PhotosUI

struct SourceSelecctionView: View {
    @Binding var isPresented: Bool
    var photoPicker: Bool = true
    var fromInternet: Bool = true
    var fromInternetAction: (() -> Void)?
    @Binding var selectionImage: PhotosPickerItem?
    var body: some View {
        if isPresented {
            ZStack(content: {
                Color(.black)
                    .ignoresSafeArea()
                    .opacity(0.2)
                    .onTapGesture(perform: {
                        withAnimation(.easeOut) {
                            isPresented = false
                        }
                    })	
                VStack(content: {
                    Spacer()
                        .opacity(0.2)
                    VStack {
                        if photoPicker {
                            PhotosPicker(selection: $selectionImage, matching: .images, label: {
                                HStack(content: {
                                    Image(systemName: "photo")
                                        .foregroundStyle(Color.blue)
                                        .font(.custom("Artifika-Regular", size: 25))
                                        .padding(.horizontal, 5)
                                    Text("Galería de Fotos")
                                        .foregroundStyle(Color.black)
                                    Spacer()
                                })
                                .padding(.all, 15)
                            })
                        }
                        if fromInternet {
                            Button(action: {
                                fromInternetAction?()
                            }, label: {
                                HStack(content: {
                                    Image(systemName: "globe.americas.fill")
                                        .foregroundStyle(Color.blue)
                                        .font(.custom("Artifika-Regular", size: 25))
                                        .blur(radius: 0)
                                        .padding(.horizontal, 8)
                                    Text("Internet")
                                        .foregroundStyle(Color.black)
                                    Spacer()
                                })
                                .padding(.all, 15)
                            })
                        }
                    }
                    .background(Color.white)
                    .cornerRadius(15)
                    Button(action: {
                        withAnimation(.easeOut) {
                            isPresented = false
                        }
                    }, label: {
                        HStack(content: {
                            Spacer()
                            Text("Cancelar")
                                .bold()
                            Spacer()
                        })
                        .padding(.vertical, 15)
                        .background(Color.white)
                        .cornerRadius(15)
                    })
                })
                .padding(.all, 10)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            })
        }
    }
}

#Preview {
    SourceSelecctionView(isPresented: .constant(true), selectionImage: .constant(nil))
}
