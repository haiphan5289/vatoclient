//
//  APIHelper.m
//  FC
//
//  Created by facecar on 7/25/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "APIHelper.h"
#import "UserDataHelper.h"
#import "UserDataHelper-Private.h"
#import "AppDelegate.h"
#import "FCHomeViewController.h"
#import "KYDrawerController.h"

#define kRequestTimeout 120.0f

@implementation APIHelper {
    NSMutableArray* _currentRequest;
    NSURLSessionDataTask* _currentDataTask;
    NSInteger _currentServiceBooking;
}

static APIHelper* instance = nil;
+ (APIHelper*) shareInstance {
    if (!instance) {
        instance = [[APIHelper alloc] init];
    }
    
    return instance;
}

- (id) init {
    self = [super init];
    if (self) {
        _currentRequest = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void) cancelCurrentRequest {
    if (_currentRequest.count > 0) {
        for (NSURLSessionDataTask* task in _currentRequest) {
            DLog(@"cancelCurrentRequest ")
            [task cancel];
        }
        
        [_currentRequest removeAllObjects];
    }
}

- (void) get: (NSString*) url
      params: (id) params
    complete:(void (^)(FCResponse *, NSError *))block {
    
    [[UserDataHelper shareInstance] getAuthToken:^(NSString * token, NSError * error) {
        if (error || [token length] == 0) {
            if (block) {
                block(nil, error);
            }
            return;
        }
        
        if (!error && token.length > 0) {
            [self call:url
                method:METHOD_GET
                params:params
                 token:token
        headerTokenKey:@"x-access-token"
              complete:block];
        }
    }];
}

- (void) post: (NSString*) url
         body:(id) params
     complete:(void (^)(FCResponse *, NSError *))block{
    
    [[UserDataHelper shareInstance] getAuthToken:^(NSString * _Nullable token, NSError * _Nullable error) {
        if (error || [token length] == 0) {
            if (block) {
                block(nil, error);
            }
            return;
        }
        
        if (!error && token.length > 0) {
            [self call:url
                method:METHOD_POST
                params:params
                 token:token
        headerTokenKey:@"x-access-token"
              complete:block];
        }
    }];
}

- (void) call: (NSString*) url
       method: (NSString*) method
       params: (id) params
        token: (NSString*) token
headerTokenKey: (NSString*) key
     complete: (void (^)(FCResponse* response, NSError *error)) handler {
    [self call:url
        method:method
        params:params
         token:token
headerTokenKey:key
       handler:^(NSError *error, id response) {
           if (error) {
               if (handler) {
                   handler(nil, error);
               }
               return;
           }
           
           @try {
               FCResponse* res = [[FCResponse alloc] initWithDictionary:response
                                                                  error:nil];
               if (handler) {
                   handler(res, nil);
               }
               
               if (res && res.status && res.status != APIStatusOK) {
                   if (res.status == APIStatusAccountBanned) {
                       [self showMessageError:@"Tài khoản của bạn đang bị tạm khoá truy cập. Bạn vui lòng quay lại sau."];
                   }
                   else if (res.status == APIStatusAccountSpam) {
                       [self showMessageError:@"Hiện tại bạn đang thao tác quá nhanh. Vui lòng kiểm tra thao tác và thử lại sau."];
                   }
                   else {
                       [self showMessageError:res.errorCode];
                   }
               }
           }
           @catch (NSException* e) {
               NSError *err = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorUnknown userInfo:e.userInfo];
               if (handler) {
                   handler(nil, err);
               }
               
               DLog(@"Error: %@", e);
           }
       }];
}

- (RACSignal *)call: (NSString*) url
             method: (NSString*) method
             params: (id) params
              token: (NSString*) token
     headerTokenKey: (NSString*) key {
        url = [url stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@/", HOSTV2] withString:@""];
        url = [url stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@/", HOSTV3] withString:@""];
        
        NSDictionary *header = @{
                                 @"Content-Type": @"application/json",
                                 @"x-app-version": [self getAppVersion],
                                 @"x-app-id": [[NSBundle mainBundle] bundleIdentifier],
                                 @"x-platform": @"ios",
                                 @"x-device-id": [self getDeviceId]
                                 };
        
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [[RequesterObjc instance] requestWithToken:token
                                                  path:url
                                                method:method
                                                header:header
                                                params:params
                                         trackProgress:YES
                                               handler:^(NSDictionary<NSString *,id> * _Nullable responseData, NSError * _Nullable error) {
                                                   if (error) {
                                                       [subscriber sendError:error];
                                                   } else {
                                                       [subscriber sendNext:responseData];
                                                       [subscriber sendCompleted];
                                                   }
                                                   
                                               }];
            return nil;
        }];
    }

- (void) call: (NSString*) url
       method: (NSString*) method
       params: (id) params
        token: (NSString*) token
headerTokenKey: (NSString*) key
      handler: (void (^)(NSError* error, id response)) block {
    [[self call:url method:method params:params token:token headerTokenKey:key] subscribeNext:^(id responseData) {
        if (block) {
            block(nil, responseData);
        }
    } error:^(NSError *error) {
        [UserDataHelper shareInstance].firebaseToken = nil;
        if (block) {
            block(error, nil);
        }
    }];
}

- (void) apiSearchDriverOnline: (NSString*) url
                         param: (id) params
                         token: (NSString*) token
                       handler: (void (^)(FCResponse *response)) block {}

- (void) showMessageError: (NSString*) errorMessage {
    AppDelegate* app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    UIViewController* vc = [app visibleViewController:app.window.rootViewController];
    if (![vc isKindOfClass:[FCHomeViewController class]] && ![vc isKindOfClass:[KYDrawerController class]]) {
        NSString* mess = [self getErrorMessage:errorMessage];
        if (mess.length > 0) {
            [[FCNotifyBannerView banner] show:nil
                                      forType:FCNotifyBannerTypeError
                                     autoHide:YES
                                      message:mess
                                   closeClick:nil
                                  bannerClick:nil];
        }
        else {
            [[FCNotifyBannerView banner] show:nil
                                      forType:FCNotifyBannerTypeError
                                     autoHide:YES
                                      message:@"Bạn vui lòng quay lại sau.\nHoặc liên hệ tổng đài để được hỗ trợ!"
                                   closeClick:nil
                                  bannerClick:^{
                                      [self callPhone:PHONE_CENTER];
                                  }];
        }
    }
}


- (NSString*) getErrorMessage: (NSString*) errorCode {
    if ([errorCode containsString:@"WrongOldPinException"]) {
        return @"Mật khẩu hiện tại không đúng. Vui lòng thử lại.";
    }
    if ([errorCode containsString:@"WrongResetTokenException"]) {
        return @"Mã bảo mật không đúng. Bạn vui lòng kiểm tra và thử lại.";
    }
    if ([errorCode containsString:@"UserNotExistedException"]) {
        return @"Tài khoản này không tồn tại. Bạn vui lòng kiểm tra và thử lại.";
    }
    if ([errorCode containsString:@"CantVerifyPinException"]) {
        return @"Mật khẩu thanh toán không đúng. Bạn vui lòng kiểm tra và thử lại.";
    }
    return nil;
}

@end
