//
//  RenderElement.swift
//  Recos
//
//  Created by wenhuan on 2021/7/26.
//

import Foundation
import SwiftUI

protocol RenderElement {
    func Render() -> AnyView?
}

class JsxRenderElement : RenderElement {
    var jsEvaluator: JsEvaluator
    var name: String
    var props: [String : Any]
    var children: [RenderElement]?
    
    init(jsEvaluator: JsEvaluator, name: String, props: [String : Any], children: [RenderElement]?) {
        self.jsEvaluator = jsEvaluator
        self.name = name
        self.props = props
        self.children = children
    }
    
    func loadMore() {
        
    }
    
    func Render() -> AnyView? {
        var style: JsObject?
        
        switch name {
            case "RecyclerView":
                let count = props["count"] as? Int ?? 0
                if count == 0 {
                    return nil
                } else {
                    let list = ScrollView {
                        LazyVStack(alignment: .leading) {
                            ForEach(0..<count) { index in
                                let child = self.props["render"] as? JsFunctionDecl
                                if (child != nil) {
                                    EvalView(functionDecl: child!, args: [index], evaluator: self.jsEvaluator)
                                }
                            }
//                            Button(action: self.loadMore) {
//                                Text("你好")
//                            }.onAppear {
//                                DispatchQueue.global(qos: .background).asyncAfter(deadline: DispatchTime(uptimeNanoseconds: 10)) {
//
//                                }
//                            }
                        }
                    }
                    return AnyView(list)
                }
            case "Text":
                style = self.props["style"] as? JsObject
                var textString = String()
                children?.forEach({ item in
                    let value = (item as! JsxValueRenderElement).value
                    if value is JsxText {
                        textString.append((value as! JsxText).text)
                    } else if value is Float {
                        textString.append(String(value as! Float))
                    } else if value is Int {
                        textString.append(String(value as! Int))
                    } else if value is String {
                        textString.append(value as! String)
                    }
                })
                let functionDecl = (props["onClick"] as? JsFunctionDecl)
                let jsStyle = style?.toJsStyle() ?? JsStyle()
                return createText(style: jsStyle, functionDecl: functionDecl, textString: textString)
            case "Image":
                style = self.props["style"] as? JsObject
                let height = style?.getValue(variable: "height") as? Float ?? 0
                let width = style?.getValue(variable: "width") as? Float ?? 0
                let raidus = style?.getValue(variable: "borderRadius") as? Float ?? 0
                let url = self.props["source"] as? String
                return AnyView(EvalImage(url: url ?? "", placeholder: "placeholder", width: CGFloat(width), height: CGFloat(height), borderRadius: CGFloat(raidus)))
            case "Button":
                style = self.props["style"] as? JsObject
                var textString = String()
                children?.forEach({ item in
                    let value = (item as! JsxValueRenderElement).value
                    if value is JsxText {
                        textString.append((value as! JsxText).text)
                    } else if value is Float {
                        textString.append(String(value as! Float))
                    } else if value is Int {
                        textString.append(String(value as! Int))
                    } else {
                        textString.append(value as! String)
                    }
                })
                let functionDecl = (props["onPress"] as? JsFunctionDecl)
                let jsStyle = style?.toJsStyle() ?? JsStyle()
                return createButton(style: jsStyle, functionDecl: functionDecl, textString: textString)
            case "View":
                style = self.props["style"] as? JsObject
                var renderItemArray = [JsxRenderElement]()
                var keys = [String]()
                if children != nil {
                    for (index, item) in children!.enumerated() {
                        if item is JsxRenderElement {
                            let jsxRenderItem = item as! JsxRenderElement
                            renderItemArray.append(jsxRenderItem)
                            var name = String(jsxRenderItem.name)
                            name.append(String(index))
                            keys.append(name)
                        } else if item is JsxValueRenderElement {
                            let subValue = (item as! JsxValueRenderElement).value
                            if subValue is JsArray {
                                let array = subValue as! JsArray
                                for item in array.list {
                                    if item is JsxRenderElement {
                                        let jsxRenderItem = item as! JsxRenderElement
                                        renderItemArray.append(jsxRenderItem)
                                        var name = String(jsxRenderItem.name)
                                        name.append(String(index))
                                        keys.append(name)
                                    }
                                }
                            }
                        }
                    }
                }
                return AnyView(DefaultFlexBoxView(keys: keys, data: renderItemArray, style: style))
            case "Crossfade":
                print("Crossfade")
                let functionDecl = (props["content"] as? JsFunctionDecl)
                return AnyView(EvalView(functionDecl: functionDecl!, args: [false], evaluator: self.jsEvaluator))
            default:
                break
        }
        return nil
    }
    
    func createText(style: JsStyle, functionDecl: JsFunctionDecl?, textString: String) -> AnyView {
        let text = Text(textString)
            .kerning(style.letterSpacing)
            .frame(width: style.width, height: style.height, alignment: style.textAlign)
            .font(style.font)
            .foregroundColor(style.fontColor)
            .background(style.backgroundColor)
            .lineSpacing(style.lineHeight)
            .padding(style.margin)
            .padding(.top, style.marginTop)
            .padding(.bottom, style.marginBottom)
            .padding(.leading, style.marginLeft)
            .padding(.trailing, style.marginRight)
            .onTapGesture {
                if functionDecl != nil {
                    functionDecl?.parentScope?.setExtraVarToHeadScope(variable: JsVariable(name: "needUpdate", kind: VariableKind.CONST, value: true))
                    self.jsEvaluator.normalEval(functionDecl: functionDecl!, args: nil, selfValue: nil)
                }
            }
        //        }.if(paddingHorizontal > 0) { content in
        //            content.padding(.top, CGFloat(paddingHorizontal)).padding(.bottom, CGFloat(paddingHorizontal))
        //        }.if(paddingVertical > 0) { content in
        //            content.padding(.leading, CGFloat(paddingVertical)).padding(.trailing, CGFloat(paddingVertical))
        //        }.if(borderWidth > 0 || borderRadius > 0) { content in
        //            content.overlay(
        //                RoundedRectangle(cornerRadius: CGFloat(borderRadius)).stroke(lineWidth: CGFloat(borderWidth)).if(borderColor != nil) { content in
        //                    content.foregroundColor(Color(borderColor!))
        //                }
        //            )
        //        }
        return AnyView(text)
    }
    
    func createButton(style: JsStyle, functionDecl: JsFunctionDecl?, textString: String) -> AnyView {
        let button = Button(action: {
            if (functionDecl != nil) {
                print("click button")
                functionDecl?.parentScope?.parentScope?.parentScope?.addVar(variable: JsVariable(name: "needUpdate", kind: VariableKind.CONST, value: true))
                self.jsEvaluator.normalEval(functionDecl: functionDecl!, args: nil, selfValue: nil)
            }
        }) {
            Text(textString)
        }
        .frame(width: style.width, height: style.height)
        .background(style.backgroundColor)
        .foregroundColor(style.fontColor)
        .font(style.font)
        return AnyView(button)
    }
}

class JsxValueRenderElement : RenderElement {
    var value: Any?
    
    init(value: Any?) {
        self.value = value
    }
    
    func Render() -> AnyView? {
        if value is JsxRenderElement {
            return (value as! JsxRenderElement).Render()
        } else if value is JsArray {
            let jsArray = value as! JsArray
            for (index, _) in jsArray.list.enumerated() {
                (jsArray.get(index: index) as? JsxRenderElement)?.Render()
            }
        }
        return nil
    }
}

class FunctionDeclRenderElement : RenderElement {
    var jsEvaluator: JsEvaluator
    var functionDecl: JsFunctionDecl
    var args: [Any]?
    
    init(jsEvaluator: JsEvaluator, functionDecl: JsFunctionDecl, args: [Any]?) {
        self.jsEvaluator = jsEvaluator
        self.functionDecl = functionDecl
        self.args = args
    }
    
    func Render() -> AnyView? {
        return AnyView(EvalView(functionDecl: functionDecl, args: args, evaluator: jsEvaluator))
    }
}
