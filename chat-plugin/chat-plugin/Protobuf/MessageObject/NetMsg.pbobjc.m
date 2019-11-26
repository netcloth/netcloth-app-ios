




#if !defined(GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS)
 #define GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS 0
#endif

#if GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS
 #import <protobuf/GPBProtocolBuffers_RuntimeSupport.h>
#else
 #import "GPBProtocolBuffers_RuntimeSupport.h"
#endif

#import <stdatomic.h>

#import "NetMsg.pbobjc.h"




@implementation NCProtoNetMsgRoot




@end


static GPBFileDescriptor *NCProtoNetMsgRoot_FileDescriptor(void) {


  static GPBFileDescriptor *descriptor = NULL;
  if (!descriptor) {
    GPB_DEBUG_CHECK_RUNTIME_VERSIONS();
    descriptor = [[GPBFileDescriptor alloc] initWithPackage:@"netcloth"
                                                 objcPrefix:@"NCProto"
                                                     syntax:GPBFileSyntaxProto3];
  }
  return descriptor;
}


GPBEnumDescriptor *NCProtoDeviceType_EnumDescriptor(void) {
  static _Atomic(GPBEnumDescriptor*) descriptor = nil;
  if (!descriptor) {
    static const char *valueNames =
        "Ios\000Android\000Pc\000";
    static const int32_t values[] = {
        NCProtoDeviceType_Ios,
        NCProtoDeviceType_Android,
        NCProtoDeviceType_Pc,
    };
    GPBEnumDescriptor *worker =
        [GPBEnumDescriptor allocDescriptorForName:GPBNSStringifySymbol(NCProtoDeviceType)
                                       valueNames:valueNames
                                           values:values
                                            count:(uint32_t)(sizeof(values) / sizeof(int32_t))
                                     enumVerifier:NCProtoDeviceType_IsValidValue];
    GPBEnumDescriptor *expected = nil;
    if (!atomic_compare_exchange_strong(&descriptor, &expected, worker)) {
      [worker release];
    }
  }
  return descriptor;
}

BOOL NCProtoDeviceType_IsValidValue(int32_t value__) {
  switch (value__) {
    case NCProtoDeviceType_Ios:
    case NCProtoDeviceType_Android:
    case NCProtoDeviceType_Pc:
      return YES;
    default:
      return NO;
  }
}


@implementation NCProtoNetMsg

@dynamic name;
@dynamic data_p;
@dynamic compress;
@dynamic hasHead, head;

typedef struct NCProtoNetMsg__storage_ {
  uint32_t _has_storage_[1];
  NSString *name;
  NSData *data_p;
  NCProtoHead *head;
} NCProtoNetMsg__storage_;



+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "name",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoNetMsg_FieldNumber_Name,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(NCProtoNetMsg__storage_, name),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeString,
      },
      {
        .name = "data_p",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoNetMsg_FieldNumber_Data_p,
        .hasIndex = 1,
        .offset = (uint32_t)offsetof(NCProtoNetMsg__storage_, data_p),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeBytes,
      },
      {
        .name = "compress",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoNetMsg_FieldNumber_Compress,
        .hasIndex = 2,
        .offset = 3, 
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeBool,
      },
      {
        .name = "head",
        .dataTypeSpecific.className = GPBStringifySymbol(NCProtoHead),
        .number = NCProtoNetMsg_FieldNumber_Head,
        .hasIndex = 4,
        .offset = (uint32_t)offsetof(NCProtoNetMsg__storage_, head),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeMessage,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[NCProtoNetMsg class]
                                     rootClass:[NCProtoNetMsgRoot class]
                                          file:NCProtoNetMsgRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(NCProtoNetMsg__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif 
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end


@implementation NCProtoHead

@dynamic fromPubKey;
@dynamic toPubKey;
@dynamic signature;
@dynamic msgTime;

typedef struct NCProtoHead__storage_ {
  uint32_t _has_storage_[1];
  NSData *fromPubKey;
  NSData *toPubKey;
  NSData *signature;
  uint64_t msgTime;
} NCProtoHead__storage_;



+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "fromPubKey",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoHead_FieldNumber_FromPubKey,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(NCProtoHead__storage_, fromPubKey),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeBytes,
      },
      {
        .name = "toPubKey",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoHead_FieldNumber_ToPubKey,
        .hasIndex = 1,
        .offset = (uint32_t)offsetof(NCProtoHead__storage_, toPubKey),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeBytes,
      },
      {
        .name = "signature",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoHead_FieldNumber_Signature,
        .hasIndex = 2,
        .offset = (uint32_t)offsetof(NCProtoHead__storage_, signature),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeBytes,
      },
      {
        .name = "msgTime",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoHead_FieldNumber_MsgTime,
        .hasIndex = 3,
        .offset = (uint32_t)offsetof(NCProtoHead__storage_, msgTime),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeUInt64,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[NCProtoHead class]
                                     rootClass:[NCProtoNetMsgRoot class]
                                          file:NCProtoNetMsgRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(NCProtoHead__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif 
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end


@implementation NCProtoHeartbeat


typedef struct NCProtoHeartbeat__storage_ {
  uint32_t _has_storage_[1];
} NCProtoHeartbeat__storage_;



+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[NCProtoHeartbeat class]
                                     rootClass:[NCProtoNetMsgRoot class]
                                          file:NCProtoNetMsgRoot_FileDescriptor()
                                        fields:NULL
                                    fieldCount:0
                                   storageSize:sizeof(NCProtoHeartbeat__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif 
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end


@implementation NCProtoClientReceipt

@dynamic result;

typedef struct NCProtoClientReceipt__storage_ {
  uint32_t _has_storage_[1];
  int32_t result;
} NCProtoClientReceipt__storage_;



+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "result",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoClientReceipt_FieldNumber_Result,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(NCProtoClientReceipt__storage_, result),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeInt32,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[NCProtoClientReceipt class]
                                     rootClass:[NCProtoNetMsgRoot class]
                                          file:NCProtoNetMsgRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(NCProtoClientReceipt__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif 
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end


@implementation NCProtoServerReceipt

@dynamic result;

typedef struct NCProtoServerReceipt__storage_ {
  uint32_t _has_storage_[1];
  int32_t result;
} NCProtoServerReceipt__storage_;



+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "result",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoServerReceipt_FieldNumber_Result,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(NCProtoServerReceipt__storage_, result),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeInt32,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[NCProtoServerReceipt class]
                                     rootClass:[NCProtoNetMsgRoot class]
                                          file:NCProtoNetMsgRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(NCProtoServerReceipt__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif 
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end


@implementation NCProtoRegisterReq

@dynamic deviceType;
@dynamic version;

typedef struct NCProtoRegisterReq__storage_ {
  uint32_t _has_storage_[1];
  NCProtoDeviceType deviceType;
  uint32_t version;
} NCProtoRegisterReq__storage_;



+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "deviceType",
        .dataTypeSpecific.enumDescFunc = NCProtoDeviceType_EnumDescriptor,
        .number = NCProtoRegisterReq_FieldNumber_DeviceType,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(NCProtoRegisterReq__storage_, deviceType),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldHasEnumDescriptor),
        .dataType = GPBDataTypeEnum,
      },
      {
        .name = "version",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoRegisterReq_FieldNumber_Version,
        .hasIndex = 1,
        .offset = (uint32_t)offsetof(NCProtoRegisterReq__storage_, version),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeUInt32,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[NCProtoRegisterReq class]
                                     rootClass:[NCProtoNetMsgRoot class]
                                          file:NCProtoNetMsgRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(NCProtoRegisterReq__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif 
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

int32_t NCProtoRegisterReq_DeviceType_RawValue(NCProtoRegisterReq *message) {
  GPBDescriptor *descriptor = [NCProtoRegisterReq descriptor];
  GPBFieldDescriptor *field = [descriptor fieldWithNumber:NCProtoRegisterReq_FieldNumber_DeviceType];
  return GPBGetMessageInt32Field(message, field);
}

void SetNCProtoRegisterReq_DeviceType_RawValue(NCProtoRegisterReq *message, int32_t value) {
  GPBDescriptor *descriptor = [NCProtoRegisterReq descriptor];
  GPBFieldDescriptor *field = [descriptor fieldWithNumber:NCProtoRegisterReq_FieldNumber_DeviceType];
  GPBSetInt32IvarWithFieldInternal(message, field, value, descriptor.file.syntax);
}


@implementation NCProtoRegisterRsp

@dynamic result;
@dynamic serverPubKey;

typedef struct NCProtoRegisterRsp__storage_ {
  uint32_t _has_storage_[1];
  int32_t result;
  NSData *serverPubKey;
} NCProtoRegisterRsp__storage_;



+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "result",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoRegisterRsp_FieldNumber_Result,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(NCProtoRegisterRsp__storage_, result),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeInt32,
      },
      {
        .name = "serverPubKey",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoRegisterRsp_FieldNumber_ServerPubKey,
        .hasIndex = 1,
        .offset = (uint32_t)offsetof(NCProtoRegisterRsp__storage_, serverPubKey),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeBytes,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[NCProtoRegisterRsp class]
                                     rootClass:[NCProtoNetMsgRoot class]
                                          file:NCProtoNetMsgRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(NCProtoRegisterRsp__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif 
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end


@implementation NCProtoAppleIdBind

@dynamic appleId;

typedef struct NCProtoAppleIdBind__storage_ {
  uint32_t _has_storage_[1];
  NSString *appleId;
} NCProtoAppleIdBind__storage_;



+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "appleId",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoAppleIdBind_FieldNumber_AppleId,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(NCProtoAppleIdBind__storage_, appleId),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeString,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[NCProtoAppleIdBind class]
                                     rootClass:[NCProtoNetMsgRoot class]
                                          file:NCProtoNetMsgRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(NCProtoAppleIdBind__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif 
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end


@implementation NCProtoAppleIdUnbind

@dynamic appleId;

typedef struct NCProtoAppleIdUnbind__storage_ {
  uint32_t _has_storage_[1];
  NSString *appleId;
} NCProtoAppleIdUnbind__storage_;



+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "appleId",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoAppleIdUnbind_FieldNumber_AppleId,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(NCProtoAppleIdUnbind__storage_, appleId),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeString,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[NCProtoAppleIdUnbind class]
                                     rootClass:[NCProtoNetMsgRoot class]
                                          file:NCProtoNetMsgRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(NCProtoAppleIdUnbind__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif 
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end


@implementation NCProtoCacheMsgReq

@dynamic roundId;
@dynamic time;
@dynamic hash_p;
@dynamic size;

typedef struct NCProtoCacheMsgReq__storage_ {
  uint32_t _has_storage_[1];
  uint32_t roundId;
  uint32_t size;
  uint64_t time;
  uint64_t hash_p;
} NCProtoCacheMsgReq__storage_;



+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "roundId",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoCacheMsgReq_FieldNumber_RoundId,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(NCProtoCacheMsgReq__storage_, roundId),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeUInt32,
      },
      {
        .name = "time",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoCacheMsgReq_FieldNumber_Time,
        .hasIndex = 1,
        .offset = (uint32_t)offsetof(NCProtoCacheMsgReq__storage_, time),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeUInt64,
      },
      {
        .name = "hash_p",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoCacheMsgReq_FieldNumber_Hash_p,
        .hasIndex = 2,
        .offset = (uint32_t)offsetof(NCProtoCacheMsgReq__storage_, hash_p),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeUInt64,
      },
      {
        .name = "size",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoCacheMsgReq_FieldNumber_Size,
        .hasIndex = 3,
        .offset = (uint32_t)offsetof(NCProtoCacheMsgReq__storage_, size),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeUInt32,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[NCProtoCacheMsgReq class]
                                     rootClass:[NCProtoNetMsgRoot class]
                                          file:NCProtoNetMsgRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(NCProtoCacheMsgReq__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif 
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end


@implementation NCProtoCacheMsgRsp

@dynamic roundId;
@dynamic msgsArray, msgsArray_Count;

typedef struct NCProtoCacheMsgRsp__storage_ {
  uint32_t _has_storage_[1];
  uint32_t roundId;
  NSMutableArray *msgsArray;
} NCProtoCacheMsgRsp__storage_;



+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "roundId",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoCacheMsgRsp_FieldNumber_RoundId,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(NCProtoCacheMsgRsp__storage_, roundId),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeUInt32,
      },
      {
        .name = "msgsArray",
        .dataTypeSpecific.className = GPBStringifySymbol(NCProtoNetMsg),
        .number = NCProtoCacheMsgRsp_FieldNumber_MsgsArray,
        .hasIndex = GPBNoHasBit,
        .offset = (uint32_t)offsetof(NCProtoCacheMsgRsp__storage_, msgsArray),
        .flags = GPBFieldRepeated,
        .dataType = GPBDataTypeMessage,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[NCProtoCacheMsgRsp class]
                                     rootClass:[NCProtoNetMsgRoot class]
                                          file:NCProtoNetMsgRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(NCProtoCacheMsgRsp__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif 
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end




