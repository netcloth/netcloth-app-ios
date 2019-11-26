




#if !defined(GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS)
 #define GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS 0
#endif

#if GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS
 #import <protobuf/GPBProtocolBuffers_RuntimeSupport.h>
#else
 #import "GPBProtocolBuffers_RuntimeSupport.h"
#endif

#import "Contacts.pbobjc.h"




@implementation NCProtoContactsRoot




@end


static GPBFileDescriptor *NCProtoContactsRoot_FileDescriptor(void) {


  static GPBFileDescriptor *descriptor = NULL;
  if (!descriptor) {
    GPB_DEBUG_CHECK_RUNTIME_VERSIONS();
    descriptor = [[GPBFileDescriptor alloc] initWithPackage:@"netcloth"
                                                 objcPrefix:@"NCProto"
                                                     syntax:GPBFileSyntaxProto3];
  }
  return descriptor;
}


@implementation NCProtoContacts

@dynamic pubKey;
@dynamic summary;
@dynamic content;

typedef struct NCProtoContacts__storage_ {
  uint32_t _has_storage_[1];
  NSData *pubKey;
  NSData *summary;
  NSData *content;
} NCProtoContacts__storage_;



+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "pubKey",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoContacts_FieldNumber_PubKey,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(NCProtoContacts__storage_, pubKey),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeBytes,
      },
      {
        .name = "summary",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoContacts_FieldNumber_Summary,
        .hasIndex = 1,
        .offset = (uint32_t)offsetof(NCProtoContacts__storage_, summary),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeBytes,
      },
      {
        .name = "content",
        .dataTypeSpecific.className = NULL,
        .number = NCProtoContacts_FieldNumber_Content,
        .hasIndex = 2,
        .offset = (uint32_t)offsetof(NCProtoContacts__storage_, content),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeBytes,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[NCProtoContacts class]
                                     rootClass:[NCProtoContactsRoot class]
                                          file:NCProtoContactsRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(NCProtoContacts__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif 
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end




