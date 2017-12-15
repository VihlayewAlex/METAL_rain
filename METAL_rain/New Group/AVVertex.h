//
//  AVVertex.h
//  METAL_rain
//
//  Created by Alex Vihlayew on 12/13/17.
//  Copyright © 2017 Alex Vihlayew. All rights reserved.
//

#ifndef AVVertex_h
#define AVVertex_h

#import <Foundation/Foundation.h>
#import <simd/simd.h>

typedef struct
{
    simd_float4 position;
    simd_float4 color;
} AVVertex;

#endif /* AVVertex_h */
