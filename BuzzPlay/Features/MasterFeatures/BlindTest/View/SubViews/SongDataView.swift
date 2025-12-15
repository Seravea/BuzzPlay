//
//  SongDataView.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 13/11/2025.
//

import Foundation
import SwiftUI

func songDataToShow(song: Song) -> some View {
    return VStack(alignment: .leading) {
        Text(song.title)
        Text(song.artist)
        Text(song.creationYear)
    }
    .font(.poppins(.title))
    .frame(maxWidth: .infinity)
}
