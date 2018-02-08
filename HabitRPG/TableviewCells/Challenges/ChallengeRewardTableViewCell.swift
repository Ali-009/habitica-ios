//
//  ChallengeRewardTableViewCell.swift
//  Habitica
//
//  Created by Elliot Schrock on 2/8/18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit
import Down

class ChallengeRewardTableViewCell: UITableViewCell {
    @IBOutlet weak var rewardLabel: UILabel!
    @IBOutlet weak var rewardSubtitleLabel: UILabel!
    @IBOutlet weak var currencyCount: HRPGCurrencyCountView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        currencyCount.orientation = .vertical
    }
    
    public func configure(reward: ChallengeTask) {
        rewardLabel.attributedText = try? Down(markdownString: (reward.text ?? "").unicodeEmoji).toHabiticaAttributedString()
        rewardSubtitleLabel.text = reward.notes
        currencyCount.amount = reward.value?.intValue ?? -1
    }
    
}
