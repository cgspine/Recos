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
                for arg in (args ?? []) as Array  {
                    if let arg = arg {
                        print(arg)
                    }
                }
                // todo 临时写
                print("引擎日志", (args?[0]! as? String ?? ""), Date().timeIntervalSince1970)
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
