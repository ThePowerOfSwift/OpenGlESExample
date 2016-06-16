//
//  MatrixTools.h
//  OpenGlESExample
//
//  Created by WeiHu on 6/15/16.
//  Copyright © 2016 WeiHu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <OpenGLES/ES2/gl.h>
#include <math.h>

#ifndef M_PI
#define M_PI 3.1415926535897932384626433832795f
#endif

#define DEG2RAD( a ) (((a) * M_PI) / 180.0f)
#define RAD2DEG( a ) (((a) * 180.f) / M_PI)

// angle indexes
#define	PITCH				0		// up / down
#define	YAW					1		// left / right
#define	ROLL				2		// fall over


@interface MatrixTools : NSObject

typedef unsigned char 		byte;

typedef struct
{
    GLfloat   m[3][3];
} Matrix3;

typedef struct
{
    GLfloat   m[4][4];
} Matrix4;

typedef struct Vec3 {
    GLfloat x;
    GLfloat y;
    GLfloat z;
} Vec3;

typedef struct Vec4 {
    GLfloat x;
    GLfloat y;
    GLfloat z;
    GLfloat w;
} Vec4;

typedef struct {
    GLfloat r;
    GLfloat g;
    GLfloat b;
    GLfloat a;
} Color;

+ (void)CopyMatrix4:(Matrix4 *) target src: (const Matrix4 *) src;

+ (void)Matrix4ToMatrix3:(Matrix3 *) target src:(const Matrix4 *) src;

+ (void)Scale:(Matrix4 *)result sx :(GLfloat) sx  sy:(GLfloat)sy sz:(GLfloat) sz;

+ (void)Translate:(Matrix4 *)result tx:(GLfloat) tx ty: (GLfloat) ty tz:(GLfloat)tz;

+ (void)Rotate:(Matrix4 *)result angle:(GLfloat) angle x:(GLfloat)x y:(GLfloat) y z:(GLfloat) z;

+ (void)MatrixMultiply:(Matrix4 *)result srcA: (const Matrix4 *)srcA srcB:(const Matrix4 *)srcB;

+ (void)MatrixLoadIdentity:(Matrix4 *)result;

+ (void)Perspective:(Matrix4 *)result fovy: (CGFloat )fovy  aspect:(CGFloat) aspect nearZ:(CGFloat) nearZ farZ: (CGFloat) farZ;

+ (void)Ortho:(Matrix4 *)result left:(CGFloat) left right:(CGFloat) right bottom:(CGFloat) bottom top:(CGFloat) top nearZ: (CGFloat) nearZ farZ:(CGFloat) farZ;

+ (void)Frustum:(Matrix4 *)result left: (CGFloat) left right: (CGFloat) right bottom: (CGFloat) bottom top: (CGFloat) top nearZ: (CGFloat) nearZ farZ: (CGFloat) farZ;
@end

