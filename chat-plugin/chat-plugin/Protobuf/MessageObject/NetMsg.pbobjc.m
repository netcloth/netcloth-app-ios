




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


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

#pragma mark - NCProtoNetMsgRoot

@implementation NCProtoNetMsgRoot




@end

#pragma mark - NCProtoNetMsgRoot_FileDescriptor

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

#pragma mark - Enum NCProtoDeviceType

GPBEnumDescriptor *NCProtoDeviceType_EnumDescriptor(void) {
  static _Atomic(GPBEnumDescriptor*) descriptor = nil;
  if (!descriptor) {
    static const char *valueNames =
        "DeviceTypeUnspecified\000DeviceTypeAndroid\000"
        "DeviceTypeIos\000DeviceTypePc\000";
    static const int32_t values[] = {
        NCProtoDeviceType_DeviceTypeUnspecified,
        NCProtoDeviceType_DeviceTypeAndroid,
        NCProtoDeviceType_DeviceTypeIos,
        NCProtoDeviceType_DeviceTypePc,
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
    case NCProtoDeviceType_DeviceTypeUnspecified:
    case NCProtoDeviceType_DeviceTypeAndroid:
    case NCProtoDeviceType_DeviceTypeIos:
    case NCProtoDeviceType_DeviceTypePc:
      return YES;
    default:
      return NO;
  }
}

#pragma mark - Enum NCProtoAppID

GPBEnumDescriptor *NCProtoAppID_EnumDescriptor(void) {
  static _Atomic(GPBEnumDescriptor*) descriptor = nil;
  if (!descriptor) {
    static const char *valueNames =
        "AppidUnspecified\000AppidNetcloth\000AppidQIsl"
        "and\000";
    static const int32_t values[] = {
        NCProtoAppID_AppidUnspecified,
        NCProtoAppID_AppidNetcloth,
        NCProtoAppID_AppidQIsland,
    };
    GPBEnumDescriptor *worker =
        [GPBEnumDescriptor allocDescriptorForName:GPBNSStringifySymbol(NCProtoAppID)
                                       valueNames:valueNames
                                           values:values
                                            count:(uint32_t)(sizeof(values) / sizeof(int32_t))
                                     enumVerifier:NCProtoAppID_IsValidValue];
    GPBEnumDescriptor *expected = nil;
    if (!atomic_compare_exchange_strong(&descriptor, &expected, worker)) {
      [worker release];
    }
  }
  return descriptor;
}

BOOL NCProtoAppID_IsValidValue(int32_t value__) {
  switch (value__) {
    case NCProtoAppID_AppidUnspecified:
    case NCProtoAppID_AppidNetcloth:
    case NCProtoAppID_AppidQIsland:
      return YES;
    default:
      return NO;
  }
}

#pragma mark - Enum NCProtoPushChannel

GPBEnumDescriptor *NCProtoPushChannel_EnumDescriptor(void) {
  static _Atomic(GPBEnumDescriptor*) descriptor = nil;
  if (!descriptor) {
    static const char *valueNames =
        "PushChannelUnspecified\000PushChannelApns\000P"
        "ushChannelUmeng\000";
    static const int32_t values[] = {
        NCProtoPushChannel_PushChannelUnspecified,
        NCProtoPushChannel_PushChannelApns,
        NCProtoPushChannel_PushChannelUmeng,
    };
    GPBEnumDescriptor *worker =
        [GPBEnumDescriptor allocDescriptorForName:GPBNSStringifySymbol(NCProtoPushChannel)
                                       valueNames:valueNames
                                           values:values
                                            count:(uint32_t)(sizeof(values) / sizeof(int32_t))
                                     enumVerifier:NCProtoPushChannel_IsValidValue];
    GPBEnumDescriptor *expected = nil;
    if (!atomic_compare_exchange_strong(&descriptor, &expected, worker)) {
      [worker release];
    }
  }
  return descriptor;
}

BOOL NCProtoPushChannel_IsValidValue(int32_t value__) {
  switch (value__) {
    case NCProtoPushChannel_PushChannelUnspecified:
    case NCProtoPushChannel_PushChannelApns:
    case NCProtoPushChannel_PushChannelUmeng:
      return YES;
    default:
      return NO;
  }
}

#pragma mark - Enum NCProtoDeleteAction

GPBEnumDescriptor *NCProtoDeleteAction_EnumDescriptor(void) {
  static _Atomic(GPBEnumDescriptor*) descriptor = nil;
  if (!descriptor) {
    static const char *valueNames =
        "DeleteActionUnspecified\000DeleteActionHash"
        "\000DeleteActionSession\000DeleteActionAll\000";
    static const int32_t values[] = {
        NCProtoDeleteAction_DeleteActionUnspecified,
        NCProtoDeleteAction_DeleteActionHash,
        NCProtoDeleteAction_DeleteActionSession,
        NCProtoDeleteAction_DeleteActionAll,
    };
    GPBEnumDescriptor *worker =
        [GPBEnumDescriptor allocDescriptorForName:GPBNSStringifySymbol(NCProtoDeleteAction)
                                       valueNames:valueNames
                                           values:values
                                            count:(uint32_t)(sizeof(values) / sizeof(int32_t))
                                     enumVerifier:NCProtoDeleteAction_IsValidValue];
    GPBEnumDescriptor *expected = nil;
    if (!atomic_compare_exchange_strong(&descriptor, &expected, worker)) {
      [worker release];
    }
  }
  return descriptor;
}

BOOL NCProtoDeleteAction_IsValidValue(int32_t value__) {
  switch (value__) {
    case NCProtoDeleteAction_DeleteActionUnspecified:
    case NCProtoDeleteAction_DeleteActionHash:
    case NCProtoDeleteAction_DeleteActionSession:
    case NCProtoDeleteAction_DeleteActionAll:
      return YES;
    default:
      return NO;
  }
}

#pragma mark - NCProtoNetMsg

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

#pragma mark - NCProtoHead

@implementation NCProtoHead

@dynamic fromPubKey;
@dynamic toPubKey;
@dynamic signature;
@dynamic msgTime;
@dynamic msgId;

typedef struct NCProtoHead__storage_ {
  uint32_t _has_storage_[1];
  NSData *fromPubKey;
  NSData *toPubKey;
  NSData *signature;
  uint64_t msgTime;
  int64_t msgId;
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
      {
        .name = "msgId",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoHead_FieldNumber_MsgId,
        .hasIndex = 4,
        .offset = (uint32_t)offsetof(NCProtoHead__storage_, msgId),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeInt64,
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

#pragma mark - NCProtoHeartbeat

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

#pragma mark - NCProtoClientReceipt

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

#pragma mark - NCProtoServerReceipt

@implementation NCProtoServerReceipt

@dynamic result;
@dynamic msgName;

typedef struct NCProtoServerReceipt__storage_ {
  uint32_t _has_storage_[1];
  int32_t result;
  NSString *msgName;
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
      {
        .name = "msgName",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoServerReceipt_FieldNumber_MsgName,
        .hasIndex = 1,
        .offset = (uint32_t)offsetof(NCProtoServerReceipt__storage_, msgName),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeString,
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

#pragma mark - NCProtoRegisterReq

@implementation NCProtoRegisterReq

@dynamic deviceType;
@dynamic version;
@dynamic appId;

typedef struct NCProtoRegisterReq__storage_ {
  uint32_t _has_storage_[1];
  NCProtoDeviceType deviceType;
  uint32_t version;
  NCProtoAppID appId;
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
      {
        .name = "appId",
        .dataTypeSpecific.enumDescFunc = NCProtoAppID_EnumDescriptor,
        .number = NCProtoRegisterReq_FieldNumber_AppId,
        .hasIndex = 2,
        .offset = (uint32_t)offsetof(NCProtoRegisterReq__storage_, appId),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldHasEnumDescriptor),
        .dataType = GPBDataTypeEnum,
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

int32_t NCProtoRegisterReq_AppId_RawValue(NCProtoRegisterReq *message) {
  GPBDescriptor *descriptor = [NCProtoRegisterReq descriptor];
  GPBFieldDescriptor *field = [descriptor fieldWithNumber:NCProtoRegisterReq_FieldNumber_AppId];
  return GPBGetMessageInt32Field(message, field);
}

void SetNCProtoRegisterReq_AppId_RawValue(NCProtoRegisterReq *message, int32_t value) {
  GPBDescriptor *descriptor = [NCProtoRegisterReq descriptor];
  GPBFieldDescriptor *field = [descriptor fieldWithNumber:NCProtoRegisterReq_FieldNumber_AppId];
  GPBSetInt32IvarWithFieldInternal(message, field, value, descriptor.file.syntax);
}

#pragma mark - NCProtoRegisterRsp

@implementation NCProtoRegisterRsp

@dynamic result;
@dynamic serverPubKey;
@dynamic token;

typedef struct NCProtoRegisterRsp__storage_ {
  uint32_t _has_storage_[1];
  int32_t result;
  NSData *serverPubKey;
  NSString *token;
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
      {
        .name = "token",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoRegisterRsp_FieldNumber_Token,
        .hasIndex = 2,
        .offset = (uint32_t)offsetof(NCProtoRegisterRsp__storage_, token),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeString,
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

#pragma mark - NCProtoAppleIdBind

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

#pragma mark - NCProtoAppleIdUnbind

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

#pragma mark - NCProtoDeviceTokenBind

@implementation NCProtoDeviceTokenBind

@dynamic deviceType;
@dynamic deviceToken;
@dynamic pushChannel;

typedef struct NCProtoDeviceTokenBind__storage_ {
  uint32_t _has_storage_[1];
  NCProtoDeviceType deviceType;
  NCProtoPushChannel pushChannel;
  NSString *deviceToken;
} NCProtoDeviceTokenBind__storage_;



+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "deviceType",
        .dataTypeSpecific.enumDescFunc = NCProtoDeviceType_EnumDescriptor,
        .number = NCProtoDeviceTokenBind_FieldNumber_DeviceType,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(NCProtoDeviceTokenBind__storage_, deviceType),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldHasEnumDescriptor),
        .dataType = GPBDataTypeEnum,
      },
      {
        .name = "deviceToken",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoDeviceTokenBind_FieldNumber_DeviceToken,
        .hasIndex = 1,
        .offset = (uint32_t)offsetof(NCProtoDeviceTokenBind__storage_, deviceToken),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeString,
      },
      {
        .name = "pushChannel",
        .dataTypeSpecific.enumDescFunc = NCProtoPushChannel_EnumDescriptor,
        .number = NCProtoDeviceTokenBind_FieldNumber_PushChannel,
        .hasIndex = 2,
        .offset = (uint32_t)offsetof(NCProtoDeviceTokenBind__storage_, pushChannel),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldHasEnumDescriptor),
        .dataType = GPBDataTypeEnum,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[NCProtoDeviceTokenBind class]
                                     rootClass:[NCProtoNetMsgRoot class]
                                          file:NCProtoNetMsgRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(NCProtoDeviceTokenBind__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif  
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

int32_t NCProtoDeviceTokenBind_DeviceType_RawValue(NCProtoDeviceTokenBind *message) {
  GPBDescriptor *descriptor = [NCProtoDeviceTokenBind descriptor];
  GPBFieldDescriptor *field = [descriptor fieldWithNumber:NCProtoDeviceTokenBind_FieldNumber_DeviceType];
  return GPBGetMessageInt32Field(message, field);
}

void SetNCProtoDeviceTokenBind_DeviceType_RawValue(NCProtoDeviceTokenBind *message, int32_t value) {
  GPBDescriptor *descriptor = [NCProtoDeviceTokenBind descriptor];
  GPBFieldDescriptor *field = [descriptor fieldWithNumber:NCProtoDeviceTokenBind_FieldNumber_DeviceType];
  GPBSetInt32IvarWithFieldInternal(message, field, value, descriptor.file.syntax);
}

int32_t NCProtoDeviceTokenBind_PushChannel_RawValue(NCProtoDeviceTokenBind *message) {
  GPBDescriptor *descriptor = [NCProtoDeviceTokenBind descriptor];
  GPBFieldDescriptor *field = [descriptor fieldWithNumber:NCProtoDeviceTokenBind_FieldNumber_PushChannel];
  return GPBGetMessageInt32Field(message, field);
}

void SetNCProtoDeviceTokenBind_PushChannel_RawValue(NCProtoDeviceTokenBind *message, int32_t value) {
  GPBDescriptor *descriptor = [NCProtoDeviceTokenBind descriptor];
  GPBFieldDescriptor *field = [descriptor fieldWithNumber:NCProtoDeviceTokenBind_FieldNumber_PushChannel];
  GPBSetInt32IvarWithFieldInternal(message, field, value, descriptor.file.syntax);
}

#pragma mark - NCProtoDeviceTokenUnbind

@implementation NCProtoDeviceTokenUnbind

@dynamic deviceType;
@dynamic deviceToken;
@dynamic pushChannel;

typedef struct NCProtoDeviceTokenUnbind__storage_ {
  uint32_t _has_storage_[1];
  NCProtoDeviceType deviceType;
  NCProtoPushChannel pushChannel;
  NSString *deviceToken;
} NCProtoDeviceTokenUnbind__storage_;



+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "deviceType",
        .dataTypeSpecific.enumDescFunc = NCProtoDeviceType_EnumDescriptor,
        .number = NCProtoDeviceTokenUnbind_FieldNumber_DeviceType,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(NCProtoDeviceTokenUnbind__storage_, deviceType),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldHasEnumDescriptor),
        .dataType = GPBDataTypeEnum,
      },
      {
        .name = "deviceToken",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoDeviceTokenUnbind_FieldNumber_DeviceToken,
        .hasIndex = 1,
        .offset = (uint32_t)offsetof(NCProtoDeviceTokenUnbind__storage_, deviceToken),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeString,
      },
      {
        .name = "pushChannel",
        .dataTypeSpecific.enumDescFunc = NCProtoPushChannel_EnumDescriptor,
        .number = NCProtoDeviceTokenUnbind_FieldNumber_PushChannel,
        .hasIndex = 2,
        .offset = (uint32_t)offsetof(NCProtoDeviceTokenUnbind__storage_, pushChannel),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldHasEnumDescriptor),
        .dataType = GPBDataTypeEnum,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[NCProtoDeviceTokenUnbind class]
                                     rootClass:[NCProtoNetMsgRoot class]
                                          file:NCProtoNetMsgRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(NCProtoDeviceTokenUnbind__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif  
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

int32_t NCProtoDeviceTokenUnbind_DeviceType_RawValue(NCProtoDeviceTokenUnbind *message) {
  GPBDescriptor *descriptor = [NCProtoDeviceTokenUnbind descriptor];
  GPBFieldDescriptor *field = [descriptor fieldWithNumber:NCProtoDeviceTokenUnbind_FieldNumber_DeviceType];
  return GPBGetMessageInt32Field(message, field);
}

void SetNCProtoDeviceTokenUnbind_DeviceType_RawValue(NCProtoDeviceTokenUnbind *message, int32_t value) {
  GPBDescriptor *descriptor = [NCProtoDeviceTokenUnbind descriptor];
  GPBFieldDescriptor *field = [descriptor fieldWithNumber:NCProtoDeviceTokenUnbind_FieldNumber_DeviceType];
  GPBSetInt32IvarWithFieldInternal(message, field, value, descriptor.file.syntax);
}

int32_t NCProtoDeviceTokenUnbind_PushChannel_RawValue(NCProtoDeviceTokenUnbind *message) {
  GPBDescriptor *descriptor = [NCProtoDeviceTokenUnbind descriptor];
  GPBFieldDescriptor *field = [descriptor fieldWithNumber:NCProtoDeviceTokenUnbind_FieldNumber_PushChannel];
  return GPBGetMessageInt32Field(message, field);
}

void SetNCProtoDeviceTokenUnbind_PushChannel_RawValue(NCProtoDeviceTokenUnbind *message, int32_t value) {
  GPBDescriptor *descriptor = [NCProtoDeviceTokenUnbind descriptor];
  GPBFieldDescriptor *field = [descriptor fieldWithNumber:NCProtoDeviceTokenUnbind_FieldNumber_PushChannel];
  GPBSetInt32IvarWithFieldInternal(message, field, value, descriptor.file.syntax);
}

#pragma mark - NCProtoCacheMsgReq

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
  int64_t hash_p;
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
        .dataType = GPBDataTypeInt64,
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

#pragma mark - NCProtoCacheMsgRsp

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

#pragma mark - NCProtoDeleteCacheMsg

@implementation NCProtoDeleteCacheMsg

@dynamic action;
@dynamic hash_p;
@dynamic relatedPubKey;

typedef struct NCProtoDeleteCacheMsg__storage_ {
  uint32_t _has_storage_[1];
  NCProtoDeleteAction action;
  NSData *relatedPubKey;
  int64_t hash_p;
} NCProtoDeleteCacheMsg__storage_;



+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "action",
        .dataTypeSpecific.enumDescFunc = NCProtoDeleteAction_EnumDescriptor,
        .number = NCProtoDeleteCacheMsg_FieldNumber_Action,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(NCProtoDeleteCacheMsg__storage_, action),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldHasEnumDescriptor),
        .dataType = GPBDataTypeEnum,
      },
      {
        .name = "hash_p",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoDeleteCacheMsg_FieldNumber_Hash_p,
        .hasIndex = 1,
        .offset = (uint32_t)offsetof(NCProtoDeleteCacheMsg__storage_, hash_p),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeInt64,
      },
      {
        .name = "relatedPubKey",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoDeleteCacheMsg_FieldNumber_RelatedPubKey,
        .hasIndex = 2,
        .offset = (uint32_t)offsetof(NCProtoDeleteCacheMsg__storage_, relatedPubKey),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeBytes,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[NCProtoDeleteCacheMsg class]
                                     rootClass:[NCProtoNetMsgRoot class]
                                          file:NCProtoNetMsgRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(NCProtoDeleteCacheMsg__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif  
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

int32_t NCProtoDeleteCacheMsg_Action_RawValue(NCProtoDeleteCacheMsg *message) {
  GPBDescriptor *descriptor = [NCProtoDeleteCacheMsg descriptor];
  GPBFieldDescriptor *field = [descriptor fieldWithNumber:NCProtoDeleteCacheMsg_FieldNumber_Action];
  return GPBGetMessageInt32Field(message, field);
}

void SetNCProtoDeleteCacheMsg_Action_RawValue(NCProtoDeleteCacheMsg *message, int32_t value) {
  GPBDescriptor *descriptor = [NCProtoDeleteCacheMsg descriptor];
  GPBFieldDescriptor *field = [descriptor fieldWithNumber:NCProtoDeleteCacheMsg_FieldNumber_Action];
  GPBSetInt32IvarWithFieldInternal(message, field, value, descriptor.file.syntax);
}

#pragma mark - NCProtoLogonNotify

@implementation NCProtoLogonNotify

@dynamic deviceType;

typedef struct NCProtoLogonNotify__storage_ {
  uint32_t _has_storage_[1];
  NCProtoDeviceType deviceType;
} NCProtoLogonNotify__storage_;



+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "deviceType",
        .dataTypeSpecific.enumDescFunc = NCProtoDeviceType_EnumDescriptor,
        .number = NCProtoLogonNotify_FieldNumber_DeviceType,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(NCProtoLogonNotify__storage_, deviceType),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldHasEnumDescriptor),
        .dataType = GPBDataTypeEnum,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[NCProtoLogonNotify class]
                                     rootClass:[NCProtoNetMsgRoot class]
                                          file:NCProtoNetMsgRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(NCProtoLogonNotify__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif  
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

int32_t NCProtoLogonNotify_DeviceType_RawValue(NCProtoLogonNotify *message) {
  GPBDescriptor *descriptor = [NCProtoLogonNotify descriptor];
  GPBFieldDescriptor *field = [descriptor fieldWithNumber:NCProtoLogonNotify_FieldNumber_DeviceType];
  return GPBGetMessageInt32Field(message, field);
}

void SetNCProtoLogonNotify_DeviceType_RawValue(NCProtoLogonNotify *message, int32_t value) {
  GPBDescriptor *descriptor = [NCProtoLogonNotify descriptor];
  GPBFieldDescriptor *field = [descriptor fieldWithNumber:NCProtoLogonNotify_FieldNumber_DeviceType];
  GPBSetInt32IvarWithFieldInternal(message, field, value, descriptor.file.syntax);
}


#pragma clang diagnostic pop


