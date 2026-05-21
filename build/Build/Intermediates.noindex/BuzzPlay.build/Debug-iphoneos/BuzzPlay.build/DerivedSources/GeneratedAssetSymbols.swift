import Foundation
#if canImport(AppKit)
import AppKit
#endif
#if canImport(UIKit)
import UIKit
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif
#if canImport(DeveloperToolsSupport)
import DeveloperToolsSupport
#endif

#if SWIFT_PACKAGE
private let resourceBundle = Foundation.Bundle.module
#else
private class ResourceBundleClass {}
private let resourceBundle = Foundation.Bundle(for: ResourceBundleClass.self)
#endif

// MARK: - Color Symbols -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension DeveloperToolsSupport.ColorResource {

    /// The "blueGame" asset catalog color resource.
    static let blueGame = DeveloperToolsSupport.ColorResource(name: "blueGame", bundle: resourceBundle)

    /// The "greenGame" asset catalog color resource.
    static let greenGame = DeveloperToolsSupport.ColorResource(name: "greenGame", bundle: resourceBundle)

    /// The "purpleGame" asset catalog color resource.
    static let purpleGame = DeveloperToolsSupport.ColorResource(name: "purpleGame", bundle: resourceBundle)

    /// The "redGame" asset catalog color resource.
    static let redGame = DeveloperToolsSupport.ColorResource(name: "redGame", bundle: resourceBundle)

    /// The "yellowGame" asset catalog color resource.
    static let yellowGame = DeveloperToolsSupport.ColorResource(name: "yellowGame", bundle: resourceBundle)

}

// MARK: - Image Symbols -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension DeveloperToolsSupport.ImageResource {

    /// The "ButtonTap" asset catalog image resource.
    static let buttonTap = DeveloperToolsSupport.ImageResource(name: "ButtonTap", bundle: resourceBundle)

    /// The "buttonFloor" asset catalog image resource.
    static let buttonFloor = DeveloperToolsSupport.ImageResource(name: "buttonFloor", bundle: resourceBundle)

}

// MARK: - Color Symbol Extensions -

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSColor {

    /// The "blueGame" asset catalog color.
    static var blueGame: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .blueGame)
#else
        .init()
#endif
    }

    /// The "greenGame" asset catalog color.
    static var greenGame: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .greenGame)
#else
        .init()
#endif
    }

    /// The "purpleGame" asset catalog color.
    static var purpleGame: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .purpleGame)
#else
        .init()
#endif
    }

    /// The "redGame" asset catalog color.
    static var redGame: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .redGame)
#else
        .init()
#endif
    }

    /// The "yellowGame" asset catalog color.
    static var yellowGame: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .yellowGame)
#else
        .init()
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIColor {

    /// The "blueGame" asset catalog color.
    static var blueGame: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .blueGame)
#else
        .init()
#endif
    }

    /// The "greenGame" asset catalog color.
    static var greenGame: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .greenGame)
#else
        .init()
#endif
    }

    /// The "purpleGame" asset catalog color.
    static var purpleGame: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .purpleGame)
#else
        .init()
#endif
    }

    /// The "redGame" asset catalog color.
    static var redGame: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .redGame)
#else
        .init()
#endif
    }

    /// The "yellowGame" asset catalog color.
    static var yellowGame: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .yellowGame)
#else
        .init()
#endif
    }

}
#endif

#if canImport(SwiftUI)
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.Color {

    /// The "blueGame" asset catalog color.
    static var blueGame: SwiftUI.Color { .init(.blueGame) }

    /// The "greenGame" asset catalog color.
    static var greenGame: SwiftUI.Color { .init(.greenGame) }

    /// The "purpleGame" asset catalog color.
    static var purpleGame: SwiftUI.Color { .init(.purpleGame) }

    /// The "redGame" asset catalog color.
    static var redGame: SwiftUI.Color { .init(.redGame) }

    /// The "yellowGame" asset catalog color.
    static var yellowGame: SwiftUI.Color { .init(.yellowGame) }

}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.ShapeStyle where Self == SwiftUI.Color {

    /// The "blueGame" asset catalog color.
    static var blueGame: SwiftUI.Color { .init(.blueGame) }

    /// The "greenGame" asset catalog color.
    static var greenGame: SwiftUI.Color { .init(.greenGame) }

    /// The "purpleGame" asset catalog color.
    static var purpleGame: SwiftUI.Color { .init(.purpleGame) }

    /// The "redGame" asset catalog color.
    static var redGame: SwiftUI.Color { .init(.redGame) }

    /// The "yellowGame" asset catalog color.
    static var yellowGame: SwiftUI.Color { .init(.yellowGame) }

}
#endif

// MARK: - Image Symbol Extensions -

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSImage {

    /// The "ButtonTap" asset catalog image.
    static var buttonTap: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .buttonTap)
#else
        .init()
#endif
    }

    /// The "buttonFloor" asset catalog image.
    static var buttonFloor: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .buttonFloor)
#else
        .init()
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIImage {

    /// The "ButtonTap" asset catalog image.
    static var buttonTap: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .buttonTap)
#else
        .init()
#endif
    }

    /// The "buttonFloor" asset catalog image.
    static var buttonFloor: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .buttonFloor)
#else
        .init()
#endif
    }

}
#endif

// MARK: - Thinnable Asset Support -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@available(watchOS, unavailable)
extension DeveloperToolsSupport.ColorResource {

    private init?(thinnableName: Swift.String, bundle: Foundation.Bundle) {
#if canImport(AppKit) && os(macOS)
        if AppKit.NSColor(named: NSColor.Name(thinnableName), bundle: bundle) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#elseif canImport(UIKit) && !os(watchOS)
        if UIKit.UIColor(named: thinnableName, in: bundle, compatibleWith: nil) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSColor {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
#if !targetEnvironment(macCatalyst)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIColor {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
#if !os(watchOS)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(SwiftUI)
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.Color {

    private init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
        if let resource = thinnableResource {
            self.init(resource)
        } else {
            return nil
        }
    }

}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.ShapeStyle where Self == SwiftUI.Color {

    private init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
        if let resource = thinnableResource {
            self.init(resource)
        } else {
            return nil
        }
    }

}
#endif

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@available(watchOS, unavailable)
extension DeveloperToolsSupport.ImageResource {

    private init?(thinnableName: Swift.String, bundle: Foundation.Bundle) {
#if canImport(AppKit) && os(macOS)
        if bundle.image(forResource: NSImage.Name(thinnableName)) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#elseif canImport(UIKit) && !os(watchOS)
        if UIKit.UIImage(named: thinnableName, in: bundle, compatibleWith: nil) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSImage {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ImageResource?) {
#if !targetEnvironment(macCatalyst)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIImage {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ImageResource?) {
#if !os(watchOS)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

