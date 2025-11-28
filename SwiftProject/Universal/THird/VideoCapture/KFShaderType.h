//
//  KFShaderType.h
//  SwiftProject
//
//  Created by cloud on 2025/11/12.
//

#ifndef KFShaderType_h
#define KFShaderType_h

#include <simd/simd.h>

// 存储数据的自定义结构，用于桥接 OC 和 Metal 代码（顶点）。
typedef struct {
    // 顶点坐标，4 维向量。
    vector_float4 position;
    // 纹理坐标。
    vector_float2 textureCoordinate;
} KFVertex;

// 存储数据的自定义结构，用于桥接 OC 和 Metal 代码（顶点）。
typedef struct {
    // YUV 矩阵。
    matrix_float3x3 matrix;
    // 是否为 full range。
    bool fullRange;
} KFConvertMatrix;

// 自定义枚举，用于桥接 OC 和 Metal 代码（顶点）。
// 顶点的桥接枚举值 KFVertexInputIndexVertices。
typedef enum KFVertexInputIndex {
    KFVertexInputIndexVertices = 0,
} KFVertexInputIndex;

// 自定义枚举，用于桥接 OC 和 Metal 代码（片元）。
// YUV 矩阵的桥接枚举值 KFFragmentInputIndexMatrix。
typedef enum KFFragmentBufferIndex {
    KFFragmentInputIndexMatrix = 0,
} KFMetalFragmentBufferIndex;

// 自定义枚举，用于桥接 OC 和 Metal 代码（片元）。
// YUV 数据的桥接枚举值 KFFragmentTextureIndexTextureY、KFFragmentTextureIndexTextureUV。
typedef enum KFFragmentYUVTextureIndex {
    KFFragmentTextureIndexTextureY = 0,
    KFFragmentTextureIndexTextureUV = 1,
} KFFragmentYUVTextureIndex;

// 自定义枚举，用于桥接 OC 和 Metal 代码（片元）。
// RGBA 数据的桥接枚举值 KFFragmentTextureIndexTextureRGB。
typedef enum KFFragmentRGBTextureIndex {
    KFFragmentTextureIndexTextureRGB = 0,
} KFFragmentRGBTextureIndex;

#endif /* KFMetalShaderType_h */



