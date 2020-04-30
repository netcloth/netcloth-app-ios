//
//  MessageObjectsV2Http.m
//  chat-plugin
//
//  Created by Grand on 2020/2/19.
//  Copyright © 2020 netcloth. All rights reserved.
//

#import "MessageObjectsV2Http.h"
#import "CPBridge.h"

NCProtoHttpReq * CreateSetMuteNotification(const std::string &from_public_key,
                                           const std::string &pri_key,
                                           NCProtoActionType action,
                                           NCProtoChatType type,
                                           const std::string &releated_pub_key
                                           ) {
        
    //body
    NCProtoSetMuteReq *body = NCProtoSetMuteReq.alloc.init;
    body.action = action;
    body.chatType = type;
    body.relatedPubKey = bytes2nsdata(releated_pub_key);
    
    //pack
    return CreateAndSignPack(from_public_key, pri_key, body);
}


NCProtoHttpReq * CreateSetMuteNotificationBatch(const std::string &from_public_key,
                                           const std::string &pri_key,
                                           NCProtoActionType action,
                                           NCProtoChatType type,
                                           NSArray<NSString *> *related_pub_keys) {
    //body
    NCProtoSetMuteBatchReq *body = NCProtoSetMuteBatchReq.alloc.init;
    body.action = action;
    body.chatType = type;
    
    NSMutableArray *dArray = @[].mutableCopy;
    try {
        for (NSString *hexpub in related_pub_keys) {
            [dArray addObject:bytes2nsdata(bytesFromHexString(hexpub))];
        }
    } catch (NSError *err) {
    }
    body.relatedPubKeysArray = dArray;
    
    //pack
    return CreateAndSignPack(from_public_key, pri_key, body);
}

NCProtoHttpReq * CreateSetBlack(const std::string &from_public_key,
                                       const std::string &pri_key,
                                       NCProtoActionType action,
                                       const std::string &releated_pub_key
                                       ) {
    //body
    NCProtoSetBlacklistReq *body = NCProtoSetBlacklistReq.alloc.init;
    body.action = action;
    body.relatedPubKey = bytes2nsdata(releated_pub_key);
    
    //pack
    return CreateAndSignPack(from_public_key, pri_key, body);
}

NCProtoHttpReq * CreateSetBlackBatch(const std::string &from_public_key,
                                            const std::string &pri_key,
                                            NCProtoActionType action,
                                            NSArray<NSString *> *related_pub_keys
                                     ) {
    //body
    NCProtoSetBlacklistBatchReq *body = NCProtoSetBlacklistBatchReq.alloc.init;
    body.action = action;
    
    NSMutableArray *dArray = @[].mutableCopy;
    try {
        for (NSString *hexpub in related_pub_keys) {
            [dArray addObject:bytes2nsdata(bytesFromHexString(hexpub))];
        }
    } catch (NSError *err) {
    }
    body.relatedPubKeysArray = dArray;
    
    //pack
    return CreateAndSignPack(from_public_key, pri_key, body);
}

/// Recall
NCProtoHttpReq *CreateQueryRecallMsgReq(const std::string &from_public_key,
                                        const std::string &pri_key,
                                        int64_t begin_time,
                                        int64_t end_time,
                                        NSMutableArray<NSData *> *group_pub_keys
                                        ) {
    //body
    NCProtoQueryRecallMsgReq *body = NCProtoQueryRecallMsgReq.alloc.init;
    body.beginTime = begin_time;
    body.endTime = end_time;
    body.groupPubKeysArray = group_pub_keys;
    
    //pack
    return CreateAndSignPack(from_public_key, pri_key, body);
}



@implementation MessageObjectsV2Http
@end
