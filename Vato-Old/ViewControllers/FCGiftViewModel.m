//
//  FCGiftViewModel.m
//  FaceCar
//
//  Created by facecar on 10/3/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCGiftViewModel.h"
#import "APIHelper.h"
#import "FCGift.h"

@interface FCGiftViewModel ()
@property (strong, nonatomic) UIViewController* viewController;
@property (strong, nonatomic) FCHomeViewModel* homeViewModel;
@end

@implementation FCGiftViewModel

- (instancetype) initWithRootVC:(UIViewController *)rootVc homeViewModel: (FCHomeViewModel*) homeModel {
    self = [super init];
    self.viewController = rootVc;
    self.homeViewModel = homeModel;
    return self;
}

- (void) getGift:(NSArray*) requireTypes complete:(void (^)(NSMutableArray *))block {
    block(nil);
    
//    [[APIHelper shareInstance] get:API_GET_GIFTS
//                            params:@{@"isReferral":(self.homeViewModel.client.friendCode.length > 0 ? @"true":@"false")}
//                          complete:^(FCResponse *response) {
//                              if (response && [response isKindOfClass:[NSDictionary class]]) {
//                                  NSDictionary* data = [response objectForKey:@"data"];
//                                  NSArray* list = [data objectForKey:@"list"];
//                                  NSMutableArray* gifts = [[NSMutableArray alloc] init];
//                                  for (NSDictionary* item in list) {
//                                      NSError* err;
//                                      FCGift* gift = [[FCGift alloc] initWithDictionary:item error:&err];
//                                      if (gift) {
//                                          for (NSNumber* type in requireTypes) {
//                                              if ([type integerValue] == ALL || [type integerValue] == gift.strategy) {
//                                                  [gifts addObject:gift];
//                                                  break;
//                                              }
//                                          }
//                                      }
//                                  }
//                                  block(gifts);
//                              }
//                              block(nil);
//                          }];
}

#pragma mark - Tracking open event

- (void) setLasttimeShowGiftEvent:(long long)timestamp {
    NSUserDefaults* userdefault = [NSUserDefaults standardUserDefaults];
    [userdefault setObject:@(timestamp) forKey:@"lasttime-show-event"];
    [userdefault synchronize];
}

- (long long) getLastimeShowGiftEvent {
    NSUserDefaults* userdefault = [NSUserDefaults standardUserDefaults];
    id time = [userdefault objectForKey:@"lasttime-show-event"];
    if (time) {
        return [time longLongValue];
    }
    return 0;
}

@end
