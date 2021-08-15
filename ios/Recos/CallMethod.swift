//
//  CallMethod.swift
//  Recos
//
//  Created by wenhuan on 2021/8/13.
//

import Foundation

struct Recos_Waterfall_Model {
    let content: String
    
    init(content: String) {
        self.content = content
    }
}

class Recos_Waterfall {
    func method() -> [Recos_Waterfall_Model] {
        var array: [Recos_Waterfall_Model] = []
        array.append(Recos_Waterfall_Model(content: "name1"))
        array.append(Recos_Waterfall_Model(content: "name2"))
        array.append(Recos_Waterfall_Model(content: "name3"))
        return array
    }
}
