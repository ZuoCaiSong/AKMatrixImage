# AKMatrixImage
## 一款轻便,高性能 的 仿微博 九宫格 GIF 轮流/随机 播放

用法简介:

三行代码即可集成.

_imageMatrixView = [[AKImageMatrixView imageMatrixViewEdge:AKEdgeMake(20, 10, 15) imagesName:arr playModel:AKPlayModelSequence]addImageClick:^(NSInteger index) {
        NSLog(@"index: %ld",index);
    }];
    _imageMatrixView.frame = CGRectMake(0, 100, 375, _imageMatrixView.imageMatrixViewHeight);
  [self.view addSubview:_imageMatrixView];
  
  
 1. 其中 AKEdgeMake(20, 10, 15) 说明 20表示图片 与 屏幕左边距 右边距 . 10表示图片与父视图的上下边距  15 表示图片图片控件之间的边距
  图片的布局是按照 3*3 九宫格 给定这三个边距参数之后, 图片的宽高就确定了(图片宽高按照相等的方式处理).并且返回图片的高度, 方便开发这获取.
  
  
 2. playmodel 表示播放模式 随机与顺序播放两种
 
 3. 图片支持开发者开启所有动画,以及关闭所有动画, 图片在下载完成 如果有GIF会自动开启动画 
 
 # 本人QQ: 2404225920
