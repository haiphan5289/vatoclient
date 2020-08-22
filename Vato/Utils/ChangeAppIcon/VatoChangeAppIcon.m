#import "VatoChangeAppIcon.h"
@import UIKit;
@implementation VatoChangeAppIcon

#pragma mark - Class's constructors
- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

#pragma mark - Class's public methods

+ (void)changeAppIconWithName:(NSString *)iconName completion:(void (^)(BOOL changed))completion {
    if ([iconName length] == 0) {
        if (completion) {
            completion(NO);
        }
        return;
    }
    
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(supportsAlternateIcons)] &&
        [[UIApplication sharedApplication] supportsAlternateIcons])
    {
        
        @try {
            NSMutableString *selectorString = [[NSMutableString alloc] initWithCapacity:40];
            [selectorString appendString:@"_setAlternate"];
            [selectorString appendString:@"IconName:"];
            [selectorString appendString:@"completionHandler:"];

            SEL selector = NSSelectorFromString(selectorString);
            IMP imp = [[UIApplication sharedApplication] methodForSelector:selector];
            void (*func)(id, SEL, id, id) = (void *)imp;
            if (func)
            {
                func([UIApplication sharedApplication], selector, iconName, ^(NSError * _Nullable error) {});
                if (completion) {
                    completion(YES);
                }
            } else {
                if (completion) {
                    completion(NO);
                }
            }
        } @catch (NSException *exception) {
            NSLog(@"%@", exception.reason ?: @"");
            if (completion) {
                completion(NO);
            }
        } @finally {}
        
    } else {
        if (completion) {
            completion(NO);
        }
    }
}

@end

