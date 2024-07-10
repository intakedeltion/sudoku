import SwiftUI
//maakt je suduko de je wil edit en de uitkomst van wil weten
struct ContentView: View {
    
    @State private var filledIndex: Int?
    @State private var isSolvedVisible: Bool = false
    @State private var sudokubase: [[Int]] = 
    [
                [0, 0, 0, 0, 5, 0, 0, 0, 0],
                [0, 1, 4, 0, 7, 0, 8, 5, 0],
                [6, 0, 0, 0, 0, 0, 0, 0, 1],
                [7, 0, 0, 0, 4, 0, 0, 0, 6],
                [0, 0, 0, 7, 0, 8, 0, 0, 0],
                [1, 0, 0, 0, 2, 0, 0, 0, 9],
                [9, 0, 0, 0, 0, 0, 0, 0, 3],
                [0, 2, 5, 0, 9, 0, 7, 6, 0],
                [0, 0, 0, 0, 6, 0, 0, 0, 0]
    ]

    @State private var solvedsudoku: [[Int]] =
    [
       [0, 0, 0, 0, 0, 0, 0, 0, 0],
       [0, 0, 0, 0, 0, 0, 0, 0, 0],
       [0, 0, 0, 0, 0, 0, 0, 0, 0],
       [0, 0, 0, 0, 0, 0, 0, 0, 0],
       [0, 0, 0, 0, 0, 0, 0, 0, 0],
       [0, 0, 0, 0, 0, 0, 0, 0, 0],
       [0, 0, 0, 0, 0, 0, 0, 0, 0],
       [0, 0, 0, 0, 0, 0, 0, 0, 0],
       [0, 0, 0, 0, 0, 0, 0, 0, 0]
   ]
    
    //check of je invalid getal in hebt gevoerd wat niet tussen de 9 en 0 is
    var hasInvalidCells: Bool {
        for row in 0..<9 {
            for col in 0..<9 {
                let cellValue = sudokubase[row][col]
                if !(0...9).contains(cellValue) {
                    return true
                }
            }
        }
        return false
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<9) { row in
                HStack(spacing: 0) {
                    ForEach(0..<9) { col in
                        CellView(value: self.$sudokubase[row][col])
                    }
                }
            }
            Button(action: {
                filledIndex = 1
                resetFilledIndexAfterDelay()
                if !self.hasInvalidCells {
                    solver(sudoku: &sudokubase,isSolvedVisible: $isSolvedVisible, bindingsudoku: $solvedsudoku)
                } else {
                    print("Cannot play due to invalid cells")
                }
            }) {
                Image(systemName: filledIndex == 1 ? "play.fill" : "play")
            }
            .font(.system(size: 50))
            .accentColor(.green)
            .padding(.top, 10)
        }
        //maakt de popup waar je de antwoorden ingevulde sudoku ziet
        .sheet(isPresented: $isSolvedVisible, content: {
            SolvedSudokuView(solvidesudoku: solvedsudoku)
        })
    }
    //maakt de animatie voor een button
    private func resetFilledIndexAfterDelay() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            filledIndex = nil
        }
    }
}
//dit laat sudoku zien
struct CellView: View {
    @Binding var value: Int
    
    var body: some View {
        TextField("", value: $value, formatter: NumberFormatter())
            .frame(width: 35, height: 35)
            .foregroundColor(Color.black)
            .border(Color.black, width: 1)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .multilineTextAlignment(.center)
            .keyboardType(.numberPad)
    }
}
//dit is de maker van de solved sudoku
struct SolvedSudokuView: View {
    @State private var filledIndex: Int?
    @State public var solvidesudoku: [[Int]]
    
    var hasInvalidCells: Bool {
        for row in 0..<9 {
            for col in 0..<9 {
                let cellValue = solvidesudoku[row][col]
                if !(0...9).contains(cellValue) {
                    return true
                }
            }
        }
        return false
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<9) { row in
                HStack(spacing: 0) {
                    ForEach(0..<9) { col in
                        SolvedSudokuCellView(value: self.$solvidesudoku[row][col])
                    }
                }
            }
        }
    }
    
}
//en dit laay de solved sudoku zien
struct SolvedSudokuCellView: View {
    @Binding var value: Int
    
    var body: some View {
        TextField("", value: $value, formatter: NumberFormatter())
            .frame(width: 35, height: 35)
            .foregroundColor(Color.black)
            .border(Color.black, width: 1)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .multilineTextAlignment(.center)
            .keyboardType(.numberPad)
    }
}
//dit gaat alleen rije bij lang om te kijken welke we nog niet gehad hebben
public func solver(sudoku: inout  [[Int]], isSolvedVisible: Binding<Bool>, bindingsudoku: Binding<[[Int]]>) {
    for y in 0..<9 {
        for x in 0..<9 {
            if sudoku[y][x] == 0 {
                for n in 1...9 {
                    if isPossible(x: x, y: y, n: n, puzzle: sudoku) {
                        sudoku[y][x] = n
                        solver(sudoku: &sudoku,isSolvedVisible: isSolvedVisible, bindingsudoku: bindingsudoku)
                        sudoku[y][x] = 0
                    }
                }
                return
            }
        }
    }
    isSolvedVisible.wrappedValue = true
    bindingsudoku.wrappedValue = sudoku
    return
}
//deze check of daar de nummer kan volgen de sudoku regels
public func isPossible(x: Int, y: Int, n: Int, puzzle: [[Int]]) -> Bool {
    //deze check vertical of het kan
    for i in 0..<9 {
        if puzzle[y][i] == n {
            return false
        }
    }
    //deze check horzinotal of het kan
    for i in 0..<9 {
        if puzzle[i][x] == n {
            return false
        }
    }
    //deze check of 3x3 geen andere getal het zelfde als getal die we daar willen plaatsen
    let x0: Int = (x / 3) * 3
    let y0: Int = (y / 3) * 3
    for i in 0..<3 {
        for j in 0..<3 {
            if puzzle[y0 + i][x0 + j] == n {
                return false
            }
        }
    }
    //als er allemaal niet klopt dat er zelfe getal in zit dan return hij dat het nummer er kan staans
    return true
}

