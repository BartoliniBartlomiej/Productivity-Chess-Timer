import SwiftUI


// 1. Kształt Fali
struct BottomWave: Shape {
    let time: Double
    let amplitude: CGFloat
    let frequency: CGFloat
    let horizontalSpeed: Double
    let baseHeightRatio: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        let baseY = height * baseHeightRatio

        path.move(to: CGPoint(x: 0, y: baseY))

        // Zoptymalizowany krok (by: 5) dla wydajności
        for x in stride(from: 0, through: width, by: 10) {
            let progress = Double(x / width)
            let phase = progress * Double.pi * 2 * Double(frequency)
            let y = baseY + sin(phase + time * horizontalSpeed) * amplitude
            path.addLine(to: CGPoint(x: x, y: y))
        }

        path.addLine(to: CGPoint(x: width, y: height + 100))
        path.addLine(to: CGPoint(x: 0, y: height + 100))
        path.closeSubpath()

        return path
    }
}

var _color1: Color = .cyan.opacity(0.3)
var _color2: Color = .mint.opacity(0.3)
var _color3: Color = colorApp1.opacity(0.3)

struct WaveBackground: View {
    @Environment(\.colorScheme) var colorScheme
    
    var color1: Color
    var color2: Color
    var color3: Color
    //var speedCons: Int
    
    init(
        color1: Color = .blue,
        color2: Color = .mint,
        color3: Color = .teal,
        //speedCons: Int = 1
    ) {
        self.color1 = color1
        self.color2 = color2
        self.color3 = color3
        //self.speedCons = speedCons
    }
    
    var body: some View {
        TimelineView(.animation) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate
            
            ZStack {
                // background
                (colorScheme == .dark ? Color(red: 0.101, green:0.105, blue: 0.107) : Color.white)
                    .ignoresSafeArea()
                
                // wave1
                wave(time: time, amp: 16, freq: 0.2, speed: 0.6, vAmp: 12, vSpeed: 0.6, base: 0.15, color: color1.opacity(0.3))
                
                // wave2
                wave(time: time, amp: 22, freq: 0.5, speed: -0.7, vAmp: 18, vSpeed: 0.4, base: 0.20, color: color2.opacity(0.3))
                
                // wave3
                wave(time: time, amp: 18, freq: 0.8, speed: 1.3, vAmp: 14, vSpeed: 0.8, base: 0.25, color: color3.opacity(0.3))
            }
            .frame(width: 300, height: 400)
        }
        //.ignoresSafeArea()
    }
    
    // helper to building wave
    func wave(
        time: Double,
        amp: CGFloat,
        freq: CGFloat,
        speed: Double,
        vAmp: CGFloat,
        vSpeed: Double,
        base: CGFloat,
        color: Color
    ) -> some View {
        let vDrift = sin(time * vSpeed) * vAmp
        return BottomWave(
            time: time,
            amplitude: amp,
            frequency: freq,
            horizontalSpeed: speed,
            baseHeightRatio: base
        )
            .fill(color)
            .offset(y: vDrift)
    }
}

#Preview {
    WaveBackground()
}
