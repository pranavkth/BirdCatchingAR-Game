//
//  Helpers.swift
//  BirdARGame
//
//  Created by Brian Advent on 27.05.18.
//  Copyright © 2018 Brian Advent. All rights reserved.
//

import Foundation

enum GameState:Int {
    case none, spwanBirds
}

func randomPosition (lowerBound lower:Float, upperBound upper:Float) -> Float {
    return Float(arc4random()) / Float(UInt32.max) * (lower - upper) + upper
}

func randomNumber (lowerBound lower:Int, upperBound upper:Int) -> Int {
    return Int(arc4random()) / Int(UInt32.max) * (lower - upper) + upper
}
