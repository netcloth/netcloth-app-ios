//
//  MessageFactoryTool.h
//  chat-plugin
//
//  Created by Grand on 2020/3/5.
//  Copyright © 2020 netcloth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CPProtobufMsgHeader.h"
#import <string>

extern BOOL CheckSignature(NCProtoHttpReq *net_msg);
extern std::string CalcHash(NCProtoHttpReq *net_msg);
extern void FillSignature(NCProtoHttpReq *net_msg, const std::string& private_key);
extern NCProtoHttpReq * CreateNetMsgPackFillName(GPBMessage *body, NSData *pubkey);

extern NCProtoHttpReq *CreateAndSignPack(const std::string &from_public_key,
                                         const std::string &pri_key,
                                         GPBMessage *body
                                         );

@interface MessageFactoryTool : NSObject
@end
