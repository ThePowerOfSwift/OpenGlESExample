//
//  VectorTools.m
//  OpenGlESExample
//
//  Created by WeiHu on 6/14/16.
//  Copyright © 2016 WeiHu. All rights reserved.
//

#import "VectorTools.h"

@implementation VectorTools

+ (void)VectorCopy:(Vec3 * )outVec withInVec:(const Vec3 *)inVec{
    outVec->x = inVec->x;
    outVec->y = inVec->y;
    outVec->z = inVec->z;
}
+ (void)VectorAdd:(Vec3 * )outVec withAVec:(const Vec3 *)aVec withBVec:(const Vec3 *)bVec{
    outVec->x = aVec->x + bVec->x;
    outVec->y = aVec->y + bVec->y;
    outVec->z = aVec->z + bVec->z;
}
+ (void)VectorSubtract:(Vec3 * )outVec withAVec:(const Vec3 *)aVec withBVec:(const Vec3 *)bVec{
    outVec->x = aVec->x - bVec->x;
    outVec->y = aVec->y - bVec->y;
    outVec->z = aVec->z - bVec->z;
}
+ (void)VectorLerp:(Vec3 * )outVec withAVec:(const Vec3 *)aVec withBVec:(const Vec3 *)bVec t:(CGFloat)t{
    outVec->x = (aVec->x * (1 - t) + bVec->x * t);
    outVec->y = (aVec->y * (1 - t) + bVec->y * t);
    outVec->z = (aVec->z * (1 - t) + bVec->z * t);
}
+ (void)CrossProduct:(Vec3 * )outVec withAVec:(const Vec3 *)aVec withBVec:(const Vec3 *)bVec{
    outVec->x = aVec->y * bVec->z - aVec->z * bVec->y;
    outVec->y = aVec->z * bVec->x - aVec->x * bVec->z;
    outVec->z = aVec->x * bVec->y - bVec->y * aVec->x;
}
+ (CGFloat)DotProduct:(const Vec3 *)aVec withBVec:(const Vec3 *)bVec{
    return (aVec->x * bVec->x + aVec->y * bVec->y + aVec->z * bVec->z);
}
+ (CGFloat)VectorLengthSquared:(Vec3 * )inVec{
    return (inVec->x * inVec->x + inVec->y * inVec->y + inVec->z * inVec->z);
}
+ (CGFloat)VectorDistanceSquared:(const Vec3 *)aVec withBVec:(const Vec3 *)bVec{
    Vec3 vVec;
    [VectorTools VectorSubtract:&vVec withAVec:aVec withBVec:bVec];
    return (vVec.x * vVec.x + vVec.y * vVec.y + vVec.z * vVec.z);
}
+ (void)VectorScale:(Vec3 * )vVec scale:(CGFloat)scale{
    vVec->x *= scale;
    vVec->y *= scale;
    vVec->z *= scale;
}
+ (void)VectorNormalize:(Vec3 * )vVec{
    float length = [VectorTools VectorLength:vVec];
    if (length != 0)
    {
        length = 1.0 / length;
        vVec->x *= length;
        vVec->y *= length;
        vVec->z *= length;
    }
}
+ (void)VectorInverse:(Vec3 * )vVec{
    vVec->x = -vVec->x;
    vVec->y = -vVec->y;
    vVec->z = -vVec->z;
}
+ (NSInteger)VectorCompare:(const Vec3 *)aVec withBVec:(const Vec3 *)bVec{
    
    if (aVec == bVec)
        return 1;
    
    if (aVec->x != bVec->x || aVec->y != bVec->y || aVec->z != bVec->z)
        return 0;
    return 1;
}
+ (CGFloat)VectorLength:(Vec3 * )inVec{
    return (float)sqrt(inVec->x * inVec->x + inVec->y * inVec->y + inVec->z * inVec->z);
}
+ (CGFloat)VectorDistance:(const Vec3 *)aVec withBVec:(const Vec3 *)bVec{
    Vec3 vVec;
    [VectorTools VectorSubtract:&vVec withAVec:aVec withBVec:bVec];
    return [VectorTools VectorLength:&vVec];
}


@end
