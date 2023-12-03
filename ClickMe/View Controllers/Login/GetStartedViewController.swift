//
//  GetStartedViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-08.
//

import UIKit

enum GetStartedSteps: Int {
    case one
    case two
    case three
    case count
    
    func image() -> UIImage {
        switch self {
        case .one:
            return UIImage(named: "1v1")!
        case .two:
            return UIImage(named: "group")!
        case .three:
            return UIImage(named: "8mood")!
        default:
            fatalError()
        }
    }
    
    func title() -> String{
        switch self {
        case .one:
            return "1-ON-1 CHAT WITH PROFESSIONALS"
        case .two:
            return "GROUP ­­CHAT WITH PROFESSIONALS"
        case .three:
            return "EXPLORE \(Mood.list().count) MOODS"
        default:
            fatalError()
        }
    }
    
    func body() -> String{
        switch self {
        case .one:
            return "Quality communication.\nEarn money while networking.\nMeaningful interactions."
        case .two:
            return "We bring what you love closer to you. Discover and engage with interesting souls. Connect with your community."
        case .three:
            return "Sharpen your skills, show your talent and get inspired! Let your voice be heard!"
        default:
            fatalError()
        }
    }
}

class GetStartedViewController: BaseViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var nextButton: UIButton!
    private var page: Int = 0 {
        didSet {
            collectionView.scrollToItem(at: IndexPath(row: page, section: 0), at: .left, animated: true)
            
            if page == (GetStartedSteps.count.rawValue - 1) {
                nextButton.setTitle("Get started", for: .normal)
            }
        }
    }
    
    override func setup() {
        super.setup()
        
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if appSettings.isGetStartedViewed() {
            let vc = StoryboardManager.loadViewController(storyboard: "Login", viewControllerId: "LoginInitialViewController") as! LoginInitialViewController
            navigationController?.pushViewController(vc, animated: false)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    @IBAction func nextPressed(_ sender: UIButton) {
        if page == (GetStartedSteps.count.rawValue - 1) {
            appSettings.setGetStartedViewed(viewed: true)
            performSegue(withIdentifier: "goToLogin", sender: self)
        } else {
            page = page + 1
        }
    }
}

extension GetStartedViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return GetStartedSteps.count.rawValue
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GetStartedCell", for: indexPath) as! GetStartedCell
        
        let step = GetStartedSteps(rawValue: indexPath.row)!
        cell.config(data: step)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
}
