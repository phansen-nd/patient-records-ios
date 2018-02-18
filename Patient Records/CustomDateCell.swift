//
//  CustomDateCell.swift
//  Patient Records
//
//  Created by Patrick Hansen on 2/4/18.
//  Copyright © 2018 Patrick Hansen. All rights reserved.
//

import UIKit
import JTAppleCalendar

class CustomDateCell: JTAppleCell {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var selectedView: UIView!
    @IBOutlet weak var todayView: UIView!
}
