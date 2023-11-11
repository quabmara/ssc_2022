import SwiftUI

enum Mode: Int {
    case start = 0
    case paused = 1
    case solved = 2
    case solvedWithSolver = 3
    case normal = 4
}

//textStrings
let titleStr: [String] = [
    "SUDOKU",
    "Your Sudoku is paused.",
    "Congratulations!",
    "Congratulations!",
]
let textStr: [String] = [
    "Start solving?",
    "Resume solving?",
    "You solved the Sudoku.",
    "You solved the Sudoku (with help of the solver)."
]
let buttonStr: [String] = [
    "Play",
    "Continue",
    "Play again",
    "Play again"
]

struct ContentView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @ObservedObject var timerManager = TimerManager()
    @ObservedObject var solver = Solver()
    @ObservedObject var generator = Generator()
    private let sudokuLogic = SudokuLogic()
    private let cols = [
        GridItem(.flexible()),GridItem(.flexible()),GridItem(.flexible()),
        GridItem(.flexible()),GridItem(.flexible()),GridItem(.flexible()),
        GridItem(.flexible()),GridItem(.flexible()),GridItem(.flexible())
    ]
    @State private var rows = [
        GridItem(.flexible()),GridItem(.flexible()),GridItem(.flexible())
    ]
    @State private var sourceData: [[Int]] = [
        [5, 3, 0, 0, 7, 0, 0, 0, 0],
        [6, 0, 0, 1, 9, 5, 0, 0, 0],
        [0, 9, 8, 0, 0, 0, 0, 6, 0],
        [8, 0, 0, 0, 6, 0, 0, 0, 3],
        [4, 0, 0, 8, 0, 3, 0, 0, 1],
        [7, 0, 0, 0, 2, 0, 0, 0, 6],
        [0, 6, 0, 0, 0, 0, 2, 8, 0],
        [0, 0, 0, 4, 1, 9, 0, 0, 5],
        [0, 0, 0, 0, 8, 0, 0, 7, 9]
    ]
    @State private var data: [[Int]] = [
        [5, 3, 0, 0, 7, 0, 0, 0, 0],
        [6, 0, 0, 1, 9, 5, 0, 0, 0],
        [0, 9, 8, 0, 0, 0, 0, 6, 0],
        [8, 0, 0, 0, 6, 0, 0, 0, 3],
        [4, 0, 0, 8, 0, 3, 0, 0, 1],
        [7, 0, 0, 0, 2, 0, 0, 0, 6],
        [0, 6, 0, 0, 0, 0, 2, 8, 0],
        [0, 0, 0, 4, 1, 9, 0, 0, 5],
        [0, 0, 0, 0, 8, 0, 0, 7, 9]
    ]
    @State private var index = 0
    @State private var accentColor: Color = Color.accentColor
    private let customFont = "Futura"
    @State private var selected: [Int] = [4,4]
    @State private var mode: Mode = .start
    @State private var showHelp = true
    @State private var showErrorMsg = false
    @State private var gridWidth = 300.0
    @State private var cellWidth = 25.0
    @State private var rowWidth = 50.0
    
    var body: some View {
        ZStack {
            VStack(spacing: 10) {
                Spacer()
                HStack {
                    Spacer()
                    HStack(alignment: .center) {
                        Text("sudoku")
                            .font(.custom(customFont, size: horizontalSizeClass == .compact ? 32 : 45, relativeTo: .title))
                        Spacer()
                        Text(timerManager.convertedTime())
                            .frame(width: 70)
                            .font(.system(size: horizontalSizeClass == .compact ? 18 : 25))
                        Menu {
                            Button("new", action: newSudoku)
                            Button("pause", action: pauseSudoku)
                            Button("solve", action: solveSudoku)
                        } label: {
                            Image(systemName: "line.3.horizontal.circle.fill")
                                .font(.system(size: horizontalSizeClass == .compact ? 25 : 35))
                                .foregroundColor(accentColor)
                        }
                    }.frame(width: gridWidth)
                    Spacer()
                }
                ZStack {
                    Image("frame")
                        .resizable()
                        .frame(width: gridWidth, height: gridWidth)
                    VStack {
                        ForEach(0...8, id:\.self) { row in
                            HStack {
                                ForEach(0...8, id:\.self) { col in
                                    Button(action: {
                                        //print(row,col)
                                        selected = [row, col]
                                    }) {
                                        Text(data[row][col] == 0 ? " " : String(data[row][col]))
                                            .frame(width: cellWidth, height: cellWidth)
                                            .foregroundColor(getFontColor(rowInt: row, colInt: col, selectedInt: selected))
                                            .font(.system(size: horizontalSizeClass == .compact ? 20 : 28))
                                    }.background(getBGColor(rowInt: row, colInt: col, selectedInt: selected))
                                }
                            }
                        }
                    }
                }
                //keyboard
                HStack {
                    if horizontalSizeClass != .compact {
                        Spacer(minLength: 180)
                    }
                    LazyVGrid(columns: rows, spacing: 25) {
                        Button(action: {
                            showHelp.toggle()
                        }) {
                            Text("?")
                                .foregroundColor(showHelp ? accentColor : .gray)
                                .frame(width: rowWidth)
                                .font(.system(size: 20, weight: .semibold))
                        }
                        ForEach(1...9, id:\.self) { num in
                            Button(action: {
                                if data[selected[0]][selected[1]] == 0 {
                                    if sudokuLogic.numIsAllowed(grid: data, row: selected[0], col: selected[1], num: num) {
                                        data[selected[0]][selected[1]] = num
                                    } else {
                                        if !showHelp {
                                            data[selected[0]][selected[1]] = num
                                            showErrorMsg = true
                                            let delay = 2 //errorMsg should disappear again
                                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(delay)) {
                                                showErrorMsg = false
                                            }
                                        }
                                    }
                                }
                                //check if Sudoku is solved
                                if sudokuLogic.isSolved(grid: data) {
                                    timerManager.stop()
                                    mode = .solved
                                }
                            }) {
                                Text(num.description)
                                    .foregroundColor(getTextColorKeyboard(selectedInt: selected, showhelp: showHelp, num: num))
                                    .frame(width: rowWidth, height: rowWidth)
                                    .background(Color.black.opacity(0.08))
                                    .font(.system(size: 20))
                            }
                            if num == 5 && horizontalSizeClass == .compact {
                                Button(action: {
                                    if data[selected[0]][selected[1]] != sourceData[selected[0]][selected[1]] {
                                        data[selected[0]][selected[1]] = 0
                                        print("deleted")
                                    }
                                }) {
                                    Text("x")
                                        .foregroundColor(data[selected[0]][selected[1]] == 0 || data[selected[0]][selected[1]]  == sourceData[selected[0]][selected[1]] ? .gray : .red)
                                        .frame(width: rowWidth)
                                        .font(.system(size: 20, weight: .semibold))
                                }
                            }
                        }.padding(.horizontal)
                        if horizontalSizeClass != .compact {
                            Button(action: {
                                if data[selected[0]][selected[1]] != sourceData[selected[0]][selected[1]] {
                                    data[selected[0]][selected[1]] = 0
                                    print("deleted")
                                }
                            }) {
                                Text("x")
                                    .foregroundColor(data[selected[0]][selected[1]] == 0 || data[selected[0]][selected[1]]  == sourceData[selected[0]][selected[1]] ? .gray : .red)
                                    .frame(width: rowWidth)
                                    .font(.system(size: 20, weight: .semibold))
                            }
                        }
                    }.padding()
                    if horizontalSizeClass != .compact {
                        Spacer(minLength: 180)
                    }
                }
                Text(showErrorMsg ? "mistake" : "")
                    .foregroundColor(.red)
                    .font(.system(size: horizontalSizeClass == .compact ? 12 : 18))
                Spacer()
            }.ignoresSafeArea(.all)
                .overlay(Color.gray.opacity(mode != .normal ? 0.4 : 0))
            
            //overlay View
            if mode != .normal {
                VStack(alignment: .center, spacing: horizontalSizeClass == .compact ? 20 : 45) {
                    Text(titleStr[mode.rawValue])
                        .font(.custom(customFont, size: horizontalSizeClass == .compact ? 28 : 45, relativeTo: .title))
                        .bold()
                        .tracking(timerManager.isPaused ? 0 : 10)
                    VStack(spacing: 2) {
                        Text(textStr[mode.rawValue])
                            .font(.custom(customFont, size: horizontalSizeClass == .compact ? 24 : 40, relativeTo: .title3))
                        if mode == .solved {
                            Text("in \(getTimeStr(time: timerManager.convertedTime())).")
                                .font(.custom(customFont, size: horizontalSizeClass == .compact ? 24 : 40, relativeTo: .body))
                        }
                    }
                    if mode == .start {
                        Text("Sudoku is a puzzle consisting of a 9x9 grid with 3x3 subsquares (boxes). The Suduko is partially completed with clues, your task is to fill the grid completely following these rules: \n - only insert numbers from 1 to 9 \n - every number appears only once in each horizontal line, vertical line, and box \n That is all you have to know to solve the sudoku yourself!")
                            .font(.system(size: horizontalSizeClass == .compact ? 12 : 16, weight: .medium))
                            .padding(2)
                            .background(accentColor.opacity(0.1))
                        
                    }
                    HStack {
                        Spacer()
                        ColorPicker(selection: $accentColor, label: {
                            Text("Accentcolor")
                                .font(.system(size: horizontalSizeClass == .compact ? 20 : 30))
                        }).padding(.horizontal)
                        Spacer()
                    }
                    VStack(spacing: 15) {
                        if mode != .paused && mode != .start {
                            Button(action: {
                                mode = .normal
                            }) {
                                Text("look at solved Sudoku")
                                    .font(.system(size: horizontalSizeClass == .compact ? 14 : 18))
                                    .padding(5)
                                    .foregroundColor(accentColor)
                            }
                        }
                        Button(action: {
                            switch mode {
                            case .solved, .solvedWithSolver:
                                //set new sudoku
                                newSudoku()
                            default: //mode == .start, .paused
                                //start sudoku
                                timerManager.start()
                                mode = .normal
                            }
                            
                        }) {
                            Text(buttonStr[mode.rawValue])
                                .bold()
                                .foregroundColor(.white)
                                .font(.system(size: horizontalSizeClass == .compact ? 18 : 25))
                                .background(RoundedRectangle(cornerRadius: horizontalSizeClass == .compact ? 25 : 35)
                                    .frame(width: horizontalSizeClass == .compact ? 150 : 180, height: horizontalSizeClass == .compact ? 40 : 50)
                                    .foregroundColor(accentColor)
                                )
                                
                        }
                    }.padding()
                    
                    VStack {
                        Text("for Swift Student Challenge 2022")
                            .font(.caption)
                            .bold()
                        Text("made by mara")
                            .font(.caption2)
                    }
                }.frame(width: gridWidth + 60, height: gridWidth + 120)
                    .padding()
                    .background(.white)
                    .clipped()
                    .shadow(radius: 5)
            }
        }
        .onAppear {
            if horizontalSizeClass == .compact {
                gridWidth = 300.0
                cellWidth = 25.0
                rows = [
                    GridItem(.adaptive(minimum: 50)),
                    GridItem(.adaptive(minimum: 50))
                ]
                rowWidth = 45.0
            } else {
                gridWidth = 500.0
                cellWidth = 47.5
                rows = [
                    GridItem(.adaptive(minimum: 50))
                ]
                rowWidth = 40.0
            }
        }
    }
    //Button actions
    func newSudoku() {
        //set new sudoku
        if sudoku_array.count != index + 2 { //if not fully filled stop
            index += 2
        } else {
            print("fehler")
        }
        sourceData = sudoku_array[index]
        data = sourceData
        //reset timer
        timerManager.reset()
        timerManager.start()
        mode = .normal
        print("haloo", data)
        
        //generate newe sudoku for next time because it may need some time
        DispatchQueue.global().async {
            //create new sudoku grid and append to sudoku_array
            var newSudoku = generator.getValidSudoku()
            while newSudoku == [] { //new sudoku can fail
                newSudoku = generator.getValidSudoku()
            }
            sudoku_array.append(contentsOf: newSudoku)
        }
    }
    func pauseSudoku() {
        //pause timer and change mode
        timerManager.stop()
        mode = .paused
    }
    func solveSudoku() {
        if solver.solve(grid: data) {
            data = solver.solvedGrid
            timerManager.stop()
            mode = .solvedWithSolver
        }
    }
    
    //UI funcs
    func getFontColor(rowInt: Int, colInt: Int, selectedInt: [Int]) -> Color {
        if rowInt == selectedInt[0] && colInt == selectedInt[1] {
            return accentColor
        } else if data[rowInt][colInt] == sourceData[rowInt][colInt] {
            return .black
        } else {
            return .blue
        }
    }
    func getBGColor(rowInt: Int, colInt: Int, selectedInt: [Int]) -> Color {
        if data[rowInt][colInt] == data[selectedInt[0]][selectedInt[1]] && data[rowInt][colInt] != 0 {
            return .gray.opacity(0.3)
        } else if rowInt == selectedInt[0] && colInt == selectedInt[1] {
            return .gray.opacity(0.3)
        } else {
            return .white
        }
    }
    func getTextColorKeyboard(selectedInt: [Int], showhelp: Bool, num: Int) -> Color {
        if data[selectedInt[0]][selectedInt[1]] == 0  {
            if showHelp {
                if sudokuLogic.numIsAllowed(grid: data, row: selectedInt[0], col: selectedInt[1], num: num) || data[selectedInt[0]][selectedInt[1]] != 0 {
                    return Color.black
                } else {
                    return Color.gray.opacity(0.4)
                }
            } else {
                return Color.black
            }
        }
        return Color.gray.opacity(0.4)
    }
    func getTimeStr(time: String) -> String {
        if time.dropLast(3) == "00" {
            return "\(time.dropFirst(3)) seconds"
        }
        return "\(time) minutes"
    }
}

