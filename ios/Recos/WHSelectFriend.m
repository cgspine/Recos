//
//  WHSelectFriend.m
//  Recos
//
//  Created by wenhuan on 2021/8/14.
//

#import "WHSelectFriend.h"

@implementation WHSelectFriend

+ (NSString *)getRecentContectUsers {
    
    NSMutableArray *array = @[].mutableCopy;
    for (int i = 0; i < 5000; i++) {
        NSDictionary *item = @{
            @"title": [NSString stringWithFormat: @"你好%d", i],
            @"url": @"https://wehear-1258476243.file.myqcloud.com/hemera/cover/59d/7f2/t9_5b8a0600339149c4ea55001b0f.png"
        };
        [array addObject: item];
    }
    NSDictionary *dict = @{@"result": array.copy};
    NSString *str = [WHSelectFriend convertToJsonData: dict];
    return str;
}

+ (NSString *)convertToJsonData:(NSDictionary *)dict {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString;
    if (!jsonData) {
        NSLog(@"%@",error);
    }else{
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    NSRange range = {0,jsonString.length};
    //去掉字符串中的空格
    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
    NSRange range2 = {0,mutStr.length};
    //去掉字符串中的换行符
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
    return mutStr;
}

@end
