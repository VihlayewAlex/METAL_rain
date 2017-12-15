//
//  AVRenderer.h
//  METAL_rain
//
//  Created by Alex Vihlayew on 12/15/17.
//  Copyright © 2017 Alex Vihlayew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <Metal/Metal.h>
#import "AVVertex.h"

@interface AVRenderer : NSObject

- (void)setupLayerOver:(CALayer*)underlyingLayer;
- (void)drawRainWithRaindropsCount:(NSInteger)raindropsCount;

@end
