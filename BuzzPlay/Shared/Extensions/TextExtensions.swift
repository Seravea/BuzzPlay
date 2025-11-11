//
//  ViewExtensions.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 10/11/2025.
//

import Foundation
import SwiftUI


enum Style {
    case filled
    case outlined
    case `default`
}



//MARK: Text Extension

extension Text {
    func primaryButtonTextStyle(_ style: Style, fontSize: Typography.Token) -> some View {
        switch style {
        case .filled:
            return self
                .foregroundStyle(.white)
                .textStyle(fontSize)
        case .outlined:
            return self
                .foregroundStyle(Color.darkPurple)
                .textStyle(fontSize)
        case .default:
            return self
                .textStyle(fontSize)
        }
    }
}



// MARK: - Poppins family for App
enum PoppinsWeight: String {
    case thin, extraLight, light, regular, medium, semiBold, bold, extraBold, black

    var baseName: String {
        switch self {
        case .thin:       return "Poppins-Thin"
        case .extraLight: return "Poppins-ExtraLight"
        case .light:      return "Poppins-Light"
        case .regular:    return "Poppins-Regular"
        case .medium:     return "Poppins-Medium"
        case .semiBold:   return "Poppins-SemiBold"
        case .bold:       return "Poppins-Bold"
        case .extraBold:  return "Poppins-ExtraBold"
        case .black:      return "Poppins-Black"
        }
    }

    func name(italic: Bool) -> String { italic ? "\(baseName)Italic" : baseName }
}

// MARK: - Font factory (Dynamic Type friendly)
extension Font {
    static func poppins(_ style: Font.TextStyle,
                        weight: PoppinsWeight = .regular,
                        italic: Bool = false) -> Font {
        .custom(weight.name(italic: italic), size: UIFont.preferredFont(forTextStyle: style.ui).pointSize,
                relativeTo: style)
    }
}

private extension Font.TextStyle {
    var ui: UIFont.TextStyle {
        switch self {
        case .largeTitle: return .largeTitle
        case .title:      return .title1
        case .title2:     return .title2
        case .title3:     return .title3
        case .headline:   return .headline
        case .subheadline:return .subheadline
        case .body:       return .body
        case .callout:    return .callout
        case .footnote:   return .footnote
        case .caption:    return .caption1
        case .caption2:   return .caption2
        @unknown default: return .body
        }
    }
}

// MARK: - Tokens
struct Typography {
    struct Token: Hashable {
        let style: Font.TextStyle
        let weight: PoppinsWeight
        let italic: Bool
        let tracking: CGFloat        // letter spacing (pt)
        let lineSpacing: CGFloat     // extra spacing between lines (pt)

        init(_ style: Font.TextStyle,
             weight: PoppinsWeight = .regular,
             italic: Bool = false,
             tracking: CGFloat = 0,
             lineSpacing: CGFloat = 0) {
            self.style = style
            self.weight = weight
            self.italic = italic
            self.tracking = tracking
            self.lineSpacing = lineSpacing
        }
    }

    // Main set (adapte si besoin)
    static let largeTitle = Token(.largeTitle, weight: .bold, tracking: 0.2)
    static let title = Token(.title,      weight: .regular)
    static let title2 = Token(.title2,     weight: .regular)
    static let title3 = Token(.title3,     weight: .regular)

    static let headline = Token(.headline,   weight: .medium)
    static let body = Token(.body,       weight: .regular)
    static let callout = Token(.callout,    weight: .regular)
    static let subheadline = Token(.subheadline,weight: .regular)

    static let footnote = Token(.footnote,   weight: .regular, tracking: 0.1)
    static let caption = Token(.caption,    weight: .medium,  tracking: 0.1)
    static let caption2 = Token(.caption2,   weight: .medium,  tracking: 0.1)
}

// MARK: - View modifier
struct TextStyleModifier: ViewModifier {
    let token: Typography.Token
    let minimumScale: CGFloat   // pour éviter les truncates

    init(_ token: Typography.Token, minimumScale: CGFloat = 0.85) {
        self.token = token
        self.minimumScale = minimumScale
    }

    func body(content: Content) -> some View {
        content
            .font(.poppins(token.style, weight: token.weight, italic: token.italic))
            .tracking(token.tracking)
            .lineSpacing(token.lineSpacing)
            .minimumScaleFactor(minimumScale)
            .accessibilityAddTraits(token.weight == .bold || token.weight == .semiBold ? .isHeader : [])
    }
}

// MARK: - Convenience API
extension View {
    func textStyle(_ token: Typography.Token, minimumScale: CGFloat = 0.85) -> some View {
        modifier(TextStyleModifier(token, minimumScale: minimumScale))
    }
}

// MARK: - Environment: default app font
private struct AppFontKey: EnvironmentKey {
    static let defaultValue: Typography.Token = .init(.body)
}

extension EnvironmentValues {
    var defaultTextStyle: Typography.Token {
        get { self[AppFontKey.self] }
        set { self[AppFontKey.self] = newValue }
    }
}

extension View {
    /// Définit la typo par défaut de l’app (ex: `.body` Poppins)
    func appDefaultTextStyle(_ token: Typography.Token) -> some View {
        environment(\.defaultTextStyle, token)
            .font(.poppins(token.style, weight: token.weight, italic: token.italic))
    }
}


//MARK: filled
//    .background(.purple)
//    .clipShape(
//        RoundedRectangle(cornerRadius: 8)
//    )

//MARK: outlined
//    .background(.purple)
//    .clipShape(
//        RoundedRectangle(cornerRadius: 8)
//            .stroke(lineWidth: 2)
//    )




