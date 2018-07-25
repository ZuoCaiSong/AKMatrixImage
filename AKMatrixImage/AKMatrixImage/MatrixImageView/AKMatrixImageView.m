//
//  AKMatrixImageView.m
//  Gif轮流/随机显示
//
//  Created by LEO on 2018/7/23.
//  Copyright © 2018年 AK. All rights reserved.
//

#import "AKMatrixImageView.h"


#if __has_include(<FLAnimatedImageView+WebCache.h>)
#import <FLAnimatedImageView+WebCache.h>
#else
#import "FLAnimatedImageView+WebCache.h"
#endif

#if __has_include(<NSData+ImageContentType.h>)
#import <NSData+ImageContentType.h>
#else
#import "NSData+ImageContentType.h"
#endif




#define labTag   666

#define AKSCREENW   UIScreen.mainScreen.bounds.size.width
#define AKSCREENH  UIScreen.mainScreen.bounds.size.height


@interface AKMatrixImageView()


@property(nonatomic,assign)AKPlayModel playModel;

@property(nonatomic,strong)NSMutableDictionary  <NSNumber*,FLAnimatedImageView*>* gifDic;

@property(nonatomic,assign)AKEdge  edge;

@property(nonatomic,strong)NSArray <NSString *>* urls;

@property(nonatomic,strong)NSArray <NSData *>*imageDatas;

@property(nonatomic,assign)CGFloat matrixImageViewHeight;

@property(nonatomic,assign)bool isAnimateing;
@property(nonatomic,assign)bool isCompleted;

@property(nonatomic,strong)NSArray <NSNumber *>* sortKeys;

@property(nonatomic,copy)void(^selectedIndexBlock)(NSInteger);

@end


@implementation AKMatrixImageView

-(NSMutableDictionary<NSNumber *,FLAnimatedImageView *> *)gifDic{
    if (_gifDic == nil) {
        _gifDic = [NSMutableDictionary dictionary];
    }
    return _gifDic;
}

+(instancetype)matrixImageViewEdge:(AKEdge)edge imagesName:(NSArray<NSString*> *)imagesName playModel:(AKPlayModel)playModel{
    AKMatrixImageView * matrixImageView = [[AKMatrixImageView alloc]init];
    matrixImageView.edge = edge;
    matrixImageView.urls = imagesName;
    matrixImageView.playModel = playModel;
    
    [matrixImageView setUpSubViewsWithNetImage];
    
    return matrixImageView;
}

+(instancetype)matrixImageViewEdge:(AKEdge)edge imageDatas:(NSArray<NSData*> *)imageDatas playModel:(AKPlayModel)playModel{
    AKMatrixImageView * matrixImageView = [[AKMatrixImageView alloc]init];
    matrixImageView.edge = edge;
    matrixImageView.imageDatas = imageDatas;
    matrixImageView.playModel = playModel;
    
    [matrixImageView setUpSubViewsWithLocalImage];
    
    return matrixImageView;
}


//gif flag
- (UILabel *)addGifLab{
    UILabel *lab = [[UILabel alloc]init];
    lab.text = @" 动图 ";
    lab.textColor = [UIColor grayColor];
    lab.font = [UIFont systemFontOfSize:14];
    lab.backgroundColor = [UIColor colorWithRed:240/255.0 green:156/255.0 blue:56/255.0 alpha:1];
    [lab sizeToFit];
    lab.font = [UIFont systemFontOfSize:13];
    CGRect oldFrame = lab.frame; oldFrame.origin = CGPointMake(5, 5);
    lab.frame = oldFrame;
    lab.hidden = true;
    lab.layer.cornerRadius = lab.frame.size.height*0.5;
    lab.layer.masksToBounds = true;
    lab.tag = labTag;
   return lab;
}

//imageView
-(FLAnimatedImageView *)creatImageViewWithFrame:(CGRect)frame imageTag:(NSInteger)imageTag{
    
    FLAnimatedImageView * imageView = [[FLAnimatedImageView alloc]initWithFrame:frame];
    imageView.userInteractionEnabled = YES;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.backgroundColor = [UIColor grayColor];
    imageView.clipsToBounds = YES;
    imageView.tag = imageTag;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imageViewClick:)];
    [imageView addSubview:[self addGifLab]];
    [imageView addGestureRecognizer:tap];
    [self addSubview:imageView];
    return imageView;
}

-(void)setUpSubViewsWithNetImage{
    CGFloat imageWH =  [self calculateHeightWithArr:self.urls];
    
    dispatch_group_t group =dispatch_group_create();
    
    for(int i=0;i<self.urls.count;i++){
       
        NSInteger col = i%3;
        NSInteger row = i/3;
        FLAnimatedImageView * imageView = [self creatImageViewWithFrame:CGRectMake(_edge.marginLR + col*(imageWH+_edge.marginImages), _edge.marginTB+ row*(imageWH + _edge.marginTB) , imageWH, imageWH) imageTag:i];
        
        dispatch_group_enter(group);
        NSURL * url = [NSURL URLWithString:self.urls[i]];
        [imageView sd_setImageWithURL:url placeholderImage:nil completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            dispatch_group_leave(group);
            if (error) {return ; }
            [self imageLoadFinish:imageURL imageView:imageView];
        }];
    }
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        
         [self sortGifdic];
         [self loopPlayGifWithIndex:0];
    });
}

/**
 loading local image
 */
-(void)setUpSubViewsWithLocalImage{
   CGFloat imageWH =  [self calculateHeightWithArr:self.imageDatas];
    for(int i=0;i<self.imageDatas.count;i++){
        
        NSInteger col = i%3;
        NSInteger row = i/3;
        
       FLAnimatedImageView * imageView = [self creatImageViewWithFrame:CGRectMake(_edge.marginLR + col*(imageWH+_edge.marginImages), _edge.marginTB+ row*(imageWH + _edge.marginTB) , imageWH, imageWH) imageTag:i];
        
        NSData *imageData = self.imageDatas[i];
         SDImageFormat imageFormat = [NSData sd_imageFormatForImageData:imageData];
        if (imageFormat == SDImageFormatGIF) {
            imageView.animatedImage = [FLAnimatedImage animatedImageWithGIFData:imageData];
            imageView.image = nil;
            self.gifDic[@(imageView.tag)] = imageView;
            [imageView viewWithTag:labTag].hidden = false;
            [imageView stopAnimating];
        } else {
            [imageView viewWithTag:labTag].hidden = true;
            imageView.animatedImage = nil;
            imageView.image = [UIImage imageWithData:imageData];
        }
    }
    [self sortGifdic];
    [self loopPlayGifWithIndex:0];
}

-(CGFloat)calculateHeightWithArr:(NSArray*)arr{
    
    CGFloat imageWH = (AKSCREENW - _edge.marginLR * 2 - _edge.marginImages*2)/3.0;
    NSInteger row = arr.count/3;
    NSInteger cor = arr.count%3;
    NSInteger list = (row + (cor==0?0:1));
    self.matrixImageViewHeight = list*imageWH + _edge.marginTB*(list+1);
    return imageWH;
}

#pragma mark - imageLoadFinish

-(void)imageLoadFinish:(NSURL *)url imageView:(FLAnimatedImageView *)imageView {
    
    NSData * imageData = [self getCacheImageDataForModel:url];
    SDImageFormat imageFormat = [NSData sd_imageFormatForImageData:imageData];
    if (imageFormat == SDImageFormatGIF) {
        self.gifDic[@(imageView.tag)] = imageView;
        [imageView viewWithTag:labTag].hidden = false;
        [imageView stopAnimating];
    } else {
        [imageView viewWithTag:labTag].hidden = true;
    }
}


-(void)loopPlayGifWithIndex:(NSInteger)index{
    if (self.gifDic.count==0) { return; }
    self.isCompleted = true;
    self.isAnimateing = true;
    NSNumber * key = _sortKeys[index];
    FLAnimatedImageView * imageV = self.gifDic[key];
    
    __weak typeof(FLAnimatedImageView *)weakImagev = imageV;
    __weak typeof(NSArray<NSNumber*> *)weakSortKeys = _sortKeys;
    [imageV startAnimating];
    imageV.loopCompletionBlock = ^(NSUInteger loopCountRemaining) {
        [weakImagev stopAnimating ];
        NSInteger nextindex = index+1== weakSortKeys.count? 0: index+1;
        [self loopPlayGifWithIndex: nextindex];
    };
}

-(void)sortGifdic{
    if (self.gifDic.count==0) { return ; }
    if (self.playModel == AKPlayModelSequence) {
       _sortKeys = [self.gifDic.allKeys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            return [obj1 compare:obj2];
        }];
    }else{
        _sortKeys = self.gifDic.allKeys;
    }
}

- (NSData *)getCacheImageDataForModel:(NSURL *)url {
    
    SDImageCache * imageCache = [SDImageCache sharedImageCache];
    NSString*cacheImageKey = [[SDWebImageManager sharedManager]cacheKeyForURL:url];
    NSString *defaultPath = [imageCache defaultCachePathForKey:cacheImageKey];
    NSData *data = [NSData dataWithContentsOfFile:defaultPath];
    if (data) {
        return data;
    }else{
        return  nil;
    }
}

-(void)startAllGifAnimating{
    if (!_isCompleted || _isAnimateing) {  return; }
    [self loopPlayGifWithIndex:0];
}

-(void)stopAllGifAnimating{
    if(!self.isAnimateing)return;
    
    if (!NSThread.isMainThread) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.gifDic enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, FLAnimatedImageView * _Nonnull obj, BOOL * _Nonnull stop) {
                [obj stopAnimating];
            }];
            self.isAnimateing = false;
        });
    }else{
        [self.gifDic enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, FLAnimatedImageView * _Nonnull obj, BOOL * _Nonnull stop) {
            [obj stopAnimating];
        }];
        self.isAnimateing = false;
    }
}

-(instancetype)addImageClick:(void (^)(NSInteger))index{
    if (index) {
        self.selectedIndexBlock = index;
    }
    return self;
}

- (void)imageViewClick:(UITapGestureRecognizer *)tap {
    if (self.selectedIndexBlock) {
        self.selectedIndexBlock(tap.view.tag);
    }
}



@end
