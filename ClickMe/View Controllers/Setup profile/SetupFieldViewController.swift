//
//  SetupFieldViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-20.
//

import UIKit

class SetupFieldViewController: BaseViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var nextButton: UIButton!
    
    private var selected: UserField?
    private let kItemPadding = 27
    
    override func setup() {
        super.setup()
        
        let bubbleLayout = MICollectionViewBubbleLayout()
        bubbleLayout.minimumLineSpacing = 10.0
        bubbleLayout.minimumInteritemSpacing = 10.0
        bubbleLayout.sectionInset = .init(top: 0, left: 0, bottom: 0, right: 0)
        bubbleLayout.delegate = self
        collectionView.setCollectionViewLayout(bubbleLayout, animated: false)
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        view.backgroundColor = themeManager.themeData!.defaultBackground.hexColor
        collectionView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        selected = userManager.user?.field == .unknown ? nil : userManager.user?.field
    }
    
    @IBAction func nextPress(_ sender: Any) {
        if let selected = selected {
            var updateForm = UpdateUserParams()
            updateForm.field = selected
            userManager.updateUser(params: updateForm) { [weak self] success in
                guard let self = self else { return }
                
                self.goToNextScreen()
            }
        } else {
            showErrorDialog(error: "Must pick a category")
        }
    }
    
    private func goToNextScreen() {
        userManager.setupManager.goToAppropriateSetupView(vc: self)
    }
}

extension SetupFieldViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return UserField.list().count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MIBubbleCollectionViewCell", for: indexPath) as! MIBubbleCollectionViewCell
        
        let field = UserField.list()[indexPath.row]
        cell.lblTitle.text = field.rawValue.capitalizingFirstLetter()
        cell.roundCorners()
        cell.addBorder()
        if selected == UserField.list()[indexPath.row] {
            cell.highlight()
        } else {
            cell.unhighlight()
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if selected == UserField.list()[indexPath.row] {
            selected = nil
        } else {
            selected = UserField.list()[indexPath.row]
        }
        collectionView.reloadData()
    }
}

extension SetupFieldViewController: MICollectionViewBubbleLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, itemSizeAt indexPath: NSIndexPath) -> CGSize {
        
        let size = CGSize(width: collectionView.frame.width / 2 - 10, height: 44.0)
        return size
    }
}
