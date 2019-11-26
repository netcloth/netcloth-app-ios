




#if !defined(GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS)
 #define GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS 0
#endif

#if GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS
 #import <protobuf/GPBProtocolBuffers_RuntimeSupport.h>
#else
 #import "GPBProtocolBuffers_RuntimeSupport.h"
#endif

#import "Chat.pbobjc.h"




@implementation NCProtoChatRoot




@end


static GPBFileDescriptor *NCProtoChatRoot_FileDescriptor(void) {


  static GPBFileDescriptor *descriptor = NULL;
  if (!descriptor) {
    GPB_DEBUG_CHECK_RUNTIME_VERSIONS();
    descriptor = [[GPBFileDescriptor alloc] initWithPackage:@"netcloth"
                                                 objcPrefix:@"NCProto"
                                                     syntax:GPBFileSyntaxProto3];
  }
  return descriptor;
}


@implementation NCProtoText

@dynamic content;

typedef struct NCProtoText__storage_ {
  uint32_t _has_storage_[1];
  NSData *content;
} NCProtoText__storage_;



+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "content",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoText_FieldNumber_Content,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(NCProtoText__storage_, content),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeBytes,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[NCProtoText class]
                                     rootClass:[NCProtoChatRoot class]
                                          file:NCProtoChatRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(NCProtoText__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif 
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end


@implementation NCProtoAudio

@dynamic content;
@dynamic playTime;

typedef struct NCProtoAudio__storage_ {
  uint32_t _has_storage_[1];
  uint32_t playTime;
  NSData *content;
} NCProtoAudio__storage_;



+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "content",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoAudio_FieldNumber_Content,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(NCProtoAudio__storage_, content),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeBytes,
      },
      {
        .name = "playTime",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoAudio_FieldNumber_PlayTime,
        .hasIndex = 1,
        .offset = (uint32_t)offsetof(NCProtoAudio__storage_, playTime),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeUInt32,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[NCProtoAudio class]
                                     rootClass:[NCProtoChatRoot class]
                                          file:NCProtoChatRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(NCProtoAudio__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif 
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end


@implementation NCProtoImage

@dynamic id_p;
@dynamic width;
@dynamic height;

typedef struct NCProtoImage__storage_ {
  uint32_t _has_storage_[1];
  uint32_t width;
  uint32_t height;
  NSString *id_p;
} NCProtoImage__storage_;



+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "id_p",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoImage_FieldNumber_Id_p,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(NCProtoImage__storage_, id_p),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeString,
      },
      {
        .name = "width",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoImage_FieldNumber_Width,
        .hasIndex = 1,
        .offset = (uint32_t)offsetof(NCProtoImage__storage_, width),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeUInt32,
      },
      {
        .name = "height",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoImage_FieldNumber_Height,
        .hasIndex = 2,
        .offset = (uint32_t)offsetof(NCProtoImage__storage_, height),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeUInt32,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[NCProtoImage class]
                                     rootClass:[NCProtoChatRoot class]
                                          file:NCProtoChatRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(NCProtoImage__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif 
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end


@implementation NCProtoVideo

@dynamic id_p;
@dynamic playTime;

typedef struct NCProtoVideo__storage_ {
  uint32_t _has_storage_[1];
  uint32_t playTime;
  NSString *id_p;
} NCProtoVideo__storage_;



+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "id_p",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoVideo_FieldNumber_Id_p,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(NCProtoVideo__storage_, id_p),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeString,
      },
      {
        .name = "playTime",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoVideo_FieldNumber_PlayTime,
        .hasIndex = 1,
        .offset = (uint32_t)offsetof(NCProtoVideo__storage_, playTime),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeUInt32,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[NCProtoVideo class]
                                     rootClass:[NCProtoChatRoot class]
                                          file:NCProtoChatRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(NCProtoVideo__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif 
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end


@implementation NCProtoFile

@dynamic id_p;
@dynamic size;

typedef struct NCProtoFile__storage_ {
  uint32_t _has_storage_[1];
  uint32_t size;
  NSString *id_p;
} NCProtoFile__storage_;



+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "id_p",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoFile_FieldNumber_Id_p,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(NCProtoFile__storage_, id_p),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeString,
      },
      {
        .name = "size",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoFile_FieldNumber_Size,
        .hasIndex = 1,
        .offset = (uint32_t)offsetof(NCProtoFile__storage_, size),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeUInt32,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[NCProtoFile class]
                                     rootClass:[NCProtoChatRoot class]
                                          file:NCProtoChatRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(NCProtoFile__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif 
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end




