
//
//  OpenGLView4.swift
//  OpenGlESExample
//
//  Created by WeiHu on 6/13/16.
//  Copyright © 2016 WeiHu. All rights reserved.
//

import UIKit

class OpenGLView5: UIView {

    var rotateShoulder: Float = 0.0
    var rotateElbow: Float = 0.0

    
    var modelViewMatrix: ksMatrix4 = ksMatrix4()
    var projectionMatrix: ksMatrix4 = ksMatrix4()
    
    var shouldModelViewMatrix: ksMatrix4 = ksMatrix4()
    var elbowModelViewMatrix: ksMatrix4 = ksMatrix4()
    
    var rotateColorCube: Float = 0.0
    
    
    private var eaglLayer: CAEAGLLayer?
    private var context = EAGLContext(API: .OpenGLES2)
    private var colorRenderBuffer: GLuint = 0
    private var frameBuffer: GLuint = 0
    
    private var programHandle: GLuint = 0
    private var positionSlot: GLuint = 0
    private var modelViewSlot: GLuint = 0
    private var projectionSlot: GLuint = 0
    
    private var colorSlot: GLuint = 0
    
    
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
        let vertexShaderPath = NSBundle.mainBundle().pathForResource("VertexShader4", ofType: "glsl")!
        let fragmentShaderPath = NSBundle.mainBundle().pathForResource("FragmentShader4", ofType: "glsl")!
        
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
        colorSlot = GLuint(glGetAttribLocation(programHandle, "vSourceColor"))
        
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
        
        glEnable(GLenum(GL_CULL_FACE))
        
    }
   
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    private func drawCube(color: ksVec4){
        let vertices: [GLfloat] = [
            0.0, -0.5, 0.5,
            0.0, 0.5, 0.5,
            1.0, 0.5, 0.5,
            1.0, -0.5, 0.5,
            
            1.0, -0.5, -0.5,
            1.0, 0.5, -0.5,
            0.0, 0.5, -0.5,
            0.0, -0.5, -0.5,
            ]
        
        let indices: [GLubyte] = [
            0, 1, 1, 2, 2, 3, 3, 0,
            4, 5, 5, 6, 6, 7, 7, 4,
            0, 7, 1, 6, 2, 5, 3, 4
        ]
        
        glVertexAttrib4f(colorSlot, color.x, color.y, color.z, color.w)
        glVertexAttribPointer(positionSlot, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 0, vertices );
        glEnableVertexAttribArray(positionSlot);
        glDrawElements(GLenum(GL_LINES), GLsizei(indices.count), GLenum(GL_UNSIGNED_BYTE), indices);
        
    }
    
    private func updateShoulderTransform(){
        ksMatrixLoadIdentity(&shouldModelViewMatrix);
        
        ksMatrixTranslate(&shouldModelViewMatrix, -0.0, 0.0, -5.5);
        
        // Rotate the shoulder
        //
        ksMatrixRotate(&shouldModelViewMatrix, self.rotateShoulder, 0.0, 0.0, 1.0);
        
        // Scale the cube to be a shoulder
        //
        ksMatrixCopy(&modelViewMatrix, &shouldModelViewMatrix);
        ksMatrixScale(&modelViewMatrix, 1.5, 0.6, 0.6);
        
        // Load the model-view matrix
        glUniformMatrix4fv(GLint(modelViewSlot), 1, GLboolean(GL_FALSE), &modelViewMatrix.m.0.0);
    }
    
    private func updateElbowTransform(){
        // Relative to shoulder
        //
        ksMatrixCopy(&elbowModelViewMatrix, &shouldModelViewMatrix);
        
        // Translate away from shoulder
        //
        ksMatrixTranslate(&elbowModelViewMatrix, 1.5, 0.0, 0.0);
        
        // Rotate the elbow
        //
        ksMatrixRotate(&elbowModelViewMatrix, self.rotateElbow, 0.0, 0.0, 1.0);
        
        // Scale the cube to be a elbow
        ksMatrixCopy(&modelViewMatrix, &elbowModelViewMatrix);
        ksMatrixScale(&modelViewMatrix, 1.5, 0.6, 0.6);
        
        // Load the model-view matrix
        glUniformMatrix4fv(GLint(modelViewSlot), 1, GLboolean(GL_FALSE), &modelViewMatrix.m.0.0);
        
    }
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    private func resetTransform(){
        
    }
    
    private func updateRectangleTransform(){
        
    }
    private func cleanup(){
        
    }
    private func toggleDisplayLink(){
        
    }
    //立方体 颜色
    private func updateColorCubeTransform(){
        ksMatrixLoadIdentity(&modelViewMatrix);
        
        ksMatrixTranslate(&modelViewMatrix, 0.0, -2, -5.5);
        //改变 矩阵 转动方向
        ksMatrixRotate(&modelViewMatrix, rotateColorCube, 0.0, 1.0, 1.0);
        
        // Load the model-view matrix
        glUniformMatrix4fv(GLint(modelViewSlot), 1, GLboolean(GL_FALSE), &modelViewMatrix.m.0.0);
    }
    
    private func drawColorCube(){
        let vertices: [GLfloat] = [
            -0.5,-0.5, 0.5, 1.0, 0.0, 0.0, 1.0,     // red
            -0.5, 0.5, 0.5, 1.0, 1.0, 0.0, 1.0,      // yellow
            0.5, 0.5, 0.5, 0.0, 0.0, 1.0, 1.0,       // blue
            0.5, -0.5, 0.5, 1.0, 1.0, 1.0, 1.0,      // white
            
            0.5, -0.5, -0.5, 1.0, 1.0, 0.0, 1.0,     // yellow
            0.5, 0.5, -0.5, 1.0, 0.0, 0.0, 1.0,      // red
            -0.5, 0.5, -0.5, 1.0, 1.0, 1.0, 1.0,     // white
            -0.5, -0.5, -0.5, 0.0, 0.0, 1.0, 1.0,    // blue
        ]
        
        let indices: [GLubyte] = [
            // Front face
            0, 3, 2, 0, 2, 1,
            
            // Back face
            7, 5, 4, 7, 6, 5,
            
            // Left face
            0, 1, 6, 0, 6, 7,
            
            // Right face
            3, 4, 5, 3, 5, 2,
            
            // Up face
            1, 2, 5, 1, 5, 6,
            
            // Down face
            0, 7, 4, 0, 4, 3
        ]
        let castPointer = UnsafePointer<GLfloat>(vertices)
        
        glVertexAttribPointer(positionSlot, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(7 * sizeof(Float)), vertices);
        //操作指针
        glVertexAttribPointer(colorSlot, 4, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(7 * sizeof(Float)), castPointer + 3);
        //顶点着色器 属性 位置数组
        glEnableVertexAttribArray(positionSlot);
        //顶点着色器 属性 颜色数组
        glEnableVertexAttribArray(colorSlot);
        //画 元素 三角形
        glDrawElements(GLenum(GL_TRIANGLES), GLsizei(indices.count/sizeof(GLubyte)), GLenum(GL_UNSIGNED_BYTE), indices)
        //失效
        glDisableVertexAttribArray(positionSlot);
        glDisableVertexAttribArray(colorSlot);
    }
    
   ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    //画三角形
    private func render(){
        glClearColor(0, 1.0, 1.0, 1.0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        // Setup viewport
        glViewport(0, 0, GLsizei(self.frame.size.width), GLsizei(self.frame.size.height))
        
        
        //改变 TransForm
        self.updateColorCubeTransform()
        //画 立方体
        self.drawColorCube()
        
        let colorRed = ksVec4(x: 1,y: 0,z: 0,w: 1)
        let colorWhite = ksVec4(x: 1,y: 1,z: 1,w: 1)
        
        self.updateShoulderTransform()
        self.drawCube(colorRed)
        
        self.updateElbowTransform()
        self.drawCube(colorWhite)
        
        
        context.presentRenderbuffer(Int(GL_RENDERBUFFER))
        
    }
    
    private func configureViews(){
        self.addSubview(slider1)
        self.addSubview(slider2)
        self.addSubview(slider3)
        self.consraintsForSubViews();
    }
    // MARK: - views actions
    @objc private func sliderValueChanged(slider: UISlider)  {
//        print(slider.tag)
//        
//        print( slider.value)
//
        switch slider.tag {
        case 1:
            rotateShoulder = slider.value * 80.0
        case 2:
            rotateElbow = slider.value * 80.0
        case 3:
            rotateColorCube = slider.value * 80.0
        default:
            break
        }
//
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
                _slider1.addTarget(self, action: #selector(OpenGLView5.sliderValueChanged(_:)), forControlEvents: .ValueChanged)
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
                _slider2.addTarget(self, action: #selector(OpenGLView5.sliderValueChanged(_:)), forControlEvents: .ValueChanged)
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
                _slider3.addTarget(self, action: #selector(OpenGLView5.sliderValueChanged(_:)), forControlEvents: .ValueChanged)
            }
            return _slider3
        }
        set{
            _slider3 = newValue
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
    }


}
