import Foundation

struct Move: Equatable {
    var nextPoint: Int
}

@Observable
class TestModel {
    let GridWidth:Int
    var grid: [Bool] = []
    var curPoint: Int = 0
    
    init(GridWidth: Int) {
        self.GridWidth = GridWidth
        grid = Array(repeating: false, count: GridWidth)
    }
    
    func nextMove() -> Move? {
        if (curPoint < GridWidth-2){
            grid[curPoint] = true
            let retVal: Move = Move(nextPoint: curPoint)
            curPoint += 1
            return retVal
        }
        return nil
    }
    
}
