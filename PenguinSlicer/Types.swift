//
//  Types.swift
//  PenguinSlicer
//
//  Created by Alisher Abdukarimov on 6/30/17.
//  Copyright © 2017 MrAliGorithm. All rights reserved.
//

import Foundation


enum ForceBomb {
    case never, always, random
}

enum SequenceType: Int {
    case oneNoBomb, one, twoWithOneBomb, two, three, four, chain, fastChain
}
