//
//  AFNetworkingHelper.m
//  FaceCar
//
//  Created by Vu Dang on 7/10/16.
//  Copyright © 2016 Vu Dang. All rights reserved.
//

#import "APICall.h"
//#import <AFNetworking/AFNetworking.h>
//#import <AFNetworking/AFNetworkReachabilityManager.h>
#import "AFNetworkReachabilityManager.h"
#import "UserDataHelper.h"
#import "UserDataHelper-Private.h"
#import "FCInvoice.h"
#import "APIHelper.h"
#import "AppDelegate.h"
#import "SplashViewController.h"

@implementation APICall {
    BOOL _showingAlertLoseNetwork;
}

static APICall* instance = nil;
+ (APICall*) shareInstance {
    if (instance == nil) {
        instance = [[APICall alloc] init];
    }
    return instance;
}

- (void) apiSearchDriver:(NSDictionary*) params  completeHandler:(void (^_Nonnull)(NSMutableArray*)) completed {
    NSInteger service = [[params objectForKey:@"service"] integerValue];
    [[UserDataHelper shareInstance] getAuthToken:^(NSString * token, NSError * error) {
        [[APIHelper shareInstance] apiSearchDriverOnline:API_SEARCH_DRIVER param:params token:token handler:^(FCResponse *response) {
            if (response.status == APIStatusOK) {
                NSMutableArray* res = [[NSMutableArray alloc] init];
                for (NSDictionary* dict in response.data) {
                    NSError* err;
                    FCDriverSearch* driver = [[FCDriverSearch alloc] initWithDictionary:dict error:&err];
                    if (driver && driver.service == service) {
                        [res addObject:driver];
                    }
                }
                
                completed(res);
            }
            else {
                completed(nil);
            }

        }];
    }];
}


- (void) apiSearchDriverForBooking:(NSDictionary*) params  completeHandler:(void (^_Nonnull)(NSMutableArray*)) completed {
    NSInteger service = [[params objectForKey:@"service"] integerValue];
    [[APIHelper shareInstance] get:API_SEARCH_DRIVER_FOR_BOOKING params:params complete:^(FCResponse *response, NSError *error) {
        if (response.status == APIStatusOK) {
            NSMutableArray* res = [[NSMutableArray alloc] init];
            for (NSDictionary* dict in response.data) {
                NSError* err;
                FCDriverSearch* driver = [[FCDriverSearch alloc] initWithDictionary:dict error:&err];
                if (driver && driver.service == service) {
                    [res addObject:driver];
                }
            }
            
            completed(res);
        }
        else {
            completed(nil);
        }
        
    }];
}

- (void) apiGetRefferalCodeWithComplete:(void (^)(NSString*)) completed {
    NSDictionary* params = [NSDictionary dictionaryWithObject:@1 forKey:@"eventId"];
    [[APIHelper shareInstance] get:API_GET_REFERAL_CODE
                            params:params
                          complete:^(FCResponse *response, NSError *error) {
                          }];
}

- (void) apiVerifyRefferalCode :(NSString*) code withComplete:(void (^)(NSString*, BOOL)) completed {
    NSDictionary* params = [NSDictionary dictionaryWithObjects:@[code, @1] forKeys:@[@"code", @"eventId"]];
    [[APIHelper shareInstance] post:API_VERIFY_REFERAL_CODE
                               body:params
                           complete:^(FCResponse *response, NSError *error) {
                           }];
}

- (void) apiGetInvoicesList:(NSDictionary*) params block:(void (^)(NSArray*, BOOL more)) completed {
    
    [[APIHelper shareInstance] get:API_GET_INVOICE
                               params:params
                           complete:^(FCResponse *response, NSError *error) {
                               NSMutableArray* list = [[NSMutableArray alloc] init];
                               NSArray* datas = [response.data objectForKey:@"transactions"];
                               BOOL more = [[response.data objectForKey:@"more"] boolValue];
                               for (id item in datas) {
                                   FCInvoice* invoice = [[FCInvoice alloc] initWithDictionary:item error:nil];
                                   if (invoice) {
                                       [list addObject:invoice];
                                   }
                               }
                               completed(list, more);
                           }];
}

- (void) checkingNetwork {
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        AppDelegate* appdelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
        UIViewController* vc = [appdelegate visibleViewController:appdelegate.window.rootViewController];
        
        if (status == 0) {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_NETWORK_DISCONNECTED
                                                                object:nil];
            if (![vc isKindOfClass:[SplashViewController class]] && ![vc isKindOfClass:[AlertVC class]]) {
                _showingAlertLoseNetwork = YES;
                AlertActionObjC* actionOk = [[AlertActionObjC alloc] initFrom:localizedFor(@"Đồng ý") style:UIAlertActionStyleDefault handler:^{
                    _showingAlertLoseNetwork = NO;
                    [self openWifiSettings];
                }];
                AlertActionObjC* actionCancel = [[AlertActionObjC alloc] initFrom:localizedFor(@"Để sau") style:UIAlertActionStyleCancel handler:^{
                    _showingAlertLoseNetwork = NO;
                }];
                [AlertVC showObjcOn:vc title:localizedFor(@"Mất kết nối")
                            message:localizedFor(@"Đường truyền mạng trên thiết bị đã mất kết nối. Vui lòng kiểm tra và thử lại.")
                          orderType:UILayoutConstraintAxisHorizontal
                               from:@[actionCancel, actionOk]];
            }
        }
        else {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_NETWOTK_CONNECTED
                                                                object:nil];
            if (![vc isKindOfClass:[SplashViewController class]] && [vc isKindOfClass:[AlertVC class]] && _showingAlertLoseNetwork) {
                [vc dismissViewControllerAnimated:YES completion:nil];
            }
        }
    }];
}

- (void) apiGetBalance:(void (^)(FCBalance *))block {
    [[APIHelper shareInstance] get:API_GET_BALANCE
                            params:nil//@{@"id":@([[UserDataHelper shareInstance] getCurrentUser].userId)}
                          complete:^(FCResponse *response, NSError *error) {
                              @try {
                                  FCBalance* balance = [[FCBalance alloc] initWithDictionary:response.data
                                                                                       error:nil];
                                  block(balance);
                              }
                              @catch (NSException* e) {
                                  block(nil);
                              }
                          }];
}

- (void) apiUpdateProfile:(NSString*) email
                 nickname:(NSString*) nickname
                 fullname:(NSString*) fullname
                   avatar:(NSString*) avatar
                  handler:(void (^)(NSError * error)) block {
    FIRUser* user = [FIRAuth auth].currentUser;
    if (!user) {
        AppLogCurrentUser()
        return;
    }
    
    NSString* phone = user.phoneNumber;
    if ([phone hasPrefix:@"+84"]) {
        phone = [phone stringByReplacingOccurrencesOfString:@"+84" withString:@"0"];
    }
    
    FCClient* client = [UserDataHelper shareInstance].getCurrentUser;
    
    NSString* uid = user.uid;
    NSMutableDictionary* body = [[NSMutableDictionary alloc] init];
    [body addEntriesFromDictionary:@{@"phoneNumber":phone,
                                     @"firebaseId":uid}];
    if (email.length > 0) {
        client.user.email = email;
        [body addEntriesFromDictionary:@{@"email":email}];
    }
    if (nickname.length > 0) {
        client.user.nickname = nickname;
        [body addEntriesFromDictionary:@{@"nickname":nickname}];
    }
    if (fullname.length > 0) {
        client.user.fullName = fullname;
        [body addEntriesFromDictionary:@{@"fullName":fullname}];
    }
    if (avatar.length > 0) {
        client.user.avatarUrl = avatar;
        [body addEntriesFromDictionary:@{@"avatarUrl":avatar}];
    }
    
    [[APIHelper shareInstance] post:API_UPDATE_ACCOUNT
                               body:body
                           complete:^(FCResponse *response, NSError *error) {
                               if (block) {
                                   block(error);
                               }
                           }];
    
    [[UserDataHelper shareInstance] saveUserToLocal:client];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_PROFILE_UPDATED
                                                        object:nil];
}

- (void) apiSigOut {
    [[APIHelper shareInstance] post:API_LOGOUT
                               body:nil
                           complete:^(FCResponse *response, NSError *error) {
                               
                           }];
}


@end
