  
  
  
  
  
  
  

#import <Foundation/Foundation.h>
#import "CPDataModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ChatSessionInterface;

@interface CPSessionHelper : NSObject <ChatSessionInterface>

@end

NS_ASSUME_NONNULL_END


@protocol ChatSessionInterface <NSObject>


+ (void)getAllRecentSessionComplete:(void (^)(BOOL success, NSString *msg, NSArray<CPSession *> * _Nullable recentSessions))complete;


+ (void)getStrengerAllSessionComplete:(void (^)(BOOL success, NSString *msg, NSArray<CPSession *> * _Nullable recentSessions))complete;


  
+ (void)getOneSessionById:(NSInteger)sessionId
                 complete:(void (^)(BOOL success, NSString *msg, CPSession * _Nullable recentSessions))complete;


  

  
+ (void)deleteSession:(NSInteger)sessionId
             complete:(void (^)(BOOL success, NSString *msg))complete;

  
+ (void)deleteSessions:(NSArray<NSNumber *> *)sessionIds
             complete:(void (^ __nullable)(BOOL success, NSString *msg))complete;

  
+ (void)deleteAllSessionComplete:(void (^)(BOOL success, NSString *msg))complete;

  
+ (void)clearSessionChatsIn:(NSInteger)sessionId
            withSessionType:(SessionType)stype
                   complete:(void (^ __nullable)(BOOL success, NSString *msg))complete;

  

  
+ (void)setAllReadOfSession:(NSInteger)sessionId
            withSessionType:(SessionType)stype
                   complete:(void (^)(BOOL success, NSString *msg))complete;

+ (void)setUnReadCount:(NSInteger)count
             ofSession:(NSInteger)sessionId
            withSessionType:(SessionType)stype
                   complete:(void (^ __nullable)(BOOL success, NSString *msg))complete;


  
+ (void)markTopOfSession:(NSInteger)sessionId
                complete:(void (^ __nullable)(BOOL success, NSString *msg))complete;

  
+ (void)unTopOfSession:(NSInteger)sessionId
              complete:(void (^ __nullable)(BOOL success, NSString *msg))complete;

@end
