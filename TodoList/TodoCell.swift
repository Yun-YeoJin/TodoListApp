

import UIKit

class TodoCell: UITableViewCell {

    @IBOutlet weak var toptitleLabel: UILabel!
    
    @IBOutlet weak var prioirtyView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
      
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

      
    }

}
