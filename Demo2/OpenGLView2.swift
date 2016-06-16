//
//  OpenGLView2.swift
//  OpenGlESExample
//
//  Created by WeiHu on 6/12/16.
//  Copyright © 2016 WeiHu. All rights reserved.
//

import UIKit
import OpenGLES

class OpenGLView2: UIView {
    
    private var eaglLayer: CAEAGLLayer?
    private var context = EAGLContext(API: .OpenGLES2)
    private var colorRenderBuffer: GLuint = 0
    private var frameBuffer: GLuint = 0
    
    private var programHandle: GLuint = 0
    private var positionSlot: GLuint = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupLayer()
        self.setupContext()
       
        self.setupProgram()

    }
    override class func layerClass() -> AnyClass {
        return CAEAGLLayer.self
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.destoryRenderAndFrameBuffer()
        self.setupRenderBuffer()
        self.setupFrameBuffer()
        self.render()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func setupLayer(){
        eaglLayer = (self.layer as! CAEAGLLayer)
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
        //有了上下文，openGL还需要在一块 buffer 上进行描绘，这块 buffer 就是 RenderBuffer（OpenGL ES 总共有三大不同用途的color buffer，depth buffer 和 stencil buffer，这里是最基本的 color buffer）。下面，我们依然创建私有方法 setupRenderBuffer 来生成 color buffer：
        
        glGenRenderbuffers(1, &colorRenderBuffer)
        glBindRenderbuffer(GLenum(GL_RENDERBUFFER), colorRenderBuffer)
        //分配空间
        context.renderbufferStorage(Int(GL_RENDERBUFFER), fromDrawable: eaglLayer)
        
    }
    private func setupFrameBuffer(){
        glGenFramebuffers(1, &frameBuffer)
        // 设置为当前 framebuffer
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), frameBuffer)
        // 将 _colorRenderBuffer 装配到 GL_COLOR_ATTACHMENT0 这个装配点上
        glFramebufferRenderbuffer(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT0), GLenum(GL_RENDERBUFFER), colorRenderBuffer)
        
    }
    
    private func destoryRenderAndFrameBuffer(){
        glDeleteFramebuffers(1, &frameBuffer)
        frameBuffer = 0
        glDeleteRenderbuffers(1, &colorRenderBuffer);
        colorRenderBuffer = 0;
        
    }
    
    private func setupProgram(){
        // Load shaders
        let vertexShaderPath = NSBundle.mainBundle().pathForResource("VertexShader2", ofType: "glsl")!
        let fragmentShaderPath = NSBundle.mainBundle().pathForResource("FragmentShader2", ofType: "glsl")!
        
        let vertexShader = GLESUtils.loadShader(GLenum(GL_VERTEX_SHADER), withFilepath: vertexShaderPath)
        let fragmentShader = GLESUtils.loadShader(GLenum(GL_FRAGMENT_SHADER), withFilepath: fragmentShaderPath)
        
        
        // Create program, attach shaders.
        programHandle = glCreateProgram();
        if programHandle == 0 {
            print("Failed to create program.");
            return
        }
        
        glAttachShader(programHandle, vertexShader);
        glAttachShader(programHandle, fragmentShader);
        
        // Link program
        //
        glLinkProgram(programHandle);
        
        // Check the link status
        var linked: GLint = 0
        glGetProgramiv(programHandle, GLenum(GL_LINK_STATUS), &linked);
        if linked == GL_FALSE
        {
            var infoLen: GLint = 0;
            glGetProgramiv (programHandle, GLenum(GL_INFO_LOG_LENGTH), &infoLen );
            
            if (infoLen > 1)
            {
                let infoLog = UnsafeMutablePointer<GLchar>.alloc(Int(infoLen))
                glGetProgramInfoLog (programHandle, infoLen, nil, infoLog)
                print("Errorlinking program:\n%s\n", infoLog)
                free (infoLog );
            }
            
            glDeleteProgram(programHandle)
            programHandle = 0
            return
        }
        
        glUseProgram(programHandle)
        
        // Get attribute slot from program
        //
        positionSlot = GLuint(glGetAttribLocation(programHandle, "vPosition"))
    }

    private func render(){
        glClearColor(0, 1.0, 1.0, 1.0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        
        glViewport(0, 0, GLsizei(self.frame.size.width), GLsizei(self.frame.size.height))
        
        // Setup viewport
        let vertices:[GLfloat] = [
            -0.5, -0.5, 0.0,
            0.5, -0.5, 0.0,
            0.5 , 0.5, 0.0,
            -0.5 , 0.5, 0.0]
        
        // Load the vertex data
        glVertexAttribPointer(positionSlot, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 0, vertices );
        glEnableVertexAttribArray(positionSlot);
        
        // Draw triangle
        glDrawArrays(GLenum(GL_TRIANGLES), 0, 3);
        
        context.presentRenderbuffer(Int(GL_RENDERBUFFER))
        
    }
   }
