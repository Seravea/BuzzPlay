//
//  TextFieldCustom.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 13/11/2025.
//

import SwiftUI

struct TextFieldCustom: View {
    @Binding var text: String
    var prompt: String
    var widthSize: CGFloat?
    var textSize: Font.TextStyle
    var body: some View {
        TextField("", text: $text, prompt: Text(prompt))
            .font(.poppins(textSize))
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 6)
                    .stroke(lineWidth: 2)
            }
//            .padding()
            .frame(maxWidth: widthSize ?? .infinity)
    }
}

#Preview {
    TextFieldCustom(text: .constant(""), prompt: "Nom de l'équipe", textSize: .largeTitle)
}
