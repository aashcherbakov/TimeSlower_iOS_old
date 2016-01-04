//
//  EditActivityNameCell.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 1/2/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import UIKit

class EditActivityNameCell: UITableViewCell {

    @IBOutlet weak var textFieldView: TextfieldView!
    @IBOutlet weak var defaultActivitySelectorView: DefaultActivitySelector!
    
    private(set) var selectedName: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        textFieldView.setup(withType: .ActivityName)
    }
    
    func setupWithActivityName(name: String?) {
        
    }
    
}
