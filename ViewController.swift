//
//  ViewController.swift
//  OpenGlESExample
//
//  Created by WeiHu on 6/8/16.
//  Copyright © 2016 WeiHu. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    private var _tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureViews()
        // Do any additional setup after loading the view, typically from a nib.
    }

      override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
// UI
extension ViewController{
    private func configureViews(){
        
        self.view.addSubview(tableView)
        self.consraintsForSubViews();
    }
    // MARK: - views actions
    
    // MARK: - getter and setter
    
    private var tableView: UITableView {
        get{
            if _tableView == nil{
                _tableView = UITableView()
                _tableView.translatesAutoresizingMaskIntoConstraints = false
                _tableView.backgroundColor = UIColor.clearColor()
                _tableView.dataSource = self
                _tableView.delegate = self
                _tableView.separatorColor = UIColor.blackColor()
                _tableView.separatorStyle = .None
                _tableView.separatorInset = UIEdgeInsetsZero
                _tableView.showsVerticalScrollIndicator = false
                _tableView.showsHorizontalScrollIndicator = false
                _tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCellID")
            }
            return _tableView
            
        }
        set{
            _tableView = newValue
        }
    }
    
    // MARK: - consraintsForSubViews
    private func consraintsForSubViews() {
        // align tableView from the left and right
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": tableView]));
        
        // align tableView from the top and bottom
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-84-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": tableView]));

    }


}
// UITableViewDataSource,UITableViewDelegate

extension ViewController: UITableViewDataSource,UITableViewDelegate{
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 5
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCellWithIdentifier("UITableViewCellID")
        cell?.textLabel?.text = "Demo\(indexPath.row + 1)"
        return cell!
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let vc = NSClassFromString("OpenGlESExample.Demo\(indexPath.row + 1)ViewController") as! UIViewController.Type
        
        self.presentViewController(vc.init(), animated: true, completion: nil)
    }
}

// swift file
// extend the NSObject class
//extension NSObject {
//    // create a static method to get a swift class for a string name
//    class func swiftClassFromString(className: String) -> AnyClass! {
//        // get the project name
//        if  var appName: String? = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleName") as! String? {
//            // generate the full name of your class (take a look into your "YourProject-swift.h" file)
//            let classStringName = "_TtC\(appName!.utf16count)\(appName)\(countElements(className))\(className)"
//            // return the class!
//            return NSClassFromString(classStringName)
//        }
//        return nil;
//    }
//}
