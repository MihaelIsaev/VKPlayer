//
//  CommonHelper.h
//  DNS
//
//  Created by Mihael on 28.08.12.
//
//

#import <Foundation/Foundation.h>

@interface CommonHelper : NSObject

+(NSDateComponents*)currentDateTime;
+(NSString*)getStringBetweenTwoSymbols:(NSString*)string:(NSString*)first:(NSString*)second;
+(void)print_array:(NSArray*)arr;
+(BOOL)containsString:(NSString*)substring inString:(NSString*)masterString;
+(NSString*)convertTimeFromSeconds:(NSString*)seconds;

@end
