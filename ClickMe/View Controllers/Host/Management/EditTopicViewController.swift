//
//  EditTopicViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-05-07.
//

import UIKit
import GrowingTextView
import JZCalendarWeekView

class ScheduleTableViewCell: UITableViewCell {
    @IBOutlet weak var label: ThemeBlackTextLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func config(time: Date) {
        label.text = DateUtil.convert(input: time, outputFormat: .format3)
    }
}

class EditSchedulesTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

enum EditTopicViewMode {
    case brandNew
    case fromTemplate(Template)
    case editSchedule(Schedule)
}

class EditTopicViewController: BaseScrollingViewController {
    var mode: EditTopicViewMode = .brandNew
    
    private let scheduleTableCellHeight: CGFloat = 50.0
    
    @IBOutlet weak var container1: UIView!
    @IBOutlet weak var container2: UIView!
    @IBOutlet weak var container3: UIView!
    @IBOutlet weak var container5: UIView!
    @IBOutlet weak var container6: UIView!
    @IBOutlet weak var container7: UIView!
    
    @IBOutlet weak var titleTextView: GrowingTextView!
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var descriptionTextView: GrowingTextView!
    @IBOutlet weak var scheduleTableView: UITableView!
    @IBOutlet weak var scheduleTableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var oneHourButton: UIButton!
    @IBOutlet weak var twoHourButton: UIButton!
    @IBOutlet weak var costField: PaddedTextField!
    @IBOutlet weak var deleteButtonContainer: UIView!
    @IBOutlet weak var postButton: UIButton!
    
    private var mood: Mood?
    private var events: [ScheduleCalendarEvent] = [] {
        didSet {
            eventsByDate = JZWeekViewHelper.getIntraEventsByDate(originalEvents: events)
            
            switch mode {
            case .fromTemplate, .brandNew:
                scheduleTableViewHeight.constant = CGFloat(events.count + 1) * scheduleTableCellHeight
            case .editSchedule:
                scheduleTableViewHeight.constant = CGFloat((max(1, events.count))) * scheduleTableCellHeight
            }
        }
    }
    private var eventsByDate: [Date: [ScheduleCalendarEvent]] = [:] {
        didSet {
            scheduleTableView.reloadData()
        }
    }
    
    private var duration: Duration = .oneHour {
        didSet {
            switch duration {
            case .oneHour:
                oneHourButton.highlightButton()
                twoHourButton.unhighlightButton(back: themeManager.themeData!.defaultBackground.hexColor,
                                                text: themeManager.themeData!.textLabel.hexColor)
            case .twoHour:
                oneHourButton.unhighlightButton(back: themeManager.themeData!.defaultBackground.hexColor,
                                                text: themeManager.themeData!.textLabel.hexColor)
                twoHourButton.highlightButton()
            }
        }
    }
    private let kItemPadding = 10
    
    override func setup() {
        super.setup()
        
        switch mode {
        case .fromTemplate, .brandNew:
            title = "New Topic"
            postButton.setTitle("Post", for: .normal)
        case .editSchedule:
            title = "Edit Topic"
            postButton.setTitle("Save", for: .normal)
        }
        
        titleTextView.roundCorners()
        titleTextView.addBorder()
        titleTextView.addInset()
        
        descriptionTextView.roundCorners()
        descriptionTextView.addBorder()
        descriptionTextView.addInset()
        
        oneHourButton.addBorder()
        twoHourButton.addBorder()
        
        costField.roundCorners()
        costField.addBorder()
        
        let bubbleLayout = MICollectionViewBubbleLayout()
        bubbleLayout.minimumLineSpacing = 6.0
        bubbleLayout.minimumInteritemSpacing = 6.0
        bubbleLayout.delegate = self
        categoryCollectionView.setCollectionViewLayout(bubbleLayout, animated: false)
        
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        contentView.backgroundColor = themeManager.themeData!.defaultBackground.hexColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        prefillFields()
        categoryCollectionView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: { [weak self] in
            self?.resizeCollectionViews()
        })
    }
    
    private func prefillFields() {
        switch mode {
        case .fromTemplate(let template):
            titleTextView.text = template.title
            descriptionTextView.text = template.description
            mood = template.mood
            deleteButtonContainer.isHidden = true
            duration = .oneHour
            costField.text = "\(100)"
        case .editSchedule(let schedule):
            titleTextView.text = schedule.title
            descriptionTextView.text = schedule.description
            mood = schedule.mood
            duration = schedule.duration
            costField.text = "\(schedule.coin)"
            deleteButtonContainer.isHidden = false
            events.append(ScheduleCalendarEvent(id: "NEW-\(UUID().uuidString)",
                                                title: "[EDIT]" + schedule.title,
                                                cost: schedule.coin,
                                                startDate: schedule.startTime,
                                                endDate: schedule.startTime.add(component: .hour, value: duration.rawValue),
                                                editable: true))
        case .brandNew:
            duration = .oneHour
            costField.text = "\(100)"
        }
        
        events = { self.events }()
    }

    private func resizeCollectionViews() {
        collectionViewHeight.constant = categoryCollectionView.contentSize.height
    }
    
    @IBAction func oneHourPress(_ sender: Any) {
        duration = .oneHour
        events = []
        
        switch mode {
        case .editSchedule(let schedule):
            events.append(ScheduleCalendarEvent(id: "NEW-\(UUID().uuidString)",
                                                title: "[EDIT]" + schedule.title,
                                                cost: schedule.coin,
                                                startDate: schedule.startTime,
                                                endDate: schedule.startTime.add(component: .hour, value: duration.rawValue),
                                                editable: true))
            events = { self.events }()
        default:
            break
        }
    }
    
    @IBAction func twoHourPress(_ sender: Any) {
        duration = .twoHour
        events = []
        
        switch mode {
        case .editSchedule(let schedule):
            events.append(ScheduleCalendarEvent(id: "NEW-\(UUID().uuidString)",
                                                title: "[EDIT]" + schedule.title,
                                                cost: schedule.coin,
                                                startDate: schedule.startTime,
                                                endDate: schedule.startTime.add(component: .hour, value: duration.rawValue),
                                                editable: true))
            events = { self.events }()
        default:
            break
        }
    }
    
    @IBAction func deletePress(_ sender: Any) {
        switch mode {
        case .editSchedule(let oldSchedule):
            FullScreenSpinner().show()
            api.deleteSchedule(scheduleId: oldSchedule.identifier) { [weak self] result in
                guard let self = self else { return }
                
                FullScreenSpinner().hide()
                
                switch result {
                case .success:
                    self.navigationController?.popViewController(animated: true)
                case .failure(let error):
                    if error.responseCode == nil {
                        showNetworkErrorDialog()
                    } else if error.responseCode == 452 {
                        showErrorDialog(error: "Time conflict with another schedule")
                    } else {
                        error.showErrorDialog()
                        print("Error occured \(error)")
                    }
                }
            }
        default:
            break
        }
    }
    
    @IBAction func postPress(_ sender: Any) {
        guard validate(),
              let mood = mood,
              let title = titleTextView.text,
              let description = descriptionTextView.text,
              let cost = costField.text?.int else { return }
        
        
        
        FullScreenSpinner().show()
        
        switch mode {
        case .brandNew, .fromTemplate:
            
            var isSuccess: Bool = true
            let queue = DispatchQueue.global(qos: .background)
            
            queue.async { [weak self] in
                guard let self = self else { return }
                
                let semaphore = DispatchSemaphore(value: 0)
                
                for timeslot in self.events {
                    if !isSuccess {
                        break
                    }
                    
                    let createScheduleParams = CreateScheduleParams(title: title, mood: mood, coin: cost, startTime: timeslot.startDate, endTime: timeslot.endDate, description: description)
                    self.api.createSchedule(params: createScheduleParams) { result in
                        switch result {
                        case .failure(let error):
                            isSuccess = false
                            if error.responseCode == nil {
                                showNetworkErrorDialog()
                            } else if error.responseCode == 452 {
                                showErrorDialog(error: "Time conflict with another schedule")
                            } else {
                                error.showErrorDialog()
                                print("Error occured \(error)")
                            }
                        default:
                            break
                        }
                        
                        semaphore.signal()
                    }
                    semaphore.wait()
                }
                
                DispatchQueue.main.async { [weak self] in
                    FullScreenSpinner().hide()
                    
                    if isSuccess {
                        self?.navigationController?.popViewController(animated: true)
                    }
                }
            }
            
        case .editSchedule(let oldSchedule):
            guard let event: ScheduleCalendarEvent = events.first else { return }
            
            let updateScheduleParams = UpdateScheduleParams(identifier: oldSchedule.identifier,
                                                            title: title,
                                                            mood: mood,
                                                            coin: cost,
                                                            startTime: event.startDate,
                                                            endTime: event.endDate,
                                                            description: description)
            api.updateSchedule(params: updateScheduleParams) { [weak self]  result in
                guard let self = self else { return }
                
                FullScreenSpinner().hide()
                
                switch result {
                case .success:
                    self.navigationController?.popViewController(animated: true)
                case .failure(let error):
                    if error.responseCode == nil {
                        showNetworkErrorDialog()
                    } else if error.responseCode == 452 {
                        showErrorDialog(error: "Time conflict with another schedule")
                    } else {
                        error.showErrorDialog()
                        print("Error occured \(error)")
                    }
                }
            }
        }
    }
    
    private func validate() -> Bool {
        if events.isEmpty {
            showErrorDialog(error: "Please choose a time slot")
            return false
        }
        
        for timeslot in events {
            if timeslot.startDate < Date() {
                showErrorDialog(error: "Can not create a session with start time in the past")
                return false
            }
        }
        
        if titleTextView.text.isEmpty {
            showErrorDialog(error: "Title not entered")
            return false
        }
        
        if descriptionTextView.text.isEmpty {
            showErrorDialog(error: "Description not entered")
            return false
        }
        
        if mood == nil {
            showErrorDialog(error: "Mood not selected")
            return false
        }
        
        if costField.text?.int ?? 0 < 100 {
            showErrorDialog(error: "Cost can't be less than 100")
            return false
        }
        
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? CalendarWeekViewController,
            let title = titleTextView.text,
            let cost = costField.text?.int {
            vc.topicTitle = title
            vc.cost = cost
            vc.duration = duration
            vc.delegate = self
            
            switch mode {
            case .fromTemplate:
                vc.editMode = false
                vc.existingEvents = events
            case .editSchedule(let schedule):
                vc.editMode = true
                vc.editingScheduleId = "\(schedule.identifier)"
            case .brandNew:
                vc.editMode = false
                vc.existingEvents = events
            }
        }
    }
}

extension EditTopicViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Mood.list().count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MIBubbleCollectionViewCell", for: indexPath) as! MIBubbleCollectionViewCell
        let mood = Mood.list()[indexPath.row]
        cell.lblTitle.text = mood.rawValue.capitalizingFirstLetter()
        cell.roundCorners()
        cell.addBorder()
        if self.mood == mood {
            cell.highlight()
        } else {
            cell.unhighlight()
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let mood = Mood.list()[indexPath.row]
        if self.mood == mood {
            self.mood = nil
        } else {
            self.mood = mood
        }
        collectionView.reloadData()
    }
}

extension EditTopicViewController: MICollectionViewBubbleLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, itemSizeAt indexPath: NSIndexPath) -> CGSize {
        let title = Mood.list()[indexPath.row].rawValue.capitalizingFirstLetter()
        var size = title.size(withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16.0)])
        size.width = CGFloat(ceilf(Float(size.width + CGFloat(kItemPadding * 2))))
        size.height = 39.5
        
        //...Checking if item width is greater than collection view width then set item width == collection view width.
        if size.width > collectionView.frame.size.width {
            size.width = collectionView.frame.size.width
        }
        
        return size
    }
}

extension EditTopicViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch mode {
        case .fromTemplate, .brandNew:
            return events.count + 1
        case .editSchedule:
            return max(1, events.count)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < events.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ScheduleTableViewCell", for: indexPath) as! ScheduleTableViewCell
            cell.config(time: events[indexPath.row].startDate)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "EditSchedulesTableViewCell", for: indexPath) as! EditSchedulesTableViewCell
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row < events.count {
            switch mode {
            case .editSchedule:
                performSegue(withIdentifier: "goToCalendar", sender: self)
            default:
                break
            }
        } else {
            performSegue(withIdentifier: "goToCalendar", sender: self)
        }
    }
}

extension EditTopicViewController: CalendarWeekViewControllerDelegate {
    func newEvents(events: [ScheduleCalendarEvent]) {
        self.events = events
    }
}
