//
//  CommonHelper.m
//  DNS
//
//  Created by Mihael on 28.08.12.
//
//

#import "CommonHelper.h"

@implementation CommonHelper

+(NSDateComponents*)currentDateTime
{
    //Получаем текущее время
    NSDate* now = [NSDate date];
    //Указываем календарь
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    //Создаем компонент даты для текущего времени и григорианского календаря
    return [gregorian components:(NSHourCalendarUnit  | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:now];
    /* пример
        //Получаем текущий час
        NSInteger hour = [dateComponents hour];
        //Получаем текущую минуту
        NSInteger minute = [dateComponents minute];
        //Получаем текущую секунду
        NSInteger second = [dateComponents second];
        //Выводим все в лог в удобном формате
        NSLog(@"%@",[NSString stringWithFormat:@"%02d:%02d:%02d", hour, minute, second]);
    */
}

+(NSString*)getStringBetweenTwoSymbols:(NSString*)string:(NSString*)first:(NSString*)second
{
    NSArray *firstStep = [string componentsSeparatedByString: first];
    NSString *stringRight = string;
    if([firstStep count]>=2)
        stringRight = [firstStep objectAtIndex:1];
    NSArray *secondStep = [stringRight componentsSeparatedByString: second];
    NSString *stringLeft = stringRight;
    if([secondStep count]>=1)
        stringLeft = [secondStep objectAtIndex:0];
    return stringLeft;
}

+(void)print_array:(NSArray*)arr
{
    NSMutableString *exString = [[NSMutableString alloc]init];
    for (NSString *yourVar in arr)
        [exString appendFormat:@"\n%@",yourVar];
    NSLog(@"array print: %@", exString);
}

+(BOOL)containsString:(NSString*)substring inString:(NSString*)masterString
{
    NSRange range = [masterString rangeOfString : substring];
    BOOL found = ( range.location != NSNotFound );
    return found;
}

+(NSString*)convertTimeFromSeconds:(NSString*)seconds
{
    NSString *result = @"";
    
    int secs = [seconds intValue];
    int tempHour    = 0;
    int tempMinute  = 0;
    int tempSecond  = 0;
    
    NSString *hour      = @"";
    NSString *minute    = @"";
    NSString *second    = @"";
    
    tempHour    = secs / 3600;
    tempMinute  = secs / 60 - tempHour * 60;
    tempSecond  = secs - (tempHour * 3600 + tempMinute * 60);
    
    hour    = [[NSNumber numberWithInt:tempHour] stringValue];
    minute  = [[NSNumber numberWithInt:tempMinute] stringValue];
    second  = [[NSNumber numberWithInt:tempSecond] stringValue];
    
    if (tempHour < 10)
        hour = [@"0" stringByAppendingString:hour];
    if (tempMinute < 10)
        minute = [@"0" stringByAppendingString:minute];
    if (tempSecond < 10)
        second = [@"0" stringByAppendingString:second];
    if (tempHour == 0)
        result = [NSString stringWithFormat:@"%@:%@", minute, second];
    else
        result = [NSString stringWithFormat:@"%@:%@:%@",hour, minute, second];
    return result;
}

@end
