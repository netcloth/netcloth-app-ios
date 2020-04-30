




#if !defined(GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS)
 #define GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS 0
#endif

#if GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS
 #import <protobuf/GPBProtocolBuffers_RuntimeSupport.h>
#else
 #import "GPBProtocolBuffers_RuntimeSupport.h"
#endif

#import "RecallMsg.pbobjc.h"
#import "CommonTypes.pbobjc.h"


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

#pragma mark - NCProtoRecallMsgRoot

@implementation NCProtoRecallMsgRoot




@end

#pragma mark - NCProtoRecallMsgRoot_FileDescriptor

static GPBFileDescriptor *NCProtoRecallMsgRoot_FileDescriptor(void) {
  
  
  static GPBFileDescriptor *descriptor = NULL;
  if (!descriptor) {
    GPB_DEBUG_CHECK_RUNTIME_VERSIONS();
    descriptor = [[GPBFileDescriptor alloc] initWithPackage:@"netcloth"
                                                 objcPrefix:@"NCProto"
                                                     syntax:GPBFileSyntaxProto3];
  }
  return descriptor;
}

#pragma mark - NCProtoRecallMsgReq

@implementation NCProtoRecallMsgReq

@dynamic fromAddr;
@dynamic fromCompressedPubKey;
@dynamic toCompressedPubKey;
@dynamic chatType;
@dynamic timestamp;
@dynamic r;
@dynamic s;
@dynamic v;
@dynamic outTradeNo;

typedef struct NCProtoRecallMsgReq__storage_ {
  uint32_t _has_storage_[1];
  NCProtoChatType chatType;
  NSData *fromAddr;
  NSData *fromCompressedPubKey;
  NSData *toCompressedPubKey;
  NSData *r;
  NSData *s;
  NSData *v;
  NSString *outTradeNo;
  int64_t timestamp;
} NCProtoRecallMsgReq__storage_;



+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "fromAddr",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoRecallMsgReq_FieldNumber_FromAddr,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(NCProtoRecallMsgReq__storage_, fromAddr),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeBytes,
      },
      {
        .name = "fromCompressedPubKey",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoRecallMsgReq_FieldNumber_FromCompressedPubKey,
        .hasIndex = 1,
        .offset = (uint32_t)offsetof(NCProtoRecallMsgReq__storage_, fromCompressedPubKey),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeBytes,
      },
      {
        .name = "toCompressedPubKey",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoRecallMsgReq_FieldNumber_ToCompressedPubKey,
        .hasIndex = 2,
        .offset = (uint32_t)offsetof(NCProtoRecallMsgReq__storage_, toCompressedPubKey),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeBytes,
      },
      {
        .name = "chatType",
        .dataTypeSpecific.enumDescFunc = NCProtoChatType_EnumDescriptor,
        .number = NCProtoRecallMsgReq_FieldNumber_ChatType,
        .hasIndex = 3,
        .offset = (uint32_t)offsetof(NCProtoRecallMsgReq__storage_, chatType),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldHasEnumDescriptor),
        .dataType = GPBDataTypeEnum,
      },
      {
        .name = "timestamp",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoRecallMsgReq_FieldNumber_Timestamp,
        .hasIndex = 4,
        .offset = (uint32_t)offsetof(NCProtoRecallMsgReq__storage_, timestamp),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeInt64,
      },
      {
        .name = "r",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoRecallMsgReq_FieldNumber_R,
        .hasIndex = 5,
        .offset = (uint32_t)offsetof(NCProtoRecallMsgReq__storage_, r),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeBytes,
      },
      {
        .name = "s",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoRecallMsgReq_FieldNumber_S,
        .hasIndex = 6,
        .offset = (uint32_t)offsetof(NCProtoRecallMsgReq__storage_, s),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeBytes,
      },
      {
        .name = "v",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoRecallMsgReq_FieldNumber_V,
        .hasIndex = 7,
        .offset = (uint32_t)offsetof(NCProtoRecallMsgReq__storage_, v),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeBytes,
      },
      {
        .name = "outTradeNo",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoRecallMsgReq_FieldNumber_OutTradeNo,
        .hasIndex = 8,
        .offset = (uint32_t)offsetof(NCProtoRecallMsgReq__storage_, outTradeNo),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeString,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[NCProtoRecallMsgReq class]
                                     rootClass:[NCProtoRecallMsgRoot class]
                                          file:NCProtoRecallMsgRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(NCProtoRecallMsgReq__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif  
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

int32_t NCProtoRecallMsgReq_ChatType_RawValue(NCProtoRecallMsgReq *message) {
  GPBDescriptor *descriptor = [NCProtoRecallMsgReq descriptor];
  GPBFieldDescriptor *field = [descriptor fieldWithNumber:NCProtoRecallMsgReq_FieldNumber_ChatType];
  return GPBGetMessageInt32Field(message, field);
}

void SetNCProtoRecallMsgReq_ChatType_RawValue(NCProtoRecallMsgReq *message, int32_t value) {
  GPBDescriptor *descriptor = [NCProtoRecallMsgReq descriptor];
  GPBFieldDescriptor *field = [descriptor fieldWithNumber:NCProtoRecallMsgReq_FieldNumber_ChatType];
  GPBSetInt32IvarWithFieldInternal(message, field, value, descriptor.file.syntax);
}

#pragma mark - NCProtoRecallMsgRsp

@implementation NCProtoRecallMsgRsp

@dynamic txHash;

typedef struct NCProtoRecallMsgRsp__storage_ {
  uint32_t _has_storage_[1];
  NSString *txHash;
} NCProtoRecallMsgRsp__storage_;



+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "txHash",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoRecallMsgRsp_FieldNumber_TxHash,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(NCProtoRecallMsgRsp__storage_, txHash),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeString,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[NCProtoRecallMsgRsp class]
                                     rootClass:[NCProtoRecallMsgRoot class]
                                          file:NCProtoRecallMsgRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(NCProtoRecallMsgRsp__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif  
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

#pragma mark - NCProtoRecallMsg

@implementation NCProtoRecallMsg

@dynamic fromPubKey;
@dynamic toPubKey;
@dynamic chatType;
@dynamic timestamp;

typedef struct NCProtoRecallMsg__storage_ {
  uint32_t _has_storage_[1];
  NCProtoChatType chatType;
  NSData *fromPubKey;
  NSData *toPubKey;
  int64_t timestamp;
} NCProtoRecallMsg__storage_;



+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "fromPubKey",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoRecallMsg_FieldNumber_FromPubKey,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(NCProtoRecallMsg__storage_, fromPubKey),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeBytes,
      },
      {
        .name = "toPubKey",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoRecallMsg_FieldNumber_ToPubKey,
        .hasIndex = 1,
        .offset = (uint32_t)offsetof(NCProtoRecallMsg__storage_, toPubKey),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeBytes,
      },
      {
        .name = "chatType",
        .dataTypeSpecific.enumDescFunc = NCProtoChatType_EnumDescriptor,
        .number = NCProtoRecallMsg_FieldNumber_ChatType,
        .hasIndex = 2,
        .offset = (uint32_t)offsetof(NCProtoRecallMsg__storage_, chatType),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldHasEnumDescriptor),
        .dataType = GPBDataTypeEnum,
      },
      {
        .name = "timestamp",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoRecallMsg_FieldNumber_Timestamp,
        .hasIndex = 3,
        .offset = (uint32_t)offsetof(NCProtoRecallMsg__storage_, timestamp),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeInt64,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[NCProtoRecallMsg class]
                                     rootClass:[NCProtoRecallMsgRoot class]
                                          file:NCProtoRecallMsgRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(NCProtoRecallMsg__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif  
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

int32_t NCProtoRecallMsg_ChatType_RawValue(NCProtoRecallMsg *message) {
  GPBDescriptor *descriptor = [NCProtoRecallMsg descriptor];
  GPBFieldDescriptor *field = [descriptor fieldWithNumber:NCProtoRecallMsg_FieldNumber_ChatType];
  return GPBGetMessageInt32Field(message, field);
}

void SetNCProtoRecallMsg_ChatType_RawValue(NCProtoRecallMsg *message, int32_t value) {
  GPBDescriptor *descriptor = [NCProtoRecallMsg descriptor];
  GPBFieldDescriptor *field = [descriptor fieldWithNumber:NCProtoRecallMsg_FieldNumber_ChatType];
  GPBSetInt32IvarWithFieldInternal(message, field, value, descriptor.file.syntax);
}

#pragma mark - NCProtoQueryRecallMsgReq

@implementation NCProtoQueryRecallMsgReq

@dynamic beginTime;
@dynamic endTime;
@dynamic groupPubKeysArray, groupPubKeysArray_Count;

typedef struct NCProtoQueryRecallMsgReq__storage_ {
  uint32_t _has_storage_[1];
  NSMutableArray *groupPubKeysArray;
  int64_t beginTime;
  int64_t endTime;
} NCProtoQueryRecallMsgReq__storage_;



+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "beginTime",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoQueryRecallMsgReq_FieldNumber_BeginTime,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(NCProtoQueryRecallMsgReq__storage_, beginTime),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeInt64,
      },
      {
        .name = "endTime",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoQueryRecallMsgReq_FieldNumber_EndTime,
        .hasIndex = 1,
        .offset = (uint32_t)offsetof(NCProtoQueryRecallMsgReq__storage_, endTime),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeInt64,
      },
      {
        .name = "groupPubKeysArray",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoQueryRecallMsgReq_FieldNumber_GroupPubKeysArray,
        .hasIndex = GPBNoHasBit,
        .offset = (uint32_t)offsetof(NCProtoQueryRecallMsgReq__storage_, groupPubKeysArray),
        .flags = GPBFieldRepeated,
        .dataType = GPBDataTypeBytes,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[NCProtoQueryRecallMsgReq class]
                                     rootClass:[NCProtoRecallMsgRoot class]
                                          file:NCProtoRecallMsgRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(NCProtoQueryRecallMsgReq__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif  
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

#pragma mark - NCProtoQueryRecallMsgRsp

@implementation NCProtoQueryRecallMsgRsp

@dynamic recallMsgsArray, recallMsgsArray_Count;

typedef struct NCProtoQueryRecallMsgRsp__storage_ {
  uint32_t _has_storage_[1];
  NSMutableArray *recallMsgsArray;
} NCProtoQueryRecallMsgRsp__storage_;



+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "recallMsgsArray",
        .dataTypeSpecific.className = GPBStringifySymbol(NCProtoRecallMsg),
        .number = NCProtoQueryRecallMsgRsp_FieldNumber_RecallMsgsArray,
        .hasIndex = GPBNoHasBit,
        .offset = (uint32_t)offsetof(NCProtoQueryRecallMsgRsp__storage_, recallMsgsArray),
        .flags = GPBFieldRepeated,
        .dataType = GPBDataTypeMessage,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[NCProtoQueryRecallMsgRsp class]
                                     rootClass:[NCProtoRecallMsgRoot class]
                                          file:NCProtoRecallMsgRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(NCProtoQueryRecallMsgRsp__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif  
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

#pragma mark - NCProtoQueryRecallStatusReq

@implementation NCProtoQueryRecallStatusReq

@dynamic relatedPubKey;
@dynamic chatType;

typedef struct NCProtoQueryRecallStatusReq__storage_ {
  uint32_t _has_storage_[1];
  NCProtoChatType chatType;
  NSData *relatedPubKey;
} NCProtoQueryRecallStatusReq__storage_;



+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "relatedPubKey",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoQueryRecallStatusReq_FieldNumber_RelatedPubKey,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(NCProtoQueryRecallStatusReq__storage_, relatedPubKey),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeBytes,
      },
      {
        .name = "chatType",
        .dataTypeSpecific.enumDescFunc = NCProtoChatType_EnumDescriptor,
        .number = NCProtoQueryRecallStatusReq_FieldNumber_ChatType,
        .hasIndex = 1,
        .offset = (uint32_t)offsetof(NCProtoQueryRecallStatusReq__storage_, chatType),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldHasEnumDescriptor),
        .dataType = GPBDataTypeEnum,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[NCProtoQueryRecallStatusReq class]
                                     rootClass:[NCProtoRecallMsgRoot class]
                                          file:NCProtoRecallMsgRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(NCProtoQueryRecallStatusReq__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif  
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

int32_t NCProtoQueryRecallStatusReq_ChatType_RawValue(NCProtoQueryRecallStatusReq *message) {
  GPBDescriptor *descriptor = [NCProtoQueryRecallStatusReq descriptor];
  GPBFieldDescriptor *field = [descriptor fieldWithNumber:NCProtoQueryRecallStatusReq_FieldNumber_ChatType];
  return GPBGetMessageInt32Field(message, field);
}

void SetNCProtoQueryRecallStatusReq_ChatType_RawValue(NCProtoQueryRecallStatusReq *message, int32_t value) {
  GPBDescriptor *descriptor = [NCProtoQueryRecallStatusReq descriptor];
  GPBFieldDescriptor *field = [descriptor fieldWithNumber:NCProtoQueryRecallStatusReq_FieldNumber_ChatType];
  GPBSetInt32IvarWithFieldInternal(message, field, value, descriptor.file.syntax);
}

#pragma mark - NCProtoQueryRecallStatusRsp

@implementation NCProtoQueryRecallStatusRsp

@dynamic fromPubKey;
@dynamic toPubKey;
@dynamic chatType;
@dynamic timestamp;
@dynamic outTradeNo;
@dynamic bizStatus;

typedef struct NCProtoQueryRecallStatusRsp__storage_ {
  uint32_t _has_storage_[1];
  NCProtoChatType chatType;
  NCProtoOrderBizStatus bizStatus;
  NSData *fromPubKey;
  NSData *toPubKey;
  NSString *outTradeNo;
  int64_t timestamp;
} NCProtoQueryRecallStatusRsp__storage_;



+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "fromPubKey",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoQueryRecallStatusRsp_FieldNumber_FromPubKey,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(NCProtoQueryRecallStatusRsp__storage_, fromPubKey),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeBytes,
      },
      {
        .name = "toPubKey",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoQueryRecallStatusRsp_FieldNumber_ToPubKey,
        .hasIndex = 1,
        .offset = (uint32_t)offsetof(NCProtoQueryRecallStatusRsp__storage_, toPubKey),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeBytes,
      },
      {
        .name = "chatType",
        .dataTypeSpecific.enumDescFunc = NCProtoChatType_EnumDescriptor,
        .number = NCProtoQueryRecallStatusRsp_FieldNumber_ChatType,
        .hasIndex = 2,
        .offset = (uint32_t)offsetof(NCProtoQueryRecallStatusRsp__storage_, chatType),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldHasEnumDescriptor),
        .dataType = GPBDataTypeEnum,
      },
      {
        .name = "timestamp",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoQueryRecallStatusRsp_FieldNumber_Timestamp,
        .hasIndex = 3,
        .offset = (uint32_t)offsetof(NCProtoQueryRecallStatusRsp__storage_, timestamp),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeInt64,
      },
      {
        .name = "outTradeNo",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoQueryRecallStatusRsp_FieldNumber_OutTradeNo,
        .hasIndex = 4,
        .offset = (uint32_t)offsetof(NCProtoQueryRecallStatusRsp__storage_, outTradeNo),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeString,
      },
      {
        .name = "bizStatus",
        .dataTypeSpecific.enumDescFunc = NCProtoOrderBizStatus_EnumDescriptor,
        .number = NCProtoQueryRecallStatusRsp_FieldNumber_BizStatus,
        .hasIndex = 5,
        .offset = (uint32_t)offsetof(NCProtoQueryRecallStatusRsp__storage_, bizStatus),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldHasEnumDescriptor),
        .dataType = GPBDataTypeEnum,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[NCProtoQueryRecallStatusRsp class]
                                     rootClass:[NCProtoRecallMsgRoot class]
                                          file:NCProtoRecallMsgRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(NCProtoQueryRecallStatusRsp__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif  
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

int32_t NCProtoQueryRecallStatusRsp_ChatType_RawValue(NCProtoQueryRecallStatusRsp *message) {
  GPBDescriptor *descriptor = [NCProtoQueryRecallStatusRsp descriptor];
  GPBFieldDescriptor *field = [descriptor fieldWithNumber:NCProtoQueryRecallStatusRsp_FieldNumber_ChatType];
  return GPBGetMessageInt32Field(message, field);
}

void SetNCProtoQueryRecallStatusRsp_ChatType_RawValue(NCProtoQueryRecallStatusRsp *message, int32_t value) {
  GPBDescriptor *descriptor = [NCProtoQueryRecallStatusRsp descriptor];
  GPBFieldDescriptor *field = [descriptor fieldWithNumber:NCProtoQueryRecallStatusRsp_FieldNumber_ChatType];
  GPBSetInt32IvarWithFieldInternal(message, field, value, descriptor.file.syntax);
}

int32_t NCProtoQueryRecallStatusRsp_BizStatus_RawValue(NCProtoQueryRecallStatusRsp *message) {
  GPBDescriptor *descriptor = [NCProtoQueryRecallStatusRsp descriptor];
  GPBFieldDescriptor *field = [descriptor fieldWithNumber:NCProtoQueryRecallStatusRsp_FieldNumber_BizStatus];
  return GPBGetMessageInt32Field(message, field);
}

void SetNCProtoQueryRecallStatusRsp_BizStatus_RawValue(NCProtoQueryRecallStatusRsp *message, int32_t value) {
  GPBDescriptor *descriptor = [NCProtoQueryRecallStatusRsp descriptor];
  GPBFieldDescriptor *field = [descriptor fieldWithNumber:NCProtoQueryRecallStatusRsp_FieldNumber_BizStatus];
  GPBSetInt32IvarWithFieldInternal(message, field, value, descriptor.file.syntax);
}

#pragma mark - NCProtoRecallMsgNotify

@implementation NCProtoRecallMsgNotify

@dynamic chatType;
@dynamic timestamp;

typedef struct NCProtoRecallMsgNotify__storage_ {
  uint32_t _has_storage_[1];
  NCProtoChatType chatType;
  int64_t timestamp;
} NCProtoRecallMsgNotify__storage_;



+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "chatType",
        .dataTypeSpecific.enumDescFunc = NCProtoChatType_EnumDescriptor,
        .number = NCProtoRecallMsgNotify_FieldNumber_ChatType,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(NCProtoRecallMsgNotify__storage_, chatType),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldHasEnumDescriptor),
        .dataType = GPBDataTypeEnum,
      },
      {
        .name = "timestamp",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoRecallMsgNotify_FieldNumber_Timestamp,
        .hasIndex = 1,
        .offset = (uint32_t)offsetof(NCProtoRecallMsgNotify__storage_, timestamp),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeInt64,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[NCProtoRecallMsgNotify class]
                                     rootClass:[NCProtoRecallMsgRoot class]
                                          file:NCProtoRecallMsgRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(NCProtoRecallMsgNotify__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif  
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

int32_t NCProtoRecallMsgNotify_ChatType_RawValue(NCProtoRecallMsgNotify *message) {
  GPBDescriptor *descriptor = [NCProtoRecallMsgNotify descriptor];
  GPBFieldDescriptor *field = [descriptor fieldWithNumber:NCProtoRecallMsgNotify_FieldNumber_ChatType];
  return GPBGetMessageInt32Field(message, field);
}

void SetNCProtoRecallMsgNotify_ChatType_RawValue(NCProtoRecallMsgNotify *message, int32_t value) {
  GPBDescriptor *descriptor = [NCProtoRecallMsgNotify descriptor];
  GPBFieldDescriptor *field = [descriptor fieldWithNumber:NCProtoRecallMsgNotify_FieldNumber_ChatType];
  GPBSetInt32IvarWithFieldInternal(message, field, value, descriptor.file.syntax);
}

#pragma mark - NCProtoRecallMsgFailedNotify

@implementation NCProtoRecallMsgFailedNotify

@dynamic chatType;
@dynamic timestamp;
@dynamic outTradeNo;

typedef struct NCProtoRecallMsgFailedNotify__storage_ {
  uint32_t _has_storage_[1];
  NCProtoChatType chatType;
  NSString *outTradeNo;
  int64_t timestamp;
} NCProtoRecallMsgFailedNotify__storage_;



+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "chatType",
        .dataTypeSpecific.enumDescFunc = NCProtoChatType_EnumDescriptor,
        .number = NCProtoRecallMsgFailedNotify_FieldNumber_ChatType,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(NCProtoRecallMsgFailedNotify__storage_, chatType),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldHasEnumDescriptor),
        .dataType = GPBDataTypeEnum,
      },
      {
        .name = "timestamp",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoRecallMsgFailedNotify_FieldNumber_Timestamp,
        .hasIndex = 1,
        .offset = (uint32_t)offsetof(NCProtoRecallMsgFailedNotify__storage_, timestamp),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeInt64,
      },
      {
        .name = "outTradeNo",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoRecallMsgFailedNotify_FieldNumber_OutTradeNo,
        .hasIndex = 2,
        .offset = (uint32_t)offsetof(NCProtoRecallMsgFailedNotify__storage_, outTradeNo),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeString,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[NCProtoRecallMsgFailedNotify class]
                                     rootClass:[NCProtoRecallMsgRoot class]
                                          file:NCProtoRecallMsgRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(NCProtoRecallMsgFailedNotify__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif  
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

int32_t NCProtoRecallMsgFailedNotify_ChatType_RawValue(NCProtoRecallMsgFailedNotify *message) {
  GPBDescriptor *descriptor = [NCProtoRecallMsgFailedNotify descriptor];
  GPBFieldDescriptor *field = [descriptor fieldWithNumber:NCProtoRecallMsgFailedNotify_FieldNumber_ChatType];
  return GPBGetMessageInt32Field(message, field);
}

void SetNCProtoRecallMsgFailedNotify_ChatType_RawValue(NCProtoRecallMsgFailedNotify *message, int32_t value) {
  GPBDescriptor *descriptor = [NCProtoRecallMsgFailedNotify descriptor];
  GPBFieldDescriptor *field = [descriptor fieldWithNumber:NCProtoRecallMsgFailedNotify_FieldNumber_ChatType];
  GPBSetInt32IvarWithFieldInternal(message, field, value, descriptor.file.syntax);
}


#pragma clang diagnostic pop


