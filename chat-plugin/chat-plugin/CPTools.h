







#import <Foundation/Foundation.h>


extern NSString *kTableName_User;
extern NSString *kTableName_Contact;
extern NSString *kTableName_Session;
extern NSString *kTableName_Message;
extern NSString *kTableName_Claim;


#if DEBUG
#define NSLog(...) NSLog(__VA_ARGS__)
#else
#define NSLog(...)
#endif

NS_ASSUME_NONNULL_BEGIN

@interface CPTools : NSObject

@end

NS_ASSUME_NONNULL_END




#ifndef dispatch_main_async_safe
#define dispatch_main_async_safe(block)\
    if (strcmp(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL), dispatch_queue_get_label(dispatch_get_main_queue())) == 0) {\
        block();\
    } else {\
        dispatch_async(dispatch_get_main_queue(), block);\
    }
#endif




@interface NSString (empty)

+ (BOOL)cp_isEmpty:(NSString *)str;
- (NSString *)localized;

@end

@interface NSData (empty)

+ (BOOL)cp_isEmpty:(NSData *)data;

@end
