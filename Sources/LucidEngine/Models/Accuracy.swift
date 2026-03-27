public struct Accuracy: Sendable, Equatable {
    public let white: Double
    public let black: Double

    public init(white: Double, black: Double) {
        self.white = white
        self.black = black
    }
}
