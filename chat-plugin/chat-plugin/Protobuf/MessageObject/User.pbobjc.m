




#if !defined(GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS)
 #define GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS 0
#endif

#if GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS
 #import <protobuf/GPBProtocolBuffers_RuntimeSupport.h>
#else
 #import "GPBProtocolBuffers_RuntimeSupport.h"
#endif

#import "User.pbobjc.h"
#import "CommonTypes.pbobjc.h"


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

#pragma mark - NCProtoUserRoot

@implementation NCProtoUserRoot




@end

#pragma mark - NCProtoUserRoot_FileDescriptor

static GPBFileDescriptor *NCProtoUserRoot_FileDescriptor(void) {
  
  
  static GPBFileDescriptor *descriptor = NULL;
  if (!descriptor) {
    GPB_DEBUG_CHECK_RUNTIME_VERSIONS();
    descriptor = [[GPBFileDescriptor alloc] initWithPackage:@"netcloth"
                                                 objcPrefix:@"NCProto"
                                                     syntax:GPBFileSyntaxProto3];
  }
  return descriptor;
}

#pragma mark - NCProtoSetMuteReq

@implementation NCProtoSetMuteReq

@dynamic relatedPubKey;
@dynamic action;
@dynamic chatType;

typedef struct NCProtoSetMuteReq__storage_ {
  uint32_t _has_storage_[1];
  NCProtoActionType action;
  NCProtoChatType chatType;
  NSData *relatedPubKey;
} NCProtoSetMuteReq__storage_;



+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "relatedPubKey",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoSetMuteReq_FieldNumber_RelatedPubKey,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(NCProtoSetMuteReq__storage_, relatedPubKey),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeBytes,
      },
      {
        .name = "action",
        .dataTypeSpecific.enumDescFunc = NCProtoActionType_EnumDescriptor,
        .number = NCProtoSetMuteReq_FieldNumber_Action,
        .hasIndex = 1,
        .offset = (uint32_t)offsetof(NCProtoSetMuteReq__storage_, action),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldHasEnumDescriptor),
        .dataType = GPBDataTypeEnum,
      },
      {
        .name = "chatType",
        .dataTypeSpecific.enumDescFunc = NCProtoChatType_EnumDescriptor,
        .number = NCProtoSetMuteReq_FieldNumber_ChatType,
        .hasIndex = 2,
        .offset = (uint32_t)offsetof(NCProtoSetMuteReq__storage_, chatType),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldHasEnumDescriptor),
        .dataType = GPBDataTypeEnum,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[NCProtoSetMuteReq class]
                                     rootClass:[NCProtoUserRoot class]
                                          file:NCProtoUserRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(NCProtoSetMuteReq__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif  
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

int32_t NCProtoSetMuteReq_Action_RawValue(NCProtoSetMuteReq *message) {
  GPBDescriptor *descriptor = [NCProtoSetMuteReq descriptor];
  GPBFieldDescriptor *field = [descriptor fieldWithNumber:NCProtoSetMuteReq_FieldNumber_Action];
  return GPBGetMessageInt32Field(message, field);
}

void SetNCProtoSetMuteReq_Action_RawValue(NCProtoSetMuteReq *message, int32_t value) {
  GPBDescriptor *descriptor = [NCProtoSetMuteReq descriptor];
  GPBFieldDescriptor *field = [descriptor fieldWithNumber:NCProtoSetMuteReq_FieldNumber_Action];
  GPBSetInt32IvarWithFieldInternal(message, field, value, descriptor.file.syntax);
}

int32_t NCProtoSetMuteReq_ChatType_RawValue(NCProtoSetMuteReq *message) {
  GPBDescriptor *descriptor = [NCProtoSetMuteReq descriptor];
  GPBFieldDescriptor *field = [descriptor fieldWithNumber:NCProtoSetMuteReq_FieldNumber_ChatType];
  return GPBGetMessageInt32Field(message, field);
}

void SetNCProtoSetMuteReq_ChatType_RawValue(NCProtoSetMuteReq *message, int32_t value) {
  GPBDescriptor *descriptor = [NCProtoSetMuteReq descriptor];
  GPBFieldDescriptor *field = [descriptor fieldWithNumber:NCProtoSetMuteReq_FieldNumber_ChatType];
  GPBSetInt32IvarWithFieldInternal(message, field, value, descriptor.file.syntax);
}

#pragma mark - NCProtoSetMuteBatchReq

@implementation NCProtoSetMuteBatchReq

@dynamic relatedPubKeysArray, relatedPubKeysArray_Count;
@dynamic action;
@dynamic chatType;

typedef struct NCProtoSetMuteBatchReq__storage_ {
  uint32_t _has_storage_[1];
  NCProtoActionType action;
  NCProtoChatType chatType;
  NSMutableArray *relatedPubKeysArray;
} NCProtoSetMuteBatchReq__storage_;



+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "relatedPubKeysArray",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoSetMuteBatchReq_FieldNumber_RelatedPubKeysArray,
        .hasIndex = GPBNoHasBit,
        .offset = (uint32_t)offsetof(NCProtoSetMuteBatchReq__storage_, relatedPubKeysArray),
        .flags = GPBFieldRepeated,
        .dataType = GPBDataTypeBytes,
      },
      {
        .name = "action",
        .dataTypeSpecific.enumDescFunc = NCProtoActionType_EnumDescriptor,
        .number = NCProtoSetMuteBatchReq_FieldNumber_Action,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(NCProtoSetMuteBatchReq__storage_, action),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldHasEnumDescriptor),
        .dataType = GPBDataTypeEnum,
      },
      {
        .name = "chatType",
        .dataTypeSpecific.enumDescFunc = NCProtoChatType_EnumDescriptor,
        .number = NCProtoSetMuteBatchReq_FieldNumber_ChatType,
        .hasIndex = 1,
        .offset = (uint32_t)offsetof(NCProtoSetMuteBatchReq__storage_, chatType),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldHasEnumDescriptor),
        .dataType = GPBDataTypeEnum,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[NCProtoSetMuteBatchReq class]
                                     rootClass:[NCProtoUserRoot class]
                                          file:NCProtoUserRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(NCProtoSetMuteBatchReq__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif  
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

int32_t NCProtoSetMuteBatchReq_Action_RawValue(NCProtoSetMuteBatchReq *message) {
  GPBDescriptor *descriptor = [NCProtoSetMuteBatchReq descriptor];
  GPBFieldDescriptor *field = [descriptor fieldWithNumber:NCProtoSetMuteBatchReq_FieldNumber_Action];
  return GPBGetMessageInt32Field(message, field);
}

void SetNCProtoSetMuteBatchReq_Action_RawValue(NCProtoSetMuteBatchReq *message, int32_t value) {
  GPBDescriptor *descriptor = [NCProtoSetMuteBatchReq descriptor];
  GPBFieldDescriptor *field = [descriptor fieldWithNumber:NCProtoSetMuteBatchReq_FieldNumber_Action];
  GPBSetInt32IvarWithFieldInternal(message, field, value, descriptor.file.syntax);
}

int32_t NCProtoSetMuteBatchReq_ChatType_RawValue(NCProtoSetMuteBatchReq *message) {
  GPBDescriptor *descriptor = [NCProtoSetMuteBatchReq descriptor];
  GPBFieldDescriptor *field = [descriptor fieldWithNumber:NCProtoSetMuteBatchReq_FieldNumber_ChatType];
  return GPBGetMessageInt32Field(message, field);
}

void SetNCProtoSetMuteBatchReq_ChatType_RawValue(NCProtoSetMuteBatchReq *message, int32_t value) {
  GPBDescriptor *descriptor = [NCProtoSetMuteBatchReq descriptor];
  GPBFieldDescriptor *field = [descriptor fieldWithNumber:NCProtoSetMuteBatchReq_FieldNumber_ChatType];
  GPBSetInt32IvarWithFieldInternal(message, field, value, descriptor.file.syntax);
}

#pragma mark - NCProtoSetBlacklistReq

@implementation NCProtoSetBlacklistReq

@dynamic relatedPubKey;
@dynamic action;

typedef struct NCProtoSetBlacklistReq__storage_ {
  uint32_t _has_storage_[1];
  NCProtoActionType action;
  NSData *relatedPubKey;
} NCProtoSetBlacklistReq__storage_;



+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "relatedPubKey",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoSetBlacklistReq_FieldNumber_RelatedPubKey,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(NCProtoSetBlacklistReq__storage_, relatedPubKey),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeBytes,
      },
      {
        .name = "action",
        .dataTypeSpecific.enumDescFunc = NCProtoActionType_EnumDescriptor,
        .number = NCProtoSetBlacklistReq_FieldNumber_Action,
        .hasIndex = 1,
        .offset = (uint32_t)offsetof(NCProtoSetBlacklistReq__storage_, action),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldHasEnumDescriptor),
        .dataType = GPBDataTypeEnum,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[NCProtoSetBlacklistReq class]
                                     rootClass:[NCProtoUserRoot class]
                                          file:NCProtoUserRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(NCProtoSetBlacklistReq__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif  
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

int32_t NCProtoSetBlacklistReq_Action_RawValue(NCProtoSetBlacklistReq *message) {
  GPBDescriptor *descriptor = [NCProtoSetBlacklistReq descriptor];
  GPBFieldDescriptor *field = [descriptor fieldWithNumber:NCProtoSetBlacklistReq_FieldNumber_Action];
  return GPBGetMessageInt32Field(message, field);
}

void SetNCProtoSetBlacklistReq_Action_RawValue(NCProtoSetBlacklistReq *message, int32_t value) {
  GPBDescriptor *descriptor = [NCProtoSetBlacklistReq descriptor];
  GPBFieldDescriptor *field = [descriptor fieldWithNumber:NCProtoSetBlacklistReq_FieldNumber_Action];
  GPBSetInt32IvarWithFieldInternal(message, field, value, descriptor.file.syntax);
}

#pragma mark - NCProtoSetBlacklistBatchReq

@implementation NCProtoSetBlacklistBatchReq

@dynamic relatedPubKeysArray, relatedPubKeysArray_Count;
@dynamic action;

typedef struct NCProtoSetBlacklistBatchReq__storage_ {
  uint32_t _has_storage_[1];
  NCProtoActionType action;
  NSMutableArray *relatedPubKeysArray;
} NCProtoSetBlacklistBatchReq__storage_;



+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "relatedPubKeysArray",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoSetBlacklistBatchReq_FieldNumber_RelatedPubKeysArray,
        .hasIndex = GPBNoHasBit,
        .offset = (uint32_t)offsetof(NCProtoSetBlacklistBatchReq__storage_, relatedPubKeysArray),
        .flags = GPBFieldRepeated,
        .dataType = GPBDataTypeBytes,
      },
      {
        .name = "action",
        .dataTypeSpecific.enumDescFunc = NCProtoActionType_EnumDescriptor,
        .number = NCProtoSetBlacklistBatchReq_FieldNumber_Action,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(NCProtoSetBlacklistBatchReq__storage_, action),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldHasEnumDescriptor),
        .dataType = GPBDataTypeEnum,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[NCProtoSetBlacklistBatchReq class]
                                     rootClass:[NCProtoUserRoot class]
                                          file:NCProtoUserRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(NCProtoSetBlacklistBatchReq__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif  
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

int32_t NCProtoSetBlacklistBatchReq_Action_RawValue(NCProtoSetBlacklistBatchReq *message) {
  GPBDescriptor *descriptor = [NCProtoSetBlacklistBatchReq descriptor];
  GPBFieldDescriptor *field = [descriptor fieldWithNumber:NCProtoSetBlacklistBatchReq_FieldNumber_Action];
  return GPBGetMessageInt32Field(message, field);
}

void SetNCProtoSetBlacklistBatchReq_Action_RawValue(NCProtoSetBlacklistBatchReq *message, int32_t value) {
  GPBDescriptor *descriptor = [NCProtoSetBlacklistBatchReq descriptor];
  GPBFieldDescriptor *field = [descriptor fieldWithNumber:NCProtoSetBlacklistBatchReq_FieldNumber_Action];
  GPBSetInt32IvarWithFieldInternal(message, field, value, descriptor.file.syntax);
}


#pragma clang diagnostic pop


