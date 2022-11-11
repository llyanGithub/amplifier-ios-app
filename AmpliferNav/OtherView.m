//
//  OtherView.m
//  AmpliferNav
//
//  Created by 鄢陵龙 on 2022/11/11.
//

#import "OtherView.h"

@interface OtherView ()

@property (nonatomic) UIButton* modeButton;
@property (nonatomic) UILabel* modeLabel;

@property (nonatomic) UIButton* outerButton;
@property (nonatomic) UIButton* normalButton;

@property (nonatomic) UIImageView* outerImageView;
@property (nonatomic) UIImageView* normalImageView;

@property (nonatomic) BOOL outerButtonSelected;

@end

@implementation OtherView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGRect mainFrame = [UIScreen mainScreen].bounds;
        
        NSUInteger imageSize = 150;
        NSUInteger imageTopMargin = 50;
        NSUInteger imagePosX = mainFrame.size.width/2 - imageSize/2;
        
        self.modeButton = [[UIButton alloc] initWithFrame:CGRectMake(imagePosX, imageTopMargin, imageSize, imageSize)];
        [self.modeButton setImage:[UIImage imageNamed:@"normal"] forState:UIControlStateNormal];
        self.modeButton.contentMode = UIViewContentModeScaleAspectFit;
        
        self.modeLabel = [[UILabel alloc] initWithFrame:CGRectMake(imagePosX, imageTopMargin, imageSize, imageSize)];
        self.modeLabel.text = @"NORMAL";
        self.modeLabel.textAlignment = NSTextAlignmentCenter;
        
        UIFont* font = [UIFont systemFontOfSize:12];
        
        


        UIImageView* bgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"按键底"]];
        
        NSUInteger buttonGroupHorizontalMargin = 80;
        NSUInteger buttonWidth = 80;
//        NSUInteger buttonWidth = (mainFrame.size.width - 2*buttonGroupHorizontalMargin) / 2;
        NSUInteger buttonHeight = 40;
        NSUInteger buttonGroupTopMargin = 60;
        NSUInteger buttonGroupPosY = imageTopMargin + imageSize + buttonGroupTopMargin;
        
//        UIView* bgView = [[UIView alloc] initWithFrame:CGRectMake(imagePosX, imageTopMargin+imageSize+20, 200, 50)];
        self.outerButton = [[UIButton alloc] initWithFrame:CGRectMake(buttonGroupHorizontalMargin, buttonGroupPosY, buttonWidth, buttonHeight)];
        self.normalButton = [[UIButton alloc] initWithFrame:CGRectMake(mainFrame.size.width - buttonGroupHorizontalMargin - buttonWidth, buttonGroupPosY, buttonWidth, buttonHeight)];
        
        self.outerButton.titleLabel.font = font;
        self.normalButton.titleLabel.font = font;
        
        self.outerImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"圆角矩形"]];
        self.normalImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"圆角矩形"]];
        
        self.outerImageView.frame = CGRectMake(buttonGroupHorizontalMargin, buttonGroupPosY, buttonWidth, buttonHeight);
        self.normalImageView.frame = CGRectMake(mainFrame.size.width - buttonGroupHorizontalMargin - buttonWidth, buttonGroupPosY, buttonWidth, buttonHeight);
        
        self.outerButtonSelected = true;
        self.normalImageView.hidden = true;
        
        bgView.frame = CGRectMake(buttonGroupHorizontalMargin, buttonGroupPosY, mainFrame.size.width - 2*buttonGroupHorizontalMargin, buttonHeight);

        [self.outerButton setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        [self.normalButton setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        
        [self.outerButton setTitle:@"Outer" forState:UIControlStateNormal];
        [self.normalButton setTitle:@"Normal" forState:UIControlStateNormal];
        
        [self.outerButton addTarget:self action:@selector(outerButtonClicked) forControlEvents:UIControlEventTouchDown];
        [self.normalButton addTarget:self action:@selector(normalButtonClicked) forControlEvents:UIControlEventTouchDown];
        
        [self addSubview:self.modeButton];
        [self addSubview:self.modeLabel];
        
        [self addSubview:bgView];
        [self addSubview:self.outerImageView];
        [self addSubview:self.normalImageView];
        [self addSubview:self.outerButton];
        [self addSubview:self.normalButton];
    }
    
    self.hidden = true;
    return self;
}

- (void) outerButtonClicked
{
    if (!self.outerButtonSelected) {
        self.outerImageView.hidden = false;
        self.normalImageView.hidden = true;
        self.outerButtonSelected = true;
    }
}

- (void) normalButtonClicked
{
    if (self.outerButtonSelected) {
        self.normalImageView.hidden = false;
        self.outerImageView.hidden = true;
        self.outerButtonSelected = false;
    }
}

@end
