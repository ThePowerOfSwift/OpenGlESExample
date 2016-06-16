//
//  VectorTools.h
//  OpenGlESExample
//
//  Created by WeiHu on 6/14/16.
//  Copyright © 2016 WeiHu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
typedef struct
{
    float x;
    float y;
    float z;
} Vec3;

typedef struct
{
    float x;
    float y;
    float z;
    float w;
} Vec4;

typedef struct
{
    float r;
    float g;
    float b;
    float a;
} Color;

@interface VectorTools : NSObject
+ (void)VectorCopy:(Vec3 * )outVec withInVec:(const Vec3 *)inVec;
+ (void)VectorAdd:(Vec3 * )outVec withAVec:(const Vec3 *)aVec withBVec:(const Vec3 *)bVec;
+ (void)VectorSubtract:(Vec3 * )outVec withAVec:(const Vec3 *)aVec withBVec:(const Vec3 *)bVec;
+ (void)VectorLerp:(Vec3 * )outVec withAVec:(const Vec3 *)aVec withBVec:(const Vec3 *)bVec t:(CGFloat)t;
+ (void)CrossProduct:(Vec3 * )outVec withAVec:(const Vec3 *)aVec withBVec:(const Vec3 *)bVec;
+ (CGFloat)DotProduct:(const Vec3 *)aVec withBVec:(const Vec3 *)bVec;
+ (CGFloat)VectorLengthSquared:(Vec3 * )inVec;
+ (CGFloat)VectorDistanceSquared:(const Vec3 *)aVec withBVec:(const Vec3 *)bVec;
+ (void)VectorScale:(Vec3 * )vVec scale:(CGFloat)scale;
+ (void)VectorNormalize:(Vec3 * )vVec;
+ (void)VectorInverse:(Vec3 * )vVec;
+ (NSInteger)VectorCompare:(const Vec3 *)aVec withBVec:(const Vec3 *)bVec;
+ (CGFloat)VectorLength:(Vec3 * )inVec;
+ (CGFloat)VectorDistance:(const Vec3 *)aVec withBVec:(const Vec3 *)bVec;


@end

