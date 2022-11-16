//
//  ImageViewGif.m
//  AmpliferNav
//
//  Created by 鄢陵龙 on 2022/11/16.
//

#import "ImageViewGif.h"
#import "GifViewDelegate.h"

@implementation ImageViewGif

- (instancetype)initWithDuration:(NSTimeInterval)duration delegate:(id<GifViewDelegate>)delegate
{
    self = [super init];
    if (self) {
        self.duration = duration;
        self.delegate = delegate;
        self.frame = CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height);
        
        self.animationImages = [self animationImages]; //获取Gif图片列表
        self.animationDuration = self.duration;   //执行一次完整动画所需的时长
        self.animationRepeatCount = 1; //动画重复次数
    }
    return self;
}

- (void)startGif
{
    [self startAnimating];
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(gifCheckTimer) userInfo:nil repeats:true];
}

- (void)gifCheckTimer
{
    NSLog(@"isAnimating: %d", [self isAnimating]);
    if (![self isAnimating]) {
        [_timer invalidate];
        _timer = nil;
        if (self.delegate) {
            [self.delegate gifStopped];
        }
    }
}

- (void)stopGif
{
    [self stopAnimating];
}

- (NSArray *)animationImages
{
    NSFileManager *fielM = [NSFileManager defaultManager];
    
    // Get the bundle containing the specified private class.
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Loading" ofType:@"bundle"];
//    NSLog(@"path=%@", path);
    
    NSArray *arrays = [fielM contentsOfDirectoryAtPath:path error:nil];
    NSMutableArray* mutabeArray = [NSMutableArray arrayWithArray:arrays];
    
    [mutabeArray sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2){
        return [obj1 compare:obj2] == NSOrderedDescending;
    }];
      
    NSMutableArray *imagesArr = [NSMutableArray array];
    
    for (NSString *name in mutabeArray) {

        UIImage *image = [UIImage imageNamed:[(@"Loading.bundle") stringByAppendingPathComponent:name]];
        if (image) {
          [imagesArr addObject:image];
        }
      }
      return imagesArr;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

