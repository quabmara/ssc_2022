//
//  Grid Genereator Class.swift
//  sudoku app
//
//  Created by mara on 20.04.22.
//

import Foundation


class Generator: ObservableObject {
    let sudokuLogic = SudokuLogic()
    struct Cell: Equatable {
        let row: Int
        let col: Int
    }

    var solvedGrid: [[Int]] = [[]]

    func isValid(grid: [[Int]]) -> Bool {
        var copy = grid
        var candidateValues: [[Int]] = []
        var emptyCells: [Cell] = []
        var solvedGrids: [[[Int]]] = []
        
        //create list with all valid values of the empty cells
        for row in 0...8 {
            for col in 0...8 {
                if copy[row][col] == 0 {
                    emptyCells.append(Cell(row: row, col: col))
                    var values: [Int] = []
                    for num in 1...9 {
                        if sudokuLogic.numIsAllowed(grid: copy, row: row, col: col, num: num) {
                            values.append(num)
                        }
                    }
                    candidateValues.append(values)
                }
            }
        }
        //print(copy)
        //find empty cell with the feewest valid values
        var fewestValidValues = 0
        for (index, list) in candidateValues.enumerated() {
            if list.count < candidateValues[fewestValidValues].count {
                fewestValidValues = index
            }
        }
        
        if emptyCells != [] {
            let selectedCell = emptyCells[fewestValidValues]
            let listOfValues = candidateValues.remove(at: fewestValidValues)
            
            if listOfValues != [] {
                for value in listOfValues {
                    copy[selectedCell.row][selectedCell.col] = value
                    
                    if isValid(grid: copy) {
                        //found value
                        solvedGrids.append(copy)
                    }
                }
            } else {
                //cell has no candidate values -> grid is unsolvable
                copy[selectedCell.row][selectedCell .col] = 0
                //print("unsolvable")
                return false
            }
            emptyCells.remove(at: 0)
        } else {
            solvedGrid = copy
            solvedGrids.append(copy)
            //grid is filled -> sudoku is solved
        }
        if solvedGrids.count == 2 {
            //print("solvedGrids:", solvedGrids)
            //print("not uniquely solvable")
            return false
        } else {
            return true
        }
    }
    
    var filledGrid: [[Int]] = []
    
    func validFilledGrid(grid: [[Int]]) -> Bool {
        var copy = grid
        var candidateValues: [[Int]] = []
        var emptyCells: [Cell] = []
        
        //create list with all valid values of the empty cells
        for row in 0...8 {
            for col in 0...8 {
                if copy[row][col] == 0 {
                    emptyCells.append(Cell(row: row, col: col))
                    var values: [Int] = []
                    for num in 1...9 {
                        if sudokuLogic.numIsAllowed(grid: copy, row: row, col: col, num: num) {
                            values.append(num)
                        }
                    }
                    candidateValues.append(values)
                }
            }
        }
        
        if emptyCells != [] {
            //find empty cell with the fewest valid values
            var fewestValidValues = 0
            for (index, list) in candidateValues.enumerated() {
                if list.count < candidateValues[fewestValidValues].count {
                    fewestValidValues = index
                }
            }
            //print(copy)
            filledGrid = copy
            if emptyCells != [] {
                let selectedCell = emptyCells[fewestValidValues]
                var listOfValues = candidateValues.remove(at: fewestValidValues)
                
                //print(listOfValues)
                if listOfValues == [] {
                    return false
                }
                let value = listOfValues.remove(at: listOfValues.indices.randomElement()!)
                
                copy[selectedCell.row][selectedCell.col] = value
                
                if !validFilledGrid(grid: copy) {
                    copy[selectedCell.row][selectedCell.col] = 0
                    emptyCells.append(Cell(row: selectedCell.row, col: selectedCell.col))
                    listOfValues.append(value)
                    return false
                }
            }
        }
        return true
    }
    
    
    func generateValidGrid(solution: [[Int]]) -> [[Int]] {
        var copy = solution
        var emptySpaces = 0
        var notValidCount = 0
        
        while emptySpaces < 50 || notValidCount > 3 {
    //        print(isValid(grid: copy))
           // print(copy)
            let row = Int.random(in: 0...8)
            let col = Int.random(in: 0...8)
            var value: Int = 0
        
            if copy[row][col] != 0 {
                value = copy[row][col]
                copy[row][col] = 0
                emptySpaces += 1
                
                if !isValid(grid: copy) {
                    copy[row][col] = value
                    notValidCount += 1
                }
            }
        }
        return copy
    }


    //final func
    func getValidSudoku() -> ([[[Int]]]) {
        let emptyGrid = [
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
        //fill filledGrid with new random numbers
        if validFilledGrid(grid: emptyGrid) {
            //generate grid with blanks frrom filledGrid
            let validSudoku: [[Int]] = generateValidGrid(solution: filledGrid)
            
            //output grids
            print("sudoku:")
            for row in validSudoku {
                print("\(row),")
            }
            print("solution:")
            for row in filledGrid {
                print("\(row),")
            }
            
            return [validSudoku, filledGrid]
        } else {
            print("failed")
        }
        return []
    }

}
