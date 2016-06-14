//
//  GlobalDefine.swift
//  OpenGlESExample
//
//  Created by WeiHu on 6/13/16.
//  Copyright © 2016 WeiHu. All rights reserved.
//

import Foundation
import UIKit

class KSVec3: NSObject {
    var x: Float = 0.0
    var y: Float = 0.0
    var z: Float = 0.0
}
class KSVec4: NSObject {
    var x: Float = 0.0
    var y: Float = 0.0
    var z: Float = 0.0
    var w: Float = 0.0
}
class KSColor: NSObject {
    var r: Float = 0.0
    var g: Float = 0.0
    var b: Float = 0.0
    var a: Float = 0.0
}
func KSVectorCopy(outKSVec3: KSVec3, inKSVec3: KSVec3) {
    outKSVec3.x = inKSVec3.x
    outKSVec3.y = inKSVec3.y
    outKSVec3.z = inKSVec3.z
}
func KSVectorAdd(outKSVec3: KSVec3, aKSVec3: UnsafePointer<KSVec3>,bKSVec3: UnsafePointer<KSVec3>) {
    outKSVec3.x = aKSVec3.memory.x + bKSVec3.memory.x
    outKSVec3.y = aKSVec3.memory.y + bKSVec3.memory.y
    outKSVec3.z = aKSVec3.memory.z + bKSVec3.memory.z
}
func KSVectorSubtract(outKSVec3: KSVec3, aKSVec3: UnsafePointer<KSVec3>,bKSVec3: UnsafePointer<KSVec3>) {
    outKSVec3.x = aKSVec3.memory.x - bKSVec3.memory.x
    outKSVec3.y = aKSVec3.memory.y - bKSVec3.memory.y
    outKSVec3.z = aKSVec3.memory.z - bKSVec3.memory.z
}
func KSVectorLerp(outKSVec3: KSVec3, aKSVec3: UnsafePointer<KSVec3>,bKSVec3: UnsafePointer<KSVec3>,t:Float) {
    outKSVec3.x = aKSVec3.memory.x * (1.0 - t) - bKSVec3.memory.x * t
    outKSVec3.y = aKSVec3.memory.y * (1.0 - t) - bKSVec3.memory.y * t
    outKSVec3.z = aKSVec3.memory.z * (1.0 - t) - bKSVec3.memory.z * t
}
func KSCrossProduct(outKSVec3: KSVec3, aKSVec3: UnsafePointer<KSVec3>,bKSVec3: UnsafePointer<KSVec3>) {
    outKSVec3.x = aKSVec3.memory.y * bKSVec3.memory.z - aKSVec3.memory.z * bKSVec3.memory.y
    outKSVec3.y = aKSVec3.memory.z * bKSVec3.memory.x - aKSVec3.memory.x * bKSVec3.memory.z
    outKSVec3.z = aKSVec3.memory.x * bKSVec3.memory.y - aKSVec3.memory.y * bKSVec3.memory.x
}
func KSDotProduct(aKSVec3: UnsafePointer<KSVec3>,bKSVec3: UnsafePointer<KSVec3>) -> Float{
    
    return aKSVec3.memory.x * bKSVec3.memory.x + aKSVec3.memory.y * bKSVec3.memory.y + aKSVec3.memory.z * bKSVec3.memory.z
}
func KSVectorLengthSquared(inKSVec3: UnsafePointer<KSVec3>) -> Float{
    
    return inKSVec3.memory.x * inKSVec3.memory.x + inKSVec3.memory.y * inKSVec3.memory.y + inKSVec3.memory.z * inKSVec3.memory.z
}
func KSVectorDistanceSquared(aKSVec3: UnsafePointer<KSVec3>,bKSVec3: UnsafePointer<KSVec3>) -> Float{
    
    let vec3: KSVec3 = KSVec3()
    KSVectorSubtract(vec3, aKSVec3: aKSVec3, bKSVec3: bKSVec3);
    return (vec3.x * vec3.x + vec3.y * vec3.y + vec3.z * vec3.z);
}

func KSVectorScale(vKSVec3: UnsafePointer<KSVec3>,scale: Float) {
    vKSVec3.memory.x *= scale;
    vKSVec3.memory.y *= scale;
    vKSVec3.memory.z *= scale;
}
func KSVectorNormalize(vKSVec3: UnsafePointer<KSVec3>) {
    var length = KSVectorLength(vKSVec3)
    if (length != 0)
    {
        length = 1.0 / length;
        vKSVec3.memory.x *= length;
        vKSVec3.memory.y *= length;
        vKSVec3.memory.z *= length;
    }
    
}
func KSVectorInverse(vKSVec3: UnsafePointer<KSVec3>) {
    vKSVec3.memory.x = -vKSVec3.memory.x;
    vKSVec3.memory.y = -vKSVec3.memory.y;
    vKSVec3.memory.z = -vKSVec3.memory.z;
}
func KSVectorCompare(aKSVec3: UnsafePointer<KSVec3>,bKSVec3: UnsafePointer<KSVec3>) -> Int{
   	if aKSVec3.memory.x == bKSVec3.memory.x && aKSVec3.memory.y == bKSVec3.memory.y && aKSVec3.memory.z == bKSVec3.memory.z{
        return 1
    }
    if aKSVec3.memory.x != bKSVec3.memory.x || aKSVec3.memory.y != bKSVec3.memory.y || aKSVec3.memory.z != bKSVec3.memory.z{
        return 0
    }
    return 1;
}
func KSVectorLength(inKSVec3: UnsafePointer<KSVec3>) -> Float{
    let result =  sqrt(Double(inKSVec3.memory.x * inKSVec3.memory.x + inKSVec3.memory.y * inKSVec3.memory.y + inKSVec3.memory.z * inKSVec3.memory.z))
    return Float(result)
}
//func KSVectorDistance(aKSVec3: UnsafePointer<KSVec3>,bKSVec3: UnsafePointer<KSVec3>) -> Float{
//    let vec3 = KSVec3()
//    KSVectorSubtract(vec3, aKSVec3: aKSVec3, bKSVec3: bKSVec3);
//    return KSVectorLength(vec3);
//}