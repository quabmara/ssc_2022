//
//  SudokuLogic Class.swift
//  sudoku app
//
//  Created by mara on 22.04.22.
//

import Foundation

class SudokuLogic: ObservableObject {
    //checks if num is allowed in cell
    func numIsAllowed(grid: [[Int]], row: Int, col: Int, num: Int) -> Bool {
        return !numIsInRow(grid: grid, row: row, num: num) && !numIsInCol(grid: grid, col: col, num: num) && !numIsInBox(grid: grid, startRow: row - (row % 3), startCol: col - (col % 3), num: num)
    }
    
    //checks if num is already in row
    func numIsInRow(grid: [[Int]], row: Int, num: Int) -> Bool {
        for i in (0...8) {
            if grid[row][i] == num {
                return true
            }
        }
        return false
    }
    
    //checks if num is already in row
    func numIsInCol(grid: [[Int]], col: Int, num: Int) -> Bool {
        for i in (0...8) {
            if grid[i][col] == num {
                return true
            }
        }
        return false
    }
    
    //checks if num is already in box
    func numIsInBox(grid: [[Int]], startRow: Int, startCol: Int, num: Int) -> Bool {
        for row in (0...2) {
            for col in (0...2) {
                if grid[startRow + row][startCol + col] == num {
                    return true
                }
            }
        }
        return false
    }
    
    //checks if sudoku is solved
    func isSolved(grid: [[Int]]) -> Bool {
        var noBlankSpaces = true
        
        for row in (0...8) {
            for col in (0...8) {
                if grid[row][col] == 0 {
                    noBlankSpaces = false
                    break
                }
            }
            if noBlankSpaces == false {
                break
            }
        }
        
        return noBlankSpaces
    }
}
