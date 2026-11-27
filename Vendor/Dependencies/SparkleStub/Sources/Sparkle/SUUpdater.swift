public final class SUUpdater {
    public static func shared() -> SUUpdater? {
        return SUUpdater()
    }

    public init() {}

    public func checkForUpdatesInBackground() {
        // Local compatibility shim. Automatic updates are disabled.
    }

    public func checkForUpdates(_ sender: Any?) {
        // Local compatibility shim. Automatic updates are disabled.
    }
}
