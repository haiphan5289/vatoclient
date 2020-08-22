//
//  FCChatViewModel.m
//  FaceCar
//
//  Created by facecar on 3/1/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#import "FCChatViewModel.h"
#import "FirebasePushHelper.h"

@implementation FCChatViewModel

- (id) init {
    self = [super init];
    if (self) {
        self.listChats = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void) startChat {
    @weakify(self);
    [self getAllChat:^(NSMutableArray *chats) {
        @strongify(self);
        [self listenerNewMessage:nil];
    }];
    
    
}

- (void) sendPushForChat: (FCChat*) chat {
    [[FirebaseHelper shareInstance] getDriver:_booking.driverFirebaseId
                                      handler:^(FCDriver * driver) {
                                          if (driver.deviceToken.length > 0) {
                                              [FirebasePushHelper sendPushTo:driver.deviceToken
                                                                        type:NotifyTypeChatting
                                                                       title:[NSString stringWithFormat:@"Tin nhắn từ khách hàng"]
                                                                     message:chat.message];
                                          }
                                      }];
}

- (FCChat*) sendMessage:(NSString *)message {
    FCChat* chat = [[FCChat alloc] init];
    chat.message = message;
    chat.sender = [NSString stringWithFormat:@"c~%ld", (long)_booking.clientUserId];
    chat.receiver = [NSString stringWithFormat:@"d~%ld", (long)_booking.driverUserId];
    chat.id = [self getCurrentTimeStamp];
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] initWithDictionary:[chat toDictionary]];
    [dict addEntriesFromDictionary:@{@"time":[FIRServerValue timestamp]}];
    FIRDatabaseReference* ref = [[[FirebaseHelper shareInstance].ref
                                  child:TABLE_CHATS]
                                 child:_booking.tripId].childByAutoId;
    [ref setValue:dict];
    [self.listChats insertObject:chat
                         atIndex:0];
    [self sendPushForChat:chat];
    return chat;
}

- (void) getAllChat:(void (^)(NSMutableArray *))handler {
    FIRDatabaseReference* ref = [[[FirebaseHelper shareInstance].ref
                                  child:TABLE_CHATS]
                                 child:_booking.tripId];
    [ref keepSynced:YES];
    [[ref queryLimitedToLast:100] observeSingleEventOfType:FIRDataEventTypeValue
                                                 withBlock:^(FIRDataSnapshot * snapshot) {
                                                     NSMutableArray* list = [[ NSMutableArray alloc] init];
                                                     for (FIRDataSnapshot* s in snapshot.children) {
                                                         FCChat* chat = [[FCChat alloc] initWithDictionary:s.value
                                                                                                     error:nil];
                                                         if (chat) {
                                                             [list insertObject:chat atIndex:0];
                                                         }
                                                     }
                                                     self.listChats = list;
                                                     handler(list);
                                                 }];
}

- (RACSignal *)listenNewChat {
    FIRDatabaseReference* ref = [[[FirebaseHelper shareInstance].ref
     child:TABLE_CHATS]
    child:_booking.tripId];
    [ref keepSynced:YES];
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        FIRDatabaseHandle handle = [ref observeEventType:FIRDataEventTypeChildAdded
                    withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            NSLog(@"!!!New %@ !!!!", snapshot.value);
            [subscriber sendNext:snapshot];
        }];
        
        return [RACDisposable disposableWithBlock:^{
            [ref removeObserverWithHandle:handle];
        }];
    }];
}

- (void) listenerNewMessage:(void (^)(FCChat *))handler {
    @weakify(self);
    [[[[self listenNewChat] bufferWithTime:1 onScheduler:[RACScheduler mainThreadScheduler]] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSArray<FIRDataSnapshot *> *values) {
        @strongify(self);
        if ([values count] == 0) {
            return;
        }
        NSInteger index = 0;
        NSMutableArray<NSIndexPath *> *indexPaths = [NSMutableArray new];
        
        for (FIRDataSnapshot* child in values) {
            FCChat* chat = [[FCChat alloc] initWithDictionary:child.value error:nil];
            if (!chat || [self.listChats containsObject:chat] || [chat.sender containsString:@"c"]) {
                continue;
            }
            [self.listChats insertObject:chat atIndex:0];
            [indexPaths addObject:[NSIndexPath indexPathForRow:index inSection:0]];
            index += 1;
        }

        NSInteger lenght = [indexPaths count];
        if (lenght == 0) {
            return;
        };
        self.chat = self.listChats.firstObject;
        NSLog(@"!!!!Changes %ld", (long)index);
        if (self.changes) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.changes(indexPaths);
            });
        }
    }];
}

@end
