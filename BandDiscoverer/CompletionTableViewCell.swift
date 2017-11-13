//
//  CompletionTableViewCell.swift
//  BandDiscoverer
//
//  Created by Koen Vestjens on 09/11/2017.
//  Copyright © 2017 Koen Vestjens. All rights reserved.
//

import UIKit

class CompletionTableViewCell: UITableViewCell {

    @IBOutlet weak var lblCompletion: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //self.backgroundColor = UIColor.lightGray
        self.backgroundColor = UIColor(red: 0.83, green: 0.83, blue: 0.83, alpha: 0.5)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
