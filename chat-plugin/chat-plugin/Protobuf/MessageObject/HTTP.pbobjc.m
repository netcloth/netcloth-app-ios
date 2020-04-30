




#if !defined(GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS)
 #define GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS 0
#endif

#if GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS
 #import <protobuf/GPBProtocolBuffers_RuntimeSupport.h>
#else
 #import "GPBProtocolBuffers_RuntimeSupport.h"
#endif

#import "HTTP.pbobjc.h"


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

#pragma mark - NCProtoHTTPRoot

@implementation NCProtoHTTPRoot




@end

#pragma mark - NCProtoHTTPRoot_FileDescriptor

static GPBFileDescriptor *NCProtoHTTPRoot_FileDescriptor(void) {
  
  
  static GPBFileDescriptor *descriptor = NULL;
  if (!descriptor) {
    GPB_DEBUG_CHECK_RUNTIME_VERSIONS();
    descriptor = [[GPBFileDescriptor alloc] initWithPackage:@"netcloth"
                                                 objcPrefix:@"NCProto"
                                                     syntax:GPBFileSyntaxProto3];
  }
  return descriptor;
}

#pragma mark - NCProtoHttpReq

@implementation NCProtoHttpReq

@dynamic pubKey;
@dynamic time;
@dynamic name;
@dynamic data_p;
@dynamic signature;

typedef struct NCProtoHttpReq__storage_ {
  uint32_t _has_storage_[1];
  NSData *pubKey;
  NSString *name;
  NSData *data_p;
  NSData *signature;
  int64_t time;
} NCProtoHttpReq__storage_;



+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "pubKey",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoHttpReq_FieldNumber_PubKey,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(NCProtoHttpReq__storage_, pubKey),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeBytes,
      },
      {
        .name = "time",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoHttpReq_FieldNumber_Time,
        .hasIndex = 1,
        .offset = (uint32_t)offsetof(NCProtoHttpReq__storage_, time),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeInt64,
      },
      {
        .name = "name",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoHttpReq_FieldNumber_Name,
        .hasIndex = 2,
        .offset = (uint32_t)offsetof(NCProtoHttpReq__storage_, name),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeString,
      },
      {
        .name = "data_p",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoHttpReq_FieldNumber_Data_p,
        .hasIndex = 3,
        .offset = (uint32_t)offsetof(NCProtoHttpReq__storage_, data_p),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeBytes,
      },
      {
        .name = "signature",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoHttpReq_FieldNumber_Signature,
        .hasIndex = 4,
        .offset = (uint32_t)offsetof(NCProtoHttpReq__storage_, signature),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeBytes,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[NCProtoHttpReq class]
                                     rootClass:[NCProtoHTTPRoot class]
                                          file:NCProtoHTTPRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(NCProtoHttpReq__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif  
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

#pragma mark - NCProtoHttpRsp

@implementation NCProtoHttpRsp

@dynamic result;
@dynamic name;
@dynamic data_p;

typedef struct NCProtoHttpRsp__storage_ {
  uint32_t _has_storage_[1];
  int32_t result;
  NSString *name;
  NSData *data_p;
} NCProtoHttpRsp__storage_;



+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "result",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoHttpRsp_FieldNumber_Result,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(NCProtoHttpRsp__storage_, result),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeInt32,
      },
      {
        .name = "name",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoHttpRsp_FieldNumber_Name,
        .hasIndex = 1,
        .offset = (uint32_t)offsetof(NCProtoHttpRsp__storage_, name),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeString,
      },
      {
        .name = "data_p",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoHttpRsp_FieldNumber_Data_p,
        .hasIndex = 2,
        .offset = (uint32_t)offsetof(NCProtoHttpRsp__storage_, data_p),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeBytes,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[NCProtoHttpRsp class]
                                     rootClass:[NCProtoHTTPRoot class]
                                          file:NCProtoHTTPRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(NCProtoHttpRsp__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif  
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end


#pragma clang diagnostic pop


