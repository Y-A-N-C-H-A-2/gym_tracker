import SwiftUI

extension Color {
    static let volt       = Color(red: 200/255, green: 247/255, blue: 44/255)
    static let bgMain     = Color(red: 13/255,  green: 14/255,  blue: 16/255)
    static let surface    = Color(red: 22/255,  green: 24/255,  blue: 28/255)
    static let surface2   = Color(red: 34/255,  green: 37/255,  blue: 43/255)
    static let cardDone   = Color(red: 24/255,  green: 29/255,  blue: 18/255)
    static let borderCol  = Color(red: 42/255,  green: 45/255,  blue: 51/255)
    static let textDim    = Color(red: 136/255, green: 141/255, blue: 148/255)
    static let textFaint  = Color(red: 107/255, green: 112/255, blue: 119/255)
    static let textGhost  = Color(red: 77/255,  green: 81/255,  blue: 88/255)
    static let restOrange = Color(red: 255/255, green: 122/255, blue: 47/255)
    static let restText   = Color(red: 255/255, green: 138/255, blue: 79/255)
    static let watchBlue  = Color(red: 125/255, green: 181/255, blue: 255/255)
    static let darkOnVolt = Color(red: 21/255,  green: 24/255,  blue: 10/255)
    static let darkOnTimer = Color(red: 21/255, green: 17/255,  blue: 10/255)
}

extension Font {
    /// Stand-in for the design's Barlow Condensed: the system font in its condensed width.
    static func condensed(_ size: CGFloat, _ weight: Font.Weight = .bold) -> Font {
        .system(size: size, weight: weight).width(.condensed)
    }
}
