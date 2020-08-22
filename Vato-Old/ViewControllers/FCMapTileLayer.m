//
//  FCMapTileLayer.m
//  FaceCar
//
//  Created by facecar on 12/20/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCMapTileLayer.h"

@implementation FCMapTileLayer

- (UIImage *)tileForX:(NSUInteger)x y:(NSUInteger)y zoom:(NSUInteger)zoom {
    if (x % 2) {
        return [UIImage imageNamed:@"australia"];
    }
    else {
        return kGMSTileLayerNoTile;
    }
}
@end
