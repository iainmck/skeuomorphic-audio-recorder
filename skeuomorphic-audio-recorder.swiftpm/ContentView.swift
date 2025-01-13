import SwiftUI

private let shadowScale: CGFloat = 1.0

struct ContentView: View {
    @StateObject var ctrl = Controller()
    
    private func onViewLoad() {
        ctrl.initializeAudio()
    }
    
    let mainHue: Double = 223
    let displayColor = Color(hex: 0xDDF2E2)
    var scale: CGFloat { ctrl.isScaled ? 1.3 : 1.0 }
    
    var body: some View {
        VStack {
            RecorderBox {
                VStack(spacing: 4) {
                    SpeakerGrid(hue: mainHue)
                    DisplayPanel(isRecording: ctrl.isRecording, audioLevel: ctrl.audioLevel, textColor: displayColor)
                    HStack(spacing: 4) {
                        ButtonCell { ctrl.isScaled.toggle() } content: {
                            ControlButton(icon: .play, hue: mainHue)
                        }
                        ButtonCell { ctrl.stop() } content: {
                            ControlButton(icon: .stop, hue: mainHue)
                        }
                        ButtonCell { ctrl.toggle() } content: {
                            ControlButton(icon: .record, hue: mainHue)
                        }
                    }
                }
                .padding(4)
            }
            .padding(25)
            .frame(height: 315).frame(maxWidth: 500)
            .scaleEffect(CGSize(width: scale, height: scale))
        }
        .frame(maxWidth: .infinity)
        .onAppear { onViewLoad() }
    }
}

struct RecorderBox<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .background(
                Color(hue: 223/360, saturation: 0.1, brightness: 0.1)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .shadow(color: .black.opacity(0.7), radius: shadowScale, x: -1, y: 0)
                    .shadow(color: .black.opacity(0.7), radius: shadowScale, x: 1, y: 1)
            )
            .padding(16)
            .background {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(hue: 223/360, saturation: 0.1, brightness: 0.8))
                    .withNoise().clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: Color.black.opacity(0.4), radius: 15 * shadowScale, x: 4, y: 3)
            }
            .innerShadow(radius: 12, spread: 8)
    }
}

struct SpeakerGrid: View {
    let hue: Double
    let columns = Array(repeating: GridItem(.flexible(), spacing: 2), count: 15)
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 2) {
            ForEach(0..<105, id: \.self) { _ in
                Circle()
                    .fill(Color(hue: hue/360, saturation: 0.1, brightness: 0.1))
                    .shadow(color: Color(hue: hue/360, saturation: 0.1, brightness: 0.7), radius: 1, x: 0, y: -1)
                    .shadow(color: Color(hue: hue/360, saturation: 0.1, brightness: 1.0), radius: 1, x: 0, y: 1)
                    .frame(width: 8, height: 8)
            }
        }
        .padding(8)
        .background(Color(hue: hue/360, saturation: 0.1, brightness: 0.8))
        .withNoise(opacity: 0.2)
        .clipShape(RoundedRectangle(cornerRadius: 4))
        .innerShadow(radius: 4)
    }
}

struct DisplayPanel: View {
    let isRecording: Bool
    let audioLevel: Float
    let textColor: Color
    
    let bghue: CGFloat = 133
    
    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(Color.red)
                .frame(width: 16, height: 16)
                .opacity(isRecording ? 1 : 0.2)
                .background(Circle().fill(.black).opacity(0.5))
                .overlay(
                    Circle()
                        .stroke(Color.red, lineWidth: 4)
                        .opacity(0.2)
                        .glow(color: isRecording ? .red : .clear, radius: 10)
                )
                .overlay(
                    Circle().fill(Color.white).frame(width: 4, height: 2).offset(x: -1, y: -2)
                        .glow(color: isRecording ? .white : .red, radius: 3)
                        .opacity(isRecording ? 0.5 : 0.1)
                        .animation(.easeOut, value: isRecording)
                )
                .blur(radius: 0.15)
            
            HStack {
                VStack {
                    Text(isRecording ? "Recording" : "Paused")
                        .font(.digital(20))
                        .kerning(0.5).offset(y: 1)
                        .foregroundColor(textColor.opacity(0.8))
                        .shadow(color: .white.opacity(0.5), radius: 2)
                        .glow(color: .white.opacity(0.1), radius: 3)
                        .animation(.snappy(duration: 0.2), value: isRecording)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                AudioLevel(level: audioLevel, textColor: textColor)
            }
            .padding(.horizontal, 10)
            .overlay {
                Image("dot-grid") // Add your noise texture image to your assets
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .colorInvert()
                    .opacity(0.05)
                    .allowsHitTesting(false)
            }
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hue: bghue/360, saturation: 0.2, brightness: 0.15),
                    Color(hue: bghue/360, saturation: 0.2, brightness: 0.12)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        
        .overlay {
            Rectangle().fill(LinearGradient(colors: [Color.white.opacity(0.0), Color.white.opacity(0.05)], startPoint: .top, endPoint: .bottom)).frame(width: 500, height: 100).offset(y: -50).rotationEffect(.init(degrees: -20))
        }
        
        .clipShape(RoundedRectangle(cornerRadius: 2))
        .innerShadow(radius: 2, spread: 2, opacity: 0.6)
    }
}

struct AudioLevel: View {
    let level: Float // 0 to 1
    let textColor: Color
    
    let levels: Int = 5
    var quantizedLevel: Int { Int(ceil(level * Float(levels))) }
    
    let warningColor = Color(hex: 0xB23D0E)
    
    var body: some View {
        VStack(spacing: 2) {
            ForEach(0..<levels, id: \.self) { step in
                let upsideDownStep = levels - step
                let active = upsideDownStep <= quantizedLevel
                
                RoundedRectangle(cornerRadius: 1)
                    .fill((step == 0 ? warningColor : textColor).opacity(active ? 0.8 : 0.2))
                    .frame(width: 24, height: 4)
                    .glow(color: (step == 0 ? Color.red : Color.white).opacity(active ? (step == 0 ? 0.3 : 0.2) : 0.0), radius: 3)
            }
        }
        .frame(height: 20)
    }
}

struct ButtonCell<Content: View>: View {
    let content: Content
    var action: () -> Void
    
    init(action: @escaping () -> Void, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.action = action
    }
    
    var body: some View {
        content
            .padding(10)
            .frame(maxWidth: .infinity)
            .background(Color(hue: 223/360, saturation: 0.1, brightness: 0.8))
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .innerShadow(radius: 4)
            .pressAnimation(scale: 0.96, action: action)
    }
}

struct ControlButton: View {
    enum IconType {
        case play, stop, record
    }
    
    let icon: IconType
    let hue: Double
    
    var iconPath: some View {
        switch icon {
        case .play:
            return AnyView(
                Image(systemName: "camera.fill").font(.system(size: 14)).opacity(0.75)
                    .foregroundStyle(.black.opacity(0.9))
            )
        case .stop:
            return AnyView(
                Image(systemName: "stop.fill").font(.system(size: 15)).opacity(0.8)
                    .foregroundStyle(.black.opacity(0.9))
            )
        case .record:
            return AnyView(
                Circle()
                    .fill(Color(hex: 0xCE0A0A))
                    .frame(width: 12, height: 12)
                    .overlay {
                        Circle()
                            .fill(RadialGradient(colors: [Color(hue: hue/360, saturation: 0.2, brightness: 0.7), .clear], center: .center, startRadius: -1, endRadius: 5)
                            )
                            .opacity(0.4)
                    }
            )
        }
    }
    
    var body: some View {
        iconPath
            .shadow(color: .white, radius: 1)
            .frame(width: 24, height: 24)
            .scaleEffect(1.5)
            .padding(12)
            .background {
                Circle()
                    .fill(Color(hue: hue/360, saturation: 0.1, brightness: 0.8))
                    .shadow(color: Color(hue: hue/360, saturation: 0.1, brightness: 0.6), radius: 2, x: 3, y: 0)
                    .shadow(color: Color(hue: hue/360, saturation: 0.1, brightness: 0.9), radius: 2, x: -2, y: 0)
            }
            .innerShadow(radius: 24, spread: 6, isCircle: true)
    }
}
