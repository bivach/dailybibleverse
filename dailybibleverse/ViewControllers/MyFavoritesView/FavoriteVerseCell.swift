//
//  FavoriteVerseCell.swift
//  dailybibleverse
//
//  Created by Agustin Bivachi on 31/10/17.
//  Copyright © 2017 Emiliano Bivachi. All rights reserved.
//

import Foundation
import UIKit

class FavoriteVerseCell: UITableViewCell {

    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var verseName: UILabel!
    func configureFor(scriptureData: ScriptureRealm) {
        let verse = "\(scriptureData["book_name"]!) \(scriptureData["span"]!)"
        verseName.text = verse
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let date = formatter.date(from: scriptureData["scripture_date"] as! String)
        
        let formatter2 = DateFormatter()
        formatter2.dateFormat = "yyyy/MM/dd"
        let string = formatter2.string(from: date!)

        dateLabel.text = string
    }
}

