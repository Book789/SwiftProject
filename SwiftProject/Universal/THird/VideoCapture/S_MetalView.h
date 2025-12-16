//
//  S_MetalView.h
//  SwiftProject
//
//  Created by cloud on 2025/11/12.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

// 渲染画面填充模式。
typedef NS_ENUM(NSInteger, KFMetalViewContentMode) {
    // 自动填充满，可能会变形。
    KFMetalViewContentModeStretch = 0,
    // 按比例适配，可能会有黑边。
    KFMetalViewContentModeFit = 1,
    // 根据比例裁剪后填充满。
    KFMetalViewContentModeFill = 2
};

@interface S_MetalView : UIView
@property (nonatomic, assign) KFMetalViewContentMode fillMode; // 画面填充模式。
- (void)renderPixelBuffer:(CVPixelBufferRef)pixelBuffer; // 渲染。
@end

NS_ASSUME_NONNULL_END
