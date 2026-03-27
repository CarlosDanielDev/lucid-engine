public enum MoveClassification: Sendable, Equatable, Comparable {
    case blunder
    case mistake
    case inaccuracy
    case book
    case good
    case great
    case brilliant

    /// Numeric rank for ordering: higher is better.
    private var rank: Int {
        switch self {
        case .blunder:    return 0
        case .mistake:    return 1
        case .inaccuracy: return 2
        case .book:       return 3
        case .good:       return 4
        case .great:      return 5
        case .brilliant:  return 6
        }
    }

    public static func < (lhs: MoveClassification, rhs: MoveClassification) -> Bool {
        lhs.rank < rhs.rank
    }
}
