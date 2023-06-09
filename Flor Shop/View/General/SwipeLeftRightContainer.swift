//
//  SwipeLeftRightContainer.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 9/06/23.
//

import SwiftUI

/** executeRight: checks if it should execute the swipeRight action
    execute Left: checks if it should execute the swipeLeft action
    submitThreshold: the threshold of the x offset when it should start executing the action
*/
class SwipeController {
    var executeRight = false
    var executeLeft = false
    let submitThreshold: CGFloat = 200
    
    func checkExecutionRight(offsetX: CGFloat) {
        if offsetX > submitThreshold && self.executeRight == false {
            //Utils.HapticSuccess()
            self.executeRight = true
        } else if offsetX < submitThreshold {
            self.executeRight = false
        }
    }
    
    func checkExecutionLeft(offsetX: CGFloat) {
        if offsetX < -submitThreshold && self.executeLeft == false {
            //Utils.HapticSuccess()
            self.executeLeft = true
        } else if offsetX > -submitThreshold {
            self.executeLeft = false
        }
    }
    
    func excuteAction() {
        if executeRight {
            print("executed right")
        } else if executeLeft {
            print("executed left")
        }
        
        self.executeLeft = false
        self.executeRight = false
    }
}

struct SwipeLeftRightContainer: View {
    
    var swipeController: SwipeController = SwipeController()
    
    @State var offsetX: CGFloat = 0
    
    let maxWidth: CGFloat = 335
    let maxHeight: CGFloat = 125
    let swipeObjectsOffset: CGFloat = 350
    let swipeObjectsWidth: CGFloat = 400
    
    @State var rowAnimationOpacity: Double = 0
    var body: some View {
        ZStack {
            Group {
                HStack {
                    Text("Sample row")
                    Spacer()
                }
            }.padding(10)
            .zIndex(1.0)
            .frame(width: maxWidth, height: maxHeight)
            .cornerRadius(5)
            .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray))
            .padding(10)
            .offset(x: offsetX)
            .gesture(DragGesture(minimumDistance: 5).onChanged { gesture in
                withAnimation(Animation.linear(duration: 0.1)) {
                    offsetX = gesture.translation.width
                }
                swipeController.checkExecutionLeft(offsetX: offsetX)
                swipeController.checkExecutionRight(offsetX: offsetX)
            }.onEnded { _ in
                withAnimation(Animation.linear(duration: 0.1)) {
                    offsetX = 0
                    //swipeController.prevLocX = 0
                    //swipeController.prevLocXDiff = 0
                    self.swipeController.excuteAction()
                }
            })
            Group {
                ZStack {
                    Rectangle().fill(Color.red).frame(width: swipeObjectsWidth, height: maxHeight).opacity(opacityDelete).cornerRadius(30)
                    Image(systemName: "multiply").font(Font.system(size: 34)).foregroundColor(Color.white).padding(.trailing, 150)
                }.padding(.horizontal, 20)
            }.zIndex(0.9).offset(x: swipeObjectsOffset + offsetX)
            Group {
                ZStack {
                    Rectangle().fill(Color.green).frame(width: swipeObjectsWidth, height: maxHeight).opacity(opacityLike)
                    Image(systemName: "heart").font(Font.system(size: 34)).foregroundColor(Color.white).padding(.leading, 150)
                }
            }.zIndex(0.9).offset(x: -swipeObjectsOffset + offsetX)
        }
    }
    
    var opacityDelete: Double {
        if offsetX < 0 {
            return Double(abs(offsetX) / 50)
        }
        return 0
    }
    
    var opacityLike: Double {
        if offsetX > 0 {
            return Double(offsetX / 50)
        }
        return 0
    }
}

struct SwipeListView: View {
    
    var body: some View {
        ScrollView {
            ForEach(0..<10) { index in
                SwipeLeftRightContainer().listRowInsets(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
            }
        }
    }
    
}

struct SwipeLeftRight_Previews: PreviewProvider {
    static var previews: some View {
        SwipeListView()
    }
}
