import SwiftUI
import UniformTypeIdentifiers

struct ImportButtonView: View {
    @State private var isFileImporterPresented = false
    var onCompletion: (Result<[URL], Error>) -> Void
    var body: some View {
        Button(action: {
            isFileImporterPresented = true
        }) {
            CustomButton6(simbol: "square.and.arrow.down")
        }
        .fileImporter(
            isPresented: $isFileImporterPresented,
            allowedContentTypes: [UTType.commaSeparatedText],
            allowsMultipleSelection: false,
            onCompletion: onCompletion
        )
    }
}

#Preview {
    ImportButtonView() { _ in }
}
