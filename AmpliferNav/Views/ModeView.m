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
#import "ScreenAdapter.h"

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
        
        NSUInteger topMargin = SHReadValue(30);
        NSUInteger horizontalMargin = SHReadValue(20);
        NSUInteger buttonWidth = mainFrame.size.width - horizontalMargin*2;
        NSUInteger spacing = SHReadValue(15);
        NSUInteger buttonHeight = SHReadValue(100); //(mainFrame.size.height*2/3)/3 - spacing;
        
        
        self.outdoorButton = [self allocButton:CGRectMake(horizontalMargin, topMargin, buttonWidth, buttonHeight) checkedImageName:@"户外选中" unCheckedImageName:@"户外" titleText: NSLocalizedString(@"outDoorMode", nil)];
        self.indoorButton = [self allocButton:CGRectMake(horizontalMargin, buttonHeight+spacing+topMargin, buttonWidth, buttonHeight) checkedImageName:@"室内选中" unCheckedImageName:@"室内" titleText:NSLocalizedString(@"indoorMode", nil) ];
        self.normalButton = [self allocButton:CGRectMake(horizontalMargin, buttonHeight*2+spacing*2+topMargin, buttonWidth, buttonHeight)  checkedImageName:@"常规选中" unCheckedImageName:@"常规" titleText:NSLocalizedString(@"normalMode", nil) ];
        
        self.buttonArray = @[self.outdoorButton, self.indoorButton, self.normalButton];
        
        
        NSUInteger labelTopMargin = SHReadValue(30);
        NSUInteger labelYPos = buttonHeight*3+spacing*2+topMargin + labelTopMargin;
        
        self.titleLable = [[UILabel alloc] initWithFrame:CGRectMake(horizontalMargin, labelYPos, buttonWidth, 40)];
        self.contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(horizontalMargin, labelYPos+spacing+10, buttonWidth, 40)];
        
        self.titleLable.text = NSLocalizedString(@"normalModeComments", nil);
        self.contentLabel.text = NSLocalizedString(@"modeTips", nil);
        self.contentLabel.numberOfLines = 2;
        
        UIFont* font = [UIFont systemFontOfSize:14];
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
