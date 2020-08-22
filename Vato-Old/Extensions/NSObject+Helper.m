//
//  NSObject.m
//  FaceCar
//
//  Created by Vu Dang on 6/6/16.
//  Copyright © 2016 Vu Dang. All rights reserved.
//

#import "NSObject+Helper.h"
#import "AppDelegate.h"
#import "libPhoneNumberiOS.h"
#import "AFNetworkReachabilityManager.h"

static AVAudioPlayer *audioPlayer;
@implementation NSObject (Helper)

#pragma mark -
- (void) saveAppVersion :(NSString*) version {
    [[NSUserDefaults standardUserDefaults] setObject:version forKey:@"current_version"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString*) getCurrentAppVersion {
    NSString* version = [[NSUserDefaults standardUserDefaults] valueForKey:@"current_version"];
    return version;
}

#pragma mark -

- (BOOL) giftAvailable: (FCGift*) gift
                client: (FCClient*) client {
    
    if (!gift) {
        return NO;
    }
    
    // het so luong su dung
    if (gift.counter >= gift.max_apply) {
        return NO;
    }
    
    // het han
    long long time = (long long)[self getCurrentTimeStamp];
    if (time > gift.end || time < gift.start) {
        return NO;
    }
    
    if (gift.zone_id != ZONE_VN && gift.zone_id != client.zoneId) {
        return NO;
    }
    
    if (gift.activated_codes != 0 && gift.activated_codes <= gift.number_of_applied ) {
        return NO;
    }
    
    return YES;
}

- (BOOL) isNetworkAvailable {
    AFNetworkReachabilityStatus st = [[AFNetworkReachabilityManager sharedManager] networkReachabilityStatus];
    if (st == AFNetworkReachabilityStatusNotReachable ||
        st == AFNetworkReachabilityStatusUnknown) {
        return FALSE;
    }
    return TRUE;
}

- (void) circleImageview : (UIImageView*) imageview {
    [imageview layoutIfNeeded];
    imageview.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    imageview.layer.borderWidth = 1.0f;
    imageview.layer.cornerRadius = imageview.frame.size.width/2;
    imageview.clipsToBounds = YES;
}

- (void) playsound: (NSString*) soundname {
    NSString *soundPath = [[NSBundle mainBundle] pathForResource:soundname ofType:@"mp3"];
    SystemSoundID soundID;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath: soundPath], &soundID);
    AudioServicesPlaySystemSound(soundID);
}

- (void) playsound:(NSString *)soundname
            ofType:(NSString*) type
        withVolume:(CGFloat)volume
            isLoop:(BOOL)loop {
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    NSURL* musicFile = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:soundname ofType:type]];
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:musicFile error:nil];
    if (loop)
    {
        audioPlayer.numberOfLoops = -1;
    }
    else
    {
        audioPlayer.numberOfLoops = 0;
    }
    
    [audioPlayer setVolume:volume];
    [audioPlayer prepareToPlay];
    [audioPlayer play];
}

- (void) playsound:(NSString *)soundname withVolume:(CGFloat)volume isLoop:(BOOL)loop
{
    [self playsound:soundname
             ofType:@"mp3"
         withVolume:volume
             isLoop:loop];
}


- (double) getCurrentTimeStamp {
    return [[NSDate date] timeIntervalSince1970] * 1000;
}

- (CGSize)findHeightForText:(NSString *)text havingWidth:(CGFloat)widthValue andFont:(UIFont *)font {
    CGSize size = CGSizeZero;
    if (text) {
        //iOS 7
        CGRect frame = [text boundingRectWithSize:CGSizeMake(widthValue, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName:font } context:nil];
        size = CGSizeMake(frame.size.width, frame.size.height + 1);
    }
    return size;
}

- (NSString*) getTimeString:(double)timeStamp {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeStamp/1000.0];
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"HH:mm dd/MM/yyyy";
    return [dateFormatter stringFromDate:date];
}

- (NSString*) getDateTimeString:(double)timeStamp {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeStamp/1000.0];
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"dd/MM/yyyy";
    return [dateFormatter stringFromDate:date];
}

- (NSString*) getTimeString:(long long) timeStamp withFormat: (NSString*) format {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeStamp/1000.0];
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = format;
    return [dateFormatter stringFromDate:date];
}

- (NSString*) getTimeStringByDate:(NSDate*)date {
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"dd/MM/yyyy";
    return [dateFormatter stringFromDate:date];
}

- (double) getTimestampOfDate:(NSDate *)date
{
    if (date != nil)
    {
        return [date timeIntervalSince1970] * 1000;
    }
    
    return -1;
}

- (CLLocationDistance) getDistance:(CLLocation*) from fromMe: (CLLocation*) to {
    CLLocationDistance distance = [to distanceFromLocation:from];
    
//    DLog(@"--------- Distance from (%f, %f) - to (%f, %f): %f",from.coordinate.latitude, from.coordinate.longitude, to.coordinate.latitude, to.coordinate.longitude, distance/1000.0f)
    
    return distance;
}

- (CLLocationDistance) getDistanceByCoordinate:(CLLocationCoordinate2D) from fromMe: (CLLocationCoordinate2D) to {
    CLLocation* f = [[CLLocation alloc] initWithLatitude:from.latitude longitude:from.longitude];
    CLLocation* t = [[CLLocation alloc] initWithLatitude:to.latitude longitude:to.longitude];

    CLLocationDistance distance = [t distanceFromLocation:f];
    
    //    DLog(@"--------- Distance from (%f, %f) - to (%f, %f): %f",from.coordinate.latitude, from.coordinate.longitude, to.coordinate.latitude, to.coordinate.longitude, distance/1000.0f)
    
    return distance;
}

- (__autoreleasing NSString *)getAppVersion {
    __autoreleasing NSDictionary<NSString*,id> *info = [[NSBundle mainBundle] infoDictionary];
    __autoreleasing NSString *version = (NSString*) info[@"CFBundleShortVersionString"];
    return version;
}

- (__autoreleasing NSString *)getBundleIdentifier {
    __autoreleasing NSDictionary<NSString*,id> *info = [[NSBundle mainBundle] infoDictionary];
    __autoreleasing NSString *bundleIdentifier = (NSString*) info[@"CFBundleIdentifier"];
    return bundleIdentifier;
}

- (NSString*) getDeviceId {
    return [[UIDevice currentDevice].identifierForVendor UUIDString];
}

- (void) callPhone: (NSString*) phone {
    NSURL *phoneUrl = [NSURL URLWithString:[NSString  stringWithFormat:@"telprompt:%@",phone]];
    
    if ([[UIApplication sharedApplication] canOpenURL:phoneUrl]) {
        [[UIApplication sharedApplication] openURL:phoneUrl];
    } else
    {
        UIAlertView* calert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Call facility is not available!!!" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
        [calert show];
    }
}

- (BOOL) validPhone :(NSString*) phone {
    NBPhoneNumberUtil *phoneUtil = [NBPhoneNumberUtil sharedInstance];
    NSError *anError = nil;
    NBPhoneNumber *myNumber = [phoneUtil parse:phone
                                 defaultRegion:@"VN" error:&anError];
    if (!anError) {
        NSString* national = [phoneUtil format:myNumber
                                  numberFormat:NBEPhoneNumberFormatNATIONAL
                                         error:&anError]; // = 902xxx (phone is 0902xxx)
        national = [national stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSLog(@"NATIONAL : %@", national);
        // prevent enter 11 numbers
        if (national.length > 10) {
            return NO;
        }
        return [phoneUtil isValidNumber:myNumber];
    }
    
    return NO;
}

- (BOOL)validatePhone:(NSString *)phoneNumber
{
    NSString *phoneRegex = @"((\\+84)|([0-9]{1}))[0-9]{9,11}";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
    
    return [phoneTest evaluateWithObject:phoneNumber];
}

- (BOOL) validEmail :(NSString*) email {
    email = [email stringByReplacingOccurrencesOfString:@" " withString:@""];
    BOOL stricterFilter = YES;
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    BOOL result = [emailTest evaluateWithObject:email];
    
    return result;
}

- (NSString*) convertAccessString : (NSString*)input {
    DLog(@"-------- Input: %@", input)
    
    NSData *data = [input dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *newStr = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    
    DLog(@"-------- Output: %@", newStr)
    return newStr;
}

- (NSString*) formatPrice :(long) _priceNum {
    /*
    NSNumberFormatter* priceFormat = [[NSNumberFormatter alloc] init];
    priceFormat.currencyCode = @"VND";
    priceFormat.currencySymbol = @"";
    [priceFormat setNumberStyle:NSNumberFormatterCurrencyStyle];
    NSString* priceStr = [priceFormat stringFromNumber:[NSNumber numberWithLong:_priceNum]];
    return [NSString stringWithFormat:@"%@đ",priceStr];
    */
    return [@(_priceNum) money];
}

- (NSString*) formatPrice:(long)priceNum withSeperator:(NSString *)seperator
{
    NSNumberFormatter* priceFormat = [[NSNumberFormatter alloc] init];
    [priceFormat setNumberStyle:NSNumberFormatterDecimalStyle];
    [priceFormat setGroupingSize:3];
    [priceFormat setGroupingSeparator:seperator];
    return [priceFormat stringFromNumber:[NSNumber numberWithLong:priceNum]];
}


- (NSInteger) getPrice : (NSString*) str {
    NSCharacterSet *notAllowedChars = [[NSCharacterSet characterSetWithCharactersInString:@"-1234567890"] invertedSet];
    NSString *resultString = [[str componentsSeparatedByCharactersInSet:notAllowedChars] componentsJoinedByString:@""];
    NSLog (@"Result: %@", resultString);
    return resultString.integerValue;
}

- (long) caculatePrice : (FCFareSetting*) receipe
               distance: (long) distance
               duration: (long) duration
               timeWait: (long) wait {
    long    perkm, // don gia / km
    limitedperkm,
    perHour,// don gia / 1 gio
    perMinute, // don gia di chuyen / 1 phut
    TienTime = 0,
    TienKM,
    FirstKM,
    //TienThoiGianDuKien,
    TongTien,
    tempPerTime = 0;
    double  kms, // tong so km
    //estimateTime, // thoi gian di (tinh bang phut)
    waitTimes; // thoi gian cho (tinh bang gio)
    kms = distance/1000.0; // tong km di
    waitTimes = wait/(1000*3600); // thoi gian cho tinh bang gio
    //estimateTime = trip.duration / 60.0; // phut
    perkm = receipe.perKm;
//    limitedperkm = perkm * 70 / 100;
    
    perHour = receipe.perHour;
    perMinute = receipe.perMin;
    
    FirstKM = receipe.firstKm; //gia mo cua

    TienKM = FirstKM + (long) (kms * perkm);
    
    for (int i = 0; i < waitTimes; i++)
    {
        if (i < 5)            {
            tempPerTime = perHour - perHour * i / 10;
            TienTime = (long)(TienTime + tempPerTime);
        }
        else
        {
            TienTime = TienTime + tempPerTime;
        }
    }
    
    TongTien = TienKM + TienTime + duration/60*perMinute;
    int TempTongTien = (int) TongTien / 1000;
    TongTien = TempTongTien * 1000;
    
    long result = TongTien + TongTien * receipe.percent/100;
    return result > receipe.min ? result : receipe.min;
}

#pragma mark - Base
- (NSString*) formatNumber:(NSUInteger)n toBase:(NSUInteger)base
{
    NSString *alphabet = @"0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"; // 62 digits
    NSAssert([alphabet length]>=base,@"Not enough characters. Use base %ld or lower.",(unsigned long)[alphabet length]);
    return [self formatNumber:n usingAlphabet:[alphabet substringWithRange:NSMakeRange (0, base)]];
}

- (NSString*) formatNumber:(NSUInteger)n usingAlphabet:(NSString*)alphabet
{
    NSUInteger base = [alphabet length];
    if (n<base){
        // direct conversion
        NSRange range = NSMakeRange(n, 1);
        return [alphabet substringWithRange:range];
    } else {
        return [NSString stringWithFormat:@"%@%@",
                
                // Get the number minus the last digit and do a recursive call.
                // Note that division between integer drops the decimals, eg: 769/10 = 76
                [self formatNumber:n/base usingAlphabet:alphabet],
                
                // Get the last digit and perform direct conversion with the result.
                [alphabet substringWithRange:NSMakeRange(n%base, 1)]];
    }
}

- (BOOL) isPhoneX {
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone && UIScreen.mainScreen.nativeBounds.size.height == 2436)  {
        return YES;
    }
    
    return NO;
}

- (BOOL) isIpad {
    if ([(NSString*)[UIDevice currentDevice].model hasPrefix:@"iPad"]) {
        return YES;
    }
    
    return NO;
}

- (void) openWifiSettings {
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
}

@end

@implementation NSArray(Extension)
- (id)firstBy:(BOOL (^)(id _Nonnull))condition {
    for (id obj in self) {
        if (condition(obj)) {
            return obj;
        }
    }
    
    return nil;
}
@end


@implementation NSObject(Cast)
+ (instancetype)castFrom:(id)obj {
    if ([obj isKindOfClass:[self class]]) {
        return obj;
    }
    return nil;
}


@end
