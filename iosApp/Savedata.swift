//
//  Savedata.swift
//  iosApp
//
//  Created by labinot on 7/19/20.
//  Copyright © 2020 GrFL. All rights reserved.
//

import UIKit

class Note: NSObject {
    var id: Int
    var note: String?
    var date:String?
    
    init(id: Int, note: String?,date:String?){
        self.id = id
        self.note = note
        self.date=date
        
    }
    
}

