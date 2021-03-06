//
//  SongFilterAndSorterTableViewController.swift
//  CGSSGuide
//
//  Created by zzk on 16/9/5.
//  Copyright © 2016年 zzk. All rights reserved.
//

import UIKit

protocol SongFilterAndSorterTableViewControllerDelegate: class {
    func doneAndReturn(_ filter: CGSSSongFilter, sorter: CGSSSorter)
}

class SongFilterAndSorterTableViewController: UITableViewController {
    @IBOutlet weak var songTypeStackView: UIView!
    
    @IBOutlet weak var eventTypeView: UIView!
    
    @IBOutlet weak var eventTypeView2: UIView!
    @IBOutlet weak var ascendingStackView: UIView!
    
    @IBOutlet weak var basicStackView: UIView!
    
    var sortingButtons: [UIButton]!
    weak var delegate: SongFilterAndSorterTableViewControllerDelegate?
    var filter: CGSSSongFilter!
    var sorter: CGSSSorter!
    // let color = UIColor.init(red: 13/255, green: 148/255, blue: 252/255, alpha: 1)
    var sorterString = ["updateId", "bpm", "maxDiffStars"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backButton = UIBarButtonItem.init(title: NSLocalizedString("完成", comment: "导航栏按钮"), style: .plain, target: self, action: #selector(doneAction))
        self.navigationItem.leftBarButtonItem = backButton
        
        let resetButton = UIBarButtonItem.init(title: NSLocalizedString("重置", comment: "导航栏按钮"), style: .plain, target: self, action: #selector(resetAction))
        self.navigationItem.rightBarButtonItem = resetButton
        
        prepare()
        setup()
        
    }
    
    func setup() {
        for i in 0...3 {
            let button = songTypeStackView.subviews[i] as! UIButton
            button.isSelected = filter.songTypes.contains(CGSSSongTypes.init(type: i))
        }
        
        var eventButtons = [UIButton]()
        eventButtons.append(contentsOf: eventTypeView.subviews as! [UIButton])
        eventButtons.append(contentsOf: eventTypeView2.subviews as! [UIButton])
        for i in 0...3 {
            let button = eventButtons[i]
            button.isSelected = filter.eventTypes.contains(CGSSSongEventTypes.init(rawValue: 1 << UInt(i)))
        }
        
        let ascendingbutton = ascendingStackView.subviews[1] as! UIButton
        ascendingbutton.isSelected = sorter.ascending
        
        let descendingButton = ascendingStackView.subviews[0] as! UIButton
        descendingButton.isSelected = !sorter.ascending
        
        for i in 0...2 {
            let button = basicStackView.subviews[i] as! UIButton
            let index = sorterString.index(of: sorter.att)
            button.isSelected = (index == i)
        }
    }
    
    func prepare() {
        for i in 0...3 {
            let button = songTypeStackView.subviews[i] as! UIButton
            button.addTarget(self, action: #selector(songTypeButtonClick), for: .touchUpInside)
            // button.setTitleColor(UIColor.redColor(), forState: .Highlighted)
            button.tag = 1000 + i
        }
        for i in 0...2 {
            let button = eventTypeView.subviews[i] as! UIButton
            button.addTarget(self, action: #selector(eventTypeButtonClick), for: .touchUpInside)
            button.tag = 2000 + i
        }
        for i in 0...0 {
            let button = eventTypeView2.subviews[i] as! UIButton
            button.addTarget(self, action: #selector(eventTypeButtonClick), for: .touchUpInside)
            button.tag = 2000 + i + 3
        }
        
        let ascendingbutton = ascendingStackView.subviews[1] as! UIButton
        ascendingbutton.addTarget(self, action: #selector(ascendingAction), for: .touchUpInside)
        
        let descendingButton = ascendingStackView.subviews[0] as! UIButton
        descendingButton.addTarget(self, action: #selector(descendingAction), for: .touchUpInside)
        
        sortingButtons = [UIButton]()
        for i in 0...2 {
            let button = basicStackView.subviews[i] as! UIButton
            sortingButtons.append(button)
            button.tag = 1000 + i
            button.addTarget(self, action: #selector(sortingButtonsAction), for: .touchUpInside)
        }
    }
    
    func songTypeButtonClick(_ sender: UIButton) {
        let tag = sender.tag - 1000
        if sender.isSelected {
            sender.isSelected = false
            filter.songTypes.remove(CGSSSongTypes.init(type: tag))
        } else {
            sender.isSelected = true
            filter.songTypes.insert(CGSSSongTypes.init(type: tag))
        }
    }
    
    func eventTypeButtonClick(_ sender: UIButton) {
        let tag = sender.tag - 2000
        if sender.isSelected {
            sender.isSelected = false
            filter.eventTypes.remove(CGSSSongEventTypes.init(rawValue: 1 << UInt(tag)))
        } else {
            sender.isSelected = true
            filter.eventTypes.insert(CGSSSongEventTypes.init(rawValue: 1 << UInt(tag)))
        }
        
    }
    
    func ascendingAction(_ sender: UIButton) {
        if !sender.isSelected {
            sender.isSelected = true
            let descendingButton = ascendingStackView.subviews[0] as! UIButton
            descendingButton.isSelected = false
            sorter.ascending = true
        }
    }
    func descendingAction(_ sender: UIButton) {
        if !sender.isSelected {
            sender.isSelected = true
            let ascendingButton = ascendingStackView.subviews[1] as! UIButton
            ascendingButton.isSelected = false
            sorter.ascending = false
        }
    }
    
    func sortingButtonsAction(_ sender: UIButton) {
        if !sender.isSelected {
            for btn in sortingButtons {
                if btn.isSelected {
                    btn.isSelected = false
                }
            }
            sender.isSelected = true
            let index = sortingButtons.index(of: sender)
            sorter.att = sorterString[index!]
        }
    }
    
    func doneAction() {
        delegate?.doneAndReturn(filter, sorter: sorter)
        _ = self.navigationController?.popViewController(animated: true)
        // 使用自定义动画效果
        /*let transition = CATransition()
         transition.duration = 0.3
         transition.type = kCATransitionReveal
         navigationController?.view.layer.addAnimation(transition, forKey: kCATransition)
         navigationController?.popViewControllerAnimated(false)*/
    }
    
    func resetAction() {
        filter = CGSSSongFilter.init(typeMask: 0b1111, eventMask: 0b1111)
        sorter = CGSSSorter.init(att: "updateId")
        setup()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            return 3
        } else {
            return 2
        }
    }
    
    /*
     override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
     let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

     // Configure the cell...

     return cell
     }
     */
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
     if editingStyle == .Delete {
     // Delete the row from the data source
     tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
     } else if editingStyle == .Insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
