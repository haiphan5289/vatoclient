//
//  FCHomeSubMenuItem.h
//  FaceCar
//
//  Created by facecar on 12/16/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCView.h"

@interface FCHomeSubMenuItem : FCView

- (void) itemWithIcon: (NSArray*) icon // select and normal icon
                lable: (NSArray*) lbl // select and normal lbls
                click: (void (^)(void)) block;

- (void) showBadge: (NSInteger) count;
@end
