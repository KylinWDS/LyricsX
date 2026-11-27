public struct ChineseConverter {
    public enum Option {
        case simplify
        case traditionalize
    }

    public init(options: [Option]) throws {
        // Local compatibility shim. Conversion is disabled to avoid the OpenCC submodule.
    }

    public func convert(_ string: String) -> String {
        return string
    }
}
