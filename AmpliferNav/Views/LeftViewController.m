//
//  LeftViewController.m
//  Amplifer
//
//  Created by 鄢陵龙 on 2022/11/19.
//

#import "LeftViewController.h"

@interface LeftViewController ()

@end

@implementation LeftViewController

+ (LeftViewController*) getInstance
{
    static dispatch_once_t predWex = 0;
    __strong static LeftViewController* _sharedWexObject = nil;
    dispatch_once(&predWex, ^
                  {
                      _sharedWexObject = [[self alloc] init];
                  });
    return _sharedWexObject;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
