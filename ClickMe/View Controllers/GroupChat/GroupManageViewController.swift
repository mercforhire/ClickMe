//
//  GroupManageViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-05-24.
//

import UIKit

protocol GroupManageViewControllerDelegate: class {
    func rearrangedUsers(speakers: [ListUser], guests: [ListUser])
}
class GroupManageViewController: BaseViewController {
    var maximumSpeakersCount: Int!
    var initialSpeakers: [ListUser]!
    var initialGuests: [ListUser]!
    
    @IBOutlet weak var tableview: UITableView!
    
    private var speakers: [ListUser] = []
    private var guests: [ListUser] = []
    weak var delegate: GroupManageViewControllerDelegate?
    
    static func create(maximumSpeakersCount: Int, initialSpeakers: [ListUser], initialGuests: [ListUser], delegate: GroupManageViewControllerDelegate) -> UIViewController {
        let vc = StoryboardManager.loadViewController(storyboard: "GroupChat", viewControllerId: "GroupManageViewController") as! GroupManageViewController
        vc.maximumSpeakersCount = maximumSpeakersCount
        vc.initialSpeakers = initialSpeakers
        vc.initialGuests = initialGuests
        vc.delegate = delegate
        let nc = UINavigationController(rootViewController: vc)
        return nc
    }
    
    override func setup() {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        speakers.append(contentsOf: initialSpeakers)
        guests.append(contentsOf: initialGuests)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        delegate?.rearrangedUsers(speakers: speakers, guests: guests)
    }
}

extension GroupManageViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
        view.tintColor = UIColor.clear
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.black
        header.textLabel?.font = UIFont.systemFont(ofSize: 22.0, weight: .medium)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Speakers"
        } else {
            return "Guests"
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return speakers.count
        } else {
            return guests.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SpeakerSelectionCell", for: indexPath) as? SpeakerSelectionCell else {
            return SpeakerSelectionCell()
        }
        
        if indexPath.section == 0 {
            cell.config(data: speakers[indexPath.row], included: true)
        } else {
            cell.config(data: guests[indexPath.row], included: false)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let toRemove = speakers[indexPath.row]
            speakers.remove(at: indexPath.row)
            guests.append(toRemove)
        } else {
            guard speakers.count < maximumSpeakersCount else { return }
            
            let toAdd = guests[indexPath.row]
            guests.remove(at: indexPath.row)
            speakers.append(toAdd)
        }
        
        tableView.reloadData()
    }
}
