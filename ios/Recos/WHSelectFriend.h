//
//  WHSelectFriend.h
//  Recos
//
//  Created by wenhuan on 2021/8/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WHSelectFriendModel : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *url;

@end
@implementation WHSelectFriendModel
@end

@interface WHSelectFriend : NSObject

+ (NSString *)getRecentContectUsers;

@end

NS_ASSUME_NONNULL_END
