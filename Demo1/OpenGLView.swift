//
//  OpenGLView.swift
//  OpenGlESExample
//
//  Created by WeiHu on 6/8/16.
//  Copyright © 2016 WeiHu. All rights reserved.
//

import UIKit
import OpenGLES

class OpenGLView: UIView {


    private var eaglLayer: CAEAGLLayer?
    private var context = EAGLContext(API: .OpenGLES2)
    private var colorRenderBuffer: GLuint = 0
    private var frameBuffer: GLuint = 0

    override init(frame: CGRect) {
        super.init(frame: frame)
        
  
        
    }
    override class func layerClass() -> AnyClass {
        return CAEAGLLayer.self
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.setupLayer()
        self.setupContext()
        self.destoryRenderAndFrameBuffer()
        self.setupRenderBuffer()
        self.setupFrameBuffer()
        self.render()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func setupLayer(){
        eaglLayer = self.layer as? CAEAGLLayer
        //CALayer 默认是透明的，必须将它设为不透明才能让其可见
        eaglLayer?.opaque = true
        //设置描绘属性，在这里设置不维持渲染内容以及颜色格式为 RGBA8
        eaglLayer?.drawableProperties = [kEAGLDrawablePropertyRetainedBacking:false,kEAGLDrawablePropertyColorFormat: kEAGLColorFormatRGBA8]
    }
    private func setupContext(){
        // 指定 OpenGL 渲染 API 的版本，在这里我们使用 OpenGL ES 2.0
        if !EAGLContext.setCurrentContext(context){
            print("Failed to set current OpenGL context");
        }
    }
    private func setupRenderBuffer(){
        glGenRenderbuffers(1, &colorRenderBuffer)
        glBindRenderbuffer(GLenum(GL_RENDERBUFFER), colorRenderBuffer)
        context.renderbufferStorage(Int(GL_RENDERBUFFER), fromDrawable: eaglLayer)
        
    }
    private func setupFrameBuffer(){
        glGenFramebuffers(1, &frameBuffer)
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), frameBuffer)
        glFramebufferRenderbuffer(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT0), GLenum(GL_RENDERBUFFER), colorRenderBuffer)
        
    }

    private func destoryRenderAndFrameBuffer(){
        glDeleteFramebuffers(1, &frameBuffer)
        frameBuffer = 0
        glDeleteRenderbuffers(1, &colorRenderBuffer);
        colorRenderBuffer = 0;
        
    }
    private func render(){
        glClearColor(0, 1.0, 1.0, 1.0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        context.presentRenderbuffer(Int(GL_RENDERBUFFER))
    
    }
}
