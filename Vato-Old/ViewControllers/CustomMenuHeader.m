//
//  CustomMenuHeader.m
//  FC
//
//  Created by Son Dinh on 4/30/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "CustomMenuHeader.h"
#import "MenusTableViewController.h"
#import "KYDrawerController.h"
#import "UIView+Border.h"
#import "UserDataHelper.h"

@interface CustomMenuHeader()
{
    void (^_profileCallback)(void);
    void (^_licenseCallback)(void);
}
@property (strong, nonatomic) IBOutlet FCImageView *avatar;
@property (strong, nonatomic) IBOutlet UILabel *labelName;

@end

@implementation CustomMenuHeader

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        
    }
    return self;
}

- (void)didMoveToSuperview
{
    [self load];
}

- (void) awakeFromNib {
    [super awakeFromNib];
    
    self.backgroundColor = ORANGE_COLOR;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onProfileUpdated) name:NOTIFICATION_PROFILE_UPDATED object:nil];
}

- (void) onProfileUpdated {
    [self load];
}

- (void) load
{
    FCClient* client = [[UserDataHelper shareInstance] getCurrentUser];
    if (client) {
        //avatar
        [self.avatar sd_setImageWithURL:[NSURL URLWithString:client.user.avatarUrl] placeholderImage:[UIImage imageNamed:@"avatar-holder"]];
//        [self.avatar setImageWithURL:[NSURL URLWithString:client.user.avatarUrl] placeholderImage:[UIImage imageNamed:@"avatar-holder"]];
        [self.avatar circleView:[UIColor whiteColor]];
        
        //label
        [self.labelName setText:[client.user getDisplayName]];
    }
}

- (IBAction)onUpdateAvatar:(id)sender
{
    DLog(@"onUpdateAvatar")
    if (_profileCallback != nil)
    {
        _profileCallback();
    }
    
}

- (void)setProfileClickCallback:(void (^)(void))callback
{
    _profileCallback = callback;
}


@end
