//
//  OtherView.m
//  AmpliferNav
//
//  Created by 鄢陵龙 on 2022/11/11.
//

#import "OtherView.h"
#import "PacketProto.h"
#import "BleProfile.h"
#import "ScreenAdapter.h"


@interface OtherView ()

@property (nonatomic) UIButton* modeButton;
@property (nonatomic) UILabel* modeLabel;

@property (nonatomic) UIButton* outerButton;
@property (nonatomic) UIButton* normalButton;

@property (nonatomic) UIImageView* outerImageView;
@property (nonatomic) UIImageView* normalImageView;

@property (nonatomic) UIImage* outerImage;
@property (nonatomic) UIImage* normalImage;

@property (nonatomic) NSUInteger previousMode;

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
        
        NSUInteger imageSize = SWReadValue(200);
        NSUInteger imageTopMargin = SHReadValue(50);
        NSUInteger imagePosX = mainFrame.size.width/2 - imageSize/2;
        
        self.outerImage = [UIImage imageNamed:@"outer"];
        self.normalImage = [UIImage imageNamed:@"normal"];
        
        self.modeButton = [[UIButton alloc] initWithFrame:CGRectMake(imagePosX, imageTopMargin, imageSize, imageSize)];
        self.modeButton.contentMode = UIViewContentModeScaleAspectFit;
        
        self.modeLabel = [[UILabel alloc] initWithFrame:CGRectMake(imagePosX, imageTopMargin, imageSize, imageSize)];
        self.modeLabel.textAlignment = NSTextAlignmentCenter;
        [self.modeLabel setFont:[UIFont systemFontOfSize:25]];
        
        UIFont* font = [UIFont systemFontOfSize:12];

        UIImageView* bgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"按键底"]];
        
        NSUInteger buttonGroupHorizontalMargin = SWReadValue(90);
        NSUInteger buttonGroupTopMargin = SHReadValue(60);
        NSUInteger buttonGroupPosY = imageTopMargin + imageSize + buttonGroupTopMargin;
        

        NSUInteger buttonHeight = SHReadValue(48);
        
        self.outerButton.titleLabel.font = font;
        self.normalButton.titleLabel.font = font;
        
        self.outerImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"圆角矩形"]];
        self.normalImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"圆角矩形"]];
        
        bgView.frame = CGRectMake(buttonGroupHorizontalMargin, buttonGroupPosY, mainFrame.size.width - 2*buttonGroupHorizontalMargin, buttonHeight);
        
        NSUInteger buttonWidth = bgView.frame.size.width/2;
        self.outerButton = [[UIButton alloc] initWithFrame:CGRectMake(buttonGroupHorizontalMargin, buttonGroupPosY, buttonWidth, buttonHeight)];
        self.normalButton = [[UIButton alloc] initWithFrame:CGRectMake(mainFrame.size.width - buttonGroupHorizontalMargin - buttonWidth, buttonGroupPosY, buttonWidth, buttonHeight)];
        
        NSUInteger imageViewWidth = bgView.frame.size.width/2;
        NSUInteger imageViewHeight = buttonHeight;
        self.outerImageView.frame = CGRectMake(buttonGroupHorizontalMargin, buttonGroupPosY, imageViewWidth, imageViewHeight);
        self.normalImageView.frame = CGRectMake(mainFrame.size.width - buttonGroupHorizontalMargin - imageViewWidth, buttonGroupPosY, imageViewWidth, imageViewHeight);

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
        
        self.currentMode = AXON_ANC_OUTER;
        self.previousMode = self.currentMode;
    }
    
    self.hidden = true;
    return self;
}

- (void) setCurrentMode:(NSUInteger)currentMode
{
    _currentMode = currentMode;
    if (_currentMode == AXON_ANC_OUTER) {
        self.normalImageView.hidden = true;
        self.outerImageView.hidden = false;
        self.modeLabel.text = @"Outer";
        [self.modeButton setImage:self.normalImage forState:UIControlStateNormal];
    } else if (_currentMode == AXON_ANC_NORMAL) {
        self.outerImageView.hidden = true;
        self.normalImageView.hidden = false;
        self.modeLabel.text = @"Normal";
        [self.modeButton setImage:self.outerImage forState:UIControlStateNormal];
    }
}

- (void) writeDeviceAncMode:(NSUInteger) ancMode
{
    PacketProto* packetProto = [PacketProto getInstance];
    packetProto.ancState = ancMode;
    NSData* ancStatePacket = [packetProto packAncSwitch];
    [[BleProfile getInstance] writeDeviceData:ancStatePacket callback:^(CBPeripheral *peripheral, CBCharacteristic *charactic, NSError *error) {
        NSLog(@"写入ANC切换指令成功");
    }];
}

- (void) restoreCurrentMode
{
    [PacketProto getInstance].ancState = _previousMode;
    self.currentMode = _previousMode;
}

- (void) outerButtonClicked
{
    NSLog(@"outerButtonClicked");
    if (_currentMode == AXON_ANC_NORMAL) {
        
        self.previousMode = _currentMode;
        self.currentMode = AXON_ANC_OUTER;
        
        [self writeDeviceAncMode:AXON_ANC_OUTER];
    }
}

- (void) normalButtonClicked
{
    NSLog(@"normalButtonClicked");
    if (_currentMode == AXON_ANC_OUTER) {
        
        self.previousMode = _currentMode;
        self.currentMode = AXON_ANC_NORMAL;
        
        [self writeDeviceAncMode:AXON_ANC_NORMAL];
    }
}

@end
