//
//  File.swift
//  sudoku app
//
//  Created by mara on 18.04.22.
//

//: [Previous](@previous)
//: [Next](@next)

import Foundation

class Solver: ObservableObject {
    let sudokuLogic = SudokuLogic()
    var solvedGrid: [[Int]] = [[]]

    func solve(grid: [[Int]]) -> Bool {
        var copy = grid
        var rowInt = 0
        var colInt = 0
        var foundBlankSpace = false
        
        for row in 0...8 {
            for col in 0...8 {
                if grid[row][col] == 0 {
                    rowInt = row
                    colInt = col
                    foundBlankSpace = true
                    break
                }
            }
            if foundBlankSpace {
                break
            }
        }
        if !foundBlankSpace {
            //print(copy)
            solvedGrid = copy
            return true //sudoku is solved
        }
        
        for num in 1...9 {
            if sudokuLogic.numIsAllowed(grid: copy, row: rowInt, col: colInt, num: num) {
                copy[rowInt][colInt] = num
                
                if solve(grid: copy) {
                    return true
                }
                copy[rowInt][colInt] = 0
            }
        }
        return false
    }
}
