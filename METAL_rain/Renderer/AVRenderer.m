//
//  AVRenderer.m
//  METAL_rain
//
//  Created by Alex Vihlayew on 12/15/17.
//  Copyright © 2017 Alex Vihlayew. All rights reserved.
//

#import "AVRenderer.h"

@interface AVRenderer ()

@property (strong, nonatomic) id<MTLDevice> METAL_device;
@property (strong, nonatomic) CAMetalLayer* METAL_layer;
@property (strong, nonatomic) id<MTLBuffer> METAL_vertexBuffer;
@property (strong, nonatomic) id<MTLRenderPipelineState> METAL_pipelineState;
@property (strong, nonatomic) id<MTLCommandQueue> METAL_commandQueue;

@property (assign, nonatomic) NSInteger raindropsCount;

@end

@implementation AVRenderer

AVVertex* vertexBuffer;

#pragma mark Synthesizing accessors

@synthesize METAL_device;
@synthesize METAL_layer;
@synthesize METAL_vertexBuffer;
@synthesize METAL_pipelineState;
@synthesize METAL_commandQueue;

#pragma mark METAL drawing calls

-(void)setupLayerOver:(CALayer*)underlyingLayer
{
    [self configureDevice];
    [self configureLayerOver:underlyingLayer];
}

- (void)drawRainWithRaindropsCount:(NSInteger)raindropsCount
{
    _raindropsCount = raindropsCount;
    [self configureVertexBufferForRaindropsCount:raindropsCount];
    [self configurePipelineState];
    [self configureCommandQueue];
    [self configureRenderer];
}

#pragma mark METAL drawing implementation

- (void)configureDevice
{
    METAL_device = MTLCreateSystemDefaultDevice(); // Returns reference to a default MTLDevice
}

- (void)configureLayerOver:(CALayer*)layer // Creating a CAMetalLayer and adding as a sublayer to a root view's layer
{
    METAL_layer = [[CAMetalLayer alloc] init];
    [METAL_layer setDevice:METAL_device];
    [METAL_layer setPixelFormat:MTLPixelFormatBGRA8Unorm];
    [METAL_layer setFramebufferOnly:YES];
    [METAL_layer setFrame:[layer bounds]];
    [METAL_layer setBackgroundColor:CGColorCreateGenericRGB(1.0, 0.0, 0.0, 1.0)];
    [layer addSublayer:METAL_layer];
}

- (void)configureVertexBufferForRaindropsCount:(NSInteger)raindropsCount
{
    vertexBuffer = (AVVertex*)malloc(sizeof(AVVertex) * 2 * _raindropsCount);
    for (int i = 0; i < raindropsCount; i++) {
        float xPos = ((arc4random_uniform(100) / 100.0) * 2) - 1;
        float yPos = ((arc4random_uniform(100) / 100.0) * 2) - 1;
        AVVertex startVertex = { .position = { xPos, yPos, 0.0, 1.0 }, .color = { 0.2, 0.2, 0.2, 1.0 } };
        AVVertex endVertex = { .position = { (xPos - 0.01), (yPos - 0.2), 0.0, 1.0 }, .color = { 1.0, 1.0, 1.0, 1.0 } };
        vertexBuffer[(2*i)] = startVertex;
        vertexBuffer[(2*i)+1] = endVertex;
    }
    METAL_vertexBuffer = [METAL_device newBufferWithBytes:vertexBuffer length:(sizeof(AVVertex) * 2 * _raindropsCount) options:MTLResourceOptionCPUCacheModeDefault];
}

- (void)configurePipelineState
{
    id<MTLLibrary> defaultLibrary = [METAL_device newDefaultLibrary];
    id<MTLFunction> fragmentShader = [defaultLibrary newFunctionWithName:@"main_fragment_rasterizer"];
    id<MTLFunction> vertexShader = [defaultLibrary newFunctionWithName:@"main_vertex_shader"];
    
    MTLRenderPipelineDescriptor* pipelineDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
    [pipelineDescriptor setLabel:@"Raindrops rendering pipeline"];
    [pipelineDescriptor setVertexFunction:vertexShader];
    [pipelineDescriptor setFragmentFunction:fragmentShader];
    [[pipelineDescriptor colorAttachments][0] setPixelFormat:MTLPixelFormatBGRA8Unorm];
    
    NSError* pipelineStateError;
    METAL_pipelineState = [METAL_device newRenderPipelineStateWithDescriptor:pipelineDescriptor error:&pipelineStateError];
    if (pipelineStateError) {
        NSLog(@"pipelineStateError: %@", [pipelineStateError localizedDescription]);
    }
    if (!METAL_pipelineState) {
        NSLog(@"Failed to create a pipeline state");
    }
}

- (void)configureCommandQueue
{
    METAL_commandQueue = [METAL_device newCommandQueue];
}

- (void)configureRenderer
{
    [NSTimer scheduledTimerWithTimeInterval:0.016 target:self selector:@selector(runLoop) userInfo:nil repeats:YES];
}

- (void)runLoop
{
    NSLog(@"Running..");
    @autoreleasepool {
        [self updateVertexBuffer];
        [self render];
    }
}

- (void)updateVertexBuffer
{
    for (int i = 0; i < _raindropsCount; i++) {
        // Start vertex
        AVVertex* startVertex = &vertexBuffer[(2*i)];
        float x1Coord = startVertex->position[0];
        float y1Coord = startVertex->position[1];
        //startVertex->position[0] = x1Coord - 0.01;
        startVertex->position[1] = (y1Coord - 0.05);
        // End vertex
        AVVertex* endVertex = &vertexBuffer[(2*i)+1];
        float x2Coord = endVertex->position[0];
        float y2Coord = endVertex->position[1];
        //endVertex->position[0] = x2Coord - 0.01;
        endVertex->position[1] = y2Coord - 0.05;
                                    
        if ((y1Coord - 0.01) < -1) {
            startVertex->position[1] = 1 + y1Coord - y2Coord;
            endVertex->position[1] = 1;
        }
    }
    METAL_vertexBuffer = [METAL_device newBufferWithBytes:vertexBuffer length:(sizeof(AVVertex) * 2 * _raindropsCount) options:MTLResourceOptionCPUCacheModeDefault];
}

- (void)render
{
    id<CAMetalDrawable> drawable = [METAL_layer nextDrawable];
    
    MTLRenderPassDescriptor* renderPassDescriptor = [[MTLRenderPassDescriptor alloc] init];
    [[renderPassDescriptor colorAttachments][0] setTexture:[drawable texture]];
    [[renderPassDescriptor colorAttachments][0] setLoadAction:MTLLoadActionClear];
    [[renderPassDescriptor colorAttachments][0] setClearColor:MTLClearColorMake(0.0, 0.0, 0.0, 1.0)];
    
    id<MTLCommandBuffer> commandBuffer = [METAL_commandQueue commandBuffer];
    
    id<MTLRenderCommandEncoder> renderCommandEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
    [renderCommandEncoder setLabel:@"Rain render encoder"];
    [renderCommandEncoder setRenderPipelineState:METAL_pipelineState];
    [renderCommandEncoder setVertexBuffer:METAL_vertexBuffer offset:0 atIndex:0];
    [renderCommandEncoder drawPrimitives:MTLPrimitiveTypeLine vertexStart:0 vertexCount:(_raindropsCount * 2) instanceCount:_raindropsCount];
    [renderCommandEncoder endEncoding];
    
    [commandBuffer presentDrawable:drawable];
    [commandBuffer commit];
}


@end
