//
//  GroupMainViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-14.
//

import UIKit

class GroupMainViewController: BaseViewController {
    @IBOutlet weak var startRoomButton: ThemeRoundedButton!
    @IBOutlet weak var tableView: UITableView!
    
    private var rooms: [GroupChatRoom] = []
    
    override func setup() {
        super.setup()
        
        startRoomButton.addBorder()
        tableView.register(UINib(nibName: "RoomCell", bundle: Bundle.main), forCellReuseIdentifier: "RoomCell")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        rooms = DataManager.shared.getGroupChatRooms()
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    private func openRoom(room: GroupChatRoom) {
        let vc = GroupChatViewController.create(room: room)
        present(vc, animated: true, completion: nil)
    }
}

extension GroupMainViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RoomCell", for: indexPath) as? RoomCell else {
            return RoomCell()
        }
        let room = rooms[indexPath.row]
        cell.config(room: room)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let room = rooms[indexPath.row]
        openRoom(room: room)
    }
}
