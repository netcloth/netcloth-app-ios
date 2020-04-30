//
//  CPHttpReqHelper.h
//  chat-plugin
//
//  Created by Grand on 2020/2/19.
//  Copyright © 2020 netcloth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CPProtobufMsgHeader.h"

@interface CPHttpReqHelper : NSObject

//MARK:- Mute
+ (void)requestSetMuteNotification:(NCProtoActionType)action
                              type:(NCProtoChatType)type
                  releated_pub_key:(NSString *)hexPubKey
                          callback:(void (^ __nullable)(BOOL success, NSString *msg, NCProtoHttpRsp * _Nullable httpRsp))result;

+ (void)requestSetMuteNotificationBatch:(NCProtoActionType)action
                                   type:(NCProtoChatType)type
                       related_pub_keys:(NSArray<NSString *> *)hexPubKeys
                               callback:(void (^ __nullable)(BOOL success, NSString *msg, NCProtoHttpRsp * _Nullable httpRsp))result;

//MARK:- Black
+ (void)requestSetBlack:(NCProtoActionType)action
       releated_pub_key:(NSString *)hexPubKey
               callback:(void (^ __nullable)(BOOL success, NSString *msg, NCProtoHttpRsp * _Nullable httpRsp))result;

+ (void)requestSetBlackBatch:(NCProtoActionType)action
            related_pub_keys:(NSArray<NSString *> *)hexPubKeys
                    callback:(void (^ __nullable)(BOOL success, NSString *msg, NCProtoHttpRsp * _Nullable httpRsp))result;


//MARK:- Recall
+ (void)requestQueryRecallMsg:(int64_t)begin_time
                      endtime:(int64_t)end_time
hexgrouppubkeys:(NSMutableArray<NSString *> *)pubkes
callback:(void (^ __nullable)(BOOL success, NSString *msg, NCProtoQueryRecallMsgRsp * _Nullable httpRsp))result;

@end
