//
//  FlexBox.swift
//  Example
//
//  Created by tigerAndBull on 2021/6/12.
//  Copyright © 2021 tigerAndBull. All rights reserved.
//

import Foundation
import SwiftUI

enum JustifyContent {
    case FlexStart
    case FlexEnd
    case Center
    case SpaceBetween
    case SpaceAround
    case SpaceEvenly
}

enum AlignItems {
    case FlexStart
    case FlexEnd
    case Center
    case Baseline
    case Stretch
}

enum AlignContent {
    case FlexStart
    case FlexEnd
    case Center
    case SpaceBetween
    case SpaceAround
    case SpaceEvenly
    case Stretch
}

enum AlignSelf {
    case Auto
    case FlexStart
    case FlexEnd
    case Center
    case Baseline
    case Stretch
}

enum FlexWrap {
    case Wrap
    case WrapReverse
    case NoWrap
}

enum FlexDirection {
    case Row
    case RowReverse
    case Column
    case ColumnReverse
}

class FlexItem {
    var intrinsicsMainSize: Int = 0
    var intrinsicsCrossSize: Int = 0
    var mainStart: Int = 0
    var crossStart: Int = 0
}

internal class FlexItemOrderModifier {
    var order: Int = 0
}
