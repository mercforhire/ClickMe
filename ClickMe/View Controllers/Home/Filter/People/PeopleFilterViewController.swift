//
//  PeopleFilterViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-07.
//

import UIKit

protocol PeopleFilterViewControllerDelegate: class {
    func peopleFilterPicked(filter: PeopleFilterCriteria)
}

struct PeopleFilterCriteria {
    var distance: Int = 1001
    var gender: GenderChoice?
    var field: UserField?
    
    func exploreEndpointParams(user: CompleteUser) -> ExploreUserParams {
        var params = ExploreUserParams()
        params.distance = distance
        params.gender = gender == .unknown ? nil : gender
        params.languages = user.languages
        params.field = field
        return params
    }
}

class PeopleFilterViewController: BaseViewController {
    var filter: PeopleFilterCriteria = PeopleFilterCriteria()
    
    @IBOutlet weak var genderCollectionView: UICollectionView!
    @IBOutlet weak var genderCollectionHeight: NSLayoutConstraint!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var distanceSlider: UISlider!
    @IBOutlet weak var expertiseCollectionView: UICollectionView!
    @IBOutlet weak var expertiseCollectionHeight: NSLayoutConstraint!
    @IBOutlet weak var applyButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    
    weak var delegate: PeopleFilterViewControllerDelegate?
    private let kItemPadding = 15
    
    static func create(filter: PeopleFilterCriteria, delegate: PeopleFilterViewControllerDelegate?) -> UIViewController {
        let vc = StoryboardManager.loadViewController(storyboard: "Search", viewControllerId: "PeopleFilterViewController") as! PeopleFilterViewController
        vc.filter = filter
        vc.delegate = delegate
        let nc = UINavigationController(rootViewController: vc)
        return nc
    }
    
    override func setup() {
        super.setup()
        
        clearButton.roundCorners()
        
        let bubbleLayout = MICollectionViewBubbleLayout()
        bubbleLayout.minimumLineSpacing = 10.0
        bubbleLayout.minimumInteritemSpacing = 10.0
        bubbleLayout.delegate = self
        genderCollectionView.setCollectionViewLayout(bubbleLayout, animated: false)
        
        let bubbleLayout2 = MICollectionViewBubbleLayout()
        bubbleLayout2.minimumLineSpacing = 10.0
        bubbleLayout2.minimumInteritemSpacing = 10.0
        bubbleLayout2.delegate = self
        expertiseCollectionView.setCollectionViewLayout(bubbleLayout2, animated: false)
        
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        view.backgroundColor = themeManager.themeData!.defaultBackground.hexColor
        genderCollectionView.reloadData()
        expertiseCollectionView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        distanceSlider.setValue(distanceSlider.maximumValue, animated: false)
        resizeCollectionViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        refreshDisplay()
    }
    
    private func resizeCollectionViews() {
        genderCollectionHeight.constant = genderCollectionView.contentSize.height
        expertiseCollectionHeight.constant = expertiseCollectionView.contentSize.height
    }
    
    private func refreshDisplay() {
        distanceSlider.value = Float(filter.distance)
        if filter.distance >= Int(distanceSlider.maximumValue) {
            distanceLabel.text = "Any distance"
        } else {
            distanceLabel.text = "Up to \(Int(distanceSlider.value)) km"
        }
        
        genderCollectionView.reloadData()
        expertiseCollectionView.reloadData()
    }

    
    @IBAction func distanceDragged(_ sender: UISlider) {
        filter.distance = Int(sender.value)
        if filter.distance >= Int(distanceSlider.maximumValue) {
            distanceLabel.text = "Any distance"
        } else {
            distanceLabel.text = "Up to \(Int(distanceSlider.value)) km"
        }
    }
    
    @IBAction func xPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func applyPress(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        delegate?.peopleFilterPicked(filter: filter)
    }
    
    @IBAction func clearPress(_ sender: Any) {
        filter = PeopleFilterCriteria()
        refreshDisplay()
        delegate?.peopleFilterPicked(filter: filter)
    }
}

extension PeopleFilterViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == genderCollectionView {
            return GenderChoice.list().count
        } else if collectionView == expertiseCollectionView {
            return UserField.list().count
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MIBubbleCollectionViewCell", for: indexPath) as! MIBubbleCollectionViewCell
        cell.roundCorners()
        
        if collectionView == genderCollectionView {
            let selection = GenderChoice.genderFrom(index: indexPath.row)
            cell.lblTitle.text = selection.label()
            if filter.gender == selection {
                cell.highlight()
            } else {
                cell.unhighlight()
            }
        } else if collectionView == expertiseCollectionView {
            cell.lblTitle.text = UserField.list()[indexPath.row].rawValue
            if filter.field == UserField.list()[indexPath.row] {
                cell.highlight()
            } else {
                cell.unhighlight()
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == genderCollectionView {
            let gender = GenderChoice.genderFrom(index: indexPath.row)
            if filter.gender == gender {
                filter.gender = nil
            } else {
                filter.gender = gender
            }
        } else if collectionView == expertiseCollectionView {
            let field = UserField.list()[indexPath.row]
            if filter.field == field {
                filter.field = nil
            } else {
                filter.field = field
            }
        }
        collectionView.reloadData()
    }
}

extension PeopleFilterViewController: MICollectionViewBubbleLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, itemSizeAt indexPath: NSIndexPath) -> CGSize {
        var title = ""
        
        if collectionView == genderCollectionView {
            title = GenderChoice.genderFrom(index: indexPath.row).label()
        } else if collectionView == expertiseCollectionView {
            title = UserField.list()[indexPath.row].rawValue.capitalizingFirstLetter()
        }
        
        var size = title.size(withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16.0)])
        size.width = CGFloat(ceilf(Float(size.width + CGFloat(kItemPadding * 2))))
        size.height = 40
        
        //...Checking if item width is greater than collection view width then set item width == collection view width.
        if size.width > collectionView.frame.size.width {
            size.width = collectionView.frame.size.width
        }
        
        return size
    }
}
