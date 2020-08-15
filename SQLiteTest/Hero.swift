//
//  Hero.swift
//  SQLiteTest
//
//  Created by Aldon Smith on 8/15/20.
//  Copyright © 2020 Aldon Smith. All rights reserved.
//

import Foundation

class Hero {
    var id: Int
    var name: String?
    var powerRanking: Int
    
    init(id: Int, name: String?, powerRanking: Int){
        self.id = id
        self.name = name
        self.powerRanking = powerRanking
    }
}
