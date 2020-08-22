//
//  FCLoginViewModel.m
//  FaceCar
//
//  Created by facecar on 11/18/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCLoginViewModel.h"
#import <SMSVatoAuthen/SMSVatoAuthen-Swift.h>

@interface FCLoginViewModel ()
@property (strong, nonatomic) NSString* phonePrefix;
@end


@implementation FCLoginViewModel

- (id) init {
    self = [super init];
    [FIRAuth auth].languageCode = @"vn";
    self.client = [[FCClient alloc] init];
    return self;
}

- (void) setPhoneNumber:(NSString *)phoneNumber
           andPhoneCode:(NSString *)phoneCode {
    NSString* phone = [[phoneNumber stringByReplacingOccurrencesOfString:phoneCode withString:@""]
                                    stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSString* firstChar = [NSString stringWithFormat:@"%c",[phone characterAtIndex:0]];
    if (![firstChar isEqualToString:@"0"]) {
        phone = [NSString stringWithFormat:@"0%@", phone];
    }
    
    DLog(@"phone enter: %@", phone);
    self.phoneNumber = phone;
    self.phonePrefix = phoneCode;
}

- (void) getSMSPasscode: (void (^)(NSError* err)) block {
    NSString* iphone = [NSString stringWithFormat:@"%@%@", self.phonePrefix, self.phoneNumber];
    ModelPhone *phone = [[ModelPhone alloc] initWith:self.phonePrefix originalPhone:self.phoneNumber internationalPhone:iphone];
    [SMSVatoAuthenInterface authenPhoneWith:phone complete:^(NSString * _Nonnull verificationID) {
        DLog(@"[Login] getSMSPasscode: %@", verificationID);
        dispatch_async(dispatch_get_main_queue(), ^{
            block (nil);
            [self savePhoneVerificationID:verificationID];
        });
        
    } error:^(NSError * _Nonnull error) {
        DLog(@"[Login] getSMSPasscode: %@", error);
        dispatch_async(dispatch_get_main_queue(), ^{
            block (error);
        });
    }];
    
    
//    DLog(@"timestampe 1: %f", [self getCurrentTimeStamp])
//    [[FIRPhoneAuthProvider provider] verifyPhoneNumber:phone
//                                            UIDelegate:nil
//                                            completion:^(NSString* verificationID, NSError* error) {
//                                                block (error);
//
//                                                DLog(@"timestampe 2: %f", [self getCurrentTimeStamp])
//
//                                                if (error) {
//                                                    DLog(@"[Login] getSMSPasscode: %@", error);
//                                                }
//                                                else {
//                                                    DLog(@"[Login] getSMSPasscode: %@", verificationID);
//                                                    [self savePhoneVerificationID:verificationID];
//                                                }
//                                            }];
}

- (void) verifySMSPassCode: (NSString*) smscode
                     block: (void (^)(NSError* err)) block {
    
    self.smsCode = smscode;
    [self phoneAuthProcess:block];
}

- (NSString*) getSocialProviderDisplayName {
    FIRUser* user = [FIRAuth auth].currentUser;
    if (!user) {
        AppLogCurrentUser()
    }

    NSString* name = nil;
    
    // get provider name
    for (id<FIRUserInfo> provider in user.providerData) {
        if ([[provider providerID] isEqual:FIRGoogleAuthProviderID]) {
            name = [provider displayName];
            break;
        }
        if ([[provider providerID] isEqual:FIRFacebookAuthProviderID]) {
            name = [provider displayName];
            break;
        }
    }
    
    return name;
}

- (NSString*) getSocialProviderAvatarUrl {
    FIRUser* user = [FIRAuth auth].currentUser;
    if (!user) {
        AppLogCurrentUser()
    }

    NSString* avatar = nil;
    // get provider name
    for (id<FIRUserInfo> provider in user.providerData) {
        if ([[provider providerID] isEqual:FIRGoogleAuthProviderID]) {
            avatar = [provider photoURL].absoluteString;
            break;
        }
        if ([[provider providerID] isEqual:FIRFacebookAuthProviderID]) {
            avatar = [provider photoURL].absoluteString;
            break;
        }
    }
    
    return avatar;
}

- (FIRPhoneAuthCredential*) getPhoneCredential {
    NSString* verificationID = [self getPhoneVericationID];
    FIRPhoneAuthCredential* phoneCredential = [[FIRPhoneAuthProvider provider] credentialWithVerificationID:verificationID
                                                                                      verificationCode:self.smsCode];
    
    return phoneCredential;
}

- (BOOL) havePhoneProvider: (FIRUser*) user {
    for (id<FIRUserInfo> provider in user.providerData) {
        if ([provider.providerID isEqualToString:FIRPhoneAuthProviderID]) {
            return YES;
        }
    }
    
    return NO;
}

#pragma mark - Social Provider (Facebook | Google) checking
- (void) checkingSocialAuth: (FIRAuthCredential*) credential
                      block: (void (^)(NSError *))block {
    self.socialCredential = credential;
    [[FIRAuth auth] signInAndRetrieveDataWithCredential:credential
                                             completion:^(FIRAuthDataResult* authResult, NSError* error) {
                                                 if (block) {
                                                     block (error);
                                                 }
                                                 
                                                 if (!error) {
                                                     self.client.user.fullName = [self getSocialProviderDisplayName];
                                                     
                                                     [self checkingLinkWithPhoneProvider:^(NSString* phone) {
                                                     }];
                                                 }
                                                 else {
                                                     DLog(@"[Login] facebook signin failure!");
                                                     self.resultCode = FCLoginResultCodeSocialCheckingFailure;
                                                 }
                                             }];
}

- (void) phoneLinkToSocialProvider: (void (^)(NSError* err)) block  {
    
    // if dont have any social provider then return success
    if (!self.socialCredential) {
        block(nil);
        return;
    }
    
    FIRUser* user = [FIRAuth auth].currentUser;
    if (!user) {
        AppLogCurrentUser()
    }

    if (self.socialCredential) {
        
        BOOL hasSameProvider = NO;
        NSString* accout;
        for (id<FIRUserInfo> provider in user.providerData) {
            if ([[provider providerID] isEqual:self.socialCredential.provider]) {
                hasSameProvider = YES;
                NSString* name = provider.displayName;
                NSString* email = provider.email;
                if (email.length > 0) {
                    accout = [NSString stringWithFormat:@"email %@", email];
                }
                else {
                    accout = name;
                }
                
                break;
            }
        }
        
        if (hasSameProvider) {
            NSString* mess = [NSString stringWithFormat:@"Số điện thoại %@ đã kết nối với tài khoản '%@'.\nBạn muốn tiếp tục với số điện thoại này không?", self.phoneNumber, accout];
            [UIAlertController showAlertInViewController:self.viewController
                                               withTitle:@"Thông báo"
                                                 message:mess
                                       cancelButtonTitle:nil
                                  destructiveButtonTitle:@"Huỷ"
                                       otherButtonTitles:@[@"Tiếp tục"]
                                                tapBlock:^(UIAlertController * _Nonnull controller, UIAlertAction * _Nonnull action, NSInteger buttonIndex) {
                                                    if (buttonIndex == 2) {
                                                        block (nil);
                                                    }
                                                }];
            
            block ([[NSError alloc] init]);
        }
        else {
            [user linkAndRetrieveDataWithCredential:self.socialCredential
                                         completion:^(FIRAuthDataResult* authResult, NSError* error) {
                                             DLog(@"[Login] phoneLinkToAnotherProvider: %@", error);
                                             block (error);
                                         }];
        }
        
    }
}


#pragma mark - Profile data checking

// detect this account link to phone auth yet?
// if (true) then -> checkingUserInfo
// else then -> have to verify phone

- (void) checkingLinkWithPhoneProvider:(void (^)(NSString*)) block  {
    FIRUser* user = [FIRAuth auth].currentUser;
    if (!user) {
        AppLogCurrentUser()
    }

    if (!user) {
        self.resultCode = FCLoginResultCodeSocialNotLinkedToPhone;
        block (nil);
    }
    else {
        for (id<FIRUserInfo> info in [user providerData]) {
            if ([info.providerID isEqual:FIRPhoneAuthProviderID]) {
                
                NSString* phone = user.phoneNumber;
                DLog(@"[Login] checkingLinkWithPhoneProvider: %@", phone);
                
                [self apiCheckPhone:^(BOOL success) {
                    if (success) {
                        self.resultCode = FCLoginResultCodeSocialLinkedToPhone;
                        block(phone);
                    }
                    else {
                        self.resultCode = FCLoginResultCodeBackendVerifyFailed;
                    }
                }];
                
                return;
            }
        }
        
        self.resultCode = FCLoginResultCodeSocialNotLinkedToPhone;
    }
}

// checking account have profile data yet?
// if (profile not nil and have phone verify) then success
// else failure
- (void) checkingUserData:(void (^)(FCClient*)) block {
    
    // for apply apple review
    if ([self.phoneNumber isEqualToString:PHONE_TEST]) {
        NSString* email = [NSString stringWithFormat:@"%@@%@", self.phoneNumber, EMAIL];
        FIRAuthCredential* credential = [FIREmailAuthProvider credentialWithEmail:email
                                                                         password:PASS_TEST];
        
        [[FIRAuth auth] signInAndRetrieveDataWithCredential:credential
                                                 completion:^(FIRAuthDataResult* authResult, NSError* error) {
                                                     if (authResult.user) {
                                                         [[FirebaseHelper shareInstance] getClient:^(FCClient * _Nullable client) {
                                                             block (client);
                                                         }];
                                                     }
                                                 }];
        
        return;
    }
    
    [[FirebaseHelper shareInstance] getClient:^(FCClient* client) {
        if (client.user.id && client.user.phone.length > 0) {
            block (client);
        }
        else {
            block (nil);
        }
    }];
}

- (void) updateUserInfo:(void (^)(NSError * error)) block {
    [self createData];
    [self apiUpdateAccount:_client
                   handler:block];
}

- (void) createUserInfo:(void (^)(NSError * error)) block {
    [self createData];
    [self apiCreateAccount:_client
                   handler:block];
}

- (void) createData {
    FIRUser* user = [FIRAuth auth].currentUser;
    if (!user) {
        AppLogCurrentUser()
    }

    _client.user.firebaseId = user.uid;
    _client.active = @(TRUE);
    _client.created = (long long)[self getTimestampOfDate:user.metadata.creationDate];
    _client.user.avatarUrl = [self getSocialProviderAvatarUrl];
}

#pragma mark - API check, create, update account
- (void) apiCheckPhone: (void (^) (BOOL success)) handler {
    FIRUser* user = [FIRAuth auth].currentUser;
    if (!user) {
        AppLogCurrentUser()
    }

    if (!user || user.phoneNumber.length == 0) {
        handler(NO);
        return;
    }
    
    NSString* phone = user.phoneNumber;
    if ([phone hasPrefix:@"+84"]) {
        phone = [phone stringByReplacingOccurrencesOfString:@"+84" withString:@"0"];
    }
    
    NSDictionary* body = @{@"firebaseId":user.uid,
                           @"phoneNumber":phone};
    
    [IndicatorUtils show];
    [[APIHelper shareInstance] post:API_CHECK_PHONE
                               body:body
                           complete:^(FCResponse *response, NSError *error) {
                               [IndicatorUtils dissmiss];
                               handler(response.status == APIStatusOK);
                           }];
}

- (void) apiCheckAccout: (void (^) (BOOL success, BOOL isUpdate, FCClient* client)) handler {
    FIRUser* user = [FIRAuth auth].currentUser;
    if (!user) {
        AppLogCurrentUser()
    }

    if (!user || user.phoneNumber.length == 0) {
        handler(NO, NO, nil);
        return;
    }
    
    NSString* phone = user.phoneNumber;
    if ([phone hasPrefix:@"+84"]) {
        phone = [phone stringByReplacingOccurrencesOfString:@"+84" withString:@"0"];
    }
    
    
    NSDictionary* body = @{@"firebaseId":user.uid,
                           @"phoneNumber":phone};
    
    [IndicatorUtils show];
    [[APIHelper shareInstance] post:API_CHECK_ACCOUNT
                               body:body
                           complete:^(FCResponse *response, NSError *error) {
                               [IndicatorUtils dissmiss];
                               [self fetchAccountData:response
                                              handler:handler];
                           }];
}

- (void) fetchAccountData: (FCResponse*) res
                  handler: (void (^) (BOOL success, BOOL isUpdate, FCClient* client)) handler {
    // checking userdata
    if (res.data != nil) {
        __block FCClient* client = nil;
        __block BOOL update = NO;
        [[FIRInstanceID instanceID] instanceIDWithHandler:^(FIRInstanceIDResult * _Nullable result, NSError * _Nullable error) {
            if ([[res.data objectForKey:@"user"] isKindOfClass:[NSDictionary class]]) {
                client = [[FCClient alloc] initWithDictionary:[res.data objectForKey:@"user"]
                                                      error:nil];
                FCUser* user = [[FCUser alloc] initWithDictionary:[res.data objectForKey:@"user"]
                                                              error:nil];
                if (user) {
                    client.user = user;
                }
                
                if ([client.deviceToken isKindOfClass:[NSNull class]] ||
                    client.deviceToken.length == 0 ||
                    ![client.deviceToken isEqualToString:result.token ?: @""]) {
                    update = YES;
                }
            }
            
            // user.username = phonenumber
            if (client != nil && client.user.firebaseId.length > 0 && client.user.phone.length > 0) {
                // update firerbase data
                if (!update) {
                    [[FirebaseHelper shareInstance] updateClientData:client
                                                 withCompletionBlock:nil];
                }
                
                handler(res.status == APIStatusOK, update, client);
            }
            else {
                handler(res.status == APIStatusOK, NO, nil);
            }
        }];
        
    }
    else {
        handler(res.status == APIStatusOK, NO, nil);
    }
}

/*
 * Call API tới server để xác nhận tài khoản đã được tạo
 * Chỉ gọi nếu chưa từng thành công trước đó
 */
- (void) apiCreateAccount: (FCClient*) client
                  handler: (void (^)(NSError * error)) block {
    [self getBodyData:client completeHandler:^(NSDictionary *dic) {
        [[APIHelper shareInstance] post:API_CREATE_ACCOUNT
            body:dic
        complete:^(FCResponse *response, NSError *error) {
            if (response.status == APIStatusOK) {
                FCUser* user = [[FCUser alloc] initWithDictionary:response.data
                                                            error:nil];
                client.user = user;
                [[FirebaseHelper shareInstance] updateClientData:client
                                             withCompletionBlock:^(NSError* error, FIRDatabaseReference *ref) {
                                                 if (block) {
                                                     block (error);
                                                 }
                                             }];
            }
            else {
                self.resultCode = FCLoginResultCodeBackendVerifyFailed;
                if (block) {
                    block ([NSError errorWithDomain:NSURLErrorDomain code:FCLoginResultCodeBackendVerifyFailed userInfo:nil]);
                }
            }
        }];
    }];
    
}


/*
 * Call API tới server cập nhât nhận tài khoản đã được tạo
 * Chỉ gọi nếu chưa từng thành công trước đó
 */
- (void) apiUpdateAccount: (FCClient*) client
                  handler: (void (^)(NSError * error)) block {
    [self getBodyData:client completeHandler:^(NSDictionary *dic) {
        [[APIHelper shareInstance] post:API_UPDATE_ACCOUNT
            body:dic
        complete:^(FCResponse *response, NSError *error) {
            if (response.status == APIStatusOK) {
                [[FirebaseHelper shareInstance] updateClientData:client
                                             withCompletionBlock:^(NSError* error, FIRDatabaseReference* ref) {
                                                 if (block) {
                                                     block(error);
                                                 }
                                             }];
            }
            else {
                if (block) {
                    block([[NSError alloc] initWithDomain:NSURLErrorDomain
                                                     code:FCLoginResultCodeBackendVerifyFailed
                                                 userInfo:nil]);
                }
            }
        }];
    }];
    
}

- (void)getBodyData: (FCClient*) client completeHandler:(void (^)(NSDictionary * dic))handler {
    FIRUser* user = [FIRAuth auth].currentUser;
    if (!user) {
        AppLogCurrentUser()
    }

    [[FIRInstanceID instanceID] instanceIDWithHandler:^(FIRInstanceIDResult * _Nullable result, NSError * _Nullable error) {
        NSString* phone = user.phoneNumber;
        if ([phone hasPrefix:@"+84"]) {
            phone = [phone stringByReplacingOccurrencesOfString:@"+84" withString:@"0"];
        }
        client.user.phone = phone;
        NSString* uid = user.uid;
        NSString* email = client.user.email.length > 0 ? client.user.email : @"";
        NSString* avatar = client.user.avatarUrl.length > 0 ? client.user.avatarUrl : @"";
        NSString* deviceToken =  result.token ?: @"";
        NSString* name = client.user.fullName.length > 0 ? client.user.fullName : @"";
        NSString* nickname = client.user.nickname.length > 0 ? client.user.nickname : @"";
        NSDictionary* body = @{@"phoneNumber":phone,
                               @"firebaseId":uid,
                               @"isDriver":@(NO),
                               @"fullName":name,
                               @"nickname":nickname,
                               @"email":email,
                               @"birthday":@(0),
                               @"deviceToken":deviceToken,
                               @"zoneId": @(client.zoneId),
                               @"avatarUrl":avatar,
                               @"appVersion":[NSString stringWithFormat:@"%@I", [self getAppVersion]]};
        if (handler) {
            handler(body);
        }
    }];
    
}

#pragma mark - Phone auth process (checking, unlink, link)
- (void) phoneAuthProcess:(void (^)(NSError* err)) block {
    
    FIRUser* currentLoginUser = [FIRAuth auth].currentUser;
    if (!currentLoginUser) {
        AppLogCurrentUser()
    }

    DLog(@"[Login] phoneAuthProcess: %@", currentLoginUser.uid);
    if (currentLoginUser) {
        if (self.socialCredential) {
            [currentLoginUser unlinkFromProvider:self.socialCredential.provider
                                      completion:^(FIRUser* user, NSError* error) {
                                          DLog(@"[Login] phoneAuthProcess: %@", error);
                                          
                                          [self phoneAuthSignIn:block];
                                      }];
        }
        else {
            [self removeEmailPassProvider:block];
        }
    }
    else {
        // checking old user with phone
        NSString* phone = [[self.phoneNumber stringByReplacingOccurrencesOfString:@" " withString:@""]
                           stringByReplacingOccurrencesOfString:@"+84" withString:@""];
        DLog(@"[Login] phoneAuthProcess: %@", phone);
        
        FIRAuthCredential* oldProvider = [[FirebaseHelper shareInstance] getPhoneCredential:phone];
        [[FIRAuth auth] signInAndRetrieveDataWithCredential:oldProvider
                                                 completion:^(FIRAuthDataResult* authResult, NSError* error) {
                                                     DLog(@"[Login] phoneAuthProcess -> signInWithCredential: %@", error);
                                                     if (authResult.user) {
                                                         [self removeEmailPassProvider:block];
                                                     }
                                                     else {
                                                         [self phoneAuthSignIn:block];
                                                     }
                                                 }];
    }
}

- (void) removeEmailPassProvider: (void (^)(NSError* err)) block  {
    FIRUser* currentLoginUser = [FIRAuth auth].currentUser;
    if (!currentLoginUser) {
        AppLogCurrentUser()
    }

    // remove old
    [currentLoginUser unlinkFromProvider:FIREmailAuthProviderID
                              completion:^(FIRUser* user, NSError* error) {
                                  DLog(@"[Login] phoneAuthProcess -> unlinkFromProvider: %@", error);
                                  [self linkToPhoneProvider:currentLoginUser
                                                      block:block];
                              }];
}

- (void) phoneAuthSignIn: (void (^)(NSError* err)) block  {
    [SMSVatoAuthenInterface authenOTPWith:self.smsCode complete:^(id<UserProtocol> _Nullable user) {
        DLog(@"[Login] phone authen success %@", user);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self phoneLinkToSocialProvider: block];
        });
    } error:^(NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            block(error);
        });
    }];
    
    
//    [[FIRAuth auth] signInAndRetrieveDataWithCredential:[self getPhoneCredential]
//                                             completion:^(FIRAuthDataResult * _Nullable authResult, NSError * _Nullable error) {
//                                                 DLog(@"[Login] verifySMSPassCode: %@", error);
//                                                 if (error) {
//                                                     block (error);
//                                                     return;
//                                                 }
//
//                                                 [self phoneLinkToSocialProvider: block];
//                                             }];
}

// link phone provider to Old User (user in old ver)
// * this make sure old user with be connected to new phone provider
- (void) linkToPhoneProvider:(FIRUser*) oldUser
                       block:(void (^)(NSError* err)) block {
    
    // link this to phone
    if ([self havePhoneProvider:oldUser]) {
        [self phoneAuthSignIn:block];
    }
    else {
        [oldUser linkAndRetrieveDataWithCredential:[self getPhoneCredential]
                                        completion:^(FIRAuthDataResult* authResult, NSError* error) {
                                            DLog(@"[Login] linkWithCredential -> %@", error);
                                            block(error);
                                        }];
    }
}

#pragma mark - Local cache
- (void) savePhoneVerificationID: (NSString*) verifyId {
    [[NSUserDefaults standardUserDefaults] setObject:verifyId
                                              forKey:@"authPhoneVerificationID"];
}

- (NSString*) getPhoneVericationID {
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"authPhoneVerificationID"];
}

@end