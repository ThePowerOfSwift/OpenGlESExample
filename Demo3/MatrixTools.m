//
//  MatrixTools.m
//  OpenGlESExample
//
//  Created by WeiHu on 6/15/16.
//  Copyright © 2016 WeiHu. All rights reserved.
//

#import "MatrixTools.h"
#include <stdlib.h>
#include <math.h>

@implementation MatrixTools


+ (void)CopyMatrix4:(Matrix4 *) target src: (const Matrix4 *) src{
    memcpy(target, src, sizeof(Matrix4));
    
}

+ (void)Matrix4ToMatrix3:(Matrix3 *) t src:(const Matrix4 *) src{
    t->m[0][0] = src->m[0][0];
    t->m[0][1] = src->m[0][1];
    t->m[0][2] = src->m[0][2];
    t->m[1][0] = src->m[1][0];
    t->m[1][1] = src->m[1][1];
    t->m[1][2] = src->m[1][2];
    t->m[2][0] = src->m[2][0];
    t->m[2][1] = src->m[2][1];
    t->m[2][2] = src->m[2][2];
}



+ (void)Scale:(Matrix4 *)result sx :(GLfloat) sx  sy:(GLfloat)sy sz:(GLfloat) sz{
    result->m[0][0] *= sx;
    result->m[0][1] *= sx;
    result->m[0][2] *= sx;
    result->m[0][3] *= sx;
    
    result->m[1][0] *= sy;
    result->m[1][1] *= sy;
    result->m[1][2] *= sy;
    result->m[1][3] *= sy;
    
    result->m[2][0] *= sz;
    result->m[2][1] *= sz;
    result->m[2][2] *= sz;
    result->m[2][3] *= sz;
}



+ (void)Translate:(Matrix4 *)result tx:(GLfloat) tx ty: (GLfloat) ty tz:(GLfloat)tz{
    result->m[3][0] += (result->m[0][0] * tx + result->m[1][0] * ty + result->m[2][0] * tz);
    result->m[3][1] += (result->m[0][1] * tx + result->m[1][1] * ty + result->m[2][1] * tz);
    result->m[3][2] += (result->m[0][2] * tx + result->m[1][2] * ty + result->m[2][2] * tz);
    result->m[3][3] += (result->m[0][3] * tx + result->m[1][3] * ty + result->m[2][3] * tz);
}



+ (void)Rotate:(Matrix4 *)result angle:(GLfloat) angle x:(GLfloat)x y:(GLfloat) y z:(GLfloat) z{
    GLfloat sinAngle, cosAngle;
    GLfloat mag = sqrtf(x * x + y * y + z * z);
    
    sinAngle = sinf ( angle * M_PI / 180.0f );
    cosAngle = cosf ( angle * M_PI / 180.0f );
    if ( mag > 0.0f )
    {
        GLfloat xx, yy, zz, xy, yz, zx, xs, ys, zs;
        GLfloat oneMinusCos;
        Matrix4 rotMat;
        
        x /= mag;
        y /= mag;
        z /= mag;
        
        xx = x * x;
        yy = y * y;
        zz = z * z;
        xy = x * y;
        yz = y * z;
        zx = z * x;
        xs = x * sinAngle;
        ys = y * sinAngle;
        zs = z * sinAngle;
        oneMinusCos = 1.0f - cosAngle;
        
        rotMat.m[0][0] = (oneMinusCos * xx) + cosAngle;
        rotMat.m[0][1] = (oneMinusCos * xy) - zs;
        rotMat.m[0][2] = (oneMinusCos * zx) + ys;
        rotMat.m[0][3] = 0.0F;
        
        rotMat.m[1][0] = (oneMinusCos * xy) + zs;
        rotMat.m[1][1] = (oneMinusCos * yy) + cosAngle;
        rotMat.m[1][2] = (oneMinusCos * yz) - xs;
        rotMat.m[1][3] = 0.0F;
        
        rotMat.m[2][0] = (oneMinusCos * zx) - ys;
        rotMat.m[2][1] = (oneMinusCos * yz) + xs;
        rotMat.m[2][2] = (oneMinusCos * zz) + cosAngle;
        rotMat.m[2][3] = 0.0F;
        
        rotMat.m[3][0] = 0.0F;
        rotMat.m[3][1] = 0.0F;
        rotMat.m[3][2] = 0.0F;
        rotMat.m[3][3] = 1.0F;
        [MatrixTools MatrixMultiply:result srcA:&rotMat srcB:result];
    }
}



+ (void)MatrixMultiply:(Matrix4 *)result srcA: (const Matrix4 *)srcA srcB:(const Matrix4 *)srcB{
    Matrix4    tmp;
    int         i;
    
    for (i=0; i<4; i++)
    {
        tmp.m[i][0] =	(srcA->m[i][0] * srcB->m[0][0]) +
        (srcA->m[i][1] * srcB->m[1][0]) +
        (srcA->m[i][2] * srcB->m[2][0]) +
        (srcA->m[i][3] * srcB->m[3][0]) ;
        
        tmp.m[i][1] =	(srcA->m[i][0] * srcB->m[0][1]) +
        (srcA->m[i][1] * srcB->m[1][1]) +
        (srcA->m[i][2] * srcB->m[2][1]) +
        (srcA->m[i][3] * srcB->m[3][1]) ;
        
        tmp.m[i][2] =	(srcA->m[i][0] * srcB->m[0][2]) +
        (srcA->m[i][1] * srcB->m[1][2]) +
        (srcA->m[i][2] * srcB->m[2][2]) +
        (srcA->m[i][3] * srcB->m[3][2]) ;
        
        tmp.m[i][3] =	(srcA->m[i][0] * srcB->m[0][3]) +
        (srcA->m[i][1] * srcB->m[1][3]) +
        (srcA->m[i][2] * srcB->m[2][3]) +
        (srcA->m[i][3] * srcB->m[3][3]) ;
    }
    
    memcpy(result, &tmp, sizeof(Matrix4));
}



+ (void)MatrixLoadIdentity:(Matrix4 *)result{
    memset(result, 0x0, sizeof(Matrix4));
    
    result->m[0][0] = 1.0f;
    result->m[1][1] = 1.0f;
    result->m[2][2] = 1.0f;
    result->m[3][3] = 1.0f;
}



+ (void)Perspective:(Matrix4 *)result fovy: (CGFloat )fovy  aspect:(CGFloat) aspect nearZ:(CGFloat) nearZ farZ: (CGFloat) farZ{
    GLfloat frustumW, frustumH;
    
    frustumH = tanf( fovy / 360.0f * M_PI ) * nearZ;
    frustumW = frustumH * aspect;
    [MatrixTools Frustum:result left:-frustumW right:frustumW bottom:-frustumH top:frustumH nearZ:nearZ farZ:farZ];
    
}



+ (void)Ortho:(Matrix4 *)result left:(CGFloat) left right:(CGFloat) right bottom:(CGFloat) bottom top:(CGFloat) top nearZ: (CGFloat) nearZ farZ:(CGFloat) farZ{
    CGFloat       deltaX = right - left;
    CGFloat       deltaY = top - bottom;
    CGFloat       deltaZ = farZ - nearZ;
    Matrix4    ortho;
    
    if ( (deltaX == 0.0f) || (deltaY == 0.0f) || (deltaZ == 0.0f) )
        return;
    [MatrixTools MatrixLoadIdentity:&ortho];

    ortho.m[0][0] = 2.0f / deltaX;
    ortho.m[3][0] = -(right + left) / deltaX;
    ortho.m[1][1] = 2.0f / deltaY;
    ortho.m[3][1] = -(top + bottom) / deltaY;
    ortho.m[2][2] = -2.0f / deltaZ;
    ortho.m[3][2] = -(nearZ + farZ) / deltaZ;
    [MatrixTools MatrixMultiply:result srcA:&ortho srcB:result];
    
}



+ (void)Frustum:(Matrix4 *)result left: (CGFloat) left right: (CGFloat) right bottom: (CGFloat) bottom top: (CGFloat) top nearZ: (CGFloat) nearZ farZ: (CGFloat) farZ{
    CGFloat       deltaX = right - left;
    CGFloat       deltaY = top - bottom;
    CGFloat       deltaZ = farZ - nearZ;
    Matrix4    frust;
    
    if ( (nearZ <= 0.0f) || (farZ <= 0.0f) ||
        (deltaX <= 0.0f) || (deltaY <= 0.0f) || (deltaZ <= 0.0f) )
        return;
    
    frust.m[0][0] = 2.0f * nearZ / deltaX;
    frust.m[0][1] = frust.m[0][2] = frust.m[0][3] = 0.0f;
    
    frust.m[1][1] = 2.0f * nearZ / deltaY;
    frust.m[1][0] = frust.m[1][2] = frust.m[1][3] = 0.0f;
    
    frust.m[2][0] = (right + left) / deltaX;
    frust.m[2][1] = (top + bottom) / deltaY;
    frust.m[2][2] = -(nearZ + farZ) / deltaZ;
    frust.m[2][3] = -1.0f;
    
    frust.m[3][2] = -2.0f * nearZ * farZ / deltaZ;
    frust.m[3][0] = frust.m[3][1] = frust.m[3][3] = 0.0f;
    [MatrixTools MatrixMultiply:result srcA:&frust srcB:result];
}

@end
