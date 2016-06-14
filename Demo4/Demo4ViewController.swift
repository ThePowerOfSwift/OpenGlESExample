//
//  Demo4ViewController.swift
//  OpenGlESExample
//
//  Created by WeiHu on 6/13/16.
//  Copyright © 2016 WeiHu. All rights reserved.
//

import UIKit

class Demo4ViewController: UIViewController {

    private var _openGLView: OpenGLView4!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureViews()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
extension Demo4ViewController{
    private func configureViews(){
        self.view.backgroundColor = UIColor.whiteColor()
        
        self.view.addSubview(openGLView)
        self.consraintsForSubViews();
        
    }
    // MARK: - views actions
    // MARK: - getter and setter
    
    private var openGLView: OpenGLView4 {
        get{
            if _openGLView == nil{
                _openGLView = OpenGLView4()
                _openGLView.translatesAutoresizingMaskIntoConstraints = false
            }
            return _openGLView
            
        }
        set{
            _openGLView = newValue
        }
    }
    // MARK: - consraintsForSubViews
    private func consraintsForSubViews() {
        // align openGLView from the left and right
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": openGLView]));
        
        // align openGLView from the top and bottom
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": openGLView]));
    }

}
