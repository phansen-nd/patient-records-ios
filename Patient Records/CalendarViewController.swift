//
//  CalendarViewController.swift
//  Patient Records
//
//  Created by Patrick Hansen on 1/17/18.
//  Copyright © 2018 Patrick Hansen. All rights reserved.
//

import UIKit
import JTAppleCalendar
import Firebase

class CalendarViewController: UIViewController {

    var db: Firestore!
    var records = [String]()
    var currentCalendar: Calendar?
    var dateFormatter = DateFormatter()
    var currentDate = Date()
    
    @IBOutlet var recordsTableView: UITableView!;
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        db = Firestore.firestore()

        setupCalendar()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        calendarView.viewWillTransition(to: size, with: coordinator, anchorDate: currentDate)
    }
    
    func setupCalendar() {
        
        // Set initial view to today.
        calendarView.scrollToDate(Date()) {
            self.calendarView.selectDates([Date()])
        }
        
        // Set up date cells.
        calendarView.minimumInteritemSpacing = 0;
        calendarView.minimumLineSpacing = 0;
        
        // Update month and year.
        calendarView.visibleDates { (visibleDates) in
            self.updateMonthAndYearLabels(from: visibleDates)
        }
    }
    
    func updateMonthAndYearLabels(from visibleDates: DateSegmentInfo) {
        let firstDate = visibleDates.monthDates.first!.date
        
        dateFormatter.dateFormat = "yyyy"
        yearLabel.text = dateFormatter.string(from: firstDate)
        
        dateFormatter.dateFormat = "MMMM"
        monthLabel.text = dateFormatter.string(from: firstDate)
    }
    
    func handleCellSelected(view: JTAppleCell?, cellState: CellState) {
        guard let validCell = view as? CustomDateCell else { return }
        if cellState.isSelected {
            validCell.selectedView.isHidden = false
        } else {
            validCell.selectedView.isHidden = true
        }
    }
    
    func handleCellTextColor(view: JTAppleCell?, cellState: CellState) {
        guard let validCell = view as? CustomDateCell else { return }
        if cellState.isSelected {
            validCell.dateLabel.textColor = UIColor.white
        } else {
            if cellState.dateBelongsTo == .thisMonth {
                validCell.dateLabel.textColor = UIColor.black
            } else {
                validCell.dateLabel.textColor = UIColor.lightGray
            }
        }
    }
    
    func updateRecordsForDate(with date:Date) {
        //dateFormatter.dateFormat = "yyyy-MM-dd"
        //let dateString = dateFormatter.string(from: date)
        
        db.collection("records").order(by: "timeReported", descending: true).addSnapshotListener({ (querySnapshot, error) in
            if let err = error {
                print("Error getting documents: \(err)")
            } else {
                // Empty it out because we will requery all records.
                self.records = [String]()
                
                for document in querySnapshot!.documents {
                    let recordDict = document.data()
                    let name = recordDict["name"]
                    let sex = recordDict["sex"]
                    let gear = recordDict["gear"]
                    let chiefComplaint = recordDict["chiefComplaint"]
                    let clothingDescrip = "\(recordDict["topColor"] ?? "unknown")/\(recordDict["bottomColor"] ?? "unknown")"
                    
                    let str = "\(name!), \(sex!), \(gear!), \(chiefComplaint!), \(clothingDescrip)"
                    print(str)
                    self.records.append(str)
                }
                self.recordsTableView.reloadData()
            }
        })
    }
}

extension CalendarViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return records.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "record", for: indexPath)
        cell.textLabel?.text = records[indexPath.item]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension CalendarViewController: JTAppleCalendarViewDelegate {
    
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {}
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "CustomDateCell", for: indexPath) as! CustomDateCell
        cell.dateLabel.text = cellState.text
        
        // Draw in today.
        if Calendar.current.isDateInToday(cellState.date) {
            cell.todayView.isHidden = false
        } else {
            cell.todayView.isHidden = true
        }
        
        handleCellSelected(view: cell, cellState: cellState)
        handleCellTextColor(view: cell, cellState: cellState)
        
        return cell
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        // We can check cellState.selectionType to see if it was user-initiated selection or programmatic.
        
        // Set currentDate
        currentDate = date
        
        // If it's an in- or out-date, scroll to it.
        var indates = [Date]()
        var outdates = [Date]()
        calendar.visibleDates { (visibleDates) in
            for (date, _) in visibleDates.indates {
                indates.append(date)
            }
         
            for (date, _) in visibleDates.outdates {
                outdates.append(date)
            }
            
            if indates.contains(date) || outdates.contains(date) {
                calendar.scrollToDate(date) {
                    calendar.selectDates([date])
                    self.handleCellSelected(view: cell, cellState: cellState)
                    self.handleCellTextColor(view: cell, cellState: cellState)
                }
            } else {
                self.handleCellSelected(view: cell, cellState: cellState)
                self.handleCellTextColor(view: cell, cellState: cellState)
            }
        }
        
        updateRecordsForDate(with: date)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        handleCellSelected(view: cell, cellState: cellState)
        handleCellTextColor(view: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        updateMonthAndYearLabels(from: visibleDates)
    }
}

extension CalendarViewController: JTAppleCalendarViewDataSource {
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = Calendar.current.timeZone
        dateFormatter.locale = Calendar.current.locale
        
        let startDate = dateFormatter.date(from: "2018-01-01")
        let endDate = dateFormatter.date(from: "2018-04-01")
        
        let params = ConfigurationParameters(startDate: startDate!, endDate: endDate!, numberOfRows: 1, calendar: Calendar.current, generateInDates: .forAllMonths, generateOutDates: .tillEndOfRow, firstDayOfWeek: .sunday, hasStrictBoundaries: true)
        
        return params
    }
}
