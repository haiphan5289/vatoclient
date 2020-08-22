//  File name   : VatoChangeAppIcon.h
//
//  Author      : Dung Vu
//  Created date: 1/9/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

@import Foundation;

@interface VatoChangeAppIcon : NSObject
+ (void)changeAppIconWithName:(NSString  * _Nullable )iconName completion:(void (^_Nullable)(BOOL changed))completion;
@end

