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
    
    func Render() -> AnyView? {
        let view : AnyView?
        var style: JsObject?
        
        switch name {
            case "RecyclerView":
                let count = props["count"] as? Int ?? 0
                if count == 0 {
                    return nil
                } else {
                    let list = List {
                        ForEach(0..<count) { index in
                            let child = self.props["render"] as? JsFunctionDecl
                            if (child != nil) {
                                EvalView(functionDecl: child!, args: [index], evaluator: self.jsEvaluator)
                            }
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
                    } else {
                        textString.append(value as! String)
                    }
                })
                let functionDecl = (props["onClick"] as? JsFunctionDecl)
                return createText(style: style ?? JsObject(), functionDecl: functionDecl, textString: textString)
            case "Image":
                style = self.props["style"] as? JsObject
                let height = style?.getValue(variable: "height") as? Float ?? 0
                let width = style?.getValue(variable: "width") as? Float ?? 0
                let url = self.props["source"] as? String
                return AnyView(EvalImage(url: url ?? "", placeholder: "placeholder", width: CGFloat(width), height: CGFloat(height)))
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
                return createButton(style: style ?? JsObject(), functionDecl: functionDecl, textString: textString)
            case "View":
                print("View")
//                RecosFlexBoxView(alignment: .center, spacing: 10, items: <#T##[_]#>, content: <#T##(Int) -> _#>)
                break
            case "Crossfade":
                print("Crossfade")
                let functionDecl = (props["content"] as? JsFunctionDecl)
                return AnyView(EvalView(functionDecl: functionDecl!, args: [false], evaluator: self.jsEvaluator))
            default:
                break
        }
        return nil
    }
    
    func createButton(style: JsObject, functionDecl: JsFunctionDecl?, textString: String) -> AnyView {
        
        var backgroundColor: UIColor?
        let backgroundColorValue = style.getValue(variable: "backgroundColor") as? String
        if (backgroundColorValue != nil) {
            backgroundColor = UIColor.init(hex: backgroundColorValue!)
        }
        
        var fontColor: UIColor?
        let fontColorValue = style.getValue(variable: "color")
        if fontColorValue != nil {
            fontColor = UIColor.init(hex: fontColorValue as! String)
        }
        
        let width = style.getValue(variable: "width") as? Float ?? 0
        let height = style.getValue(variable: "height") as? Float ?? 0
        
        let button = Button(action: {
            if (functionDecl != nil) {
                print("click button")
                functionDecl?.parentScope?.parentScope?.parentScope?.addVar(variable: JsVariable(name: "needUpdate", kind: VariableKind.CONST, value: true))
                self.jsEvaluator.normalEval(functionDecl: functionDecl!, args: nil, selfValue: nil)
            }
        }) {
            Text(textString)
        }.if(height > 0) { content in
            content.frame(height: CGFloat(height))
        }.if(width > 0) { content in
            content.frame(width: CGFloat(width))
        }.if(backgroundColor != nil) { content in
            content.background(Color(backgroundColor!))
        }.if(fontColor != nil) { content in
            content.foregroundColor(Color(fontColor!))
        }
        
        return AnyView(button)
    }
    
    func createText(style: JsObject, functionDecl: JsFunctionDecl?, textString: String) -> AnyView {
        var backgroundColor: UIColor?
        
        var fontColor: UIColor?
        var textAlign: Alignment = .leading
        
        // TODO
//        let left = style.getValue(variable: "left") as? Float ?? 0
//        let right = style.getValue(variable: "right") as? Float ?? 0
//        let top = style.getValue(variable: "top") as? Float ?? 0
//        let bottom = style.getValue(variable: "bottom") as? Float ?? 0
        
        var borderColor: UIColor?
        
        let width = style.getValue(variable: "width") as? Float ?? 0
        let height = style.getValue(variable: "height") as? Float ?? 0
        let lineHeight = style.getValue(variable: "lineHeight") as? Float ?? 0
        let letterSpacing = style.getValue(variable: "letterSpacing") as? Float ?? 0
        
        let fontSize = style.getValue(variable: "fontSize") as? Float ?? 0
        let fontColorValue = style.getValue(variable: "color")
        if fontColorValue != nil {
            fontColor = UIColor.init(hex: fontColorValue as! String)
        }
        
        var fontWeight: Font.Weight = .regular
        let fontWeightValue = style.getValue(variable: "fontWeight") as? String
        if (fontWeightValue != nil) {
            switch fontWeightValue! {
            case "bold":
                fontWeight = .bold
            case "light":
                fontWeight = .light
            case "medium":
                fontWeight = .medium
            case "normal":
                fontWeight = .regular
            default:
                fontWeight = .regular
            }
        }
        
        let backgroundColorValue = style.getValue(variable: "backgroundColor") as? String
        if (backgroundColorValue != nil) {
            backgroundColor = UIColor.init(hex: backgroundColorValue!)
        }
        
        let paddingLeft = style.getValue(variable: "paddingLeft") as? Float ?? 0
        let paddingRight = style.getValue(variable: "paddingRight") as? Float ?? 0
        let paddingTop = style.getValue(variable: "paddingTop") as? Float ?? 0
        let paddingBottom = style.getValue(variable: "paddingBottom") as? Float ?? 0
        let paddingHorizontal = style.getValue(variable: "paddingHorizontal") as? Float ?? 0
        let paddingVertical = style.getValue(variable: "paddingVertical") as? Float ?? 0
        
        let textAlignValue = style.getValue(variable: "textAlign") as? String
        if textAlignValue != nil {
            switch (textAlignValue!) {
            case "auto":
                textAlign = .leading
                break
            case "center":
                textAlign = .center
                break
            case "right":
                textAlign = .trailing
            case "left":
                textAlign = .leading
                break
            default:
                textAlign = .leading
            }
        }
        
        // border
        let borderWidth = style.getValue(variable: "borderWidth") as? Float ?? 0
        
        // TODO
//        let borderTopWidth = style.getValue(variable: "borderTopWidth") as? Float ?? 0
//        let borderRightWidth = style.getValue(variable: "borderRightWidth") as? Float ?? 0
//        let borderBottomWidth = style.getValue(variable: "borderBttomWidth") as? Float ?? 0
//        let borderLeftWidth = style.getValue(variable: "borderLeftWidth") as? Float ?? 0
        
        let borderRadius = style.getValue(variable: "borderRadius") as? Float ?? 0
        
        let borderColorValue = style.getValue(variable: "borderColor") as? String
        if borderColorValue != nil {
            borderColor = UIColor.init(hex: borderColorValue!)
        }
        
        // TODO
//        let borderTopRadius = style.getValue(variable: "borderTopRadius") as? Float ?? 0
//        let borderRightRadius = style.getValue(variable: "borderRightRadius") as? Float ?? 0
//        let borderBottomRadius = style.getValue(variable: "borderBottomRadius") as? Float ?? 0
//        let borderLeftRadius = style.getValue(variable: "borderLeftRadius") as? Float ?? 0
//        let borderTopLeftRadius = style.getValue(variable: "borderTopLeftRadius") as? Float ?? 0
//        let borderTopRightRadius = style.getValue(variable: "borderTopRightRadius") as? Float ?? 0
//        let borderBottomLeftRadius = style.getValue(variable: "borderBottomLeftRadius") as? Float ?? 0
//        let borderBottomRightRadius = style.getValue(variable: "borderBottomRightRadius") as? Float ?? 0
//
//        var borderTopColor: UIColor?
//        var borderRightColor: UIColor?
//        var borderBottomColor: UIColor?
//        var borderLeftColor: UIColor?
//
//        let borderTopColorValue = style.getValue(variable: "borderTopColor") as? String
//        if borderTopColorValue != nil {
//            borderTopColor = UIColor.init(hex: borderTopColorValue!)
//        }
//
//        let borderRightColorValue = style.getValue(variable: "borderRightColor") as? String
//        if borderRightColorValue != nil {
//            borderRightColor = UIColor.init(hex: borderRightColorValue!)
//        }
//
//        let borderBottomColorValue = style.getValue(variable: "borderBottomColor") as? String
//        if borderBottomColorValue != nil {
//            borderBottomColor = UIColor.init(hex: borderBottomColorValue!)
//        }
//
//        let borderLeftColorValue = style.getValue(variable: "borderLeftColor") as? String
//        if borderLeftColorValue != nil {
//            borderLeftColor = UIColor.init(hex: borderLeftColorValue!)
//        }
//
//        var shadowColor: UIColor?
//        let shadowColorValue = style.getValue(variable: "shadowColor") as? String
//        if shadowColorValue != nil {
//            shadowColor = UIColor.init(hex: shadowColorValue!)
//        }
        
        let text = Text(textString).kerning(CGFloat(letterSpacing)).frame(width: nil, height: nil, alignment: textAlign)
            
        .if(height > 0) { content in
            content.frame(height: CGFloat(height))
        }.if(width > 0) { content in
            content.frame(width: CGFloat(width))
        }.if(functionDecl != nil) { content in
            content.onTapGesture {
                print("click text")
                functionDecl?.parentScope?.setExtraVarToHeadScope(variable: JsVariable(name: "needUpdate", kind: VariableKind.CONST, value: true))
                self.jsEvaluator.normalEval(functionDecl: functionDecl!, args: nil, selfValue: nil)
            }
        }.if(fontSize > 0) { content in
            let font = Font.system(size: CGFloat(fontSize), weight: fontWeight)
            content.font(font)
        }.if(fontColor != nil) { content in
            content.foregroundColor(Color.init(fontColor!))
        }.if(backgroundColor != nil) { content in
            content.background(Color(backgroundColor!))
        }.if(lineHeight > 0) { content in
            content.lineSpacing(CGFloat(lineHeight))
        }.if(paddingLeft > 0) { content in
            content.padding(.leading, CGFloat(paddingLeft))
        }.if(paddingRight > 0) { content in
            content.padding(.trailing, CGFloat(paddingRight))
        }.if(paddingTop > 0) { content in
            content.padding(.top, CGFloat(paddingTop))
        }.if(paddingBottom > 0) { content in
            content.padding(.bottom, CGFloat(paddingBottom))
        }.if(paddingHorizontal > 0) { content in
            content.padding(.top, CGFloat(paddingHorizontal)).padding(.bottom, CGFloat(paddingHorizontal))
        }.if(paddingVertical > 0) { content in
            content.padding(.leading, CGFloat(paddingVertical)).padding(.trailing, CGFloat(paddingVertical))
        }.if(borderWidth > 0 || borderRadius > 0) { content in
            content.overlay(
                RoundedRectangle(cornerRadius: CGFloat(borderRadius)).stroke(lineWidth: CGFloat(borderWidth)).if(borderColor != nil) { content in
                    content.foregroundColor(Color(borderColor!))
                }
            )
        }
        return AnyView(text)
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
            for (index, item) in jsArray.list.enumerated() {
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
