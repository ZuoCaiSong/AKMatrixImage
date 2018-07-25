//
//  ViewController.m
//  AKMatrixImage
//
//  Created by LEO on 2018/7/25.
//  Copyright © 2018年 AK. All rights reserved.
//

#import "ViewController.h"
#import "AKMatrixImageView.h"

@interface ViewController ()

/**view*/
@property(nonatomic,strong)AKMatrixImageView * matrixImageView ;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSArray * arr = @[
                      //小图
                      @"http://wx1.sinaimg.cn/thumbnail/bfc243a3gy1febm7orgqfj20i80ht15x.jpg",
                      @"http://p7.pstatp.com/large/w960/5322000131e01b7a477d",
                      @"http://p7.pstatp.com/large/w960/5321000135125ebb938a",
                      @"http://wx4.sinaimg.cn/mw690/006ZrXHXgy1fsr0qx5cyzg307p06ve81.gif",
                      @"http://wx2.sinaimg.cn/thumbnail/bfc243a3gy1febm7pmnk7j20i70jidwo.jpg",
                      @"http://wx4.sinaimg.cn/mw690/006ZrXHXgy1fsr0qr99d6g305808wu0x.gif",
                      @"http://wx3.sinaimg.cn/mw690/006ZrXHXgy1fsr0qo6f9bg30dw074qv5.gif",
                      @"http://wx4.sinaimg.cn/mw690/006ZrXHXgy1fsr0qmudqwg3096062kjl.gif",
                      @"http://wx1.sinaimg.cn/thumbnail/bfc243a3gy1febm7n9eorj20i60hsann.jpg",
                      @"http://wx3.sinaimg.cn/mw690/006ZrXHXgy1fsr0qy8cp5g306z05mqqo.gif",
                      ];
    
    _matrixImageView = [[AKMatrixImageView matrixImageViewEdge:AKEdgeMake(20, 10, 15) imagesName:arr playModel:AKPlayModelSequence]addImageClick:^(NSInteger index) {
        NSLog(@"index: %ld",index);
    }];
    _matrixImageView.frame = CGRectMake(0, 100, 375, _matrixImageView.matrixImageViewHeight);
    [self.view addSubview:_matrixImageView];
}

- (IBAction)start:(id)sender {
    [_matrixImageView startAllGifAnimating];
}

- (IBAction)stop:(id)sender {
    [_matrixImageView stopAllGifAnimating];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
