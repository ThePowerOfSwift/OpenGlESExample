//
//  OpenGLView2.swift
//  OpenGlESExample
//
//  Created by WeiHu on 6/12/16.
//  Copyright © 2016 WeiHu. All rights reserved.
//

import UIKit
import OpenGLES


class OpenGLView3: UIView {
    
    var posX: Float = 0.0
    var posY: Float = 0.0
    var posZ: Float = -5
    var rotateX: Float = 1.0
    var scaleZ: Float = 0.0
    var modelViewMatrix: ksMatrix4 = ksMatrix4()
    var projectionMatrix: ksMatrix4 = ksMatrix4()
    
    private var eaglLayer: CAEAGLLayer?
    private var context = EAGLContext(API: .OpenGLES2)
    private var colorRenderBuffer: GLuint = 0
    private var frameBuffer: GLuint = 0

    private var programHandle: GLuint = 0
    private var positionSlot: GLuint = 0
    private var modelViewSlot: GLuint = 0
    private var projectionSlot: GLuint = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    override class func layerClass() -> AnyClass {
        return CAEAGLLayer.self
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.configureViews()
        
        self.setupLayer()
        self.setupContext()
        self.destoryRenderAndFrameBuffer()
        self.setupRenderBuffer()
        self.setupFrameBuffer()
        
        self.setupProgram()
        self.setupProjection()
        
        self.render()
        
        
//        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
//        dispatch_after(delayTime, dispatch_get_main_queue()) {
//            print("test")
//        }
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
    private func destoryRenderAndFrameBuffer(){
        glDeleteFramebuffers(1, &frameBuffer)
        frameBuffer = 0
        glDeleteRenderbuffers(1, &colorRenderBuffer);
        colorRenderBuffer = 0;
        
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
    
  
    
    private func setupProgram(){
        // Load shaders
        let vertexShaderPath = NSBundle.mainBundle().pathForResource("VertexShader3", ofType: "glsl")!
        let fragmentShaderPath = NSBundle.mainBundle().pathForResource("FragmentShader3", ofType: "glsl")!
        
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
//        
        modelViewSlot = GLuint(glGetUniformLocation(programHandle, "modelView"))
//
        projectionSlot = GLuint(glGetUniformLocation(programHandle, "projection"))
    }
    private func setupProjection(){
        // Generate a perspective matrix with a 60 degree FOV
        //
        let aspect: Float = Float(self.frame.size.width / self.frame.size.height)
        ksMatrixLoadIdentity(&projectionMatrix);
        ksPerspective(&projectionMatrix, 60.0, aspect, 1.0, 20.0);
        // Load projection matrix
        glUniformMatrix4fv(GLint(projectionSlot), GLsizei(1), GLboolean(GL_FALSE), &projectionMatrix.m.0.0)

    }
    //画四边形
    private func drawTriCone(){
        
        let vertices: [GLfloat] = [
            0.5, 0.5, 0.0,
            0.5, -0.5, 0.0,
            -0.5, -0.5, 0.0,
            -0.5, 0.5, 0.0,
            0.0, 0.0, -0.707,
            ]
        
        let indices: [GLubyte] = [
            0, 1, 1, 2, 2, 3, 3, 0,
            4, 0, 4, 1, 4, 2, 4, 3
            ]
            //设置线宽度
            glLineWidth(5)
            glVertexAttribPointer(positionSlot, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 0, vertices);
            glEnableVertexAttribArray(positionSlot);
        
            // Draw lines
            glDrawElements(GLenum(GL_LINES), GLsizei(indices.count), GLenum(GL_UNSIGNED_BYTE), indices);
        
        
    }
    
    func updateTransform() {
        
        // Generate a model view matrix to rotate/translate/scale
        //
        ksMatrixLoadIdentity(&modelViewMatrix);
        
        // Translate away from the viewer
        //
        
        ksMatrixTranslate(&modelViewMatrix, self.posX, self.posY, self.posZ);
        
        // Rotate the triangle
        //
        ksMatrixRotate(&modelViewMatrix, self.rotateX, 1.0, 0.0, 0.0);
        
        // Scale the triangle
        ksMatrixScale(&modelViewMatrix, 1.0, 1.0, self.scaleZ);
        
        // Load the model-view matrix
        glUniformMatrix4fv(GLint(modelViewSlot), 1, GLboolean(GL_FALSE), &modelViewMatrix.m.0.0)
    }
    private func drawTriangle(){
        // Load the vertex data
        let vertices:[GLfloat] = [
            -0.5, -0.5, 0.0,
            0.5, -0.5, 0.0,
            0.0 , 0.5, 0.0 ]
        
        glVertexAttribPointer(positionSlot, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 0, vertices );
        glEnableVertexAttribArray(positionSlot);

        // Draw triangle
        glDrawArrays(GLenum(GL_TRIANGLES), 0, 3)
        
        
    }
    //画三角形
    private func render(){
        glClearColor(0, 1.0, 1.0, 1.0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        // Setup viewport
        glViewport(0, 0, GLsizei(self.frame.size.width), GLsizei(self.frame.size.height))
        self.updateTransform()
        self.drawTriCone()
        context.presentRenderbuffer(Int(GL_RENDERBUFFER))
        
    }
    
    private func configureViews(){
        self.addSubview(slider1)
        self.addSubview(slider2)
        self.addSubview(slider3)
        self.addSubview(slider4)
        self.addSubview(slider5)
        
        self.consraintsForSubViews();
    }
    // MARK: - views actions
    @objc private func sliderValueChanged(slider: UISlider)  {
        print(slider.tag)
        
        print( slider.value)
        
        switch slider.tag {
        case 1:
            posX = slider.value
        case 2:
            posY = slider.value
        case 3:
            posZ = slider.value
        case 4:
            rotateX = slider.value
        case 5:
            scaleZ = slider.value
        default:
            break
        }
        
        self.render()
        
    }
    // MARK: - getter and setter
    private var _slider1: UISlider!
    private var slider1: UISlider {
        get{
            if _slider1 == nil{
                _slider1 = UISlider()
                _slider1.translatesAutoresizingMaskIntoConstraints = false
                _slider1.minimumValue = -3
                _slider1.value = 0
                _slider1.maximumValue = 3
                _slider1.tag = 1
                _slider1.addTarget(self, action: #selector(OpenGLView3.sliderValueChanged(_:)), forControlEvents: .ValueChanged)
            }
            return _slider1
        }
        set{
            _slider1 = newValue
        }
    }
    
    private var _slider2: UISlider!
    private var slider2: UISlider {
        get{
            if _slider2 == nil{
                _slider2 = UISlider()
                _slider2.translatesAutoresizingMaskIntoConstraints = false
                _slider2.minimumValue = -3
                _slider2.value = 0
                _slider2.maximumValue = 3
                _slider2.tag = 2
                _slider2.addTarget(self, action: #selector(OpenGLView3.sliderValueChanged(_:)), forControlEvents: .ValueChanged)
            }
            return _slider2
        }
        set{
            _slider2 = newValue
        }
    }
    
  
    private var _slider3: UISlider!
    private var slider3: UISlider {
        get{
            if _slider3 == nil{
                _slider3 = UISlider()
                _slider3.translatesAutoresizingMaskIntoConstraints = false
                _slider3.minimumValue = -3
                _slider3.value = 0
                _slider3.maximumValue = 3
                _slider3.tag = 3
                _slider3.addTarget(self, action: #selector(OpenGLView3.sliderValueChanged(_:)), forControlEvents: .ValueChanged)
            }
            return _slider3
        }
        set{
            _slider3 = newValue
        }
    }
    
    private var _slider4: UISlider!
    private var slider4: UISlider {
        get{
            if _slider4 == nil{
                _slider4 = UISlider()
                _slider4.translatesAutoresizingMaskIntoConstraints = false
                _slider4.minimumValue = -3
                _slider4.value = 0
                _slider4.maximumValue = 3
                _slider4.tag = 4
                _slider4.addTarget(self, action: #selector(OpenGLView3.sliderValueChanged(_:)), forControlEvents: .ValueChanged)
            }
            return _slider4
        }
        set{
            _slider4 = newValue
        }
    }
    private var _slider5: UISlider!
    private var slider5: UISlider {
        get{
            if _slider5 == nil{
                _slider5 = UISlider()
                _slider5.translatesAutoresizingMaskIntoConstraints = false
                _slider5.minimumValue = -3
                _slider5.value = 0
                _slider5.maximumValue = 3
                _slider5.tag = 5
                _slider5.addTarget(self, action: #selector(OpenGLView3.sliderValueChanged), forControlEvents: .ValueChanged)
            }
            return _slider5
        }
        set{
            _slider5 = newValue
        }
    }
    
    
    // MARK: - consraintsForSubViews
    private func consraintsForSubViews() {
        // align slider1 from the left and right
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-10-[view]-10-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": slider1]));
        
        // align slider1 from the top and bottom
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[view(==20)]-20-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": slider1]));
        
        // align slider2 from the left and right
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-10-[view]-10-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": slider2]));
        
        // align slider2 from the top and bottom
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[view(==20)]-40-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": slider2]));
        
        // align slider3 from the left and right
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-10-[view]-10-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": slider3]));
        
        // align slider3 from the top and bottom
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[view(==20)]-60-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": slider3]));
        
        // align slider4 from the left and right
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-10-[view]-10-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": slider4]));
        
        // align slider4 from the top and bottom
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[view(==20)]-80-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": slider4]));
        
        // align slider5 from the left and right
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-10-[view]-10-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": slider5]));
        
        // align slider5 from the top and bottom
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[view(==20)]-100-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": slider5]));
        
    }
    
}
