//
//  EditFieldViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-28.
//

import UIKit

class EditFieldViewController: BaseViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var selectedCategory: UserField?
    private let kItemPadding = 27
    
    override func setup() {
        super.setup()
        
        let bubbleLayout = MICollectionViewBubbleLayout()
        bubbleLayout.minimumLineSpacing = 10.0
        bubbleLayout.minimumInteritemSpacing = 10.0
        bubbleLayout.sectionInset = .init(top: 0, left: 20.0, bottom: 0, right: 20.0)
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
        selectedCategory = userManager.user?.field
        collectionView.reloadData()
    }
    
    private func validate() -> Bool {
        if selectedCategory != nil {
            return true
        } else {
            let ac = UIAlertController(title: "Please make a selection", message: nil, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Okay", style: .default)
            ac.addAction(cancelAction)
            present(ac, animated: true)
            return false
        }
    }

    @IBAction func savePress(_ sender: Any) {
        if validate(), let field = selectedCategory {
            var updateForm = UpdateUserParams()
            updateForm.field = field
            userManager.updateUser(params: updateForm) { [weak self] success in
                guard let self = self else { return }
                
                if success {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
}

extension EditFieldViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return UserField.list().count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MIBubbleCollectionViewCell", for: indexPath) as! MIBubbleCollectionViewCell
        
        let field = UserField.list()[indexPath.row]
        cell.lblTitle.text = field.rawValue.capitalizingFirstLetter()
        cell.roundCorners()
        if selectedCategory == UserField.list()[indexPath.row] {
            cell.highlight()
        } else {
            cell.unhighlight()
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if selectedCategory == UserField.list()[indexPath.row] {
            selectedCategory = nil
        } else {
            selectedCategory = UserField.list()[indexPath.row]
        }
        collectionView.reloadData()
    }
}

extension EditFieldViewController: MICollectionViewBubbleLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, itemSizeAt indexPath: NSIndexPath) -> CGSize {
        let title = UserField.list()[indexPath.row].rawValue.capitalizingFirstLetter()
        var size = title.size(withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17.0)])
        size.width = CGFloat(ceilf(Float(size.width + CGFloat(kItemPadding * 2))))
        size.height = 40
        
        //...Checking if item width is greater than collection view width then set item width == collection view width.
        if size.width > collectionView.frame.size.width {
            size.width = collectionView.frame.size.width
        }
        
        return size
    }
}
