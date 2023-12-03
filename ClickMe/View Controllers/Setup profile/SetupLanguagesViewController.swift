//
//  SetupLanguagesViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-05-25.
//

import UIKit

class SetupLanguagesViewController: BaseViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var selectedLanguages: [Language] = []
    private let kItemPadding = 27
    private let MaxLanguages = 2
    
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
        selectedLanguages = userManager.user?.languages ?? []
    }
    
    private func validate() -> Bool {
        if !selectedLanguages.isEmpty {
            return true
        } else {
            let ac = UIAlertController(title: "Please select at least one language", message: nil, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Okay", style: .default)
            ac.addAction(cancelAction)
            present(ac, animated: true)
            return false
        }
    }

    @IBAction func nextPress(_ sender: Any) {
        if validate() {
            var updateForm = UpdateUserParams()
            updateForm.languages = selectedLanguages
            userManager.updateUser(params: updateForm) { [weak self] success in
                guard let self = self else { return }
                
                self.goToNextScreen()
            }
        }
    }
    
    private func goToNextScreen() {
        userManager.setupManager.goToAppropriateSetupView(vc: self)
    }
}

extension SetupLanguagesViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Language.list().count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MIBubbleCollectionViewCell", for: indexPath) as! MIBubbleCollectionViewCell
        
        let lang = Language.list()[indexPath.row]
        cell.lblTitle.text = lang.rawValue.capitalizingFirstLetter()
        cell.roundCorners()
        cell.addBorder()
        if selectedLanguages.contains(Language.list()[indexPath.row]) {
            cell.highlight()
        } else {
            cell.unhighlight()
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let index = selectedLanguages.firstIndex(of: Language.list()[indexPath.row]) {
            selectedLanguages.remove(at: index)
        } else {
            selectedLanguages.append(Language.list()[indexPath.row])
            if selectedLanguages.count > MaxLanguages {
                selectedLanguages.removeFirst()
            }
        }
        collectionView.reloadData()
    }
}

extension SetupLanguagesViewController: MICollectionViewBubbleLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, itemSizeAt indexPath: NSIndexPath) -> CGSize {
        let size = CGSize(width: collectionView.frame.width / 2 - 10, height: 44.0)
        return size
    }
}
