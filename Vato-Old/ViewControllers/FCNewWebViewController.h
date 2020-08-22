//
//  FCNewWebViewController.h
//  FC
//
//  Created by facecar on 6/13/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TopupLinkConfigureProtocol;
@interface FCNewWebViewController : UIViewController
@property (strong, nonatomic) NSString* title;
- (void) loadWebview: (NSString*) url;
- (void) loadWebviewWithConfigure:(id<TopupLinkConfigureProtocol>) url;
@end
