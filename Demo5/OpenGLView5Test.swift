//
//  OpenGLView5Test.swift
//  OpenGlESExample
//
//  Created by WeiHu on 6/16/16.
//  Copyright © 2016 WeiHu. All rights reserved.
//

import UIKit

let TEX_COORD_MAX : Float = 1

class OpenGLView5Test: UIView {
    struct Vertex{
        
        var Position: (CFloat, CFloat, CFloat, CFloat);
        var TexCoord: (CFloat, CFloat);
    }
    
    var Vertices : [Vertex] = [
        Vertex(Position: (1, -1, 0, 1), TexCoord: (TEX_COORD_MAX, 0)),
        Vertex(Position: (1, 1, 0, 1), TexCoord: (TEX_COORD_MAX, TEX_COORD_MAX)),
        Vertex(Position: (-1, 1, 0, 1), TexCoord: (0, TEX_COORD_MAX)),
        Vertex(Position: (-1, -1, 0, 1), TexCoord: (0, 0))
    ]
    
    var Indices: [GLubyte] = [
        0, 1, 2,
        2, 3, 0
    ]
    //基本属性
    private var eaglLayer : CAEAGLLayer?
    private var context : EAGLContext?
    private var colorRenderBuffer : GLuint = 0
    
    //着色器
    //
    private var fragmentShader : GLuint = 0
    //点点着色器
    private var vertexShader : GLuint = 0
    //位置
    private var positionSlot : GLuint = 0
    private var textCoordSlot : GLuint = 0
    
    private var textureUni : GLuint = 0
    private var filterUni : GLuint = 0
    
    //纹理
    private var texture : GLuint = 0
    
    //VBO
    private var vertexBuffer : GLuint = 0
    private var indexBuffer : GLuint = 0
    
    //UIImage的CGImage,从外部接收
    var spriteImage : CGImage?
    
    override class func layerClass() -> AnyClass
    {
        return CAEAGLLayer.self
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpLayer()
        setUpContext()
        setUpRenderBuffer()
        setUpFramebuffer()
        compileShaders()
        setUpVBOs()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    private func setUpLayer() {
        eaglLayer = layer as? CAEAGLLayer;
        eaglLayer!.opaque = true;
    }
    
    private func setUpContext()
    {
        context = EAGLContext(API: .OpenGLES2)
        if context == nil {
            print("fail load OpenGLES2")
            return
        }
        
        if EAGLContext.setCurrentContext(context) == false{
            print("fail to set currentContext")
        }
    }
       private func setUpRenderBuffer()
    {
        glGenRenderbuffers(1, &colorRenderBuffer);
        glBindRenderbuffer(GLenum(GL_RENDERBUFFER), colorRenderBuffer);
        context!.renderbufferStorage(Int(GL_RENDERBUFFER), fromDrawable: eaglLayer);
    }
    
    private func setUpFramebuffer()
    {
        var framebuffer = GLuint()
        glGenFramebuffers(1, &framebuffer)
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), framebuffer)
        glFramebufferRenderbuffer(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT0),
                                  GLenum(GL_RENDERBUFFER), colorRenderBuffer)
    }
    private func compileShaders()
    {
        fragmentShader = compileShader("FragmentShader", type: GLenum(GL_FRAGMENT_SHADER))
        vertexShader = compileShader("VertexShader", type: GLenum(GL_VERTEX_SHADER))
        
        let programHandle = glCreateProgram()
        glAttachShader(programHandle, vertexShader);
        glAttachShader(programHandle, fragmentShader);
        glLinkProgram(programHandle);
        
        var linkSuccess : GLint = 0
        glGetProgramiv(programHandle, GLenum(GL_LINK_STATUS), &linkSuccess)
        if linkSuccess == GL_FALSE
        {
            var value: GLint = 0
            glGetProgramiv(programHandle, GLenum(GL_INFO_LOG_LENGTH), &value)
            var infoLog: [GLchar] = [GLchar](count: Int(value), repeatedValue: 0)
            var infoLogLength: GLsizei = 0
            glGetProgramInfoLog(programHandle, value, &infoLogLength, &infoLog)
            let s = NSString(bytes: infoLog, length: Int(infoLogLength), encoding: NSASCIIStringEncoding)
            print(s)
        }
        glUseProgram(programHandle)
        
        //关联shader的参数
        positionSlot = GLuint(glGetAttribLocation(programHandle, "position"))
        glEnableVertexAttribArray(GLuint(positionSlot))
        
        
        glGetAttribLocation(programHandle, "texCoordIn")
        glEnableVertexAttribArray(GLuint(textCoordSlot))
        
        textureUni = GLuint(glGetUniformLocation(programHandle, "textureImage"))
        
        filterUni = GLuint(glGetUniformLocation(programHandle, "rgbaFilter"))
        
//        glUniformMatrix4fv(GLint(filterUni), 1, GLboolean(GL_FALSE), 0)
    }
    
    private func compileShader(shaderName : String, type : GLenum) -> GLuint
    {
        //1
        let shaderPath = NSBundle.mainBundle().pathForResource(shaderName, ofType: "glsl")
        var shaderString : NSString?
        do{
            shaderString = try NSString(contentsOfFile: shaderPath!, encoding: NSUTF8StringEncoding)
        }
        catch{
            print("fail to compile shader")
        }
        
        //2
        let shaderHandle = glCreateShader(type)
        
        //3
        var shaderStringUTF8 = shaderString?.cStringUsingEncoding(NSUTF8StringEncoding)
        glShaderSource(shaderHandle, 1, &shaderStringUTF8!, nil)
        
        //4
        glCompileShader(shaderHandle)
        
        //5
        var compileSuccess  : GLint = 0
        glGetShaderiv(shaderHandle, GLenum(GL_COMPILE_STATUS), &compileSuccess)
        if compileSuccess == GL_FALSE
        {
            var value: GLint = 0
            glGetShaderiv(shaderHandle, GLenum(GL_INFO_LOG_LENGTH), &value)
            var infoLog: [GLchar] = [GLchar](count: Int(value), repeatedValue: 0)
            var infoLogLength: GLsizei = 0
            glGetShaderInfoLog(shaderHandle, value, &infoLogLength, &infoLog)
            let s = NSString(bytes: infoLog, length: Int(infoLogLength), encoding: NSASCIIStringEncoding)
            print(s)
        }
        return shaderHandle
    }

    private func setUpVBOs()
    {
        glGenBuffers(1, &vertexBuffer)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vertexBuffer);
        glBufferData(GLenum(GL_ARRAY_BUFFER), Vertices.count * sizeofValue(Vertices[0]), Vertices, GLenum(GL_STATIC_DRAW))
        
        glGenBuffers(1, &indexBuffer);
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), indexBuffer);
        glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER), Indices.count * sizeofValue(Indices[0]), Indices, GLenum(GL_STATIC_DRAW))
    }
    

    private func render()
    {
        glClearColor(0.0, 1.0, 0.0, 0.0)
        glClear(GLenum(GL_COLOR_BUFFER_BIT))
        
        glViewport(0, 0, GLsizei(frame.size.width), GLsizei(frame.size.height))
        
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vertexBuffer)
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), indexBuffer)
        
        glEnableVertexAttribArray(positionSlot)
        glVertexAttribPointer(GLuint(positionSlot), 4, GLenum(GL_FLOAT), GLboolean(GL_FALSE),
                              GLsizei(sizeof(Vertex)), UnsafePointer<Int>(bitPattern: 0))
        
        glVertexAttribPointer(textCoordSlot, 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), Int32(sizeof(Vertex)), UnsafePointer<Void>(bitPattern: sizeof(Float) * 4))
        
        glActiveTexture(GLenum(GL_TEXTURE0))
        glBindTexture(GLenum(GL_TEXTURE_2D), texture)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MAG_FILTER), GL_LINEAR)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GL_LINEAR)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), GL_CLAMP_TO_EDGE)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_T), GL_CLAMP_TO_EDGE)
        
        glDrawElements(GLuint(GL_TRIANGLES), GLsizei(Indices.count), GLenum(GL_UNSIGNED_BYTE), UnsafePointer<Int>(bitPattern: 0))
        
        glDeleteTextures(1, &texture)
        
        context!.presentRenderbuffer(Int(GL_RENDERBUFFER))
    }
    //暴露接口
    func setUpTexture(spriteImage : CGImage)
    {
        // 1
        self.spriteImage = spriteImage
        // 2
        let width = CGImageGetWidth(spriteImage)
        let height = CGImageGetHeight(spriteImage)
        
        
        let spriteData = UnsafeMutablePointer<Void>(calloc(width * height * 4, sizeof(GLubyte)))
        
        let spriteContext = CGBitmapContextCreate(spriteData, width, height, 8, width * 4,CGImageGetColorSpace(spriteImage), CGImageAlphaInfo.PremultipliedLast.rawValue);
        
        // 3
        CGContextDrawImage(spriteContext, CGRectMake(0, 0, CGFloat(width), CGFloat(height)), spriteImage)
        
        // 4
        glGenTextures(1, &texture)
        glBindTexture(GLenum(GL_TEXTURE_2D), texture)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GLint(GL_NEAREST))
        
        glTexImage2D(GLenum(GL_TEXTURE_2D), 0, GL_RGBA, GLsizei(width), GLsizei(height), 0, GLenum(GL_RGBA), GLenum(GL_UNSIGNED_BYTE), spriteData)
    
        
        free(spriteData)
        render()
    }
}
