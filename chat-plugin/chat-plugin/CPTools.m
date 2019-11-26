







#import "CPTools.h"

NSString *kTableName_User = @"user";
NSString *kTableName_Contact = @"contact";
NSString *kTableName_Session = @"session";
NSString *kTableName_Message = @"message";
NSString *kTableName_Claim = @"claim";

@implementation CPTools

@end


@implementation NSString (empty)

+ (BOOL)cp_isEmpty:(NSString *)str {
    if (str && [str isKindOfClass:NSString.class] && str.length) {
        return NO;
    }
    return YES;
}

- (NSString *)localized {
    return NSLocalizedString(self, nil);
}

@end


@implementation NSData (empty)
+ (BOOL)cp_isEmpty:(NSData *)data {
    if (data &&
        [data isKindOfClass:NSData.class] &&
        data.length > 0 ) {
        return false;
    }
    return true;
}
@end
