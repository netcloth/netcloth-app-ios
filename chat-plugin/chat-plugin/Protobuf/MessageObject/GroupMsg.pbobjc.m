




#if !defined(GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS)
 #define GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS 0
#endif

#if GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS
 #import <protobuf/GPBProtocolBuffers_RuntimeSupport.h>
#else
 #import "GPBProtocolBuffers_RuntimeSupport.h"
#endif

#import <stdatomic.h>

#import "GroupMsg.pbobjc.h"
#import "CommonTypes.pbobjc.h"
#import "NetMsg.pbobjc.h"


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

#pragma mark - NCProtoGroupMsgRoot

@implementation NCProtoGroupMsgRoot




@end

#pragma mark - NCProtoGroupMsgRoot_FileDescriptor

static GPBFileDescriptor *NCProtoGroupMsgRoot_FileDescriptor(void) {
  
  
  static GPBFileDescriptor *descriptor = NULL;
  if (!descriptor) {
    GPB_DEBUG_CHECK_RUNTIME_VERSIONS();
    descriptor = [[GPBFileDescriptor alloc] initWithPackage:@"netcloth"
                                                 objcPrefix:@"NCProto"
                                                     syntax:GPBFileSyntaxProto3];
  }
  return descriptor;
}

#pragma mark - Enum NCProtoGroupRole

GPBEnumDescriptor *NCProtoGroupRole_EnumDescriptor(void) {
  static _Atomic(GPBEnumDescriptor*) descriptor = nil;
  if (!descriptor) {
    static const char *valueNames =
        "Owner\000Manager\000Member\000";
    static const int32_t values[] = {
        NCProtoGroupRole_Owner,
        NCProtoGroupRole_Manager,
        NCProtoGroupRole_Member,
    };
    GPBEnumDescriptor *worker =
        [GPBEnumDescriptor allocDescriptorForName:GPBNSStringifySymbol(NCProtoGroupRole)
                                       valueNames:valueNames
                                           values:values
                                            count:(uint32_t)(sizeof(values) / sizeof(int32_t))
                                     enumVerifier:NCProtoGroupRole_IsValidValue];
    GPBEnumDescriptor *expected = nil;
    if (!atomic_compare_exchange_strong(&descriptor, &expected, worker)) {
      [worker release];
    }
  }
  return descriptor;
}

BOOL NCProtoGroupRole_IsValidValue(int32_t value__) {
  switch (value__) {
    case NCProtoGroupRole_Owner:
    case NCProtoGroupRole_Manager:
    case NCProtoGroupRole_Member:
      return YES;
    default:
      return NO;
  }
}

#pragma mark - NCProtoGroupCreate

@implementation NCProtoGroupCreate

@dynamic groupName;
@dynamic groupType;
@dynamic ownerNickName;
@dynamic toInviteeMsgsArray, toInviteeMsgsArray_Count;

typedef struct NCProtoGroupCreate__storage_ {
  uint32_t _has_storage_[1];
  int32_t groupType;
  NSString *groupName;
  NSString *ownerNickName;
  NSMutableArray *toInviteeMsgsArray;
} NCProtoGroupCreate__storage_;



+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "groupName",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoGroupCreate_FieldNumber_GroupName,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(NCProtoGroupCreate__storage_, groupName),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeString,
      },
      {
        .name = "groupType",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoGroupCreate_FieldNumber_GroupType,
        .hasIndex = 1,
        .offset = (uint32_t)offsetof(NCProtoGroupCreate__storage_, groupType),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeInt32,
      },
      {
        .name = "ownerNickName",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoGroupCreate_FieldNumber_OwnerNickName,
        .hasIndex = 2,
        .offset = (uint32_t)offsetof(NCProtoGroupCreate__storage_, ownerNickName),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeString,
      },
      {
        .name = "toInviteeMsgsArray",
        .dataTypeSpecific.className = GPBStringifySymbol(NCProtoNetMsg),
        .number = NCProtoGroupCreate_FieldNumber_ToInviteeMsgsArray,
        .hasIndex = GPBNoHasBit,
        .offset = (uint32_t)offsetof(NCProtoGroupCreate__storage_, toInviteeMsgsArray),
        .flags = GPBFieldRepeated,
        .dataType = GPBDataTypeMessage,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[NCProtoGroupCreate class]
                                     rootClass:[NCProtoGroupMsgRoot class]
                                          file:NCProtoGroupMsgRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(NCProtoGroupCreate__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif  
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

#pragma mark - NCProtoGroupInvite

@implementation NCProtoGroupInvite

@dynamic groupPrivateKey;
@dynamic groupName;
@dynamic groupPubKey;

typedef struct NCProtoGroupInvite__storage_ {
  uint32_t _has_storage_[1];
  NSData *groupPrivateKey;
  NSString *groupName;
  NSData *groupPubKey;
} NCProtoGroupInvite__storage_;



+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "groupPrivateKey",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoGroupInvite_FieldNumber_GroupPrivateKey,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(NCProtoGroupInvite__storage_, groupPrivateKey),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeBytes,
      },
      {
        .name = "groupName",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoGroupInvite_FieldNumber_GroupName,
        .hasIndex = 1,
        .offset = (uint32_t)offsetof(NCProtoGroupInvite__storage_, groupName),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeString,
      },
      {
        .name = "groupPubKey",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoGroupInvite_FieldNumber_GroupPubKey,
        .hasIndex = 2,
        .offset = (uint32_t)offsetof(NCProtoGroupInvite__storage_, groupPubKey),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeBytes,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[NCProtoGroupInvite class]
                                     rootClass:[NCProtoGroupMsgRoot class]
                                          file:NCProtoGroupMsgRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(NCProtoGroupInvite__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif  
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

#pragma mark - NCProtoGroupJoin

@implementation NCProtoGroupJoin

@dynamic nickName;
@dynamic description_p;
@dynamic source;
@dynamic inviterPubKey;

typedef struct NCProtoGroupJoin__storage_ {
  uint32_t _has_storage_[1];
  int32_t source;
  NSString *nickName;
  NSString *description_p;
  NSData *inviterPubKey;
} NCProtoGroupJoin__storage_;



+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "nickName",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoGroupJoin_FieldNumber_NickName,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(NCProtoGroupJoin__storage_, nickName),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeString,
      },
      {
        .name = "description_p",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoGroupJoin_FieldNumber_Description_p,
        .hasIndex = 1,
        .offset = (uint32_t)offsetof(NCProtoGroupJoin__storage_, description_p),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeString,
      },
      {
        .name = "source",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoGroupJoin_FieldNumber_Source,
        .hasIndex = 2,
        .offset = (uint32_t)offsetof(NCProtoGroupJoin__storage_, source),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeInt32,
      },
      {
        .name = "inviterPubKey",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoGroupJoin_FieldNumber_InviterPubKey,
        .hasIndex = 3,
        .offset = (uint32_t)offsetof(NCProtoGroupJoin__storage_, inviterPubKey),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeBytes,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[NCProtoGroupJoin class]
                                     rootClass:[NCProtoGroupMsgRoot class]
                                          file:NCProtoGroupMsgRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(NCProtoGroupJoin__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif  
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

#pragma mark - NCProtoGroupKickReq

@implementation NCProtoGroupKickReq

@dynamic kickPubKeysArray, kickPubKeysArray_Count;

typedef struct NCProtoGroupKickReq__storage_ {
  uint32_t _has_storage_[1];
  NSMutableArray *kickPubKeysArray;
} NCProtoGroupKickReq__storage_;



+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "kickPubKeysArray",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoGroupKickReq_FieldNumber_KickPubKeysArray,
        .hasIndex = GPBNoHasBit,
        .offset = (uint32_t)offsetof(NCProtoGroupKickReq__storage_, kickPubKeysArray),
        .flags = GPBFieldRepeated,
        .dataType = GPBDataTypeBytes,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[NCProtoGroupKickReq class]
                                     rootClass:[NCProtoGroupMsgRoot class]
                                          file:NCProtoGroupMsgRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(NCProtoGroupKickReq__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif  
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

#pragma mark - NCProtoGroupKickResult

@implementation NCProtoGroupKickResult

@dynamic kickPubKey;
@dynamic result;

typedef struct NCProtoGroupKickResult__storage_ {
  uint32_t _has_storage_[1];
  int32_t result;
  NSData *kickPubKey;
} NCProtoGroupKickResult__storage_;



+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "kickPubKey",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoGroupKickResult_FieldNumber_KickPubKey,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(NCProtoGroupKickResult__storage_, kickPubKey),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeBytes,
      },
      {
        .name = "result",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoGroupKickResult_FieldNumber_Result,
        .hasIndex = 1,
        .offset = (uint32_t)offsetof(NCProtoGroupKickResult__storage_, result),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeInt32,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[NCProtoGroupKickResult class]
                                     rootClass:[NCProtoGroupMsgRoot class]
                                          file:NCProtoGroupMsgRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(NCProtoGroupKickResult__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif  
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

#pragma mark - NCProtoGroupKickRsp

@implementation NCProtoGroupKickRsp

@dynamic result;
@dynamic kickResultArray, kickResultArray_Count;

typedef struct NCProtoGroupKickRsp__storage_ {
  uint32_t _has_storage_[1];
  int32_t result;
  NSMutableArray *kickResultArray;
} NCProtoGroupKickRsp__storage_;



+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "result",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoGroupKickRsp_FieldNumber_Result,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(NCProtoGroupKickRsp__storage_, result),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeInt32,
      },
      {
        .name = "kickResultArray",
        .dataTypeSpecific.className = GPBStringifySymbol(NCProtoGroupKickResult),
        .number = NCProtoGroupKickRsp_FieldNumber_KickResultArray,
        .hasIndex = GPBNoHasBit,
        .offset = (uint32_t)offsetof(NCProtoGroupKickRsp__storage_, kickResultArray),
        .flags = GPBFieldRepeated,
        .dataType = GPBDataTypeMessage,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[NCProtoGroupKickRsp class]
                                     rootClass:[NCProtoGroupMsgRoot class]
                                          file:NCProtoGroupMsgRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(NCProtoGroupKickRsp__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif  
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

#pragma mark - NCProtoGroupKick

@implementation NCProtoGroupKick

@dynamic kickedPubKeysArray, kickedPubKeysArray_Count;

typedef struct NCProtoGroupKick__storage_ {
  uint32_t _has_storage_[1];
  NSMutableArray *kickedPubKeysArray;
} NCProtoGroupKick__storage_;



+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "kickedPubKeysArray",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoGroupKick_FieldNumber_KickedPubKeysArray,
        .hasIndex = GPBNoHasBit,
        .offset = (uint32_t)offsetof(NCProtoGroupKick__storage_, kickedPubKeysArray),
        .flags = GPBFieldRepeated,
        .dataType = GPBDataTypeBytes,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[NCProtoGroupKick class]
                                     rootClass:[NCProtoGroupMsgRoot class]
                                          file:NCProtoGroupMsgRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(NCProtoGroupKick__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif  
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

#pragma mark - NCProtoGroupQuit

@implementation NCProtoGroupQuit


typedef struct NCProtoGroupQuit__storage_ {
  uint32_t _has_storage_[1];
} NCProtoGroupQuit__storage_;



+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[NCProtoGroupQuit class]
                                     rootClass:[NCProtoGroupMsgRoot class]
                                          file:NCProtoGroupMsgRoot_FileDescriptor()
                                        fields:NULL
                                    fieldCount:0
                                   storageSize:sizeof(NCProtoGroupQuit__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif  
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

#pragma mark - NCProtoGroupDismiss

@implementation NCProtoGroupDismiss


typedef struct NCProtoGroupDismiss__storage_ {
  uint32_t _has_storage_[1];
} NCProtoGroupDismiss__storage_;



+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[NCProtoGroupDismiss class]
                                     rootClass:[NCProtoGroupMsgRoot class]
                                          file:NCProtoGroupMsgRoot_FileDescriptor()
                                        fields:NULL
                                    fieldCount:0
                                   storageSize:sizeof(NCProtoGroupDismiss__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif  
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

#pragma mark - NCProtoGroupUpdateName

@implementation NCProtoGroupUpdateName

@dynamic name;

typedef struct NCProtoGroupUpdateName__storage_ {
  uint32_t _has_storage_[1];
  NSString *name;
} NCProtoGroupUpdateName__storage_;



+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "name",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoGroupUpdateName_FieldNumber_Name,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(NCProtoGroupUpdateName__storage_, name),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeString,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[NCProtoGroupUpdateName class]
                                     rootClass:[NCProtoGroupMsgRoot class]
                                          file:NCProtoGroupMsgRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(NCProtoGroupUpdateName__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif  
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

#pragma mark - NCProtoGroupUpdateNotice

@implementation NCProtoGroupUpdateNotice

@dynamic notice;

typedef struct NCProtoGroupUpdateNotice__storage_ {
  uint32_t _has_storage_[1];
  NSString *notice;
} NCProtoGroupUpdateNotice__storage_;



+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "notice",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoGroupUpdateNotice_FieldNumber_Notice,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(NCProtoGroupUpdateNotice__storage_, notice),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeString,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[NCProtoGroupUpdateNotice class]
                                     rootClass:[NCProtoGroupMsgRoot class]
                                          file:NCProtoGroupMsgRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(NCProtoGroupUpdateNotice__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif  
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

#pragma mark - NCProtoGroupUpdateNickName

@implementation NCProtoGroupUpdateNickName

@dynamic nickName;

typedef struct NCProtoGroupUpdateNickName__storage_ {
  uint32_t _has_storage_[1];
  NSString *nickName;
} NCProtoGroupUpdateNickName__storage_;



+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "nickName",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoGroupUpdateNickName_FieldNumber_NickName,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(NCProtoGroupUpdateNickName__storage_, nickName),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeString,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[NCProtoGroupUpdateNickName class]
                                     rootClass:[NCProtoGroupMsgRoot class]
                                          file:NCProtoGroupMsgRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(NCProtoGroupUpdateNickName__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif  
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

#pragma mark - NCProtoGroupTransferOwner

@implementation NCProtoGroupTransferOwner

@dynamic newOwnerPubKey;

typedef struct NCProtoGroupTransferOwner__storage_ {
  uint32_t _has_storage_[1];
  NSData *newOwnerPubKey;
} NCProtoGroupTransferOwner__storage_;



+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "newOwnerPubKey",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoGroupTransferOwner_FieldNumber_NewOwnerPubKey,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(NCProtoGroupTransferOwner__storage_, newOwnerPubKey),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeBytes,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[NCProtoGroupTransferOwner class]
                                     rootClass:[NCProtoGroupMsgRoot class]
                                          file:NCProtoGroupMsgRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(NCProtoGroupTransferOwner__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif  
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

#pragma mark - NCProtoGroupText

@implementation NCProtoGroupText

@dynamic content;
@dynamic atAll;
@dynamic atMembersArray, atMembersArray_Count;

typedef struct NCProtoGroupText__storage_ {
  uint32_t _has_storage_[1];
  NSData *content;
  NSMutableArray *atMembersArray;
} NCProtoGroupText__storage_;



+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "content",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoGroupText_FieldNumber_Content,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(NCProtoGroupText__storage_, content),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeBytes,
      },
      {
        .name = "atAll",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoGroupText_FieldNumber_AtAll,
        .hasIndex = 1,
        .offset = 2,  
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeBool,
      },
      {
        .name = "atMembersArray",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoGroupText_FieldNumber_AtMembersArray,
        .hasIndex = GPBNoHasBit,
        .offset = (uint32_t)offsetof(NCProtoGroupText__storage_, atMembersArray),
        .flags = GPBFieldRepeated,
        .dataType = GPBDataTypeBytes,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[NCProtoGroupText class]
                                     rootClass:[NCProtoGroupMsgRoot class]
                                          file:NCProtoGroupMsgRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(NCProtoGroupText__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif  
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

#pragma mark - NCProtoGroupAudio

@implementation NCProtoGroupAudio

@dynamic content;
@dynamic playTime;

typedef struct NCProtoGroupAudio__storage_ {
  uint32_t _has_storage_[1];
  uint32_t playTime;
  NSData *content;
} NCProtoGroupAudio__storage_;



+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "content",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoGroupAudio_FieldNumber_Content,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(NCProtoGroupAudio__storage_, content),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeBytes,
      },
      {
        .name = "playTime",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoGroupAudio_FieldNumber_PlayTime,
        .hasIndex = 1,
        .offset = (uint32_t)offsetof(NCProtoGroupAudio__storage_, playTime),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeUInt32,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[NCProtoGroupAudio class]
                                     rootClass:[NCProtoGroupMsgRoot class]
                                          file:NCProtoGroupMsgRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(NCProtoGroupAudio__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif  
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

#pragma mark - NCProtoGroupImage

@implementation NCProtoGroupImage

@dynamic id_p;
@dynamic width;
@dynamic height;

typedef struct NCProtoGroupImage__storage_ {
  uint32_t _has_storage_[1];
  uint32_t width;
  uint32_t height;
  NSString *id_p;
} NCProtoGroupImage__storage_;



+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "id_p",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoGroupImage_FieldNumber_Id_p,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(NCProtoGroupImage__storage_, id_p),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeString,
      },
      {
        .name = "width",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoGroupImage_FieldNumber_Width,
        .hasIndex = 1,
        .offset = (uint32_t)offsetof(NCProtoGroupImage__storage_, width),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeUInt32,
      },
      {
        .name = "height",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoGroupImage_FieldNumber_Height,
        .hasIndex = 2,
        .offset = (uint32_t)offsetof(NCProtoGroupImage__storage_, height),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeUInt32,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[NCProtoGroupImage class]
                                     rootClass:[NCProtoGroupMsgRoot class]
                                          file:NCProtoGroupMsgRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(NCProtoGroupImage__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif  
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

#pragma mark - NCProtoGroupVideo

@implementation NCProtoGroupVideo

@dynamic id_p;
@dynamic playTime;

typedef struct NCProtoGroupVideo__storage_ {
  uint32_t _has_storage_[1];
  uint32_t playTime;
  NSString *id_p;
} NCProtoGroupVideo__storage_;



+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "id_p",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoGroupVideo_FieldNumber_Id_p,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(NCProtoGroupVideo__storage_, id_p),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeString,
      },
      {
        .name = "playTime",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoGroupVideo_FieldNumber_PlayTime,
        .hasIndex = 1,
        .offset = (uint32_t)offsetof(NCProtoGroupVideo__storage_, playTime),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeUInt32,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[NCProtoGroupVideo class]
                                     rootClass:[NCProtoGroupMsgRoot class]
                                          file:NCProtoGroupMsgRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(NCProtoGroupVideo__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif  
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

#pragma mark - NCProtoGroupFile

@implementation NCProtoGroupFile

@dynamic id_p;
@dynamic name;
@dynamic size;

typedef struct NCProtoGroupFile__storage_ {
  uint32_t _has_storage_[1];
  uint32_t size;
  NSString *id_p;
  NSString *name;
} NCProtoGroupFile__storage_;



+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "id_p",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoGroupFile_FieldNumber_Id_p,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(NCProtoGroupFile__storage_, id_p),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeString,
      },
      {
        .name = "name",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoGroupFile_FieldNumber_Name,
        .hasIndex = 1,
        .offset = (uint32_t)offsetof(NCProtoGroupFile__storage_, name),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeString,
      },
      {
        .name = "size",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoGroupFile_FieldNumber_Size,
        .hasIndex = 2,
        .offset = (uint32_t)offsetof(NCProtoGroupFile__storage_, size),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeUInt32,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[NCProtoGroupFile class]
                                     rootClass:[NCProtoGroupMsgRoot class]
                                          file:NCProtoGroupMsgRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(NCProtoGroupFile__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif  
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

#pragma mark - NCProtoGroupNews

@implementation NCProtoGroupNews

@dynamic title;
@dynamic description_p;
@dynamic URL;
@dynamic picURL;

typedef struct NCProtoGroupNews__storage_ {
  uint32_t _has_storage_[1];
  NSData *title;
  NSData *description_p;
  NSData *URL;
  NSData *picURL;
} NCProtoGroupNews__storage_;



+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "title",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoGroupNews_FieldNumber_Title,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(NCProtoGroupNews__storage_, title),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeBytes,
      },
      {
        .name = "description_p",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoGroupNews_FieldNumber_Description_p,
        .hasIndex = 1,
        .offset = (uint32_t)offsetof(NCProtoGroupNews__storage_, description_p),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeBytes,
      },
      {
        .name = "URL",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoGroupNews_FieldNumber_URL,
        .hasIndex = 2,
        .offset = (uint32_t)offsetof(NCProtoGroupNews__storage_, URL),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldTextFormatNameCustom),
        .dataType = GPBDataTypeBytes,
      },
      {
        .name = "picURL",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoGroupNews_FieldNumber_PicURL,
        .hasIndex = 3,
        .offset = (uint32_t)offsetof(NCProtoGroupNews__storage_, picURL),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldTextFormatNameCustom),
        .dataType = GPBDataTypeBytes,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[NCProtoGroupNews class]
                                     rootClass:[NCProtoGroupMsgRoot class]
                                          file:NCProtoGroupMsgRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(NCProtoGroupNews__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
#if !GPBOBJC_SKIP_MESSAGE_TEXTFORMAT_EXTRAS
    static const char *extraTextFormatInfo =
        "\002\003!!!\000\004\003\241!!\000";
    [localDescriptor setupExtraTextInfo:extraTextFormatInfo];
#endif  
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif  
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

#pragma mark - NCProtoGroupMember

@implementation NCProtoGroupMember

@dynamic pubKey;
@dynamic nickName;
@dynamic role;
@dynamic joinTime;

typedef struct NCProtoGroupMember__storage_ {
  uint32_t _has_storage_[1];
  NCProtoGroupRole role;
  NSData *pubKey;
  NSString *nickName;
  int64_t joinTime;
} NCProtoGroupMember__storage_;



+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "pubKey",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoGroupMember_FieldNumber_PubKey,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(NCProtoGroupMember__storage_, pubKey),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeBytes,
      },
      {
        .name = "nickName",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoGroupMember_FieldNumber_NickName,
        .hasIndex = 1,
        .offset = (uint32_t)offsetof(NCProtoGroupMember__storage_, nickName),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeString,
      },
      {
        .name = "role",
        .dataTypeSpecific.enumDescFunc = NCProtoGroupRole_EnumDescriptor,
        .number = NCProtoGroupMember_FieldNumber_Role,
        .hasIndex = 2,
        .offset = (uint32_t)offsetof(NCProtoGroupMember__storage_, role),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldHasEnumDescriptor),
        .dataType = GPBDataTypeEnum,
      },
      {
        .name = "joinTime",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoGroupMember_FieldNumber_JoinTime,
        .hasIndex = 3,
        .offset = (uint32_t)offsetof(NCProtoGroupMember__storage_, joinTime),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeInt64,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[NCProtoGroupMember class]
                                     rootClass:[NCProtoGroupMsgRoot class]
                                          file:NCProtoGroupMsgRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(NCProtoGroupMember__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif  
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

int32_t NCProtoGroupMember_Role_RawValue(NCProtoGroupMember *message) {
  GPBDescriptor *descriptor = [NCProtoGroupMember descriptor];
  GPBFieldDescriptor *field = [descriptor fieldWithNumber:NCProtoGroupMember_FieldNumber_Role];
  return GPBGetMessageInt32Field(message, field);
}

void SetNCProtoGroupMember_Role_RawValue(NCProtoGroupMember *message, int32_t value) {
  GPBDescriptor *descriptor = [NCProtoGroupMember descriptor];
  GPBFieldDescriptor *field = [descriptor fieldWithNumber:NCProtoGroupMember_FieldNumber_Role];
  GPBSetInt32IvarWithFieldInternal(message, field, value, descriptor.file.syntax);
}

#pragma mark - NCProtoGroupGetMemberReq

@implementation NCProtoGroupGetMemberReq


typedef struct NCProtoGroupGetMemberReq__storage_ {
  uint32_t _has_storage_[1];
} NCProtoGroupGetMemberReq__storage_;



+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[NCProtoGroupGetMemberReq class]
                                     rootClass:[NCProtoGroupMsgRoot class]
                                          file:NCProtoGroupMsgRoot_FileDescriptor()
                                        fields:NULL
                                    fieldCount:0
                                   storageSize:sizeof(NCProtoGroupGetMemberReq__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif  
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

#pragma mark - NCProtoGroupGetMemberRsp

@implementation NCProtoGroupGetMemberRsp

@dynamic result;
@dynamic modifiedTime;
@dynamic membersArray, membersArray_Count;

typedef struct NCProtoGroupGetMemberRsp__storage_ {
  uint32_t _has_storage_[1];
  int32_t result;
  NSMutableArray *membersArray;
  int64_t modifiedTime;
} NCProtoGroupGetMemberRsp__storage_;



+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "result",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoGroupGetMemberRsp_FieldNumber_Result,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(NCProtoGroupGetMemberRsp__storage_, result),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeInt32,
      },
      {
        .name = "modifiedTime",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoGroupGetMemberRsp_FieldNumber_ModifiedTime,
        .hasIndex = 1,
        .offset = (uint32_t)offsetof(NCProtoGroupGetMemberRsp__storage_, modifiedTime),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeInt64,
      },
      {
        .name = "membersArray",
        .dataTypeSpecific.className = GPBStringifySymbol(NCProtoGroupMember),
        .number = NCProtoGroupGetMemberRsp_FieldNumber_MembersArray,
        .hasIndex = GPBNoHasBit,
        .offset = (uint32_t)offsetof(NCProtoGroupGetMemberRsp__storage_, membersArray),
        .flags = GPBFieldRepeated,
        .dataType = GPBDataTypeMessage,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[NCProtoGroupGetMemberRsp class]
                                     rootClass:[NCProtoGroupMsgRoot class]
                                          file:NCProtoGroupMsgRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(NCProtoGroupGetMemberRsp__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif  
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

#pragma mark - NCProtoGroupGetMsgReq

@implementation NCProtoGroupGetMsgReq

@dynamic beginId;
@dynamic endId;
@dynamic count;

typedef struct NCProtoGroupGetMsgReq__storage_ {
  uint32_t _has_storage_[1];
  int32_t count;
  int64_t beginId;
  int64_t endId;
} NCProtoGroupGetMsgReq__storage_;



+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "beginId",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoGroupGetMsgReq_FieldNumber_BeginId,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(NCProtoGroupGetMsgReq__storage_, beginId),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeInt64,
      },
      {
        .name = "endId",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoGroupGetMsgReq_FieldNumber_EndId,
        .hasIndex = 1,
        .offset = (uint32_t)offsetof(NCProtoGroupGetMsgReq__storage_, endId),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeInt64,
      },
      {
        .name = "count",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoGroupGetMsgReq_FieldNumber_Count,
        .hasIndex = 2,
        .offset = (uint32_t)offsetof(NCProtoGroupGetMsgReq__storage_, count),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeInt32,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[NCProtoGroupGetMsgReq class]
                                     rootClass:[NCProtoGroupMsgRoot class]
                                          file:NCProtoGroupMsgRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(NCProtoGroupGetMsgReq__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif  
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

#pragma mark - NCProtoGroupGetMsgRsp

@implementation NCProtoGroupGetMsgRsp

@dynamic result;
@dynamic beginId;
@dynamic endId;
@dynamic remainCount;
@dynamic msgsArray, msgsArray_Count;

typedef struct NCProtoGroupGetMsgRsp__storage_ {
  uint32_t _has_storage_[1];
  int32_t result;
  int32_t remainCount;
  NSMutableArray *msgsArray;
  int64_t beginId;
  int64_t endId;
} NCProtoGroupGetMsgRsp__storage_;



+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "result",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoGroupGetMsgRsp_FieldNumber_Result,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(NCProtoGroupGetMsgRsp__storage_, result),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeInt32,
      },
      {
        .name = "beginId",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoGroupGetMsgRsp_FieldNumber_BeginId,
        .hasIndex = 1,
        .offset = (uint32_t)offsetof(NCProtoGroupGetMsgRsp__storage_, beginId),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeInt64,
      },
      {
        .name = "endId",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoGroupGetMsgRsp_FieldNumber_EndId,
        .hasIndex = 2,
        .offset = (uint32_t)offsetof(NCProtoGroupGetMsgRsp__storage_, endId),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeInt64,
      },
      {
        .name = "remainCount",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoGroupGetMsgRsp_FieldNumber_RemainCount,
        .hasIndex = 3,
        .offset = (uint32_t)offsetof(NCProtoGroupGetMsgRsp__storage_, remainCount),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeInt32,
      },
      {
        .name = "msgsArray",
        .dataTypeSpecific.className = GPBStringifySymbol(NCProtoNetMsg),
        .number = NCProtoGroupGetMsgRsp_FieldNumber_MsgsArray,
        .hasIndex = GPBNoHasBit,
        .offset = (uint32_t)offsetof(NCProtoGroupGetMsgRsp__storage_, msgsArray),
        .flags = GPBFieldRepeated,
        .dataType = GPBDataTypeMessage,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[NCProtoGroupGetMsgRsp class]
                                     rootClass:[NCProtoGroupMsgRoot class]
                                          file:NCProtoGroupMsgRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(NCProtoGroupGetMsgRsp__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif  
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

#pragma mark - NCProtoGroupUnreadReq

@implementation NCProtoGroupUnreadReq

@dynamic groupPubKey;
@dynamic lastMsgId;

typedef struct NCProtoGroupUnreadReq__storage_ {
  uint32_t _has_storage_[1];
  NSData *groupPubKey;
  int64_t lastMsgId;
} NCProtoGroupUnreadReq__storage_;



+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "groupPubKey",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoGroupUnreadReq_FieldNumber_GroupPubKey,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(NCProtoGroupUnreadReq__storage_, groupPubKey),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeBytes,
      },
      {
        .name = "lastMsgId",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoGroupUnreadReq_FieldNumber_LastMsgId,
        .hasIndex = 1,
        .offset = (uint32_t)offsetof(NCProtoGroupUnreadReq__storage_, lastMsgId),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeInt64,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[NCProtoGroupUnreadReq class]
                                     rootClass:[NCProtoGroupMsgRoot class]
                                          file:NCProtoGroupMsgRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(NCProtoGroupUnreadReq__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif  
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

#pragma mark - NCProtoGroupUnreadRsp

@implementation NCProtoGroupUnreadRsp

@dynamic result;
@dynamic groupPubKey;
@dynamic unreadCount;
@dynamic hasLastMsg, lastMsg;

typedef struct NCProtoGroupUnreadRsp__storage_ {
  uint32_t _has_storage_[1];
  int32_t result;
  uint32_t unreadCount;
  NSData *groupPubKey;
  NCProtoNetMsg *lastMsg;
} NCProtoGroupUnreadRsp__storage_;



+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "result",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoGroupUnreadRsp_FieldNumber_Result,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(NCProtoGroupUnreadRsp__storage_, result),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeInt32,
      },
      {
        .name = "groupPubKey",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoGroupUnreadRsp_FieldNumber_GroupPubKey,
        .hasIndex = 1,
        .offset = (uint32_t)offsetof(NCProtoGroupUnreadRsp__storage_, groupPubKey),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeBytes,
      },
      {
        .name = "unreadCount",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoGroupUnreadRsp_FieldNumber_UnreadCount,
        .hasIndex = 2,
        .offset = (uint32_t)offsetof(NCProtoGroupUnreadRsp__storage_, unreadCount),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeUInt32,
      },
      {
        .name = "lastMsg",
        .dataTypeSpecific.className = GPBStringifySymbol(NCProtoNetMsg),
        .number = NCProtoGroupUnreadRsp_FieldNumber_LastMsg,
        .hasIndex = 3,
        .offset = (uint32_t)offsetof(NCProtoGroupUnreadRsp__storage_, lastMsg),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeMessage,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[NCProtoGroupUnreadRsp class]
                                     rootClass:[NCProtoGroupMsgRoot class]
                                          file:NCProtoGroupMsgRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(NCProtoGroupUnreadRsp__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif  
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

#pragma mark - NCProtoGroupGetUnreadReq

@implementation NCProtoGroupGetUnreadReq

@dynamic reqItemsArray, reqItemsArray_Count;

typedef struct NCProtoGroupGetUnreadReq__storage_ {
  uint32_t _has_storage_[1];
  NSMutableArray *reqItemsArray;
} NCProtoGroupGetUnreadReq__storage_;



+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "reqItemsArray",
        .dataTypeSpecific.className = GPBStringifySymbol(NCProtoGroupUnreadReq),
        .number = NCProtoGroupGetUnreadReq_FieldNumber_ReqItemsArray,
        .hasIndex = GPBNoHasBit,
        .offset = (uint32_t)offsetof(NCProtoGroupGetUnreadReq__storage_, reqItemsArray),
        .flags = GPBFieldRepeated,
        .dataType = GPBDataTypeMessage,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[NCProtoGroupGetUnreadReq class]
                                     rootClass:[NCProtoGroupMsgRoot class]
                                          file:NCProtoGroupMsgRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(NCProtoGroupGetUnreadReq__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif  
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

#pragma mark - NCProtoGroupGetUnreadRsp

@implementation NCProtoGroupGetUnreadRsp

@dynamic result;
@dynamic rspItemsArray, rspItemsArray_Count;

typedef struct NCProtoGroupGetUnreadRsp__storage_ {
  uint32_t _has_storage_[1];
  int32_t result;
  NSMutableArray *rspItemsArray;
} NCProtoGroupGetUnreadRsp__storage_;



+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "result",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoGroupGetUnreadRsp_FieldNumber_Result,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(NCProtoGroupGetUnreadRsp__storage_, result),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeInt32,
      },
      {
        .name = "rspItemsArray",
        .dataTypeSpecific.className = GPBStringifySymbol(NCProtoGroupUnreadRsp),
        .number = NCProtoGroupGetUnreadRsp_FieldNumber_RspItemsArray,
        .hasIndex = GPBNoHasBit,
        .offset = (uint32_t)offsetof(NCProtoGroupGetUnreadRsp__storage_, rspItemsArray),
        .flags = GPBFieldRepeated,
        .dataType = GPBDataTypeMessage,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[NCProtoGroupGetUnreadRsp class]
                                     rootClass:[NCProtoGroupMsgRoot class]
                                          file:NCProtoGroupMsgRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(NCProtoGroupGetUnreadRsp__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif  
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

#pragma mark - NCProtoGroupUpdateInviteType

@implementation NCProtoGroupUpdateInviteType

@dynamic inviteType;

typedef struct NCProtoGroupUpdateInviteType__storage_ {
  uint32_t _has_storage_[1];
  int32_t inviteType;
} NCProtoGroupUpdateInviteType__storage_;



+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "inviteType",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoGroupUpdateInviteType_FieldNumber_InviteType,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(NCProtoGroupUpdateInviteType__storage_, inviteType),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeInt32,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[NCProtoGroupUpdateInviteType class]
                                     rootClass:[NCProtoGroupMsgRoot class]
                                          file:NCProtoGroupMsgRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(NCProtoGroupUpdateInviteType__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif  
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

#pragma mark - NCProtoGroupJoinApproveNotify

@implementation NCProtoGroupJoinApproveNotify

@dynamic hasJoinMsg, joinMsg;

typedef struct NCProtoGroupJoinApproveNotify__storage_ {
  uint32_t _has_storage_[1];
  NCProtoNetMsg *joinMsg;
} NCProtoGroupJoinApproveNotify__storage_;



+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "joinMsg",
        .dataTypeSpecific.className = GPBStringifySymbol(NCProtoNetMsg),
        .number = NCProtoGroupJoinApproveNotify_FieldNumber_JoinMsg,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(NCProtoGroupJoinApproveNotify__storage_, joinMsg),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeMessage,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[NCProtoGroupJoinApproveNotify class]
                                     rootClass:[NCProtoGroupMsgRoot class]
                                          file:NCProtoGroupMsgRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(NCProtoGroupJoinApproveNotify__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif  
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

#pragma mark - NCProtoGroupJoinApproved

@implementation NCProtoGroupJoinApproved

@dynamic hasJoinMsg, joinMsg;
@dynamic groupPrivateKey;
@dynamic groupName;

typedef struct NCProtoGroupJoinApproved__storage_ {
  uint32_t _has_storage_[1];
  NCProtoNetMsg *joinMsg;
  NSData *groupPrivateKey;
  NSString *groupName;
} NCProtoGroupJoinApproved__storage_;



+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "joinMsg",
        .dataTypeSpecific.className = GPBStringifySymbol(NCProtoNetMsg),
        .number = NCProtoGroupJoinApproved_FieldNumber_JoinMsg,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(NCProtoGroupJoinApproved__storage_, joinMsg),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeMessage,
      },
      {
        .name = "groupPrivateKey",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoGroupJoinApproved_FieldNumber_GroupPrivateKey,
        .hasIndex = 1,
        .offset = (uint32_t)offsetof(NCProtoGroupJoinApproved__storage_, groupPrivateKey),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeBytes,
      },
      {
        .name = "groupName",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoGroupJoinApproved_FieldNumber_GroupName,
        .hasIndex = 2,
        .offset = (uint32_t)offsetof(NCProtoGroupJoinApproved__storage_, groupName),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeString,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[NCProtoGroupJoinApproved class]
                                     rootClass:[NCProtoGroupMsgRoot class]
                                          file:NCProtoGroupMsgRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(NCProtoGroupJoinApproved__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif  
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

#pragma mark - NCProtoGroupMemberMute

@implementation NCProtoGroupMemberMute

@dynamic action;

typedef struct NCProtoGroupMemberMute__storage_ {
  uint32_t _has_storage_[1];
  NCProtoActionType action;
} NCProtoGroupMemberMute__storage_;



+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "action",
        .dataTypeSpecific.enumDescFunc = NCProtoActionType_EnumDescriptor,
        .number = NCProtoGroupMemberMute_FieldNumber_Action,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(NCProtoGroupMemberMute__storage_, action),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldHasEnumDescriptor),
        .dataType = GPBDataTypeEnum,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[NCProtoGroupMemberMute class]
                                     rootClass:[NCProtoGroupMsgRoot class]
                                          file:NCProtoGroupMsgRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(NCProtoGroupMemberMute__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif  
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

int32_t NCProtoGroupMemberMute_Action_RawValue(NCProtoGroupMemberMute *message) {
  GPBDescriptor *descriptor = [NCProtoGroupMemberMute descriptor];
  GPBFieldDescriptor *field = [descriptor fieldWithNumber:NCProtoGroupMemberMute_FieldNumber_Action];
  return GPBGetMessageInt32Field(message, field);
}

void SetNCProtoGroupMemberMute_Action_RawValue(NCProtoGroupMemberMute *message, int32_t value) {
  GPBDescriptor *descriptor = [NCProtoGroupMemberMute descriptor];
  GPBFieldDescriptor *field = [descriptor fieldWithNumber:NCProtoGroupMemberMute_FieldNumber_Action];
  GPBSetInt32IvarWithFieldInternal(message, field, value, descriptor.file.syntax);
}


#pragma clang diagnostic pop


