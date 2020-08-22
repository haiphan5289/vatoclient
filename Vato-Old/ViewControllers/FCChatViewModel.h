//
//  FCChatViewModel.h
//  FaceCar
//
//  Created by facecar on 3/1/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FCChat.h"
typedef void(^BlockChangeIndexs)(NSArray<NSIndexPath *> *indexs);
@interface FCChatViewModel : NSObject

@property (strong, nonatomic) FCBookInfo* booking;
@property (strong, nonatomic) FCChat* chat;
@property (assign, nonatomic) NSInteger noChats;
@property (strong, nonatomic) NSMutableArray* listChats;
@property (copy, nonatomic) BlockChangeIndexs changes;

- (void) startChat;

- (FCChat*) sendMessage: (NSString*) message;

- (void) getAllChat: (void (^)(NSMutableArray* chats)) handler;
- (void) listenerNewMessage: (void (^)(FCChat* chat)) handler;

@end