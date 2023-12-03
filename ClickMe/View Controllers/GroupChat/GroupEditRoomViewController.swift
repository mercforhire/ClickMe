//
//  GroupEditRoomViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-15.
//

import UIKit
import GrowingTextView

enum EditGroupRoomViewMode {
    case newRoom
    case editRoom(GroupChatRoom)
}

class GroupEditRoomViewController: BaseViewController {
    var mode: EditGroupRoomViewMode = .newRoom
    
    @IBOutlet weak var titleTextView: GrowingTextView!
    @IBOutlet weak var charCountLabel: UILabel!
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    @IBOutlet weak var categoryCollectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var speakersCollectionView: UICollectionView!
    @IBOutlet weak var speakersCollectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var container1: UIView!
    @IBOutlet weak var container2: UIView!
    @IBOutlet weak var container3: UIView!
    @IBOutlet weak var container4: UIView!
    @IBOutlet weak var container5: UIView!
    @IBOutlet weak var container6: UIView!
    @IBOutlet weak var container7: UIView!
    @IBOutlet weak var selectTimeButton: UIButton!
    @IBOutlet weak var oneHourButton: UIButton!
    @IBOutlet weak var twoHourButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    
    private let kItemPadding = 10
    private let CharCount = 500
    private let MaxSpeakersCount = 9
    private let SpeakerCellWidth: CGFloat = 31.0
    
    private var mood: Mood? {
        didSet {
            categoryCollectionView.reloadData()
        }
    }
    private var startTime: Date? {
        didSet {
            if let time = startTime {
                let dateTime = DateUtil.convert(input: time, outputFormat: .format10)
                selectTimeButton.setTitle(dateTime, for: .normal)
            } else {
                selectTimeButton.setTitle("Select time", for: .normal)
            }
        }
    }
    private var duration: Duration? {
        didSet {
            switch duration {
            case .none:
                oneHourButton.unhighlightButton()
                twoHourButton.unhighlightButton()
            case .oneHour:
                oneHourButton.highlightButton()
                twoHourButton.unhighlightButton()
            case .twoHour:
                oneHourButton.unhighlightButton()
                twoHourButton.highlightButton()
            }
        }
    }
    private var speakers: [ListUser] = [] {
        didSet {
            let totalWidthNeeded: CGFloat = CGFloat(speakers.count + 1) * SpeakerCellWidth + CGFloat(speakers.count * 10)
            speakersCollectionViewHeight.constant = ceil(totalWidthNeeded / speakersCollectionView.frame.width) * SpeakerCellWidth
        }
    }
    
    override func setup() {
        super.setup()
        
        switch mode {
        case .newRoom:
            title = "New Room"
            submitButton.setTitle("SCHEDULE ROOM", for: .normal)
        case .editRoom:
            title = "Edit Room"
            submitButton.setTitle("SAVE", for: .normal)
        }
        
        titleTextView.roundCorners()
        titleTextView.addBorder()
        titleTextView.addInset()
        
        oneHourButton.addBorder()
        twoHourButton.addBorder()
        
        charCountLabel.text = "0/\(CharCount)"
        
        let bubbleLayout = MICollectionViewBubbleLayout()
        bubbleLayout.minimumLineSpacing = 6.0
        bubbleLayout.minimumInteritemSpacing = 6.0
        bubbleLayout.delegate = self
        categoryCollectionView.setCollectionViewLayout(bubbleLayout, animated: false)
        
        let flowlayout = UICollectionViewFlowLayout()
        flowlayout.itemSize = .init(width: SpeakerCellWidth, height: SpeakerCellWidth)
        flowlayout.scrollDirection = .vertical
        flowlayout.minimumLineSpacing = 0.0
        flowlayout.minimumInteritemSpacing = 10.0
        speakersCollectionView.setCollectionViewLayout(flowlayout, animated: false)
        
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        resizeCollectionViews()
        prefillFields()
        categoryCollectionView.reloadData()
    }
    
    private func resizeCollectionViews() {
        categoryCollectionViewHeight.constant = categoryCollectionView.contentSize.height
    }
    
    @IBAction func oneHourPress(_ sender: Any) {
        duration = .oneHour
    }
    
    @IBAction func twoHourPress(_ sender: Any) {
        duration = .twoHour
    }
    
    @IBAction func timePress(_ sender: UIButton) {
        let minDate = Date()
        RPicker.selectDate(title: "Select Time", cancelText: "Cancel", datePickerMode: .dateAndTime, selectedDate: startTime ?? minDate, minDate: minDate, style: .Wheel, didSelectDate: {[weak self] selectedDate in
            self?.startTime = selectedDate
        })
    }
    
    @IBAction private func bottomButtonPressed(_ sender: UIButton) {
        guard validate(),
              let host = userManager.user?.toSimpleUser(),
              let mood = mood,
              let roomTitle = titleTextView.text,
              let startTime = startTime,
              let duration = duration else { return }
              
//        let newRoom = GroupChatRoom(host: host,
//                                    mood: mood,
//                                    title: roomTitle,
//                                    speakers: speakers,
//                                    startDate: startTime,
//                                    duration: duration.rawValue)
        switch mode {
        case .newRoom:
//            DataManager.shared.newGroupChatRoom(newRoom: newRoom)
            break
        case .editRoom(let oldRoom):
//            newRoom.identifier = oldRoom.identifier
//            DataManager.shared.editGroupChatRoom(existingRoom: newRoom)
            break
        default:
            fatalError()
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func addSpeakerPressed() {
        performSegue(withIdentifier: "goToAddSpeakers", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? GroupAddSpeakersViewController {
            vc.preSelectedUsers = speakers
            vc.maximumSpeakersCount = MaxSpeakersCount
            vc.delegate = self
        }
    }
    
    private func prefillFields() {
        switch mode {
        case .editRoom(let room):
            titleTextView.text = room.title
            textViewDidChange(titleTextView)
            mood = room.mood
            startTime = room.startDate
            duration = Duration(rawValue: room.duration)
            speakers = room.speakers
            speakersCollectionView.reloadData()
        default:
            break
        }
    }
    
    private func validate() -> Bool {
        if titleTextView.text.isEmpty {
            showErrorDialog(error: "Title not entered")
            return false
        }
        
        if mood == nil {
            showErrorDialog(error: "Category not selected")
            return false
        }
        
        if startTime == nil {
            showErrorDialog(error: "Start time not selected")
            return false
        }
        
        if duration == nil {
            showErrorDialog(error: "Chat duration not selected")
            return false
        }
        
        return true
    }
}

extension GroupEditRoomViewController: GroupAddSpeakersViewControllerDelegate {
    func pickedUsers(users: [ListUser]) {
        speakers = users
        speakersCollectionView.reloadData()
    }
}

extension GroupEditRoomViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == categoryCollectionView {
            return Mood.list().count
        } else if collectionView == speakersCollectionView {
            return speakers.count + 1
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == categoryCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MIBubbleCollectionViewCell", for: indexPath) as! MIBubbleCollectionViewCell
            
            let field = Mood.list()[indexPath.row]
            cell.lblTitle.text = field.rawValue.capitalizingFirstLetter()
            cell.roundCorners()
            cell.addBorder()
            if mood == field {
                cell.highlight()
            } else {
                cell.unhighlight()
            }
            return cell
        } else if collectionView == speakersCollectionView {
            if indexPath.row == speakers.count {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddSpeakerCell", for: indexPath) as! ButtonCell
                cell.button.addTarget(self, action: #selector(addSpeakerPressed), for: .touchUpInside)
                return cell
            } else if let avatarURL = speakers[indexPath.row].avatarURL{
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SpeakerCell", for: indexPath) as! ImageCell
                cell.loadImageFromURL(urlString: avatarURL)
                cell.imageView.roundCorners()
                return cell
            }
        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == categoryCollectionView {
            let field = Mood.list()[indexPath.row]
            if mood == field {
                mood = nil
            } else {
                mood = field
            }
        }
    }
}

extension GroupEditRoomViewController: MICollectionViewBubbleLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, itemSizeAt indexPath: NSIndexPath) -> CGSize {
        let moodName = Mood.list()[indexPath.row].rawValue.capitalizingFirstLetter()
        var size = moodName.size(withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16.0)])
        size.width = CGFloat(ceilf(Float(size.width + CGFloat(kItemPadding * 2))))
        size.height = 40
        
        //...Checking if item width is greater than collection view width then set item width == collection view width.
        if size.width > collectionView.frame.size.width {
            size.width = collectionView.frame.size.width
        }
        
        return size
    }
}

extension GroupEditRoomViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            view.endEditing(true)
            return false
        }
    
        // get the current text, or use an empty string if that failed
        let currentText = textView.text ?? ""
        
        // attempt to read the range they are trying to change, or exit if we can't
        guard let stringRange = Range(range, in: currentText) else { return false }
        
        // add their new text to the existing text
        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
        
        // make sure the result is under 150 characters
        return updatedText.count <= CharCount
    }
    
    func textViewDidChange(_ textView: UITextView) {
        charCountLabel.text = "\(textView.text.count)/\(CharCount)"
    }
}
