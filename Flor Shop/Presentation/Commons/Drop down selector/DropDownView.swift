import SwiftUI

struct DropDownView<T: Listable>: View {
    // Customation Properties
    var hind: String
    var options: [T]
    var anchor : Anchor = .bottom
    var cornerRadius: CGFloat = 25
    @Binding var selection: T?
    // View Properties
    @State private var showOptions: Bool = false
    // Environment Scheme
    @Environment(\.colorScheme) private var scheme
    @SceneStorage("drop_down_zindex") private var index = 1000.0
    @State private var zIndex: Double = 1000.0
    var body: some View {
        GeometryReader {
            let size = $0.size
            VStack(spacing: 0) {
                if showOptions && anchor == .top {
                    OptionView()
                }
                HStack(spacing: 0) {
                    Text(selection?.name ?? hind)
                        .foregroundStyle(selection == nil ? .gray : Color.primary)
                        .lineLimit(1)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.title3)
                        .foregroundStyle(selection == nil ? .gray : Color.primary)
                        .rotationEffect(.init(degrees: showOptions ? -180 : 0))
                }
                .padding(.horizontal, 15)
                .frame(width: size.width, height: size.height)
                .background(scheme == .dark ? .black : .white)
                .contentShape(.rect)
                .onTapGesture {
                    index += 1
                    zIndex = index
                    withAnimation(.snappy) {
                        showOptions.toggle()
                    }
                }
                .zIndex(10)
                if showOptions && anchor == .bottom {
                    OptionView()
                }
            }
            .clipped()
            .contentShape(.rect)
            .background((scheme == .dark ? Color.black : Color.white).shadow(.drop(color: .primary.opacity(0.15), radius: 4)), in: .rect(cornerRadius: cornerRadius))
            .frame(height: size.height, alignment: anchor == .top ? .bottom : .top)
        }
        .frame(height: 50)
        .zIndex(zIndex)
    }
    
    /// Options View
    @ViewBuilder
    func OptionView() -> some View {
        let maxLines = 5
        VStack(spacing: 10) {
            ScrollView {
                ForEach(options, id: \.id) { option in
                    HStack(spacing: 0) {
                        Text(option.name)
                            .lineLimit(1)
                        Spacer(minLength: 0)
                        Image(systemName: "checkmark")
                            .foregroundStyle(Color.primary)
                            .font(.caption)
                            .opacity(selection?.id == option.id ? 1 : 0)
                    }
                    .foregroundStyle(selection?.id == option.id ? Color.primary : Color.gray)
                    .animation(.none, value: selection?.id)
                    .frame(height: 40)
                    .contentShape(.rect)
                    .onTapGesture {
                        withAnimation(.snappy) {
                            selection = option
                            showOptions = false
                        }
                    }
                }
            }
            .scrollIndicators(ScrollIndicatorVisibility.hidden)
            .frame(height: options.count > maxLines ? CGFloat(maxLines) * 40 + 10 : CGFloat(options.count) * 40 + 10)
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 5)
        .transition(.move(edge: anchor == .top ? .bottom : .top))
    }
    
    enum Anchor {
        case top
        case bottom
    }
}

//#Preview {
//    @Previewable @State var selected: Local?
//    @Previewable @State var selected2: Local?
//    VStack {
//        DropDownView(
//            hind: "Select",
//            options: [
//            ],
//            selection: $selected
//        )
//        DropDownView(
//            hind: "Select",
//            options: [
//                Local(codLocal: "Youtube"),
//                Local(codLocal: "Google"),
//                Local(codLocal: "Apple"),
//                Local(codLocal: "Apple"),
//                Local(codLocal: "Apple"),
//                Local(codLocal: "Apple"),
//                Local(codLocal: "Apple"),
//                Local(codLocal: "Apple"),
//                Local(codLocal: "Apple"),
//                Local(codLocal: "Apple"),
//                Local(codLocal: "Apple"),
//                Local(codLocal: "Apple"),
//                Local(codLocal: "Apple"),
//                Local(codLocal: "Apple2")
//            ],
//            anchor: .top,
//            selection: $selected2
//        )
//        Button {
//            
//        } label: {
//            Text("Click me")
//        }
//
//    }
//}
