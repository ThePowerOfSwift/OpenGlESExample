//
//  OpenGLView2Test.swift
//  OpenGlESExample
//
//  Created by WeiHu on 6/12/16.
//  Copyright © 2016 WeiHu. All rights reserved.
//

import UIKit
import OpenGLES

class OpenGLView2Test: UIView {
    let vertices: [GLfloat] = [
                            -0.5, -0.5, 0.0,
                            0.5, -0.5, 0.0,
                            0.0,  0.5, 0.0
                            ]
    
    var VBO = GLuint()
    
    func setUpConfigure() {
        //VBO的创建、配置: 生成一个缓冲ID：
//        glGenBuffers(1, &VBO)
//        //绑定新创建的缓冲：
//        glBindBuffer(GLenum(GL_ARRAY_BUFFER), VBO)
//        glBufferData(GLenum(GL_ARRAY_BUFFER), vertices.size(), vertices, GL_STATIC_DRAW)
        
        
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
