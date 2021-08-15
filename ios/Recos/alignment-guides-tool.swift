// The SwiftUI Lab
// Website: https://swiftui-lab.com
// Article: https://swiftui-lab.com/alignment-guides

import SwiftUI

class Model: ObservableObject {
    @Published var minimumContainer = true
    @Published var extendedTouchBar = false
    @Published var twoPhases = true
    @Published var addImplicitView = false
    @Published var showImplicit = false
    
    @Published var algn: [AlignmentEnum] = [.center, .center, .center]
    @Published var delayedAlgn: [AlignmentEnum] = [.center, .center, .center]
    @Published var frameAlignment: Alignment = .center
    @Published var stackAlignment: HorizontalAlignment = .leading
    
    func nextAlignment() -> Alignment {
        if self.frameAlignment == .leading {
            return .center
        } else if self.frameAlignment == .center {
            return .trailing
        } else {
            return .leading
        }
    }
}

extension Alignment {
    var asString: String {
        switch self {
        case .leading:
            return ".leading"
        case .center:
            return ".center"
        case .trailing:
            return ".trailing"
        default:
            return "unknown"
        }
    }
}

extension HorizontalAlignment {
    var asString: String {
        switch self {
        case .leading:
            return ".leading"
        case .trailing:
            return ".trailing"
        case .center:
            return ".center"
        default:
            return "unknown"
        }
    }
}

extension HorizontalAlignment: Hashable {
    public func hash(into hasher: inout Hasher) {
        switch self {
        case .leading:
            hasher.combine(0)
        case .center:
            hasher.combine(1)
        case .trailing:
            hasher.combine(2)
        default:
            hasher.combine(3)
        }
    }
}

extension Alignment: Hashable {
    public func hash(into hasher: inout Hasher) {
        switch self {
        case .leading:
            hasher.combine(0)
        case .center:
            hasher.combine(1)
        case .trailing:
            hasher.combine(2)
        default:
            hasher.combine(3)
        }
    }
}

struct AlignmentGuidesToolContentView: View {
    
    var body: some View {
        Group {
            if UIDevice.current.userInterfaceIdiom == .pad
            {
                GeometryReader { proxy in
            
                    VStack(spacing: 0) {
                        HStack(spacing: 0) {
                            ControlsView().frame(width: 380).layoutPriority(1).background(Color(UIColor.secondarySystemBackground))

                            DisplayView(width: proxy.size.width - 380).frame(maxWidth: proxy.size.width - 380).clipShape(Rectangle())//.border(Color.green, width: 3)
                            
                        }.frame(height: (proxy.size.height - 300))

                        VStack {
                            CodeView().frame(height: 300)
                        }.frame(width: proxy.size.width, alignment: .center).background(Color(UIColor.secondarySystemBackground))

                        
                    }.environmentObject(Model())
                }
            } else {
                VStack(spacing: 30) {
                    Text("I need an iPad to run!")
                    Text("😟").scaleEffect(2)
                }.font(.largeTitle)
            }
        }
    }
}

struct ControlsView: View {
    @EnvironmentObject var model: Model
    
    var body: some View {
        
        return Form {
            HStack { Spacer(); Text("Settings").font(.title); Spacer() }
            Toggle(isOn: self.$model.minimumContainer, label: { Text("Narrow Container") })
            Toggle(isOn: self.$model.extendedTouchBar, label: { Text("Extended Bar") })
            Toggle(isOn: self.$model.twoPhases, label: { Text("Show in Two Phases") })
            Toggle(isOn: self.$model.addImplicitView, label: { Text("Include Implicitly View") })
            
            if self.model.addImplicitView {
                Toggle(isOn: self.$model.showImplicit, label: { Text("Show Implicit Guides") })//.disabled(!self.model.addImplicitView)
            }
            
            HStack {
                Text("Frame Alignment")
                Picker(selection: self.$model.frameAlignment.animation(), label: EmptyView()) {
                    Text(".leading").tag(Alignment.leading)
                    Text(".center").tag(Alignment.center)
                    Text(".trailing").tag(Alignment.trailing)
                }.pickerStyle(SegmentedPickerStyle())
            }
            
            HStack {
                Text("Stack Alignment")
                Picker(selection: self.$model.stackAlignment.animation(), label: EmptyView()) {
                    Text(".leading").tag(HorizontalAlignment.leading)
                    Text(".center").tag(HorizontalAlignment.center)
                    Text(".trailing").tag(HorizontalAlignment.trailing)
                }.pickerStyle(SegmentedPickerStyle())
            }
        }.padding(10).background(Color(UIColor.secondarySystemBackground))
    }
}

struct CodeView: View {
    @EnvironmentObject var model: Model
    
    var body: some View {
        VStack(alignment: .leading) {
            
            Text("VStack(alignment: \(self.model.stackAlignment.asString) {")
            
            CodeFragment(idx: 0)
            CodeFragment(idx: 1)
            
            if model.addImplicitView {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 0) {
                        Text("    SomeView()").foregroundColor(.primary)
                        Text(".alignmentGuide(\(self.model.stackAlignment.asString), computedValue { d in ")
                        Text("d[\(self.model.stackAlignment.asString)]").padding(5)
                        Text(" }")
                    }.foregroundColor(self.model.showImplicit ? .secondary : .clear)//.transition(AnyTransition.opacity.animation())
                }
            }
            
            CodeFragment(idx: 2)
            
            HStack(spacing: 0) {
                Text("}.frame(alignment: ")
                Text("\(self.model.frameAlignment.asString)").padding(5)
                Text(")")
            }
            
        }
        .font(Font.custom("Menlo", size: 16))
        .padding(20)
    }
}

struct CodeFragment: View {
    @EnvironmentObject var model: Model
    
    var idx: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 0) {
                Text("    SomeView()")
                Text(".alignmentGuide(\(self.model.stackAlignment.asString), computedValue { d in ")
                Text("\(self.model.algn[idx].asString)").padding(5).background(self.model.algn[idx] != self.model.delayedAlgn[idx] ? Color.yellow : Color.clear)
                Text(" }")
            }
        }
    }
}

struct DisplayView: View {
    @EnvironmentObject var model: Model
    let width: CGFloat
    
    var body: some View {
        
        VStack(alignment: self.model.stackAlignment, spacing: 20) {
            
            Block(algn: binding(0)).frame(width: 250)
                .alignmentGuide(self.model.stackAlignment, computeValue: { d in self.model.delayedAlgn[0].computedValue(d) })
            
            Block(algn: binding(1)).frame(width: 200)
                .alignmentGuide(self.model.stackAlignment, computeValue: { d in self.model.delayedAlgn[1].computedValue(d) })
            
            if model.addImplicitView {
                RoundedRectangle(cornerRadius: 8).fill(Color.gray).frame(width: 250, height: 50)
                    .overlay(Text("Implicitly Aligned").foregroundColor(.white))
                    .overlay(Marker(algn: AlignmentEnum.fromHorizontalAlignment(self.model.stackAlignment)).opacity(0.5))
            }
            
            Block(algn: binding(2)).frame(width: 300)
                .alignmentGuide(self.model.stackAlignment, computeValue: { d in self.model.delayedAlgn[2].computedValue(d) })
            
                        
        }.frame(width: self.model.minimumContainer ? nil : width, alignment: self.model.frameAlignment).border(Color.red)
        
    }
    
    func binding(_ idx: Int) -> Binding<AlignmentEnum> {
        return Binding<AlignmentEnum>(get: {
            self.model.algn[idx]
        }, set: { v in
            self.model.algn[idx] = v
            
            let delay = self.model.twoPhases ? 500 : 0
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(delay)) {
                withAnimation(.easeInOut(duration: 0.5)
                ) {
                    self.model.delayedAlgn[idx] = v
                }
            }
        })
    }
    
}

struct Block: View {
    @Binding var algn: AlignmentEnum
    
    let a = Animation.easeInOut(duration: 0.5)
    
    var body: some View {
        let gesture = DragGesture(minimumDistance: 0, coordinateSpace: .local)
            .onEnded({v in
                withAnimation(self.a) {
                    self.algn = .value(v.startLocation.x)
                }
            })
        
        return VStack(spacing: 0) {
            HStack {
                AlignButton(label: "L", action: { withAnimation(self.a) { self.algn = .leading } })
                Spacer()
                AlignButton(label: "C", action: { withAnimation(self.a) { self.algn = .center } })
                Spacer()
                AlignButton(label: "T", action: { withAnimation(self.a) { self.algn = .trailing } })
            }.padding(5)
                .padding(.bottom, 20)
            
        }
        .background(RoundedRectangle(cornerRadius: 8).foregroundColor(.gray))
        .overlay(TouchBar().gesture(gesture))
        .overlay(Marker(algn: algn).opacity(0.5))
    }
}

struct TouchBar: View {
    @EnvironmentObject var model: Model
    
    @State private var flag = false
    
    var body: some View {
        GeometryReader { proxy in
            RoundedRectangle(cornerRadius: 8)
                .foregroundColor(.yellow)
                .frame(width: proxy.size.width + (self.model.extendedTouchBar ? 100 : 0), height: 20)
                .offset(x: 0, y: proxy.size.height / 2.0 - 10)
        }
    }
}


struct AlignButton: View {
    let label: String
    let action: () -> ()
    
    var body: some View {
        Button(action: {
            self.action()
        }, label: {
            Text(label)
                .foregroundColor(.black)
                .padding(10)
                .background(RoundedRectangle(cornerRadius: 8).foregroundColor(.green))
        })
    }
}

struct Marker: View {
    let algn: AlignmentEnum
    
    var body: some View {
        GeometryReader { proxy in
            MarkerLine().offset(x: self.algn.asNumber(width: proxy.size.width))
        }
    }
}

struct MarkerLine: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
                
        p.move(to: CGPoint(x: 0, y: 0))
        p.addLine(to: CGPoint(x: 0, y: rect.maxY))
        p = p.strokedPath(.init(lineWidth: 4, lineCap: .round, lineJoin: .bevel, miterLimit: 1, dash: [6, 6], dashPhase: 3))
        
        return p
    }
}

enum AlignmentEnum: Equatable {
    case leading
    case center
    case trailing
    case value(CGFloat)
    
    var asString: String {
        switch self {
        case .leading:
            return "d[.leading]"
        case .center:
            return "d[.center]"
        case .trailing:
            return "d[.trailing]"
        case .value(let v):
            return "\(v)"
        }
    }
    
    func asNumber(width: CGFloat) -> CGFloat {
        switch self {
        case .leading:
            return 0
        case .center:
            return width / 2.0
        case .trailing:
            return width
        case .value(let v):
            return v
        }
    }
    
    func computedValue(_ d: ViewDimensions) -> CGFloat {
        switch self {
        case .leading:
            return d[.leading]
        case .center:
            return d.width / 2.0
        case .trailing:
            return d[.trailing]
        case .value(let v):
            return v
        }
    }
    
    static func fromHorizontalAlignment(_ a: HorizontalAlignment) -> AlignmentEnum {
        switch a {
        case .leading:
            return .leading
        case .center:
            return .center
        case .trailing:
            return .trailing
        default:
            return .value(0)
        }
    }
}
