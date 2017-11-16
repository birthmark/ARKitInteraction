/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Popover view controller for choosing virtual objects to place in the AR scene.
*/

import UIKit

// MARK: - ObjectCell

class ObjectCell: UITableViewCell {
    static let reuseIdentifier = "ObjectCell"
    
    var objectTitleLabel: UILabel!
    var objectImageView: UIImageView!
    

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier:reuseIdentifier)
        self.setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setupViews() {
        objectTitleLabel = UILabel.init(frame: CGRect.init(x: 50, y: 0, width: self.width-60, height: self.height))
        self.contentView.addSubview(objectTitleLabel)
        
        objectImageView = UIImageView.init(frame: CGRect.init(x: 10, y: 5, width: 30, height: 30))
        self.contentView.addSubview(objectImageView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.objectImageView.centerY = self.height/2
    }
    
    var modelName = "" {
        didSet {
            objectTitleLabel.text = modelName.capitalized
            if let icon = UIImage(named: modelName) {
                objectImageView.image = icon
            } else {
                objectImageView.image = UIImage(named: "emoji_3d")
            }
        }
    }
}

// MARK: - VirtualObjectSelectionViewControllerDelegate

/// A protocol for reporting which objects have been selected.
protocol EmojiSelectionDelegate: class {
    func emojiSelectionVC(_ VC: EmojiSelectionVC, didSelectObject: BaseNode)
    func emojiSelectionVC(_ VC: EmojiSelectionVC, didDeselectObject: BaseNode)
}

/// A custom table view controller to allow users to select `VirtualObject`s for placement in the scene.
class EmojiSelectionVC: UITableViewController {
    
    /// The collection of `VirtualObject`s to select from.
    var virtualObjects = [BaseNode]()
    
    /// The rows of the currently selected `VirtualObject`s.
    var selectedEmojiObjectRows = IndexSet()
    
    weak var delegate: EmojiSelectionDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(ObjectCell.classForCoder(), forCellReuseIdentifier: ObjectCell.reuseIdentifier)
        tableView.separatorEffect = UIVibrancyEffect(blurEffect: UIBlurEffect(style: .light))
    }
    
    override func viewWillLayoutSubviews() {
        preferredContentSize = CGSize(width: 250, height: tableView.contentSize.height)
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let object = virtualObjects[indexPath.row]
        
        // Check if the current row is already selected, then deselect it.
        if selectedEmojiObjectRows.contains(indexPath.row) {
            delegate?.emojiSelectionVC(self, didDeselectObject: object)
        } else {
            delegate?.emojiSelectionVC(self, didSelectObject: object)
        }

        dismiss(animated: true, completion: nil)
    }
        
    // MARK: - UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return virtualObjects.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ObjectCell.reuseIdentifier, for: indexPath) as? ObjectCell else {
            fatalError("Expected `\(ObjectCell.self)` type for reuseIdentifier \(ObjectCell.reuseIdentifier). Check the configuration in Main.storyboard.")
        }
        
        cell.modelName = virtualObjects[indexPath.row].modelName

        if selectedEmojiObjectRows.contains(indexPath.row) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
    }
    
    override func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.backgroundColor = .clear
    }
}
