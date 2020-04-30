//
//  CPHttpReqHelper.m
//  chat-plugin
//
//  Created by Grand on 2020/2/19.
//  Copyright © 2020 netcloth. All rights reserved.
//

#import "CPHttpReqHelper.h"
#import "CPInnerState.h"
#import <chat_plugin/chat_plugin-Swift.h>
#import "MessageObjectsV2Http.h"
#import "CPBridge.h"
#import <YYKit/YYKit.h>
#import <web3swift-Swift.h>

@implementation CPHttpReqHelper

+ (void)requestSetMuteNotification:(NCProtoActionType)action
                              type:(NCProtoChatType)type
                  releated_pub_key:(NSString *)hexPubKey
                          callback:(void (^ __nullable)(BOOL success, NSString *msg, NCProtoHttpRsp * _Nullable httpRsp))result {
    
    void(^callback)(BOOL success, NSString *msg, NCProtoHttpRsp * _Nullable httpRsp) = ^(BOOL success, NSString *msg, NCProtoHttpRsp * _Nullable httpRsp) {
        if (result) {
            result(success, msg, httpRsp);
        }
    };
    dispatch_block_t task = ^{
        std::string fromstrpubkey = getPublicKeyFromUser(CPInnerState.shared.loginUser);
        std::string mySignPrikey = getDecodePrivateKeyForUser(CPInnerState.shared.loginUser, CPInnerState.shared.loginUser.password);
        
        std::string toPubkey = bytesFromHexString(hexPubKey);
        
        NCProtoHttpReq *req = CreateSetMuteNotification(fromstrpubkey,mySignPrikey, action, type, toPubkey);
        [CPNetWork uploadHttpWithBody:req.data
                                toUrl:CPNetURL.setMute
                               method:@"POST"
                             complete:^(BOOL r, NSData * _Nullable value) {
            if (r) {
                NCProtoHttpRsp *rsp = [NCProtoHttpRsp parseFromData:value error:nil];
                callback(rsp != nil, nil, rsp);
            }
            else {
                callback(false, nil, nil);
            }
        }];
    };
    [self runTask:task];
}

+ (void)requestSetMuteNotificationBatch:(NCProtoActionType)action
                                   type:(NCProtoChatType)type
                       related_pub_keys:(NSArray<NSString *> *)hexPubKeys
                               callback:(void (^ __nullable)(BOOL success, NSString *msg, NCProtoHttpRsp * _Nullable httpRsp))result {
    
    void(^callback)(BOOL success, NSString *msg, NCProtoHttpRsp * _Nullable httpRsp) = ^(BOOL success, NSString *msg, NCProtoHttpRsp * _Nullable httpRsp) {
        if (result) {
            result(success, msg, httpRsp);
        }
    };
    dispatch_block_t task = ^{
        std::string fromstrpubkey = getPublicKeyFromUser(CPInnerState.shared.loginUser);
        std::string mySignPrikey = getDecodePrivateKeyForUser(CPInnerState.shared.loginUser, CPInnerState.shared.loginUser.password);
        
        NCProtoHttpReq *req = CreateSetMuteNotificationBatch(fromstrpubkey, mySignPrikey, action, type, hexPubKeys);
        [CPNetWork uploadHttpWithBody:req.data
                                toUrl:CPNetURL.setMuteList
                               method:@"POST"
                             complete:^(BOOL r, NSData * _Nullable value) {
            if (r) {
                NCProtoHttpRsp *rsp = [NCProtoHttpRsp parseFromData:value error:nil];
                callback(rsp != nil, nil, rsp);
            }
            else {
                callback(false, nil, nil);
            }
        }];
    };
    [self runTask:task];
}

+ (void)requestSetBlack:(NCProtoActionType)action
       releated_pub_key:(NSString *)hexPubKey
               callback:(void (^ __nullable)(BOOL success, NSString *msg, NCProtoHttpRsp * _Nullable httpRsp))result {
    
    void(^callback)(BOOL success, NSString *msg, NCProtoHttpRsp * _Nullable httpRsp) = ^(BOOL success, NSString *msg, NCProtoHttpRsp * _Nullable httpRsp) {
        if (result) {
            result(success, msg, httpRsp);
        }
    };
    dispatch_block_t task = ^{
        std::string fromstrpubkey = getPublicKeyFromUser(CPInnerState.shared.loginUser);
        std::string mySignPrikey = getDecodePrivateKeyForUser(CPInnerState.shared.loginUser, CPInnerState.shared.loginUser.password);
        
        std::string toPubkey = bytesFromHexString(hexPubKey);
        NCProtoHttpReq *req = CreateSetBlack(fromstrpubkey, mySignPrikey, action, toPubkey);
        [CPNetWork uploadHttpWithBody:req.data
                                toUrl:CPNetURL.setBlack
                               method:@"POST"
                             complete:^(BOOL r, NSData * _Nullable value) {
            if (r) {
                NCProtoHttpRsp *rsp = [NCProtoHttpRsp parseFromData:value error:nil];
                callback(rsp != nil, nil, rsp);
            }
            else {
                callback(false, nil, nil);
            }
        }];
    };
    [self runTask:task];
}

+ (void)requestSetBlackBatch:(NCProtoActionType)action
            related_pub_keys:(NSArray<NSString *> *)hexPubKeys
                    callback:(void (^ __nullable)(BOOL success, NSString *msg, NCProtoHttpRsp * _Nullable httpRsp))result {
    
    void(^callback)(BOOL success, NSString *msg, NCProtoHttpRsp * _Nullable httpRsp) = ^(BOOL success, NSString *msg, NCProtoHttpRsp * _Nullable httpRsp) {
        if (result) {
            result(success, msg, httpRsp);
        }
    };
    dispatch_block_t task = ^{
        std::string fromstrpubkey = getPublicKeyFromUser(CPInnerState.shared.loginUser);
        std::string mySignPrikey = getDecodePrivateKeyForUser(CPInnerState.shared.loginUser, CPInnerState.shared.loginUser.password);
        
        NCProtoHttpReq *req = CreateSetBlackBatch(fromstrpubkey, mySignPrikey, action, hexPubKeys);
        [CPNetWork uploadHttpWithBody:req.data
                                toUrl:CPNetURL.setBlackList
                               method:@"POST"
                             complete:^(BOOL r, NSData * _Nullable value) {
            if (r) {
                NCProtoHttpRsp *rsp = [NCProtoHttpRsp parseFromData:value error:nil];
                callback(rsp != nil, nil, rsp);
            }
            else {
                callback(false, nil, nil);
            }
        }];
    };
    [self runTask:task];
}

//MARK:- Recall
+ (void)requestQueryRecallMsg:(int64_t)begin_time
                      endtime:(int64_t)end_time
              hexgrouppubkeys:(NSMutableArray<NSString *> *)pubkes
                     callback:(void (^ __nullable)(BOOL success, NSString *msg, NCProtoQueryRecallMsgRsp * _Nullable httpRsp))result {
    
    void(^callback)(BOOL success, NSString *msg, NCProtoQueryRecallMsgRsp * _Nullable httpRsp) = ^(BOOL success, NSString *msg, NCProtoQueryRecallMsgRsp * _Nullable httpRsp) {
        if (result) {
            result(success, msg, httpRsp);
        }
    };
    dispatch_block_t task = ^{
        std::string fromstrpubkey = getPublicKeyFromUser(CPInnerState.shared.loginUser);
        std::string mySignPrikey = getDecodePrivateKeyForUser(CPInnerState.shared.loginUser, CPInnerState.shared.loginUser.password);
        
        NSMutableArray *mArr = NSMutableArray.array;
        NSData *pkt;
        for (NSString *pk in pubkes) {
            pkt =bytes2nsdata(bytesFromHexString(pk));
            if (pkt != nil) {
                [mArr addObject:pkt];
            }
        }
        
        NCProtoHttpReq *req = CreateQueryRecallMsgReq(fromstrpubkey, mySignPrikey, begin_time, end_time, mArr);
        [CPNetWork uploadHttpWithBody:req.data
                                toUrl:CPNetURL.getQuryRecallMsgs
                               method:@"POST"
                             complete:^(BOOL r, NSData * _Nullable value) {
            if (r) {
                NCProtoHttpRsp *rsp = [NCProtoHttpRsp parseFromData:value error:nil];
                if (rsp == nil) {
                    callback(false, nil, nil);
                } else{
                    NCProtoQueryRecallMsgRsp *dRsp = [NCProtoQueryRecallMsgRsp parseFromData:rsp.data_p error:nil];
                    callback(dRsp != nil, nil, dRsp);
                }
            }
            else {
                callback(false, nil, nil);
            }
        }];
    };
    [self runTask:task];
}


//MARK:- Helper
+ (void)runTask:(dispatch_block_t)block {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        block();
    });
}

@end
