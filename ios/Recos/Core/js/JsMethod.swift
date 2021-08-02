//
//  JsMethod.swift
//  Recos
//
//  Created by wenhuan on 2021/7/29.
//

import Foundation

protocol JsMethod {
    func invoke(selfValue: Any?, args: [Any]?) -> Any?
}
//
//class JsUseStateMethod : JsMethod {
//    var stackFrame: JsStackFrame
//
//    func invoke(selfValue: Any?, args: [Any]?) -> Any? {
//
//    }
//}
//
//class JsCallBackMethod: JsMethod {
//    var stackFrame: JsStackFrame
//
//    func invoke(selfValue: Any?, args: [Any]?) -> Any? {
//
//    }
//}
//
//class JsUseEffectMethod: JsMethod {
//    var stackFrame: JsStackFrame
//
//    func invoke(selfValue: Any?, args: [Any]?) -> Any? {
//
//    }
//}
//
//class JsArrayPushMethod: JsMethod {
//    func invoke(selfValue: Any?, args: [Any]?) -> Any? {
//
//    }
//}
