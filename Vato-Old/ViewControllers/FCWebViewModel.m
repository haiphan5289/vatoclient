//
//  FCWebViewModel.m
//  FC
//
//  Created by facecar on 5/8/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCWebViewModel.h"


@implementation FCWebViewModel

- (instancetype) initWithUrl:(NSString *)url {
    self = [super init];
    if (self) {
        self.url = url;   
    }
    
    return self;
}
@end
