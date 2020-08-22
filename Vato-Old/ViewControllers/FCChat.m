
//
//  FCChat.m
//  FaceCar
//
//  Created by facecar on 3/1/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#import "FCChat.h"

@implementation FCChat
- (BOOL)isEqual:(id)object {
    FCChat *other = [FCChat castFrom:object];
    if (!other) return NO;
    return self.id == other.id && self.time == other.time;
}
@end
