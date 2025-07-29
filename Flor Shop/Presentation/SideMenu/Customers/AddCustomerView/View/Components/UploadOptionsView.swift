import SwiftUI

struct UploadOptionsView: View {
    var body: some View {
        VStack(content: {
            Spacer()
            VStack {
                Button(action: {
                    
                }, label: {
                    HStack(content: {
                        Image(systemName: "photo")
                            .foregroundStyle(Color.blue)
                            .font(.custom("Artifika-Regular", size: 25))
                            .padding(.horizontal, 5)
                        Text("Galería de Fotos")
                            .foregroundStyle(Color.black)
                        Spacer()
                    })
                    .padding(.leading, 15)
                    .padding(.vertical, 15)
                })
                Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
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
                    .padding(.leading, 15)
                    .padding(.vertical, 15)
                })
            }
            .background(Color.white)
            .cornerRadius(15)
            Button(action: {
                print("Sss")
            }, label: {
                HStack(content: {
                    Spacer()
                    Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                        Text("Cancelar")
                            .bold()
                    })
                    Spacer()
                })
                .padding(.vertical, 15)
                .background(Color.white)
                .cornerRadius(15)
            })
        })
        .padding(.all, 10)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.gray))
        //.blur(radius: 4)
    }
}

#Preview {
    UploadOptionsView()
}
