public struct WinProbability: Sendable, Equatable {
    public let white: Double
    public let draw: Double
    public let black: Double

    public init(white: Double, draw: Double, black: Double) {
        self.white = white
        self.draw = draw
        self.black = black
    }
}
