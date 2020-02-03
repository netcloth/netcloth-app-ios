  
  

  
  
#if !defined(GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS)
 #define GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS 0
#endif

#if GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS
 #import <protobuf/GPBProtocolBuffers.h>
#else
 #import "GPBProtocolBuffers.h"
#endif

#if GOOGLE_PROTOBUF_OBJC_VERSION < 30002
#error This file was generated by a newer version of protoc which is incompatible with your Protocol Buffer library sources.
#endif
#if 30002 < GOOGLE_PROTOBUF_OBJC_MIN_SUPPORTED_VERSION
#error This file was generated by an older version of protoc which is incompatible with your Protocol Buffer library sources.
#endif

  

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

CF_EXTERN_C_BEGIN

@class NCProtoGroupKickResult;
@class NCProtoGroupMember;
@class NCProtoGroupUnreadReq;
@class NCProtoGroupUnreadRsp;
@class NCProtoNetMsg;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Enum NCProtoGroupRole

 
typedef GPB_ENUM(NCProtoGroupRole) {
  /**
   * Value used if any message's field encounters a value that is not defined
   * by this enum. The message will also have C functions to get/set the rawValue
   * of the field.
   **/
  NCProtoGroupRole_GPBUnrecognizedEnumeratorValue = kGPBUnrecognizedEnumeratorValue,
   
  NCProtoGroupRole_Owner = 0,

   
  NCProtoGroupRole_Manager = 1,

   
  NCProtoGroupRole_Member = 2,
};

GPBEnumDescriptor *NCProtoGroupRole_EnumDescriptor(void);

/**
 * Checks to see if the given value is defined by the enum or was not known at
 * the time this source was generated.
 **/
BOOL NCProtoGroupRole_IsValidValue(int32_t value);

#pragma mark - NCProtoGroupMsgRoot

/**
 * Exposes the extension registry for this file.
 *
 * The base class provides:
 * @code
 *   + (GPBExtensionRegistry *)extensionRegistry;
 * @endcode
 * which is a @c GPBExtensionRegistry that includes all the extensions defined by
 * this file and all files that it depends on.
 **/
@interface NCProtoGroupMsgRoot : GPBRootObject
@end

#pragma mark - NCProtoGroupCreate

typedef GPB_ENUM(NCProtoGroupCreate_FieldNumber) {
  NCProtoGroupCreate_FieldNumber_GroupName = 1,
  NCProtoGroupCreate_FieldNumber_GroupType = 2,
  NCProtoGroupCreate_FieldNumber_OwnerNickName = 3,
  NCProtoGroupCreate_FieldNumber_ToInviteeMsgsArray = 4,
};

 
@interface NCProtoGroupCreate : GPBMessage

 
@property(nonatomic, readwrite, copy, null_resettable) NSString *groupName;

/** 群类型  0: 普通群 1：禁言群 */
@property(nonatomic, readwrite) int32_t groupType;

 
@property(nonatomic, readwrite, copy, null_resettable) NSString *ownerNickName;

 
@property(nonatomic, readwrite, strong, null_resettable) NSMutableArray<NCProtoNetMsg*> *toInviteeMsgsArray;
/** The number of items in @c toInviteeMsgsArray without causing the array to be created. */
@property(nonatomic, readonly) NSUInteger toInviteeMsgsArray_Count;

@end

#pragma mark - NCProtoGroupInvite

typedef GPB_ENUM(NCProtoGroupInvite_FieldNumber) {
  NCProtoGroupInvite_FieldNumber_GroupPrivateKey = 1,
  NCProtoGroupInvite_FieldNumber_GroupName = 2,
  NCProtoGroupInvite_FieldNumber_GroupPubKey = 3,
};

@interface NCProtoGroupInvite : GPBMessage

@property(nonatomic, readwrite, copy, null_resettable) NSData *groupPrivateKey;

@property(nonatomic, readwrite, copy, null_resettable) NSString *groupName;

@property(nonatomic, readwrite, copy, null_resettable) NSData *groupPubKey;

@end

#pragma mark - NCProtoGroupJoin

typedef GPB_ENUM(NCProtoGroupJoin_FieldNumber) {
  NCProtoGroupJoin_FieldNumber_NickName = 1,
  NCProtoGroupJoin_FieldNumber_Description_p = 2,
  NCProtoGroupJoin_FieldNumber_Source = 3,
  NCProtoGroupJoin_FieldNumber_InviterPubKey = 4,
};

@interface NCProtoGroupJoin : GPBMessage

 
@property(nonatomic, readwrite, copy, null_resettable) NSString *nickName;

 
@property(nonatomic, readwrite, copy, null_resettable) NSString *description_p;

 
@property(nonatomic, readwrite) int32_t source;

 
@property(nonatomic, readwrite, copy, null_resettable) NSData *inviterPubKey;

@end

#pragma mark - NCProtoGroupKickReq

typedef GPB_ENUM(NCProtoGroupKickReq_FieldNumber) {
  NCProtoGroupKickReq_FieldNumber_KickPubKeysArray = 1,
};

@interface NCProtoGroupKickReq : GPBMessage

@property(nonatomic, readwrite, strong, null_resettable) NSMutableArray<NSData*> *kickPubKeysArray;
/** The number of items in @c kickPubKeysArray without causing the array to be created. */
@property(nonatomic, readonly) NSUInteger kickPubKeysArray_Count;

@end

#pragma mark - NCProtoGroupKickResult

typedef GPB_ENUM(NCProtoGroupKickResult_FieldNumber) {
  NCProtoGroupKickResult_FieldNumber_KickPubKey = 1,
  NCProtoGroupKickResult_FieldNumber_Result = 2,
};

@interface NCProtoGroupKickResult : GPBMessage

@property(nonatomic, readwrite, copy, null_resettable) NSData *kickPubKey;

@property(nonatomic, readwrite) int32_t result;

@end

#pragma mark - NCProtoGroupKickRsp

typedef GPB_ENUM(NCProtoGroupKickRsp_FieldNumber) {
  NCProtoGroupKickRsp_FieldNumber_Result = 1,
  NCProtoGroupKickRsp_FieldNumber_KickResultArray = 2,
};

@interface NCProtoGroupKickRsp : GPBMessage

@property(nonatomic, readwrite) int32_t result;

@property(nonatomic, readwrite, strong, null_resettable) NSMutableArray<NCProtoGroupKickResult*> *kickResultArray;
/** The number of items in @c kickResultArray without causing the array to be created. */
@property(nonatomic, readonly) NSUInteger kickResultArray_Count;

@end

#pragma mark - NCProtoGroupKick

typedef GPB_ENUM(NCProtoGroupKick_FieldNumber) {
  NCProtoGroupKick_FieldNumber_KickedPubKeysArray = 1,
};

@interface NCProtoGroupKick : GPBMessage

@property(nonatomic, readwrite, strong, null_resettable) NSMutableArray<NSData*> *kickedPubKeysArray;
/** The number of items in @c kickedPubKeysArray without causing the array to be created. */
@property(nonatomic, readonly) NSUInteger kickedPubKeysArray_Count;

@end

#pragma mark - NCProtoGroupQuit

@interface NCProtoGroupQuit : GPBMessage

@end

#pragma mark - NCProtoGroupDismiss

@interface NCProtoGroupDismiss : GPBMessage

@end

#pragma mark - NCProtoGroupUpdateName

typedef GPB_ENUM(NCProtoGroupUpdateName_FieldNumber) {
  NCProtoGroupUpdateName_FieldNumber_Name = 1,
};

@interface NCProtoGroupUpdateName : GPBMessage

@property(nonatomic, readwrite, copy, null_resettable) NSString *name;

@end

#pragma mark - NCProtoGroupUpdateNotice

typedef GPB_ENUM(NCProtoGroupUpdateNotice_FieldNumber) {
  NCProtoGroupUpdateNotice_FieldNumber_Notice = 1,
};

@interface NCProtoGroupUpdateNotice : GPBMessage

@property(nonatomic, readwrite, copy, null_resettable) NSString *notice;

@end

#pragma mark - NCProtoGroupUpdateNickName

typedef GPB_ENUM(NCProtoGroupUpdateNickName_FieldNumber) {
  NCProtoGroupUpdateNickName_FieldNumber_NickName = 1,
};

@interface NCProtoGroupUpdateNickName : GPBMessage

@property(nonatomic, readwrite, copy, null_resettable) NSString *nickName;

@end

#pragma mark - NCProtoGroupText

typedef GPB_ENUM(NCProtoGroupText_FieldNumber) {
  NCProtoGroupText_FieldNumber_Content = 1,
  NCProtoGroupText_FieldNumber_AtAll = 2,
  NCProtoGroupText_FieldNumber_AtMembersArray = 3,
};

@interface NCProtoGroupText : GPBMessage

 
@property(nonatomic, readwrite, copy, null_resettable) NSData *content;

@property(nonatomic, readwrite) BOOL atAll;

@property(nonatomic, readwrite, strong, null_resettable) NSMutableArray<NSData*> *atMembersArray;
/** The number of items in @c atMembersArray without causing the array to be created. */
@property(nonatomic, readonly) NSUInteger atMembersArray_Count;

@end

#pragma mark - NCProtoGroupAudio

typedef GPB_ENUM(NCProtoGroupAudio_FieldNumber) {
  NCProtoGroupAudio_FieldNumber_Content = 1,
  NCProtoGroupAudio_FieldNumber_PlayTime = 2,
};

@interface NCProtoGroupAudio : GPBMessage

 
@property(nonatomic, readwrite, copy, null_resettable) NSData *content;

 
@property(nonatomic, readwrite) uint32_t playTime;

@end

#pragma mark - NCProtoGroupImage

typedef GPB_ENUM(NCProtoGroupImage_FieldNumber) {
  NCProtoGroupImage_FieldNumber_Id_p = 1,
  NCProtoGroupImage_FieldNumber_Width = 2,
  NCProtoGroupImage_FieldNumber_Height = 3,
};

@interface NCProtoGroupImage : GPBMessage

 
@property(nonatomic, readwrite, copy, null_resettable) NSString *id_p;

@property(nonatomic, readwrite) uint32_t width;

@property(nonatomic, readwrite) uint32_t height;

@end

#pragma mark - NCProtoGroupVideo

typedef GPB_ENUM(NCProtoGroupVideo_FieldNumber) {
  NCProtoGroupVideo_FieldNumber_Id_p = 1,
  NCProtoGroupVideo_FieldNumber_PlayTime = 2,
};

@interface NCProtoGroupVideo : GPBMessage

 
@property(nonatomic, readwrite, copy, null_resettable) NSString *id_p;

 
@property(nonatomic, readwrite) uint32_t playTime;

@end

#pragma mark - NCProtoGroupFile

typedef GPB_ENUM(NCProtoGroupFile_FieldNumber) {
  NCProtoGroupFile_FieldNumber_Id_p = 1,
  NCProtoGroupFile_FieldNumber_Name = 2,
  NCProtoGroupFile_FieldNumber_Size = 3,
};

@interface NCProtoGroupFile : GPBMessage

 
@property(nonatomic, readwrite, copy, null_resettable) NSString *id_p;

 
@property(nonatomic, readwrite, copy, null_resettable) NSString *name;

 
@property(nonatomic, readwrite) uint32_t size;

@end

#pragma mark - NCProtoGroupMember

typedef GPB_ENUM(NCProtoGroupMember_FieldNumber) {
  NCProtoGroupMember_FieldNumber_PubKey = 1,
  NCProtoGroupMember_FieldNumber_NickName = 2,
  NCProtoGroupMember_FieldNumber_Role = 3,
  NCProtoGroupMember_FieldNumber_JoinTime = 4,
};

 
@interface NCProtoGroupMember : GPBMessage

 
@property(nonatomic, readwrite, copy, null_resettable) NSData *pubKey;

 
@property(nonatomic, readwrite, copy, null_resettable) NSString *nickName;

 
@property(nonatomic, readwrite) NCProtoGroupRole role;

/** 入群时间 UTC timestamp (millisecond) */
@property(nonatomic, readwrite) int64_t joinTime;

@end

/**
 * Fetches the raw value of a @c NCProtoGroupMember's @c role property, even
 * if the value was not defined by the enum at the time the code was generated.
 **/
int32_t NCProtoGroupMember_Role_RawValue(NCProtoGroupMember *message);
/**
 * Sets the raw value of an @c NCProtoGroupMember's @c role property, allowing
 * it to be set to a value that was not defined by the enum at the time the code
 * was generated.
 **/
void SetNCProtoGroupMember_Role_RawValue(NCProtoGroupMember *message, int32_t value);

#pragma mark - NCProtoGroupGetMemberReq

 
@interface NCProtoGroupGetMemberReq : GPBMessage

@end

#pragma mark - NCProtoGroupGetMemberRsp

typedef GPB_ENUM(NCProtoGroupGetMemberRsp_FieldNumber) {
  NCProtoGroupGetMemberRsp_FieldNumber_Result = 1,
  NCProtoGroupGetMemberRsp_FieldNumber_ModifiedTime = 2,
  NCProtoGroupGetMemberRsp_FieldNumber_MembersArray = 3,
};

 
@interface NCProtoGroupGetMemberRsp : GPBMessage

@property(nonatomic, readwrite) int32_t result;

/** UTC timestamp (millisecond) */
@property(nonatomic, readwrite) int64_t modifiedTime;

@property(nonatomic, readwrite, strong, null_resettable) NSMutableArray<NCProtoGroupMember*> *membersArray;
/** The number of items in @c membersArray without causing the array to be created. */
@property(nonatomic, readonly) NSUInteger membersArray_Count;

@end

#pragma mark - NCProtoGroupGetMsgReq

typedef GPB_ENUM(NCProtoGroupGetMsgReq_FieldNumber) {
  NCProtoGroupGetMsgReq_FieldNumber_BeginId = 1,
  NCProtoGroupGetMsgReq_FieldNumber_EndId = 2,
  NCProtoGroupGetMsgReq_FieldNumber_Count = 3,
};

@interface NCProtoGroupGetMsgReq : GPBMessage

@property(nonatomic, readwrite) int64_t beginId;

@property(nonatomic, readwrite) int64_t endId;

@property(nonatomic, readwrite) int32_t count;

@end

#pragma mark - NCProtoGroupGetMsgRsp

typedef GPB_ENUM(NCProtoGroupGetMsgRsp_FieldNumber) {
  NCProtoGroupGetMsgRsp_FieldNumber_Result = 1,
  NCProtoGroupGetMsgRsp_FieldNumber_BeginId = 2,
  NCProtoGroupGetMsgRsp_FieldNumber_EndId = 3,
  NCProtoGroupGetMsgRsp_FieldNumber_RemainCount = 4,
  NCProtoGroupGetMsgRsp_FieldNumber_MsgsArray = 5,
};

@interface NCProtoGroupGetMsgRsp : GPBMessage

@property(nonatomic, readwrite) int32_t result;

@property(nonatomic, readwrite) int64_t beginId;

@property(nonatomic, readwrite) int64_t endId;

@property(nonatomic, readwrite) int32_t remainCount;

@property(nonatomic, readwrite, strong, null_resettable) NSMutableArray<NCProtoNetMsg*> *msgsArray;
/** The number of items in @c msgsArray without causing the array to be created. */
@property(nonatomic, readonly) NSUInteger msgsArray_Count;

@end

#pragma mark - NCProtoGroupUnreadReq

typedef GPB_ENUM(NCProtoGroupUnreadReq_FieldNumber) {
  NCProtoGroupUnreadReq_FieldNumber_GroupPubKey = 1,
  NCProtoGroupUnreadReq_FieldNumber_LastMsgId = 2,
};

@interface NCProtoGroupUnreadReq : GPBMessage

@property(nonatomic, readwrite, copy, null_resettable) NSData *groupPubKey;

@property(nonatomic, readwrite) int64_t lastMsgId;

@end

#pragma mark - NCProtoGroupUnreadRsp

typedef GPB_ENUM(NCProtoGroupUnreadRsp_FieldNumber) {
  NCProtoGroupUnreadRsp_FieldNumber_Result = 1,
  NCProtoGroupUnreadRsp_FieldNumber_GroupPubKey = 2,
  NCProtoGroupUnreadRsp_FieldNumber_UnreadCount = 3,
  NCProtoGroupUnreadRsp_FieldNumber_LastMsg = 4,
};

@interface NCProtoGroupUnreadRsp : GPBMessage

@property(nonatomic, readwrite) int32_t result;

@property(nonatomic, readwrite, copy, null_resettable) NSData *groupPubKey;

@property(nonatomic, readwrite) uint32_t unreadCount;

@property(nonatomic, readwrite, strong, null_resettable) NCProtoNetMsg *lastMsg;
/** Test to see if @c lastMsg has been set. */
@property(nonatomic, readwrite) BOOL hasLastMsg;

@end

#pragma mark - NCProtoGroupGetUnreadReq

typedef GPB_ENUM(NCProtoGroupGetUnreadReq_FieldNumber) {
  NCProtoGroupGetUnreadReq_FieldNumber_ReqItemsArray = 1,
};

@interface NCProtoGroupGetUnreadReq : GPBMessage

@property(nonatomic, readwrite, strong, null_resettable) NSMutableArray<NCProtoGroupUnreadReq*> *reqItemsArray;
/** The number of items in @c reqItemsArray without causing the array to be created. */
@property(nonatomic, readonly) NSUInteger reqItemsArray_Count;

@end

#pragma mark - NCProtoGroupGetUnreadRsp

typedef GPB_ENUM(NCProtoGroupGetUnreadRsp_FieldNumber) {
  NCProtoGroupGetUnreadRsp_FieldNumber_Result = 1,
  NCProtoGroupGetUnreadRsp_FieldNumber_RspItemsArray = 2,
};

@interface NCProtoGroupGetUnreadRsp : GPBMessage

@property(nonatomic, readwrite) int32_t result;

@property(nonatomic, readwrite, strong, null_resettable) NSMutableArray<NCProtoGroupUnreadRsp*> *rspItemsArray;
/** The number of items in @c rspItemsArray without causing the array to be created. */
@property(nonatomic, readonly) NSUInteger rspItemsArray_Count;

@end

#pragma mark - NCProtoGroupUpdateInviteType

typedef GPB_ENUM(NCProtoGroupUpdateInviteType_FieldNumber) {
  NCProtoGroupUpdateInviteType_FieldNumber_InviteType = 1,
};

@interface NCProtoGroupUpdateInviteType : GPBMessage

 
@property(nonatomic, readwrite) int32_t inviteType;

@end

#pragma mark - NCProtoGroupJoinApproveNotify

typedef GPB_ENUM(NCProtoGroupJoinApproveNotify_FieldNumber) {
  NCProtoGroupJoinApproveNotify_FieldNumber_JoinMsg = 1,
};

 
@interface NCProtoGroupJoinApproveNotify : GPBMessage

@property(nonatomic, readwrite, strong, null_resettable) NCProtoNetMsg *joinMsg;
/** Test to see if @c joinMsg has been set. */
@property(nonatomic, readwrite) BOOL hasJoinMsg;

@end

#pragma mark - NCProtoGroupJoinApproved

typedef GPB_ENUM(NCProtoGroupJoinApproved_FieldNumber) {
  NCProtoGroupJoinApproved_FieldNumber_JoinMsg = 1,
  NCProtoGroupJoinApproved_FieldNumber_GroupPrivateKey = 2,
  NCProtoGroupJoinApproved_FieldNumber_GroupName = 3,
};

 
@interface NCProtoGroupJoinApproved : GPBMessage

@property(nonatomic, readwrite, strong, null_resettable) NCProtoNetMsg *joinMsg;
/** Test to see if @c joinMsg has been set. */
@property(nonatomic, readwrite) BOOL hasJoinMsg;

 
@property(nonatomic, readwrite, copy, null_resettable) NSData *groupPrivateKey;

 
@property(nonatomic, readwrite, copy, null_resettable) NSString *groupName;

@end

NS_ASSUME_NONNULL_END

CF_EXTERN_C_END

#pragma clang diagnostic pop

  
