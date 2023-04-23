//
//  JsMath.swift
//  Recos
//
//  Created by anwenhu on 2023/4/19.
//

import Foundation

class JsMath : MemberProvider {
    func getMemeber(name: String) -> Any? {
        if name == "floor" {
            return NativeMemberInvoker { args in
                if args?[0] is Float {
                    return round(args?[0] as! Float)
                }
                return args?[0]
            }
        }
        return nil
    }

    func memberSetter(name: String) -> MemberInvoker {
        let memberInvoker: MemberInvoker = {(it: Any?) -> Void in
            
        }
        return memberInvoker
    }
}
