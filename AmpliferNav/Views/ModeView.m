//
//  ModeView.m
//  AmpliferNav
//
//  Created by 鄢陵龙 on 2022/11/10.
//

#import "ModeView.h"
#import "PacketProto.h"
#include "BleProfile.h"
#import <CoreBluetooth/CoreBluetooth.h>

#define INVALID_MODE        0xFF
#define OUTDOOR_MODE        0x00
#define INDOOR_MODE         0x01
#define NORMAL_MODE         0x02

@interface ModeView()

@property (nonatomic) ModeButton* outdoorButton;
@property (nonatomic) ModeButton* indoorButton;
@property (nonatomic) ModeButton* normalButton;

@property (nonatomic) NSArray* buttonArray;

@property (nonatomic) UILabel* titleLable;
@property (nonatomic) UILabel* contentLabel;

@end

@implementation ModeView
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
        
        self.currentMode = INVALID_MODE;
        
        CGRect mainFrame = [UIScreen mainScreen].bounds;
        
        NSUInteger topMargin = 20;
        NSUInteger horizontalMargin = 20;
        NSUInteger buttonHeight = 80;
        NSUInteger buttonWidth = mainFrame.size.width - horizontalMargin*2;
        NSUInteger spacing = 20;
        
        UIFont* font = [UIFont systemFontOfSize:12];
        
        self.outdoorButton = [self allocButton:CGRectMake(horizontalMargin, topMargin, buttonWidth, buttonHeight) checkedImageName:@"户外选中" unCheckedImageName:@"户外" titleText:@"户外模式"];
        self.indoorButton = [self allocButton:CGRectMake(horizontalMargin, buttonHeight+spacing+topMargin, buttonWidth, buttonHeight) checkedImageName:@"室内选中" unCheckedImageName:@"室内" titleText:@"室内模式"];
        self.normalButton = [self allocButton:CGRectMake(horizontalMargin, buttonHeight*2+spacing*2+topMargin, buttonWidth, buttonHeight)  checkedImageName:@"常规选中" unCheckedImageName:@"常规" titleText:@"常规模式"];
        
        self.buttonArray = @[self.outdoorButton, self.indoorButton, self.normalButton];
        
        
        NSUInteger labelTopMargin = 10;
        NSUInteger labelYPos = buttonHeight*3+spacing*2+topMargin + labelTopMargin;
        
        self.titleLable = [[UILabel alloc] initWithFrame:CGRectMake(horizontalMargin, labelYPos, buttonWidth, 40)];
        self.contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(horizontalMargin, labelYPos+spacing+10, buttonWidth, 40)];
        
        self.titleLable.text = @"常规模式：用于地铁或飞机等场景";
        self.contentLabel.text = @"请在其中选择最合适您的模式进行使用。\n如左右耳都已连接设备，将同步进行模式切换";
        self.contentLabel.numberOfLines = 2;
        [self.titleLable setFont:font];
        [self.contentLabel setFont:font];
        
        [self addSubview:self.outdoorButton];
        [self addSubview:self.indoorButton];
        [self addSubview:self.normalButton];
        [self addSubview:self.titleLable];
        [self addSubview:self.contentLabel];
        
        self.hidden = true;
    }
    return self;
}

- (ModeButton*)allocButton:(CGRect)frame checkedImageName:(NSString*)checkedImageName unCheckedImageName:(NSString*)unCheckedImageName titleText:(NSString*)titleText
{
    ModeButton* button = [[ModeButton alloc] initWithCheckedImage:frame checkedImage:[UIImage imageNamed:checkedImageName] unCheckedImage:[UIImage imageNamed:unCheckedImageName]];
    [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchDown];
    
    [button  setTitle:titleText forState:UIControlStateNormal];
    [button layoutButtonWithImageStyle:ButtonImageStyleTop imageTitleToSpace:20];
    
    [button setCornerRadius:10.0];
    
    return button;
}

- (void)buttonClicked:(ModeButton*)sender
{
    self.currentMode = [self.buttonArray indexOfObject:sender];
    NSLog(@"current mode: %ld", self.currentMode);
    
    [PacketProto getInstance].mode = _currentMode;
    NSData* modeSet = [[PacketProto getInstance] packVolumeModeSet];
    [[BleProfile getInstance] writeDeviceData:modeSet callback:^(CBPeripheral *peripheral, CBCharacteristic *charactic, NSError *error) {
        NSLog(@"写入模式设置指令成功");
    }];
}

- (void)setCurrentMode:(NSUInteger)currentMode
{
    switch (currentMode) {
        case OUTDOOR_MODE:
        case INDOOR_MODE:
        case NORMAL_MODE:
            break;
            
        default:
            return;;
    }
    
    _currentMode = currentMode;
    
    for (ModeButton* button in self.buttonArray) {
        button.checked = false;
    }
    
    ModeButton* button = (ModeButton*)[self.buttonArray objectAtIndex:currentMode];
    button.checked = true;
}


@end
