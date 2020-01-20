//
//  Meme.swift
//  MemeMe2.0
//
//  Created by Isaac Iniongun on 05/12/2019.
//  Copyright © 2019 Ing Groups. All rights reserved.
//

import UIKit

struct Meme {
    let id: String = UUID().uuidString
    var topText: String
    var bottomText: String
    var originalImage: UIImage
    var memedImage: UIImage
}
