//
//  GroupScheduleViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-05-26.
//

import UIKit

class GroupScheduleViewController: BaseViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var sections: [String] = []
    var rooms: [String: [GroupChatRoom]] = [:]
    var selected: GroupChatRoom?
    
    override func setup() {
        tableView.register(UINib(nibName: "RoomCell", bundle: Bundle.main), forCellReuseIdentifier: "RoomCell")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        organizeData()
    }
    
    private func organizeData() {
        sections.removeAll()
        rooms.removeAll()
        
//        for room in DataManager.shared.getMyGroupChatRooms() {
//            guard let key = DateUtil.convert(input: room.startDate, outputFormat: .format11) else { continue }
//            
//            if !sections.contains(key) {
//                sections.append(key)
//            }
//            
//            if rooms[key] == nil {
//                rooms[key] = []
//            }
//            
//            rooms[key]?.append(room)
//        }
        
        tableView.reloadData()
        noResultsViewContainer.isHidden = !sections.isEmpty
    }

    private func editRoom(room: GroupChatRoom) {
        selected = room
        performSegue(withIdentifier: "goToEditRoom", sender: self)
    }
    
    private func openRoom(room: GroupChatRoom) {
        let vc = GroupChatViewController.create(room: room)
        present(vc, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let room = selected, let vc = segue.destination as? GroupEditRoomViewController {
            vc.mode = .editRoom(room)
        }
    }
}

extension GroupScheduleViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
        view.tintColor = UIColor.clear
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont.systemFont(ofSize: 22.0, weight: .medium)
        header.textLabel?.textColor = UIColor.black
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rooms[sections[section]]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RoomCell", for: indexPath) as? RoomCell, let roomsForTheDay = rooms[sections[indexPath.section]] else {
            return RoomCell()
        }
        let room = roomsForTheDay[indexPath.row]
        cell.config(room: room)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let roomsForToday = rooms[sections[indexPath.section]] else { return }
        
        let room = roomsForToday[indexPath.row]
        if room.aboutToStart {
            openRoom(room: room)
        } else {
            editRoom(room: room)
        }
    }
}
