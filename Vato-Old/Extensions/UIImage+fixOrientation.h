//
//  UIImage+fixOrientation.h
//  FaceCar
//
//  Created by facecar on 4/21/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIImage (fixOrientation)
- (UIImage *)fixOrientation;
- (UIImage *)scaledToSize:(CGSize)size;
@end
