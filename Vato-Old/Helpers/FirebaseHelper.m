//
//  FirebaseHelper.m
//  FaceCar
//
//  Created by Vu Dang on 5/30/16.
//  Copyright © 2016 Vu Dang. All rights reserved.
//

#import "FirebaseHelper.h"
#import "UserDataHelper.h"
#import "GoogleMapsHelper.h"
#import "TripTypeUtil.h"
#import <SMSVatoAuthen/SMSVatoAuthen-Swift.h>

#if DEV
#import "VATO_DEV-Swift.h"
#elif STG
#import "VATO_Staging-Swift.h"
#else
#import "VATO-Swift.h"
#endif

@interface FIRUser(Extension)<UserProtocol>

@end

@implementation FirebaseHelper

static FirebaseHelper * instnace = nil;
+ (FirebaseHelper*) shareInstance {
    if (instnace == nil) {
        instnace = [[FirebaseHelper alloc] init];
    }
    return instnace;
}

- (id) init {
    self = [super init];
    if (self) {
        self.ref = [FIRDatabase database].reference;
    }
    
    return self;
}

#pragma mark - Auth handler
- (FIRAuthCredential*) getfacebookCredential {
    FIRAuthCredential *credential = [FIRFacebookAuthProvider
                                     credentialWithAccessToken:[FBSDKAccessToken currentAccessToken]
                                     .tokenString];
    
    return credential;
}

- (void) facebookAuth:(FIRAuthCredential*)credential handler:(void (^)(FIRUser *))completed {
    [[FIRAuth auth] signInWithCredential:credential
                              completion:^(FIRAuthDataResult * _Nullable authResult, NSError * _Nullable error) {
                                  if (!error) {
                                      completed(authResult.user);
                                  }
                                  else {
                                      DLog(@"Error: %@", error)
                                      completed(nil);
                                  }
                              }];
    
}

- (FIRAuthCredential*) getPhoneCredential:(NSString*) phone {
    NSString* email = [NSString stringWithFormat:@"%@@%@", phone, EMAIL];
    FIRAuthCredential *credential = [FIREmailAuthProvider credentialWithEmail:email
                                                                     password:PASS];
    return credential;
    
}

- (FIRAuthCredential*) getGoogleCredential:(NSString*) idToken accessToken: (NSString*) acctoken {
    if (!idToken || !acctoken) {
        return nil;
    }
    FIRAuthCredential *credential = [FIRGoogleAuthProvider credentialWithIDToken:idToken accessToken:acctoken];
    return credential;
}

- (void) googleAuth:(FIRAuthCredential*) credential handler:(void (^)(FIRUser *))completed {
    if (!credential) {
        completed(nil);
        return;
    }
    
    [[FIRAuth auth] signInWithCredential:credential
                              completion:^(FIRAuthDataResult * _Nullable authResult, NSError * _Nullable error) {
                                  if (!error) {
                                      completed(authResult.user);
                                  }
                                  else {
                                      DLog(@"Error: %@", error)
                                      completed(nil);
                                  }
                              }];
}

- (void) unlinkAcount: (FIRUser*) user fromAuthCredential: (FIRAuthCredential*) credential handler:(void (^)(NSError * error)) completed {
    [user unlinkFromProvider:credential.provider completion:^(FIRUser* user, NSError* error) {
        if (!error) {
            // unlink success
            completed(nil);
        }
        else {
            // unlink failed
            completed(error);
        }
    }];
}

- (void) remvoveAnonymousUser: (FIRUser*) user {
    [user deleteWithCompletion:^(NSError * error) {
        DLog(@"remvoveAnonymousUser: %@", user.uid)
    }];
}

#pragma mark - Users: save , get, update client

- (void) updateClientData: (FCClient*) client
      withCompletionBlock: (void (^)(NSError * error, FIRDatabaseReference * ref))block {
    @try {
        if ([[FIRAuth auth] currentUser]) {
            if (client.user) {
                FIRDatabaseReference* ref = [[self.ref child:TABLE_USER] child:[FIRAuth auth].currentUser.uid];
                FCUser* user = client.user;
                NSDictionary *post = [user toDictionary];
                [ref updateChildValues:post
                   withCompletionBlock:block];
            }
            
            {
                FIRDatabaseReference* ref = [[self.ref child:TABLE_CLIENT] child:[FIRAuth auth].currentUser.uid];
                NSMutableDictionary *post = [[NSMutableDictionary alloc] initWithDictionary:[client toDictionary]];
                [post removeObjectForKey:@"user"];
                [ref updateChildValues:post
                   withCompletionBlock:block];
            }
        } else {
            AppLogCurrentUser()
        }
    }
    @catch (NSException* e) {
        AppError(e)
    }
}

- (void) getClient:(void (^)(FCClient *))completed {
    @try {
        NSString* firebaseId = [FIRAuth auth].currentUser.uid;
        AppLog(firebaseId)

        [self getUser: firebaseId
              handler:^(FCUser * user) {
            if (user) {
                @try {
                    FIRDatabaseReference* ref = [[self.ref child:TABLE_CLIENT] child:firebaseId];
                    [ref keepSynced:TRUE];
                    [ref observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
                        if ([snapshot.value isKindOfClass:[NSDictionary class]]) {
                            NSDictionary* dict = [NSDictionary dictionaryWithDictionary:snapshot.value];
                            NSError* err;
                            FCClient* client = [[FCClient alloc] initWithDictionary:dict error:&err];
                            client.user = user;
                            if (client && client.user.phone.length > 0) {
                                self.currentClient = client;
                                [[UserDataHelper shareInstance] saveUserToLocal:client];  // save to local
                                completed(client);
                            }
                            else {
                                completed (nil);
                            }
                        }
                        else {
                            completed (nil);
                        }
                    }];
                }
                @catch (NSException* e) {
                    AppError(e)
                }
            }
            else {
                completed(nil);
            }
        }];
    }
    @catch (NSException* e) {
        AppError(e)
    }
}

- (void) getUser: (NSString*) firebaseId
         handler: (void (^)(FCUser *))completed {
    @try {
        FIRDatabaseReference* ref = [[self.ref child:TABLE_USER] child:firebaseId];
        [ref keepSynced:TRUE];
        [ref observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot* snapshot) {
            if ([snapshot.value isKindOfClass:[NSDictionary class]]) {
                NSDictionary* dict = [NSDictionary dictionaryWithDictionary:snapshot.value];
                NSError* err;
                FCUser* user = [[FCUser alloc] initWithDictionary:dict error:&err];
                if (user && user.phone.length > 0) {
                    completed(user);
                }
                else {
                    completed (nil);
                }
            }
            else {
                completed (nil);
            }
        }];
    }
    @catch (NSException* e) {
        AppError(e)
        completed(nil);
    }
}
    
FIRDatabaseHandle clientInfoListenerHandler;
- (void) addClientInfoChangedListener:(void (^)(FIRDataSnapshot * _Nullable))completed
    {
        @try {
            // remove listener before add listener
            [self removeClientInfoChangedListener];
            
            // listen to driver info changed
            FIRDatabaseReference *ref = [[self.ref child:TABLE_CLIENT] child:[FIRAuth auth].currentUser.uid];
            clientInfoListenerHandler = [ref observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
                completed(snapshot);
            }];
        } @catch (NSException *exception) {
            DLog(@"%@", exception.description)
        }
    }
    
- (void)removeClientInfoChangedListener {
        if (clientInfoListenerHandler != 0) {
            FIRDatabaseReference *ref = [[self.ref child:TABLE_CLIENT] child:[FIRAuth auth].currentUser.uid];
            [ref removeObserverWithHandle:clientInfoListenerHandler];
        }
}
    
- (void) updateUserPhone: (NSString*) phone {
    @try {
        if ([[FIRAuth auth] currentUser]) {
            FIRDatabaseReference* ref = [[self.ref child:TABLE_USER] child:[FIRAuth auth].currentUser.uid];
            NSDictionary *post = @{@"phone":phone};
            [ref updateChildValues:post];
        } else {
            AppLogCurrentUser()
        }
    }
    @catch (NSException* e) {
        AppError(e)
    }
}

- (void) updateUserId:(NSInteger) userid {
    @try {
        if ([[FIRAuth auth] currentUser] && userid > 0) {
            FIRDatabaseReference* ref = [[self.ref child:TABLE_USER]
                                         child:[FIRAuth auth].currentUser.uid];
            NSDictionary *post = @{@"id":@(userid)};
            [ref updateChildValues:post];
        } else {
            AppLogCurrentUser()
        }
    }
    @catch (NSException* e) {
        AppError(e)
    }
    
}

- (void) updateUserCreated {
    if ([[FIRAuth auth] currentUser]) {
        FIRDatabaseReference* ref = [[self.ref child:TABLE_CLIENT] child:[FIRAuth auth].currentUser.uid];
        NSDictionary *post = @{@"created":@((long long)[self getTimestampOfDate:[FIRAuth auth].currentUser.metadata.creationDate])};
        [ref updateChildValues:post];
    } else {
        AppLogCurrentUser()
    }
}

- (void) updateUserEmail: (NSString*) email complete: (void (^) (NSError* err)) block {
    @try {
        if ([[FIRAuth auth] currentUser]) {
            FIRDatabaseReference* ref = [[self.ref child:TABLE_USER] child:[FIRAuth auth].currentUser.uid];
            NSDictionary *post = @{@"email":email};
            [ref updateChildValues:post];
            
            self.currentClient.user.email = email;
            [[UserDataHelper shareInstance] saveUserToLocal:self.currentClient]; // save to local
        } else {
            AppLogCurrentUser()
        }
        
        if ([[FIRAuth auth] currentUser].email.length == 0) {
            NSString *message = [NSString stringWithFormat:@"User is trying to update email: %@", email];
            AppLog(message)

            [[FIRAuth auth].currentUser updateEmail:email completion:^(NSError * error) {
                if (block) {
                    AppError(error)
                    block(error);
                }
            }];
        } else {
            AppLogCurrentUser()
            if (block) {
                block(nil);
            }
        }
    }
    @catch (NSException* e) {
        AppError(e)
        if (block) {
            block(nil);
        }
    }
}

- (void) updateNickname: (NSString*) nickname {
    @try {
        if ([[FIRAuth auth] currentUser]) {
            FIRDatabaseReference* ref = [[self.ref child:TABLE_USER] child:[FIRAuth auth].currentUser.uid];
            NSDictionary *post = @{@"nickname":nickname};
            [ref updateChildValues:post];
        } else {
            AppLogCurrentUser()
        }
    }
    @catch (NSException* e) {
        AppError(e)
    }
}

- (void) updateFullname: (NSString*) nickname {
    @try {
        if ([[FIRAuth auth] currentUser]) {
            FIRDatabaseReference* ref = [[self.ref child:TABLE_USER] child:[FIRAuth auth].currentUser.uid];
            NSDictionary *post = @{@"fullName":nickname};
            [ref updateChildValues:post];
        } else {
            AppLogCurrentUser()
        }
    }
    @catch (NSException* e) {
        AppError(e)
    }
}

- (void) updatePlatfom {
    @try {
        if ([[FIRAuth auth] currentUser]) {
            FIRDatabaseReference* ref = [[self.ref child:TABLE_CLIENT] child:[FIRAuth auth].currentUser.uid];
            NSDictionary *post = @{@"version":[self getAppVersion]};
            [ref updateChildValues:post];
        } else {
            AppLogCurrentUser()
        }
    }
    @catch (NSException* e) {
        AppError(e)
    }
    @finally {}
}

- (void) updateDeviceInfo {
    @try {
        if ([[FIRAuth auth] currentUser]) {
            FIRDatabaseReference* ref = [[self.ref child:TABLE_CLIENT] child:[FIRAuth auth].currentUser.uid];
            NSDictionary *post = @{@"deviceInfo":[[[FCDevice alloc] init] toDictionary]};
            [ref updateChildValues:post];
        } else {
            AppLogCurrentUser()
        }
    }
    @catch (NSException* e) {
        AppError(e)
    }
    @finally {}
}

- (void) updateLocationInfo: (CLLocation*) location {
    if ([[FIRAuth auth] currentUser]) {
        FIRDatabaseReference* refZone = [[[[self.ref child:TABLE_MASTER] child:TABLE_ZONE] child:@"0"] child:@"cities"];
        [refZone keepSynced:YES];
        [refZone observeSingleEventOfType:FIRDataEventTypeValue
                                withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
                                    if (snapshot.value) {
                                        for (FIRDataSnapshot* s in snapshot.children) {
                                            NSString* polyline = [s.value valueForKey:@"polyline"];
                                            if (polyline.length > 0) {
                                                GMSPath *path =[GMSPath pathFromEncodedPath:polyline];
                                                if (GMSGeometryContainsLocation(location.coordinate, path, NO)) {
                                                    NSInteger zoneId = [[s.value valueForKey:@"id"] integerValue];
                                                    [self updateZoneId: zoneId];
                                                    break;
                                                }
                                            }
                                        }
                                    }
                                }];
    } else {
        AppLogCurrentUser()
    }
}

- (void) updateZoneId: (NSInteger) zoneId {
    @try {
        AppLog([FIRAuth auth].currentUser.uid)

        FIRDatabaseReference* ref = [[self.ref child:TABLE_CLIENT] child:[FIRAuth auth].currentUser.uid];
        NSDictionary *post = @{@"zoneId":@(zoneId)};
        [ref updateChildValues:post];
        
        [self subscribeToTopic:zoneId];
    }
    @catch(NSException* e) {
        AppError(e)
    }
}

- (void) subscribeToTopic: (NSInteger) zoneId {
    [self getClient:^(FCClient * client) {
        @try {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
                @try {
                    if (client.topic.length > 0) {
                        [[FIRMessaging messaging] unsubscribeFromTopic:client.topic];
                    }
                    
                    [[FIRMessaging messaging] subscribeToTopic:[NSString stringWithFormat: @"client.city~%ld", zoneId]];
                }
                @catch (NSException* e) {}
                
                // update new topic
                FIRDatabaseReference* ref = [[self.ref child:TABLE_CLIENT] child:[FIRAuth auth].currentUser.uid];
                [ref updateChildValues:@{@"topic" : [NSString stringWithFormat: @"client.city~%ld", zoneId]}];
            }];
        }
        @catch(NSException* e) {}
    }];
    
}

- (void) updateAvatarUrl:(NSString*) avatarUrl {
    @try {
        if ([[FIRAuth auth] currentUser] && avatarUrl.length > 0) {
            NSString *message = [NSString stringWithFormat:@"User is trying to update avatarURL: %@", avatarUrl];
            AppLog(message)

            FIRUserProfileChangeRequest *changeRequest = [[FIRAuth auth].currentUser profileChangeRequest];
            changeRequest.photoURL = [NSURL URLWithString:avatarUrl];
            [changeRequest commitChangesWithCompletion:^(NSError * error) {
                FIRDatabaseReference* ref = [[self.ref child:TABLE_USER]
                                             child:[FIRAuth auth].currentUser.uid];
                NSDictionary *post = @{@"avatarUrl":avatarUrl};
                [ref updateChildValues:post];
            }];
        } else {
            AppLogCurrentUser()
        }
    }
    @catch (NSException* e) {
        AppError(e)
    }
    
}

- (void) updatePaymentMethod:(PaymentMethod) method {
    @try {
        AppLog([FIRAuth auth].currentUser.uid)

        FIRDatabaseReference* ref = [[self.ref child:TABLE_CLIENT]
                                     child:[FIRAuth auth].currentUser.uid];
        NSDictionary *post = @{@"paymentMethod":@(method)};
        [ref updateChildValues:post];
    }
    @catch (NSException* e) {}
    
}


#pragma mark - Storage
- (FIRStorageUploadTask*) uploadImage:(UIImage*) image withPath: (NSString*) path handler : (void (^)(NSURL* url)) block {
    FIRStorage *storage = [FIRStorage storage];
    
    FIRStorageReference *storageRef = [[storage reference] child:path];
    
    NSData *data = UIImagePNGRepresentation([image fixOrientation]);
    
    // Upload the file to the path "images/rivers.jpg"
    FIRStorageUploadTask *uploadTask = [storageRef putData:data
                                                  metadata:nil
                                                completion:^(FIRStorageMetadata *metadata,
                                                            NSError *error) {
                                                   if (error != nil) {
                                                       block(nil);
                                                   } else {
                                                       [storageRef downloadURLWithCompletion:^(NSURL * URL, NSError * error) {
                                                           block(URL);
                                                       }];
                                                   }
                                               }];
    
    return uploadTask;
}

- (void) updateUserAvatar: (NSURL*) url {
    if ([[FIRAuth auth] currentUser]) {
        FIRDatabaseReference* ref = [[self.ref child:TABLE_USER] child:[FIRAuth auth].currentUser.uid];
        NSDictionary *post = @{@"avatarUrl": url.absoluteString};
        [ref updateChildValues:post];
    } else {
        AppLogCurrentUser()
    }
}

- (void) updateDeviceToken:(NSString*) token {
    if ([[FIRAuth auth] currentUser] && token.length > 0) {
        FIRDatabaseReference* ref = [[self.ref child:TABLE_CLIENT] child:[FIRAuth auth].currentUser.uid];
        NSDictionary *post = @{@"deviceToken": token};
        [ref updateChildValues:post];
    } else {
        AppLogCurrentUser()

        NSString *message = [NSString stringWithFormat:@"User is trying to update device's token: %@", token];
        AppLog(message)
    }
}

#pragma mark - Drivers
NSMutableArray* driverListnerHandler;
NSMutableArray* driverDeadHandler;

- (void) driverChangedListener:(NSString*) key handler:(void (^ _Nullable)(FIRDataSnapshot * _Nullable))completed {
    // remove listener before add listener
    [self removeDriverChangedListener];

    // listener driver changed
    driverListnerHandler = [[NSMutableArray alloc] init];
    FIRDatabaseReference* ref = [self.ref child:TABLE_DRIVER_ONLINE];
    for (int i = 0; i < NUM_OF_DRIVER_GROUP; i ++) {
        FIRDatabaseReference* refReal  = [ref child:[NSString stringWithFormat:@"%d", i]];
        FIRDatabaseQuery* query = [[refReal queryOrderedByChild:@"key"] queryStartingAtValue:key];
        FIRDatabaseHandle handler = [query observeEventType:FIRDataEventTypeChildChanged withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            completed(snapshot);
        }];

        [driverListnerHandler addObject:[NSNumber numberWithUnsignedInteger:handler]];
    }
}

- (void) removeDriverChangedListener {
    FIRDatabaseReference* ref = [self.ref child:TABLE_DRIVER_ONLINE];
    for (int i = 0; i < driverListnerHandler.count; i ++) {
        FIRDatabaseReference* refReal = [ref child:[NSString stringWithFormat:@"%d", i]];
        [refReal removeObserverWithHandle:[[driverListnerHandler objectAtIndex:i] integerValue]];
    }
}

- (void) driverDeadListener:(NSString*) key handler:(void (^)(FIRDataSnapshot*__nullable))completed {
    driverDeadHandler = [[NSMutableArray alloc] init];
    FIRDatabaseReference* ref = [self.ref child:TABLE_DRIVER_ONLINE];
    for (int i = 0; i < NUM_OF_DRIVER_GROUP; i ++) {
        FIRDatabaseReference* refReal = [ref child:[NSString stringWithFormat:@"%d", i]];
        FIRDatabaseQuery* query = [[refReal queryOrderedByChild:@"key"] queryStartingAtValue:key];
        FIRDatabaseHandle handler = [query observeEventType:FIRDataEventTypeChildRemoved withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            completed(snapshot);
        }];
        
        [driverDeadHandler addObject:[NSNumber numberWithUnsignedInteger:handler]];
    }
}

- (void) removeDriverDeadListener {
    FIRDatabaseReference* ref = [self.ref child:TABLE_DRIVER_ONLINE];
    for (int i = 0; i < driverDeadHandler.count; i ++) {
        FIRDatabaseReference* refReal = [ref child:[NSString stringWithFormat:@"%d", i]];
        [refReal removeObserverWithHandle:[[driverDeadHandler objectAtIndex:i] integerValue]];
    }
}

- (void) listenerDriverLocationChanged: (NSString*) driverFirebaseId
                              callback: (void (^)(FCLocation * _Nullable))completed {
    
    @try {
        NSString* group = [NSString stringWithFormat:@"%ld", (long)[driverFirebaseId javaHashCode] % 10];
        FIRDatabaseReference* ref = [[[self.ref child:TABLE_DRIVER_ONLINE] child:group] child:driverFirebaseId];
        
        [ref observeEventType:FIRDataEventTypeChildChanged withBlock:^(FIRDataSnapshot * snapshot) {
            if ([snapshot.key isEqualToString:@"location"]) {
                FCLocation* lo = [[FCLocation alloc] initWithDictionary:snapshot.value
                                                                  error:nil];
                completed(lo);
            }
        }];
    }
    @catch (NSException* e) {
        
    }
}

- (void) getDriver: (NSString*) driverId handler:(void (^)(FCDriver*))completed  {
    @try {
        [self getUser:driverId
              handler:^(FCUser * user) {
                  FIRDatabaseReference* ref = [[self.ref child:TABLE_DRIVER] child:driverId];
                  [ref keepSynced:TRUE];
                  [ref observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * snapshot) {
                      NSError* error;
                      NSDictionary* dictionary = snapshot.value;
                      FCDriver* driver = [[FCDriver alloc] initWithDictionary:dictionary error:&error];
                      driver.user = user;
                      completed(driver);
                  }];
              }];
    }
    @catch (NSException* e) {
        
    }
    
}

- (void)findTrip:(NSString*)tripId handler:(void (^)(NSDictionary* value))completed {
    @try {
        FIRDatabaseReference* ref = [[self.ref child:TABLE_BOOK_TRIP] child:tripId];
        [ref keepSynced:TRUE];
        [ref observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * snapshot) {
            completed(snapshot.value);
        }];
    }
    @catch (NSException* e) {
        
    }
    
}

- (void) saveDriverToBackList:(FCDriver*) driver {
    
}

- (void) getLastLocationOfDriver: (NSString*) driverFirebaseId
                        callback: (void (^)(FCLocation * _Nullable))completed {
    @try {
        NSString* group = [NSString stringWithFormat:@"%ld", (long)[driverFirebaseId javaHashCode] % 10];
        if (group) {
            FIRDatabaseReference* ref = [[[[self.ref child:TABLE_DRIVER_ONLINE] child:group]   child:driverFirebaseId] child:@"location"];
            [ref keepSynced:TRUE];
            [ref observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
                NSError* err;
                FCLocation* lo = [[FCLocation alloc] initWithDictionary:snapshot.value error:&err];
                completed(lo);
            }];
        }
    }
    @catch (NSException* e) {}
}

- (void) getDriverKeepalive: (NSString*) firebaseId  handler:(void (^)(FCOnlineStatus*))completed {
    @try {
        NSString* groupid = [NSString stringWithFormat:@"%ld", (long)[firebaseId javaHashCode] % 10];
        FIRDatabaseReference* ref = [[[self.ref
                                       child:TABLE_DRIVER_ONLINE]
                                       child:groupid]
                                       child:firebaseId];
        [ref keepSynced:YES];
        [ref observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            if (snapshot.value) {
                FCOnlineStatus* keepalive = [[FCOnlineStatus alloc] initWithDictionary:snapshot.value error:nil];
                completed (keepalive);
            }
            else {
                completed (nil);
            }
        }];
    }
    @catch (NSException* e) {
        completed (nil);
    }
    @finally {}
}

#pragma mark - Driver KeepAlive

- (void) registerDriverRealtime: (NSArray*) drivers
                        handler: (void (^)(FIRDataSnapshot*, BOOL isOnline))completed {
    for (FCDriverSearch* driver in drivers) {
        [self listenerDriverRealtime: driver
                             handler:completed];
    }
}

- (void) listenerDriverRealtime: (FCDriverSearch*) driver
                        handler: (void (^)(FIRDataSnapshot*, BOOL isOnline))completed {
    @try {
        NSString* groupid = [NSString stringWithFormat:@"%ld", (long)[driver.firebaseId javaHashCode] % 10];
        FIRDatabaseReference* ref = [[[self.ref
                                        child:TABLE_DRIVER_ONLINE]
                                        child:groupid]
                                        child:driver.firebaseId];
        [ref keepSynced:YES];
        
        // for location changed
        [ref observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot* snapshot) {
            if (![snapshot.value isKindOfClass:[NSNull class]]) {
                completed(snapshot, TRUE);
            }
            else {
                // for offline
                completed(snapshot, FALSE);
            }
        }];
    }
    @catch (NSException* e) {
        
    }
    @finally {}
}

#pragma mark - Cars
- (void) getCarsDetail:(NSInteger) carId handler:(void (^)(FCMCar*))completed {
    FIRDatabaseReference* ref = [[self.ref child:TABLE_CARS] child:[NSString stringWithFormat:@"%ld", (long)carId]];
    [ref keepSynced:TRUE];
    [ref observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        DLog(@"Car's Info: %@", snapshot.value)
        NSError* err;
        FCMCar* car = [[FCMCar alloc] initWithDictionary:snapshot.value error:&err];
        completed(car);
    }];
}

- (void) getListCarType:(NSInteger) groupid handler:(void (^)(NSMutableArray *))completed {
    FIRDatabaseReference* ref = [[self.ref child:TABLE_MASTER] child:TABLE_CAR_TYPE];
    FIRDatabaseQuery* query = [[ref queryOrderedByChild:@"groupId"] queryEqualToValue:[NSNumber numberWithInteger:groupid]];
    [query keepSynced:TRUE];
    [query observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        DLog(@"---------- getListCarType: %@", snapshot.value)
        NSMutableArray* list = [[NSMutableArray alloc] init];
        for (FIRDataSnapshot* s in snapshot.children) {
            FCMCarType* car = [[FCMCarType alloc] initWithDictionary:s.value error:nil];
            if (car)
                [list addObject:car];
        }
        
        completed(list);
    }];
}

- (void) getCarType:(NSInteger) carTypeId handler:(void (^)(FCMCarType*))completed {
    FIRDatabaseReference* ref = [[[self.ref child:TABLE_MASTER] child:TABLE_CAR_TYPE] child:[NSString stringWithFormat:@"%ld", (long)carTypeId]];
    
    [ref keepSynced:TRUE];
    [ref observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        DLog(@"---------- getCarType: %@", snapshot.value)
        FCMCarType* car = [[FCMCarType alloc] initWithDictionary:snapshot.value error:nil];
        completed(car);
    }];
}

- (void) getListCarGroup:(void (^)(NSMutableArray *))completed {
    FIRDatabaseReference* ref = [[self.ref child:TABLE_MASTER] child:TABLE_CAR_GROUP];
    [ref keepSynced:TRUE];
    [ref observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        DLog(@"----------- getListCarGroup: %@", snapshot.value)
        NSMutableArray* list = [[NSMutableArray alloc] init];
        for (FIRDataSnapshot* s in snapshot.children) {
            FCMCarGroup* car = [[FCMCarGroup alloc] initWithDictionary:s.value error:nil];
            if (car)
                [list addObject:car];
        }
        
        completed(list);
    }];
}

- (void) setEvalute:(FCEvalute *)evalute {
    @try {
        FIRDatabaseReference* ref = [[self.ref child:TABLE_EVALUTION]
                                     child:evalute.bookingId];
        
        NSMutableDictionary* dict = [[NSMutableDictionary alloc] initWithDictionary:[evalute toDictionary]];
        [dict addEntriesFromDictionary:@{@"created":[FIRServerValue timestamp]}];
        
        [ref setValue:dict];
    }
    @catch (NSException* e) {
        
    }
    @finally {}
}

#pragma mark - Favorites
- (void) requestAddFavorite: (FCFavorite*) fav withCompletionBlock:(void (^)(NSError * error, FIRDatabaseReference * ref))block {
    @try {
        AppLog([FIRAuth auth].currentUser.uid)

        FIRDatabaseReference* ref = [[[self.ref child:TABLE_FAVORITE] child:[FIRAuth auth].currentUser.uid] child:fav.userFirebaseId];
        [ref setValue:[fav toDictionary] withCompletionBlock:block];
    }
    @catch(NSException* e) {
        
    }
}

- (void) removeFromFavoritelist: (FCFavorite*) favorite handler:(void (^)(NSError *__nullable error, FIRDatabaseReference * ref))block {
    AppLog([FIRAuth auth].currentUser.uid)

    FIRDatabaseReference* ref = [[[self.ref child:TABLE_FAVORITE] child:[FIRAuth auth].currentUser.uid] child:favorite.userFirebaseId];
    [ref removeValueWithCompletionBlock:block];
}

- (void) getFavoriteInfo: (NSString*) forDriver handler:(void (^)(FCFavorite * fav))block  {
    @try {
        AppLog([FIRAuth auth].currentUser.uid)

        FIRDatabaseReference* ref = [[[self.ref child:TABLE_FAVORITE] child:[FIRAuth auth].currentUser.uid] child:forDriver];
        [ref keepSynced:TRUE];
        [ref observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot* snapshot) {
            NSError* err;
            FCFavorite* fav = [[FCFavorite alloc] initWithDictionary:snapshot.value error:&err];
            block(fav);
        }];
    }
    @catch (NSException* e) {
        AppError(e)
    }
}

- (void) checkBlockDirverInfo: (NSString*) forDriver handler:(void (^)(FCFavorite * fav))block  {
    @try {
        AppLog([FIRAuth auth].currentUser.uid)
        
        FIRDatabaseReference* ref = [[[self.ref child:TABLE_FAVORITE] child:[FIRAuth auth].currentUser.uid] child:forDriver];
        [ref keepSynced:TRUE];
        [ref observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot* snapshot) {
            NSError* err;
            FCFavorite* fav = [[FCFavorite alloc] initWithDictionary:snapshot.value error:&err];
            if (fav == nil || fav.isFavorite == true) {
                block (nil);
            } else {
                block(fav);
            }
        }];
    }
    @catch (NSException* e) {
        AppError(e)
    }
}

- (void) getListFavorite:(void (^)(NSMutableArray*))completed {
    AppLog([FIRAuth auth].currentUser.uid)

    FIRDatabaseReference* ref = [[self.ref child:TABLE_FAVORITE] child:[FIRAuth auth].currentUser.uid];
    FIRDatabaseQuery* query = [ref queryLimitedToLast:50];
    [query keepSynced:TRUE];
    [query observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        DLog(@"------- GetListFavorite: %@", snapshot.value)
        
        NSMutableArray* list = [[NSMutableArray alloc] init];
        for(FIRDataSnapshot* s in snapshot.children) {
            FCFavorite* fav = [[FCFavorite alloc] initWithDictionary:s.value error:nil];
            if (fav && fav.isFavorite)
                [list addObject:fav];
        }
        completed(list);
    }];
}

#pragma mark - BackList

- (void) removeFromBacklist: (FCFavorite*) favorite handler:(void (^)(NSError *__nullable error, FIRDatabaseReference * ref))block {
    AppLog([FIRAuth auth].currentUser.uid)

    FIRDatabaseReference* ref = [[[self.ref child:TABLE_FAVORITE] child:[FIRAuth auth].currentUser.uid] child:favorite.userFirebaseId];
    [ref removeValue];
}

- (void) getListBackList:(void (^)(NSMutableArray*))completed  {
    AppLog([FIRAuth auth].currentUser.uid)
    
    FIRDatabaseReference* ref = [[self.ref child:TABLE_FAVORITE] child:[FIRAuth auth].currentUser.uid];
    FIRDatabaseQuery* query = [ref queryLimitedToLast:50];
    [query keepSynced:TRUE];
    [query observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        DLog(@"------- GetListFavorite: %@", snapshot.value)
        
        NSMutableArray* list = [[NSMutableArray alloc] init];
        for(FIRDataSnapshot* s in snapshot.children) {
            FCFavorite* fav = [[FCFavorite alloc] initWithDictionary:s.value error:nil];
            if (fav && !fav.isFavorite)
                [list addObject:fav];
        }
        completed(list);
    }];
}

#pragma mark - App Settings
- (void) getServerTime: (void (^)(NSTimeInterval)) block {
    FIRDatabaseReference *offsetRef = [[FIRDatabase database] referenceWithPath:@".info/serverTimeOffset"];
    [offsetRef observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot) {
        long long offset = [(NSNumber *)snapshot.value longLongValue];
        long long estimatedServerTimeMs = [[NSDate date] timeIntervalSince1970] * 1000 + offset;
        DLog(@"Estimated server time: %lld", estimatedServerTimeMs)
        if (block) {
            block(estimatedServerTimeMs/1000);
        }
    }
                withCancelBlock:^(NSError * _Nonnull error) {
                    
                }];
}

- (void) getAppSettings:(void (^)(FCSetting*))completed {
    FIRDatabaseReference* ref = [[[self.ref child:@"Settings"]
                                            child:@"Client"]
                                            child:@"IOS"];
    FIRDatabaseQuery* query = [[ref queryOrderedByChild:@"newest"] queryEqualToValue:[NSNumber numberWithBool:TRUE]];
    [query keepSynced:YES];
    [query observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        DLog(@"------- getAppSettings: %@", snapshot.value)
        for (FIRDataSnapshot* s in snapshot.children) {
            FCSetting* fav = [[FCSetting alloc] initWithDictionary:s.value error:nil];
            if (fav) {
                completed(fav);
                return;
            }
        }
        completed(nil);
    }];
}

- (void) getUserConfigs:(void (^)(FCConfigs* config))completed {
    FIRDatabaseReference* ref = [[[self.ref child:TABLE_APP_SETTINGS] child:@"Client"] child:@"Configs"];
    [ref keepSynced:TRUE];
    [ref observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        DLog(@"------- getAppConfigs: %@", snapshot.value)
        
        NSError* err;
        self.appConfigs = [[FCConfigs alloc] initWithDictionary:snapshot.value error:&err];
        completed(self.appConfigs);
        
    }];
}

#pragma MARK: - Services

- (void) getZoneById: (NSInteger) zoneId handler:(void (^)(FCZone*)) completed {
    FIRDatabaseReference* ref = [[[[self.ref child:TABLE_MASTER] child:TABLE_ZONE] child:@"0"] child:@"cities"];
    FIRDatabaseQuery* query = [[ref queryOrderedByChild:@"id"] queryEqualToValue:@(zoneId)];
    [query keepSynced:TRUE];
    [query observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        DLog(@"------- getZoneById: %@", snapshot.value)
        if (!snapshot.value) {
            completed(nil);
            return;
        }
        for (FIRDataSnapshot* s in snapshot.children) {
            NSError* err;
            FCZone* zone = [[FCZone alloc] initWithDictionary:s.value error:&err];
            if (zone) {
                completed(zone);
                return;
            }
        }
        
        completed(nil);
    }];
}

- (void) getZoneByLocation: (CLLocationCoordinate2D) location handler:(void (^)(FCZone*)) completed {
    FIRDatabaseReference* refZone = [[[[self.ref child:TABLE_MASTER] child:TABLE_ZONE] child:@"0"] child:@"cities"];
    [refZone keepSynced:YES];
    [refZone observeSingleEventOfType:FIRDataEventTypeValue
                            withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
                                if (snapshot.value) {
                                    BOOL has = NO;
                                    for (FIRDataSnapshot* s in snapshot.children) {
                                        NSString* polyline = [s.value valueForKey:@"polyline"];
                                        if (polyline.length > 0) {
                                            GMSPath *path =[GMSPath pathFromEncodedPath:polyline];
                                            if (GMSGeometryContainsLocation(location, path, NO)) {
                                                has = YES;
                                                FCZone* zone = [[FCZone alloc] initWithDictionary:s.value
                                                                                            error:nil];
                                                completed(zone);
                                                break;
                                            }
                                        }
                                    }
                                    
                                    if (!has) {
                                        completed (nil);
                                    }
                                }
                                else {
                                    completed (nil);
                                }
                            }];
}

- (void) getServices:(CLLocation*) atLocation
             handler:(void (^)(NSMutableArray*))completed {
    
    [self getZoneByLocation:atLocation.coordinate
                    handler:^(FCZone * zone) {
                        NSInteger cityid = ZONE_VN;
                        if (zone) {
                            cityid = zone.id;
                        }
                        
                        [self getService:cityid
                                  handle:completed];
                        
                    }];
}

- (void) getService: (NSInteger) cityid
             handle: (void (^)(NSMutableArray*))completed {
    FIRDatabaseReference* ref = [[[self.ref child:TABLE_MASTER]
                                  child:TABLE_SERVICE]
                                 child:[NSString stringWithFormat:@"%ld", (long)cityid]];
    [ref keepSynced:YES];
    [ref observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        DLog(@"------- getServices: %@", snapshot.value)
        
        NSMutableArray* lst = [[NSMutableArray alloc] init];
        for (FIRDataSnapshot* s in snapshot.children) {
            NSError* err;
            FCService* service = [[FCService alloc] initWithDictionary:s.value error:&err];
            if (service)
                [lst addObject:service];
        }
        
        if (lst.count == 0) {
            [self getService:ZONE_VN
                      handle:completed];
        }
        else {
            completed(lst);
        }
    }];
}

- (void) getPartners:(CLLocation*) atLocation
             handler:(void (^)(NSMutableArray*))completed {
    
    [self getZoneByLocation:atLocation.coordinate
                    handler:^(FCZone * zone) {
                        NSInteger cityid = ZONE_VN;
                        if (zone) {
                            cityid = zone.id;
                        }
                        
                        FIRDatabaseReference* ref = [[[self.ref child:TABLE_MASTER]
                                                      child:TABLE_PARTNER]
                                                     child:[NSString stringWithFormat:@"%ld", (long)cityid]];
                        [ref keepSynced:YES];
                        [ref observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
                            DLog(@"------- getPartners: %@", snapshot.value)
                            
                            NSMutableArray* lst = [[NSMutableArray alloc] init];
                            for (FIRDataSnapshot* s in snapshot.children) {
                                NSError* err;
                                FCPartner* partner = [[FCPartner alloc] initWithDictionary:s.value error:&err];
                                if (partner && partner.group_id >= 1000 && partner.group_id <= 10000) // phai la taxi moi duoc add vao pảrtner search ([1000, 10000])
                                    [lst addObject:partner];
                            }
                            
                            completed(lst);
                        }];
                        
                    }];
}


- (void)getPunishmentForTrip:(FCBookInfo*)trip
              withCompletion:(void (^)(CGFloat))completed
{
    [self getPunishment:trip.zoneId
                service:trip.serviceId
         withCompletion:completed];
}

- (void) getPunishment: (NSInteger) zone
               service: (NSInteger) service
        withCompletion: (void (^)(CGFloat))completed {
    @try {
        FIRDatabaseReference* ref = [[[self.ref child:TABLE_MASTER]
                                      child:TABLE_PUNISHMENT]
                                     child:[NSString stringWithFormat:@"%ld", zone]];
        FIRDatabaseQuery* query = [[ref queryOrderedByChild:@"refer"] queryEqualToValue:@(service)];
        [query keepSynced:YES];
        [query observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot* snapshot) {
            if (snapshot && snapshot.value)
            {
                DLog(@"getPunishmentForTrip: %@", snapshot.value);
                
                for (FIRDataSnapshot* s in snapshot.children) {
                    FCFee* fee = [[FCFee alloc] initWithDictionary:s.value
                                                             error:nil];
                    if (fee) {
                        completed(fee.fee * 1.0f/ 100.0f);
                        return;
                    }
                }
            }
            
            // default
            [self getPunishment:ZONE_VN
                        service:service
                 withCompletion:completed];
            
        }];
    }
    @catch (NSException* e) {
        
    }
}


- (void) getShipService: (void (^)(NSMutableArray* list)) handler {
    FIRDatabaseReference* ref = [[[self.ref child:TABLE_MASTER]
                                  child:TABLE_SHIP_SERVICE]
                                 child:[NSString stringWithFormat:@"%d", 1]];
    [ref keepSynced:YES];
    [ref observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot* snapshot) {
        DLog(@"------- getShipService: %@", snapshot.value)
        
        NSMutableArray* lst = [[NSMutableArray alloc] init];
        for (FIRDataSnapshot* s in snapshot.children) {
            NSError* err;
            FCShipService* service = [[FCShipService alloc] initWithDictionary:s.value
                                                                         error:&err];
            if (service &&  service.enable) {
                [lst addObject:service];
            }
        }
        
        handler(lst);
    }];
}

- (void) getAppConfigure:(void (^)(FCAppConfigure *))completed {
    @try {
        if (self.appConfigure) {
            completed(self.appConfigure);
            return;
        }
        
        FIRDatabaseReference* ref = [[self.ref child:TABLE_MASTER]
                                      child:TABLE_APP_CONFIGURE];
        [ref keepSynced:YES];
        [ref observeEventType:FIRDataEventTypeValue
                    withBlock:^(FIRDataSnapshot* snapshot) {
                        if (snapshot && snapshot.value)
                        {
                            DLog(@"getAppConfigure: %@", snapshot.value);
                            self.appConfigure = nil;
                            
                            FCAppConfigure* configure = [[FCAppConfigure alloc] initWithDictionary:snapshot.value error:nil];
                            
                            self.appConfigure = configure;
                            completed(configure);
                        }
            
        }];
    }
    @catch (NSException* e) {
        
    }
}

- (void) getPriceAdditional: (void (^) (NSMutableArray* list)) block {
    [self getAppConfigure:^(FCAppConfigure * appconfigure) {
        if (appconfigure.booking_price_additional.count > 0) {
            NSMutableArray* arr = [[NSMutableArray alloc] init];
            for (FCPriceAddition* price in appconfigure.booking_price_additional) {
                if (price.active) {
                    [arr addObject:price];
                }
            }
            block(arr);
        }
        else {
            block(nil);
        }
    }];
}

- (BOOL) isInPeakHours {
    if (self.appConfigure.peak_hours.count > 0) {
        NSString* time = [self getTimeString:[self getCurrentTimeStamp]
                                  withFormat:@"HHmmss"];
        NSInteger timeInt = [time integerValue];
        for (FCPeakHours* h in self.appConfigure.peak_hours) {
            if (timeInt >= h.start && timeInt <= h.end) {
                return YES;
            }
        }
    }
    
    return NO;
}

- (void) getInviteContent:(void (^)(FCMInvite *))completed {
    @try {
        FIRDatabaseReference* ref = [[[self.ref child:TABLE_MASTER]
                                      child:TABLE_CAMPAIGNS] child:@"Invite"];
        [ref keepSynced:YES];
        [ref observeEventType:FIRDataEventTypeValue
                    withBlock:^(FIRDataSnapshot* snapshot) {
                        if (snapshot && snapshot.value)
                        {
                            DLog(@"getInviteContent: %@", snapshot.value);
                            
                            FCMInvite* invite = [[FCMInvite alloc] initWithDictionary:snapshot.value
                                                                                   error:nil];
                            completed(invite);
                        }
                        
                    }];
    }
    @catch (NSException* e) {
        
    }
}

- (void) resetMapKeys {
    self.googleKeys = nil;
}

- (void) getGoogleMapKeys: (void (^)(NSString* key)) block {
    @try {
        if (self.googleKeys.length > 0) {
            if (block) {
                block(self.googleKeys);
            }
            return;
        }
        
        FIRDatabaseReference* ref = [[[self.ref child:TABLE_MASTER]
                                                child:TABLE_APP_CONFIGURE]
                                                child:@"google_api_keys"];
        [ref keepSynced:YES];
        [ref observeEventType:FIRDataEventTypeValue
                    withBlock:^(FIRDataSnapshot* snapshot) {
                        
                        // Nếu keys settings có thay đổi thì reset ngay -> get key mới
                        [self resetMapKeys];
                        
                        if (snapshot && snapshot.value) {
                            DLog(@"getListGoogleMapKeys: %@", snapshot.value);
                            NSMutableArray* list = [[NSMutableArray alloc] init];
                            for (FIRDataSnapshot* s in snapshot.children) {
                                FCGoogleKey* invite = [[FCGoogleKey alloc] initWithDictionary:s.value
                                                                                        error:nil];
                                if (invite && invite.active) {
                                    [list addObject:invite];
                                }
                            }
                            
                            if (list.count > 0) {
                                int index = arc4random() % list.count;
                                FCGoogleKey* keyObj = [list objectAtIndex:index];
                                NSString* key = keyObj.key;
                                self.googleKeys = key;
                                DLog(@"Result GoogleMapKeys: %@", key);
                                
                                if (block) {
                                    block(key);
                                }
                            }
                        }
                    }];
    }
    @catch (NSException* e) {
        
    }
}

#pragma mark -

- (void) getAllFare: (void (^)(NSMutableArray* list)) block {
    FIRDatabaseReference* ref = [[self.ref child:TABLE_MASTER] child:TABLE_FARE_SETTING];
    [ref keepSynced:TRUE];
    [ref observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * snapshot) {
        NSMutableArray* receipts = [[NSMutableArray alloc] init];
        for (FIRDataSnapshot* snap in snapshot.children) {
            FCFareSetting* receipt = [[FCFareSetting alloc] initWithDictionary:snap.value error:nil];
            if (receipt && receipt.active) {
                [receipts addObject:receipt];
            }
        }
        
        block(receipts);
    }];
}


- (void) getFareDetail: (NSInteger) service
              tripType: (NSInteger) type
            atLocation: (CLLocation*) location
               handler: (void (^)(FCFareSetting*))completed {
    [self getZoneByLocation:location.coordinate  handler:^(FCZone * zone) {
        NSInteger zoneId = ZONE_VN;
        if (zone) {
            zoneId = zone.id;
        }
        
        [self getFareDetail:service tripType:type zone:zoneId handler:completed];
    }];
}


- (void) getFareDetail: (NSInteger) service
              tripType: (NSInteger) type
                  zone: (NSInteger) zoneId
               handler: (void (^)(FCFareSetting*))completed {
    [self getAllFare:^(NSMutableArray *list) {
        NSArray* arr = [list filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(FCFareSetting* r, NSDictionary<NSString *,id> * _Nullable bindings) {
            if (!r.active) {
                return NO;
            }
            
            if (r.zoneId != zoneId) {
                return NO;
            }
            
            if (r.service != service) {
                return NO;
            }
            
            NSArray* tripTypes = [TripTypeUtil splitTripType:r.tripType];
            if (![tripTypes containsObject:@(type)]) {
                return NO;
            }
            
            return TRUE;
        }]];
        
        FCFareSetting* result = nil;
        if (arr.count > 0) {
            result = [[arr sortedArrayUsingComparator:^NSComparisonResult(FCFareSetting*  obj1, FCFareSetting* obj2) {
                return obj1.priority < obj2.priority;
            }] firstObject];
        }
        
        if (result) {
            completed(result);
        }
        else {
            [self getFareDetail:service tripType:type zone:ZONE_VN handler:completed];
        }
    }];
}

- (void) getListFareByLocation: (CLLocation*) atlocation
                       handler: (void (^)(NSArray*))completed {
    [self getZoneByLocation:atlocation.coordinate
                    handler:^(FCZone * zone) {
                        NSInteger zoneId = ZONE_VN;
                        if (zone) {
                            zoneId = zone.id;
                        }
                        
                        [self getListFareByZoneId:zoneId
                                           handler:completed];
                        
                    }];
}

- (void) getListFareByZoneId: (NSInteger) zoneId
                     handler: (void (^)(NSArray*))completed {
    [self getAllFare:^(NSMutableArray *list) {
        NSArray* arr = [list filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(FCFareSetting* r, NSDictionary<NSString *,id> * _Nullable bindings) {
            if (!r.active) {
                return NO;
            }
            
            if (r.zoneId != zoneId) {
                return NO;
            }
            
            // id = 4 is digital trip
            if (r.tripType == 4) {
                return NO;
            }
            
            return TRUE;
        }]];
        
        if (arr.count > 0) {
            completed (arr);
        }
        else {
            [self getListFareByZoneId:ZONE_VN
                               handler:completed];
        }
    }];
}



- (void)authenWithPhone:(NSString * _Nonnull)phone complete:(void (^ _Nonnull)(NSString * _Nonnull))complete error:(void (^ _Nonnull)(NSError * _Nonnull))error {
    [[FIRPhoneAuthProvider provider] verifyPhoneNumber:phone
                                            UIDelegate:nil
                                            completion:^(NSString* verificationID, NSError* e) {
                                                DLog(@"timestampe 2: %f", [self getCurrentTimeStamp])
                                                
                                                if (e) {
                                                    DLog(@"[Login] getSMSPasscode: %@", error);
                                                    error(e);
                                                }
                                                else {
                                                    complete(verificationID ?: @"");
                                                }
                                            }];
}
- (void)authenWithOtp:(NSString * _Nonnull)otp use:(NSString * _Nonnull)verify complete:(void (^ _Nonnull)(id <UserProtocol> _Nullable))complete error:(void (^ _Nonnull)(NSError * _Nonnull))error {
    FIRPhoneAuthCredential* phoneCredential = [[FIRPhoneAuthProvider provider] credentialWithVerificationID:verify
                                                                                           verificationCode:otp];
    
    [[FIRAuth auth] signInAndRetrieveDataWithCredential:phoneCredential
                                             completion:^(FIRAuthDataResult * _Nullable authResult, NSError * _Nullable e) {
                                                 DLog(@"[Login] verifySMSPassCode: %@", e);
                                                 if (e) {
                                                     error(e);
                                                     return;
                                                 }
                                                 
                                                 complete(authResult.user);
                                             }];
    
}
- (void)authenWithCustomToken:(NSString * _Nonnull)customToken complete:(void (^ _Nonnull)(id <UserProtocol> _Nullable))complete error:(void (^ _Nonnull)(NSError * _Nonnull))error {
    [[FIRAuth auth] signInWithCustomToken:customToken completion:^(FIRAuthDataResult * _Nullable authResult, NSError * _Nullable e) {
        if (e) {
            error(e);
            return;
        }
        complete(authResult.user);
    }];
}

- (void)authenTrackingWithService:(NSInteger)type {
    self.authService = type;
}

- (NSString*) getAuthServiceName {
    return self.authService == 0 ? @"Firebase" : @"Vato";
}

- (void) removeClientCurrentTrip {
    [self.ref removeClientCurrentTripWithClientFirebaseId:[FIRAuth auth].currentUser.uid];
}

- (void) writeClientCurrentTrip:(NSString *)tripId {
    [self.ref writeClientCurrentTripWithClientFirebaseId:[FIRAuth auth].currentUser.uid
                                                  tripId:tripId];
}
- (void) writeClientCurrentRating:(FCBookInfo *)bookInfo {
    [self.ref writeCurrentRatingTripWithClientFirebaseId:[FIRAuth auth].currentUser.uid
                                                    info:bookInfo];
}


- (void) removeCurrentRating {
    [self.ref removeClientCurrentRatingWithClientFirebaseId:[FIRAuth auth].currentUser.uid];
}

@end
