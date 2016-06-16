//
//  Demo5ViewController.swift
//  OpenGlESExample
//
//  Created by WeiHu on 6/14/16.
//  Copyright © 2016 WeiHu. All rights reserved.
//

import UIKit

class Demo5ViewController: UIViewController {
    
    private var _openGLView: OpenGLView5Test!
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
extension Demo5ViewController{
    private func configureViews(){
        self.view.backgroundColor = UIColor.whiteColor()
        
        self.view.addSubview(openGLView)
        self.consraintsForSubViews();
        
        openGLView.setUpTexture(UIImage(named: "container.jpg")!.CGImage!)
        
    }
    // MARK: - views actions
    // MARK: - getter and setter
    
    private var openGLView: OpenGLView5Test {
        get{
            if _openGLView == nil{
                _openGLView = OpenGLView5Test()
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
