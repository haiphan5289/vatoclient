//
//  TimeWorkVCViewController.swift
//  Vato
//
//  Created by khoi tran on 10/28/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import UIKit

class TimeWorkVCViewController: UIViewController {
    @IBOutlet weak var openDayPicker: UIDatePicker!
    @IBOutlet weak var closeDatePicker: UIDatePicker!
    
    @IBOutlet weak var containerView: UIView!
    
    var day: FoodWeekDayType?
    var callback: ((FoodWorkingWeekDay?) -> Void)?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        visualize()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localize()
    }
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    private func localize() {
        let rect = containerView.bounds
        let benzier = UIBezierPath(roundedRect: rect, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 8, height: 8))
        let shape = CAShapeLayer()
        shape.frame = rect
        shape.fillColor = UIColor.blue.cgColor
        shape.path = benzier.cgPath
        containerView.layer.mask = shape
       
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first else {
            return
        }
        
        let p = point.location(in: self.view)
        guard self.containerView?.frame.contains(p) == false else {
            return
        }
        self.dismiss(animated: true, completion: nil)

    }
    
    private func visualize() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat =  "HH:mm"
        
        let openDate = dateFormatter.date(from: "06:00")
        openDayPicker.date = openDate ?? Date()
        
        let closeDate = dateFormatter.date(from: "21:00")
        closeDatePicker.date = closeDate ?? Date()
    }

    @IBAction func updateButtonPressed(_ sender: Any) {
        if let callback = self.callback {
            let foodWorkingWeekDay = FoodWorkingWeekDay(day: self.day!,
                                                        time: FoodTimeWorking(open: self.getMinutesFromDate(date: openDayPicker.date),
                                                                              close: self.getMinutesFromDate(date: closeDatePicker.date)))
            
            callback(foodWorkingWeekDay)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func openDatePickerValueChanged(_ sender: Any) {
        self.closeDatePicker.minimumDate = Date(timeInterval: 60, since: openDayPicker.date)
    }
    
    @IBAction func closeDatePickerValueChanged(_ sender: Any) {
        self.openDayPicker.minimumDate = Date(timeInterval: -60, since: openDayPicker.date)
    }
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func getMinutesFromDate(date: Date) -> Int {
        let hour = Calendar.current.component(.hour, from: date)
        let minutes = Calendar.current.component(.minute, from: date)
        return  hour*60 + minutes
    }
}
