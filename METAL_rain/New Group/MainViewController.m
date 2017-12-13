//
//  MainViewController.m
//  METAL_rain
//
//  Created by Alex Vihlayew on 12/11/17.
//  Copyright © 2017 Alex Vihlayew. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()

@property (strong, nonatomic) id<MTLDevice> METAL_device;
@property (strong, nonatomic) CAMetalLayer* METAL_layer;
@property (strong, nonatomic) id<MTLBuffer> METAL_vertexBuffer;
@property (strong, nonatomic) id<MTLRenderPipelineState> METAL_pipelineState;
@property (strong, nonatomic) id<MTLCommandQueue> METAL_commandQueue;

@end

@implementation MainViewController

#pragma mark Vertex data

float vertexData[] = {0.0, 1.0, 0.0,
                      -1.0, -1.0, 0.0,
                      1.0, -1.0, 0.0};

#pragma mark Synthesizing accessors

@synthesize METAL_device;
@synthesize METAL_layer;
@synthesize METAL_vertexBuffer;
@synthesize METAL_pipelineState;
@synthesize METAL_commandQueue;

#pragma mark Life cycle

- (void)viewDidAppear
{
    [super viewDidAppear];
    
    [self configureDevice];
    [self configureLayer];
    [self configureVertexBuffer];
    [self configurePipelineState];
    [self configureCommandQueue];
    [self configureRenderer];
}

#pragma mark METAL drawing

- (void)configureDevice
{
    METAL_device = MTLCreateSystemDefaultDevice(); // Returns reference to a default MTLDevice
}

- (void)configureLayer // Creating a CAMetalLayer and adding as a sublayer to a root view's layer
{
    [[self view] setWantsLayer:YES];
    METAL_layer = [[CAMetalLayer alloc] init];
    [METAL_layer setDevice:METAL_device];
    [METAL_layer setPixelFormat:MTLPixelFormatBGRA8Unorm];
    [METAL_layer setFramebufferOnly:YES];
    [METAL_layer setFrame:[[[self view] layer] bounds]];
    [METAL_layer setBackgroundColor:CGColorCreateGenericRGB(1.0, 0.0, 0.0, 1.0)];
    [[[self view] layer] addSublayer:METAL_layer];
}

- (void)configureVertexBuffer
{
    METAL_vertexBuffer = [METAL_device newBufferWithBytes:vertexData length:sizeof(vertexData) options:MTLResourceOptionCPUCacheModeDefault];
}

- (void)configurePipelineState
{
    id<MTLLibrary> defaultLibrary = [METAL_device newDefaultLibrary];
    id<MTLFunction> fragmentShader = [defaultLibrary newFunctionWithName:@"basic_fragment"];
    id<MTLFunction> vertexShader = [defaultLibrary newFunctionWithName:@"basic_vertex"];
    
    MTLRenderPipelineDescriptor* pipelineDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
    [pipelineDescriptor setLabel:@"Triangle rendering pipeline"];
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
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(runLoop) userInfo:nil repeats:YES];
}

- (void)runLoop
{
    NSLog(@"Running..");
    @autoreleasepool {
        [self render];
    }
}

- (void)render
{
    id<CAMetalDrawable> drawable = [METAL_layer nextDrawable];
    
    MTLRenderPassDescriptor* renderPassDescriptor = [[MTLRenderPassDescriptor alloc] init];
    [[renderPassDescriptor colorAttachments][0] setTexture:[drawable texture]];
    [[renderPassDescriptor colorAttachments][0] setLoadAction:MTLLoadActionClear];
    [[renderPassDescriptor colorAttachments][0] setClearColor:MTLClearColorMake(0.0, 104.0/255.0, 5.0/255.0, 1.0)];
    
    id<MTLCommandBuffer> commandBuffer = [METAL_commandQueue commandBuffer];
    
    id<MTLRenderCommandEncoder> renderCommandEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
    [renderCommandEncoder setLabel:@"Triangle render encoder"];
    [renderCommandEncoder setRenderPipelineState:METAL_pipelineState];
    [renderCommandEncoder setVertexBuffer:METAL_vertexBuffer offset:0 atIndex:0];
    [renderCommandEncoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:3 instanceCount:1];
    [renderCommandEncoder endEncoding];
    
    [commandBuffer presentDrawable:drawable];
    [commandBuffer commit];
}

@end

