//
//  XTableViewCell.swift
//  ff_RW_Sample
//
//  Created by Rube Williams on 4/7/21.
//

import UIKit

class XTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var placeText: UILabel!
    @IBOutlet weak var dateIssued: UILabel!
    
    @IBOutlet weak var longitude: UILabel!
    @IBOutlet weak var latitude: UILabel!
    @IBOutlet weak var densityAltitudeFt: UILabel!
    @IBOutlet weak var pressureHg: UILabel!
    @IBOutlet weak var dewpointC: UILabel!
    @IBOutlet weak var elevationFt: UILabel!
    @IBOutlet weak var relativeHumidity: UILabel!
    @IBOutlet weak var tempC: UILabel!
    @IBOutlet weak var flightRules: UILabel!
    
    @IBOutlet weak var distanceSm: UILabel!
    @IBOutlet weak var prevailingVisSm: UILabel!
    
    @IBOutlet weak var weatherString: UILabel!
    
    @IBOutlet weak var wind_direction: UILabel!
    @IBOutlet weak var wind_from: UILabel!
    @IBOutlet weak var speedKts: UILabel!
    @IBOutlet weak var gustSpeedKts: UILabel!
    @IBOutlet weak var variable: UILabel!
    
    @IBOutlet weak var clay1_alt1: UILabel!
    @IBOutlet weak var clay1_ceil1: UILabel!
    @IBOutlet weak var clay1_cover1: UILabel!
    
    @IBOutlet weak var clay1_alt2: UILabel!
    @IBOutlet weak var clay1_ceil2: UILabel!
    @IBOutlet weak var clay1_cover2: UILabel!
    
    @IBOutlet weak var clay1_alt3: UILabel!
    @IBOutlet weak var clay1_ceil3: UILabel!
    @IBOutlet weak var clay1_cover3: UILabel!
    
    @IBOutlet weak var cloudlayer1_1StackView: UIStackView!
    @IBOutlet weak var cloudlayer1_2StackView: UIStackView!
    @IBOutlet weak var cloudlayer1_3StackView: UIStackView!
    
    @IBOutlet weak var clay2_alt1: UILabel!
    @IBOutlet weak var clay2_ceil1: UILabel!
    @IBOutlet weak var clay2_cover1: UILabel!
    
    @IBOutlet weak var clay2_alt2: UILabel!
    @IBOutlet weak var clay2_ceil2: UILabel!
    @IBOutlet weak var clay2_cover2: UILabel!
    
    @IBOutlet weak var clay2_alt3: UILabel!
    @IBOutlet weak var clay2_ceil3: UILabel!
    @IBOutlet weak var clay2_cover3: UILabel!
    
    @IBOutlet weak var cloudlayer2_1StackView: UIStackView!
    @IBOutlet weak var cloudlayer2_2StackView: UIStackView!
    @IBOutlet weak var cloudlayer2_3StackView: UIStackView!
    
    
   
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
       
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
