//
//  ContentView.swift
//  AnimationTest
//
//  Created by Thomas Dean on 2025-05-12.
//

import SwiftUI

struct ContentView: View {
    @Environment(TestModel.self) var model
    @State var currentMove: Move? = nil
    var hasAnimation: Bool
    var body: some View {
        VStack {
            Arena(model: model, currentMove: $currentMove, hasAnimation: hasAnimation)
                .frame(width: 640, height: 200)
            Button(action:{
                currentMove = model.nextMove()
            }){
                Text("Next Move")
            }
        }
        .padding()
    }
}

struct Arena: View {
    var model: TestModel
    @Binding var currentMove: Move?
    var hasAnimation: Bool
    var body: some View {
        GeometryReader { geometry in
            ZStack{
                DotGrid(model: model)
                GridState(model: model, currentMove: $currentMove)
                if hasAnimation {
                    MoveAnimator(model: model, currentMove: $currentMove)
                }
            }
        }
    }
}

let spaceX = 30.0
let spaceY: CGFloat = 20.0

struct DotGrid: View {
    var model: TestModel
    
    var body: some View {
        ZStack{
            // If no geometry reader, dots end up in lower right
            GeometryReader { _ in
                ForEach(0 ..< model.GridWidth, id: \.self) { col in
                    let posX = CGFloat(col) * spaceX + spaceY
                    Circle()
                        .frame(width:2, height: 2)
                        .offset(x: posX, y: spaceY)
                }
            }
        }
    }
}

struct GridState: View {
    let model: TestModel
    @Binding var currentMove: Move?
    
    // dirs might have been better as an array......
    var body: some View {
        ZStack {
            // Why no need for Geometry reader here/
            ForEach(0 ..< model.GridWidth, id: \.self) { col in
                GirdPointLines(model: model, col:col, currentMove: $currentMove)
            }
        }
    }
}

struct GirdPointLines: View {
    let model: TestModel
    let col: Int
    @Binding var currentMove: Move?

    var body: some View {
        let posX = CGFloat(col) * spaceX + spaceY
        ZStack {
            if model.grid[col] {
                if (drawLine(col: col,  move: currentMove)){
                    Path { path in
                        path.move(to: CGPoint(x: posX, y: spaceY))
                        path.addLine(to: CGPoint(x: posX + spaceX, y: spaceY))
                    }
                    .stroke(Color.blue, lineWidth: 4)
                }
           }
        }
    }
    
    // check if there is a move that covers
    // this line segment
    func drawLine(col: Int, move: Move?) -> Bool {
        if move == nil { return true }
        if let m = move {
            if m.nextPoint == col {
                return false
            }
        }
        return true
    }
}

struct MoveAnimator: View {
    let model: TestModel
    @Binding var currentMove: Move?
    @State private var isAnimating: Bool = false
    
    var body: some View {
        if let currentMove = self.currentMove {
            let posX = CGFloat(currentMove.nextPoint) * spaceX + spaceY
            Path { path in
                path.move(to: CGPoint(x: posX, y: spaceY))
                path.addLine(to: CGPoint(x: posX + spaceX, y: spaceY))
            }
            .trim(from: 0, to: isAnimating ? 1 : 0)
            .stroke(Color.red, lineWidth: 4)
            .onAppear {
                withAnimation(.easeIn(duration: 0.5) ){
                    self.isAnimating = true
                } completion: {
                    self.currentMove = nil // self.currentMove = model.nextMove9)
                    self.isAnimating = false
                }
            }
            .onChange(of: currentMove) { oldValue,  newValue in
                if (self.currentMove != nil){
                    self.isAnimating = true
                }
            }
        }
    }
}

#Preview ("ContentView Moves New"){
    let model = TestModel(GridWidth: 10)
    ContentView(hasAnimation: true)
        .environment(model)
}

#Preview ("ContentView Moves Already Drawn"){
    let model = TestModel(GridWidth: 10)
    model.grid[0] = true
    model.grid[1] = true
    model.grid[2] = true
    model.grid[3] = true
    return ContentView(hasAnimation: true)
        .environment(model)
}

#Preview ("Arena"){
    @Previewable @State var move: Move? = Move(nextPoint: 3)
    let model = TestModel(GridWidth: 10)
    model.grid[0] = true
    model.grid[1] = true
    model.grid[2] = true
    model.grid[3] = true // suppressed until animation done
    return Arena(model: model, currentMove: $move, hasAnimation: true)
        .frame(width: 640, height: 100)

}

#Preview("DotGrid") {
    let model = TestModel(GridWidth: 10)
    DotGrid(model: model)
        .frame(width: 640, height: 100)
}


#Preview("GridState") {
    @Previewable @State var move: Move? = Move(nextPoint: 3)
    let model = TestModel(GridWidth: 10)
    model.grid[0] = true
    model.grid[1] = true
    model.grid[2] = true
    model.grid[3] = true // should be suppressed by the move.
    //model.grid[4] = true
    return GridState(model: model, currentMove: $move)
        .frame(width: 640, height: 100)
}

#Preview("GridPointLines next move matches") {
    @Previewable @State var move: Move? = Move(nextPoint: 2)
    let model = TestModel(GridWidth: 10)
    model.grid[2] = true
    return GirdPointLines(model: model, col: 2, currentMove: $move)
        .frame(width: 640, height: 100)

}

#Preview("GridPointLines next move different") {
    @Previewable @State var move: Move? = Move(nextPoint: 3)
    let model = TestModel(GridWidth: 10)
    model.grid[2] = true
    return GirdPointLines(model: model, col: 2, currentMove: $move)
        .frame(width: 640, height: 100)

}

#Preview ("MoveAnimation") {
    @Previewable @State var move: Move? = Move(nextPoint:3)
    let model = TestModel(GridWidth: 13)
    MoveAnimator(model: model, currentMove: $move)
        .frame(width: 640, height: 200)
}
