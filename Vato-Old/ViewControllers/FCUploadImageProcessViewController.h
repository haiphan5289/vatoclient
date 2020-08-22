//
//  FCUploadImageProcessViewController.h
//  FC
//
//  Created by facecar on 10/27/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    FONT_CMND,
    BACK_CMND,
    AVATAR
} ImageType;

@interface FCUploadImageProcessViewController : UIViewController

@property (strong, nonatomic) NSString* imageUrlResult;
@property (assign, nonatomic) NSInteger imageType;

@end
