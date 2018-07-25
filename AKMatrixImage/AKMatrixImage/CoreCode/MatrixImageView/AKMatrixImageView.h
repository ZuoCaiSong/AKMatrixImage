//
//  AKMatrixImageView.h
//  Gif轮流/随机显示
//
//  Created by LEO on 2018/7/23.
//  Copyright © 2018年 AK. All rights reserved.
//

#import <UIKit/UIKit.h>



typedef enum : NSUInteger {
    AKPlayModelRandom = 0,  //default
    AKPlayModelSequence,
} AKPlayModel;

typedef struct AKEdgeStruct{
    CGFloat marginLR; // left right   to  supViwe
    CGFloat marginTB; // top  bottom  to supView
    CGFloat marginImages;  // The space between imageView and imageView
}AKEdge;

static inline  AKEdge AKEdgeMake(CGFloat marginLR, CGFloat marginTB, CGFloat marginImages){
    
    AKEdge edge;
    edge.marginLR = marginLR;
    edge.marginImages = marginImages;
    edge.marginTB = marginTB;
    return edge;
}


@interface AKMatrixImageView : UIView

/**height of AKMatrixImageView */
@property(nonatomic,assign,readonly)CGFloat matrixImageViewHeight;


/**
 matrixImageView

 @param edge edge
 @param imagesName urlstr array
 @param playModel playmodel
 @return matrixImageView instance
 */
+(instancetype)matrixImageViewEdge:(AKEdge)edge imagesName:(NSArray<NSString*> *)imagesName playModel:(AKPlayModel)playModel;


/**
 matrixImageView

 @param edge edge
 @param imageDatas imageDatas
 @param playModel playModel
 @return matrixImageView instance
 */
+(instancetype)matrixImageViewEdge:(AKEdge)edge imageDatas:(NSArray<NSData*> *)imageDatas playModel:(AKPlayModel)playModel;


/**
 stop all gif animation
 */
-(void)stopAllGifAnimating;


/**
 start all gif animation , The animation sequence will be the same as when it was initialized
 */
-(void)startAllGifAnimating;

/**
 *index: 0 ~ image.count-1
 */
-(instancetype)addImageClick:(void(^)(NSInteger))index;

@end
