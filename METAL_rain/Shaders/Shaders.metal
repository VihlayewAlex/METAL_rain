//
//  Shaders.metal
//  METAL_rain
//
//  Created by Alex Vihlayew on 12/11/17.
//  Copyright © 2017 Alex Vihlayew. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct Vertex
{
    float4 position [[position]];
    float4 color;
};

vertex Vertex main_vertex_shader(device Vertex* vertices [[buffer(0)]],
                                 uint vid [[vertex_id]])
{
    return vertices[vid];
}

fragment float4 main_fragment_rasterizer(Vertex inVertex [[stage_in]])
{
    return inVertex.color;
}
