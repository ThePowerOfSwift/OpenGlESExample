//
//  ParametricSurface.h
//  OpenGlESExample
//
//  Created by WeiHu on 6/16/16.
//  Copyright © 2016 WeiHu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


enum VertexFlags
{
    VertexFlagsNormals = 1 << 0,
    VertexFlagsTexCoords = 1 << 1,
};

struct ParametricInterval
{
//    ivec2 Divisions;
//    vec2 UpperBound;
//    vec2 TextureCount;
};

@interface ParametricSurface : NSObject

- (void)setVertexFlags:(NSUInteger)flags;
- (void)GetVertexSize;
- (void)GetVertexCount;
- (void)GetLineIndexCount;
- (void)GetTriangleIndexCount;
- (void)GenerateVertices:(CGFloat)vertices;
- (void)GenerateLineIndices:(NSUInteger)indices;
- (void)GenerateTriangleIndices:(NSUInteger)indices;

@end
