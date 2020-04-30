







#import <Foundation/Foundation.h>
#import "MessageFactoryTool.h"

extern NCProtoHttpReq * CreateSetMuteNotification(const std::string &from_public_key,
                                           const std::string &pri_key,
                                           NCProtoActionType action,
                                           NCProtoChatType type,
                                           const std::string &releated_pub_key
                                           );


extern NCProtoHttpReq * CreateSetMuteNotificationBatch(const std::string &from_public_key,
                                                  const std::string &pri_key,
                                                  NCProtoActionType action,
                                                  NCProtoChatType type,
                                                  NSArray<NSString *> *related_pub_keys
                                                  );


extern NCProtoHttpReq * CreateSetBlack(const std::string &from_public_key,
                                       const std::string &pri_key,
                                       NCProtoActionType action,
                                       const std::string &releated_pub_key
                                       );

extern NCProtoHttpReq * CreateSetBlackBatch(const std::string &from_public_key,
                                            const std::string &pri_key,
                                            NCProtoActionType action,
                                            NSArray<NSString *> *related_pub_keys
                                            );


extern NCProtoHttpReq *CreateQueryRecallMsgReq(const std::string &from_public_key,
const std::string &pri_key,
int64_t begin_time,
int64_t end_time,
NSMutableArray<NSData *> *group_pub_keys
                                        );

@interface MessageObjectsV2Http : NSObject
@end
