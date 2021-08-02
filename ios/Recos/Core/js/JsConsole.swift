//
//  JsConsole.swift
//  Recos
//
//  Created by wenhuan on 2021/8/1.
//

import Foundation

class JsConsole : MemberProvider {
    func getMemeber(name: String) -> Any? {
        if name == "log" {
            return NativeMemberInvoker { args in
                print((args?[0]! as? String ?? "", args?[1]! as? String ?? ""))
                return nil
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
