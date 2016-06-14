//
//  GLESUtils.swift
//  OpenGlESExample
//
//  Created by WeiHu on 6/12/16.
//  Copyright © 2016 WeiHu. All rights reserved.
//

import UIKit

class GLESUtils: NSObject {
    class func loadShader(type: GLenum, withString shaderString: String = "") -> GLuint {
        // Create the shader object
        let shader: GLuint = glCreateShader(type)

        if shader == 0{
            print("Error: failed to create shader.")
            return 0
        }
  
        var shaderStringUTF8 = (shaderString as NSString).UTF8String
        glShaderSource(shader, GLsizei(1), &shaderStringUTF8, nil)
        glCompileShader(shader)
        var compiled: GLint = 0
        glGetShaderiv(shader, GLenum(GL_COMPILE_STATUS), &compiled)
        
        if compiled == 0 {
            var infoLen: GLint = 0;
            glGetShaderiv (shader,GLenum(GL_INFO_LOG_LENGTH), &infoLen )
            
            if infoLen > 1 {
                let infoLog = UnsafeMutablePointer<GLchar>.alloc(Int(infoLen))
                glGetShaderInfoLog (shader, infoLen, nil, infoLog)
                print("Error compiling shader:\n%s\n", infoLog )
                
                free(infoLog)
            }
            
            glDeleteShader(shader)
            return 0
        }
        
        return shader
    }
    class func loadShader(type: GLenum, withFilepath shaderFilepath: String = "") -> GLuint{
        do {
            if let shaderString: String = try String(contentsOfFile:shaderFilepath, encoding:NSUTF8StringEncoding){
               return GLESUtils.loadShader(type, withString: shaderString)
            }
        }catch _ as NSError{
            
        }
        return 0
    }
}
