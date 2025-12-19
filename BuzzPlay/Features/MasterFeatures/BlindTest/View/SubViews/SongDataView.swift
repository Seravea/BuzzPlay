//
//  SongDataView.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 13/11/2025.
//

import Foundation
import SwiftUI

func songDataToShow(song: BlindTestSong) -> some View {
    return VStack(alignment: .leading) {
        Text(song.title)
        Text(song.artist)
    }
    .font(.poppins(.body))
    .frame(maxWidth: .infinity)
}
