//
//  SwipeSideView.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 03/05/2024.
//

import SwiftUI

enum SwipeDirections {
    case left
    case right
}

struct SideSwipeView: View {
    @State var offset: CGFloat = 0
    let screenWidth = UIScreen.main.bounds.width
    var swipeThreshold: CGFloat { screenWidth / 10 }
    var swipeDirection: SwipeDirections
    var swipeAction: () -> Void // Función para swipe
    var swipe: some Gesture {
        DragGesture()
            .onEnded { value in
                withAnimation {
                    offset = value.translation.width
                    switch swipeDirection {
                    case .left:
                        if offset < -swipeThreshold {
                            swipeAction()
                        }
                    case .right:
                        if offset > swipeThreshold {
                            swipeAction()
                        }
                    }
                    
                }
            }
    }
    var body: some View {
        VStack(spacing: 0, content: {
            Color.red
                .opacity(0.0001)
        })
        .frame(width: 10/*, height: .infinity*/)
        .gesture(swipe)
    }
}

//#Preview {
//    HStack(spacing: 0, content: {
//        SideSwipeView(swipeDirection: .left, swipeAction: print("ss"))
//        Spacer()
//        SideSwipeView()
//    })
//}
