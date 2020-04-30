//
//  CPSessionHelper.h
//  chat-plugin
//
//  Created by Grand on 2019/12/11.
//  Copyright © 2019 netcloth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CPDataModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ChatSessionInterface;

@interface CPSessionHelper : NSObject <ChatSessionInterface>

// - Group recommendation
+ (void)requestRecommendedGroupInServerNodeComplete:(void (^)(BOOL success, NSString *msg, NSArray<CPRecommendedGroup *> * _Nullable recommendGroup))complete;

//fake recommend group only once
+ (void)fakeAddRecommendedGroupSession;
+ (void)fakeUpdateRecommendedGroupSessionCount:(NSInteger)count;


@end

NS_ASSUME_NONNULL_END


@protocol ChatSessionInterface <NSObject>


+ (void)getAllRecentSessionComplete:(void (^)(BOOL success, NSString *msg, NSArray<CPSession *> * _Nullable recentSessions))complete;


+ (void)getStrengerAllSessionComplete:(void (^)(BOOL success, NSString *msg, NSArray<CPSession *> * _Nullable recentSessions))complete;


/// 仅仅是session， no other
+ (void)getOneSessionById:(NSInteger)sessionId
                 complete:(void (^)(BOOL success, NSString *msg, CPSession * _Nullable recentSessions))complete;


//MARK:- Delete

// delete session
+ (void)deleteSession:(NSInteger)sessionId
             complete:(void (^)(BOOL success, NSString *msg))complete;

// 陌生人会话，删除选择
+ (void)deleteSessions:(NSArray<NSNumber *> *)sessionIds
             complete:(void (^ __nullable)(BOOL success, NSString *msg))complete;

// delete session 清空所有聊天记录
+ (void)deleteAllSessionComplete:(void (^)(BOOL success, NSString *msg))complete;

//清空聊天记录
+ (void)clearSessionChatsIn:(NSInteger)sessionId
            withSessionType:(SessionType)stype
                   complete:(void (^ __nullable)(BOOL success, NSString *msg))complete;

//MARK:- Update

// make session read
+ (void)setAllReadOfSession:(NSInteger)sessionId
            withSessionType:(SessionType)stype
                   complete:(void (^)(BOOL success, NSString *msg))complete;

+ (void)setUnReadCount:(NSInteger)count
             ofSession:(NSInteger)sessionId
            withSessionType:(SessionType)stype
                   complete:(void (^ __nullable)(BOOL success, NSString *msg))complete;


//mark top
+ (void)markTopOfSession:(NSInteger)sessionId
                complete:(void (^ __nullable)(BOOL success, NSString *msg))complete;

//unmark top
+ (void)unTopOfSession:(NSInteger)sessionId
              complete:(void (^ __nullable)(BOOL success, NSString *msg))complete;

@end
