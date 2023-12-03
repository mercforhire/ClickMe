//
//  CalendarWeekViewController.swift
//  JZCalendarWeekViewExample
//
//  Created by Jeff Zhang on 30/4/18.
//  Copyright © 2018 Jeff Zhang. All rights reserved.
//

import UIKit
import JZCalendarWeekView
import Alamofire

protocol CalendarWeekViewControllerDelegate : class {
    func newEvents(events: [ScheduleCalendarEvent])
}

class CalendarWeekViewController: BaseViewController {
    var topicTitle: String!
    var cost: Int!
    var duration: Duration!
    var editMode: Bool!
    var editingScheduleId: String?
    var existingEvents: [ScheduleCalendarEvent] = []
    
    weak var delegate: CalendarWeekViewControllerDelegate?
    
    @IBOutlet private weak var calendarWeekView: LongPressWeekView!
    @IBOutlet weak var tutorialText: ThemeBlackTextLabel!
    
    private var allSchedules: [Schedule]? {
        didSet {
            events = []
            events.append(contentsOf: existingEvents)
            for schedule in allSchedules ?? [] {
                let event = ScheduleCalendarEvent(id: "\(schedule.identifier)",
                                                  title: "\(schedule.identifier)" == editingScheduleId ? "[EDIT]\(schedule.title)" : schedule.title,
                                                  cost: schedule.coin,
                                                  startDate: schedule.startTime,
                                                  endDate: schedule.endTime,
                                                  editable: false)
                events.append(event)
            }
        }
    }
    private var startDate: Date = Date()
    private var events: [ScheduleCalendarEvent] = [] {
        didSet {
            eventsByDate = JZWeekViewHelper.getIntraEventsByDate(originalEvents: events)
        }
    }
    private var eventsByDate: [Date: [ScheduleCalendarEvent]] = [:]
    
    override func setupTheme() {
        super.setupTheme()
        
        view.backgroundColor = themeManager.themeData!.defaultBackground.hexColor
        calendarWeekView.collectionView.backgroundColor = themeManager.themeData!.defaultBackground.hexColor
    }
    
    override func setup() {
        super.setup()
        
        navigationItem.hidesBackButton = true
        setupCalendarView()
        
        if editMode {
            tutorialText.text = "Hold down the schedule being edited to change its time"
        } else {
            tutorialText.text = "Hold down on an empty cell to add a new schedule or newly created schedule to change its time"
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchSchedules()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        var newEvents = events.filter { $0.id.contains(string: "NEW") || $0.id == editingScheduleId }
        newEvents.sort { $0.startDate < $1.startDate }
        delegate?.newEvents(events: newEvents)
    }
    
    private func fetchSchedules(complete: ((Bool) -> Void)? = nil) {
        allSchedules == nil ? FullScreenSpinner().show() : nil
        
        userManager.fetchHostSchedule { [weak self] schedules, error in
            guard let self = self else { return }
            
            self.allSchedules == nil ? FullScreenSpinner().hide() : nil
            
            if let error = error {
                if let _ = error.responseCode {
                    error.showErrorDialog()
                } else {
                    showNetworkErrorDialog()
                }
                complete?(false)
            } else {
                self.allSchedules = schedules
                self.calendarWeekView.forceReload(reloadEvents: self.eventsByDate)
                complete?(true)
            }
        }
    }
    
    private func setupCalendarView() {
        let now = Date()
        calendarWeekView.setupCalendar(numOfDays: 3,
                                       setDate: startDate,
                                       allEvents: eventsByDate,
                                       scrollType: .sectionScroll,
                                       scrollableRange: (now.getPastOrFutureDate(month: -1), (now.getPastOrFutureDate(month: 3))))
        
        let layout: JZWeekViewFlowLayout = JZWeekViewFlowLayout(
            hourHeight: 125,
            rowHeaderWidth: nil,
            columnHeaderHeight: nil,
            hourGridDivision: JZHourGridDivision.noneDiv)
        calendarWeekView.updateFlowLayout(layout)
        
        // LongPress delegate, datasorce and type setup
        calendarWeekView.longPressDelegate = self
        calendarWeekView.longPressDataSource = self
        calendarWeekView.delegate = self
        
        if editMode {
            calendarWeekView.longPressTypes = [.move]
        } else {
            calendarWeekView.longPressTypes = [.addNew, .move]
        }
        // Optional
        calendarWeekView.addNewDurationMins = 120
        calendarWeekView.moveTimeMinInterval = 15
    }
}

extension CalendarWeekViewController: LongPressWeekViewDelegate {
    func deletePressed(eventId: String) {
        events = events.filter({ $0.id != eventId })
        calendarWeekView.forceReload(reloadEvents: eventsByDate)
    }
}

// LongPress core
extension CalendarWeekViewController: JZLongPressViewDelegate, JZLongPressViewDataSource {
    func weekView(_ weekView: JZLongPressWeekView, didEndAddNewLongPressAt startDate: Date) {
        let newEvent = ScheduleCalendarEvent(id: "NEW-\(UUID().uuidString)",
                                             title: "[NEW]" + topicTitle,
                                             cost: cost,
                                             startDate: startDate,
                                             endDate: startDate.add(component: .hour,
                                                                    value: duration.rawValue),
                                             editable: true)
        
        for other in events where other.id != newEvent.id {
            if newEvent.conflict(other: other) {
                return
            }
        }
        
        if eventsByDate[startDate.startOfDay()] == nil {
            eventsByDate[startDate.startOfDay()] = [ScheduleCalendarEvent]()
        }
        events.append(newEvent)
        weekView.forceReload(reloadEvents: eventsByDate)
    }
    
    func weekView(_ weekView: JZLongPressWeekView, editingEvent: JZBaseEvent, didEndMoveLongPressAt startDate: Date) {
        guard let event = editingEvent as? ScheduleCalendarEvent,
                event.id.contains(string: "NEW") || event.id == editingScheduleId else { return }
        let duration = Calendar.current.dateComponents([.minute], from: event.startDate, to: event.endDate).minute!
        
        for other in events where other.id != event.id {
            if event.conflict(other: other,
                              overrideStart: startDate,
                              overrideEnd: startDate.add(component: .minute, value: duration)) {
                return
            }
        }
        
        let selectedIndex = events.firstIndex(where: { $0.id == event.id })!
        events[selectedIndex].startDate = startDate
        events[selectedIndex].endDate = startDate.add(component: .minute, value: duration)
        
        eventsByDate = JZWeekViewHelper.getIntraEventsByDate(originalEvents: events)
        weekView.forceReload(reloadEvents: eventsByDate)
    }
    
    func weekView(_ weekView: JZLongPressWeekView, viewForAddNewLongPressAt startDate: Date) -> UIView {
        if let view = UINib(nibName: EventCell.className, bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? EventCell {
            view.titleLabel.text = topicTitle
            return view
        }
        return UIView()
    }

}
