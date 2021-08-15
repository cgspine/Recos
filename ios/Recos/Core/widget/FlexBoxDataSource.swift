//
//  FlexBoxDataSource.swift
//  Recos
//
//  Created by wenhuan on 2021/8/4.
//

import Foundation
import SwiftUI

protocol FlexBoxDataSource {
    func getAnyView(index: Int) -> AnyView
}
