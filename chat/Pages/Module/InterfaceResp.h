//
//  InterfaceResp.h
//  chat
//
//  Created by Grand on 2019/11/9.
//  Copyright © 2019 netcloth. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ChainAssets : NSObject
@property (nonatomic, copy) NSString *denom;
@property (nonatomic, copy) NSString *amount;
@end

@interface  IPALServiceAddress: NSObject
@property (nonatomic, copy) NSString *type;/// 1 chat-cipal  3 aiapl
// cipal: netgateway http://
// aipal: web page url
@property (nonatomic, copy, nullable) NSString *endpoint;
@end

@interface IPALNode : NSObject
@property (nonatomic, copy, nullable) NSString *operator_address;
@property (nonatomic, copy, nullable) NSString *moniker;
@property (nonatomic, copy, nullable) NSString *website;
@property (nonatomic, copy, nullable) NSString *details;
@property (nonatomic, strong, nullable) NSArray<IPALServiceAddress *> *endpoints;
@property (nonatomic, strong, nullable) ChainAssets *bond;
@end

@interface IPALNode ()
- (IPALServiceAddress * _Nullable)cIpalEnd;
@property (nonatomic, assign) NSInteger ping; //ms
@property (nonatomic, assign) int isClaimOk; //0 wait  1succ  2fail register ok
- (IPALServiceAddress * _Nullable)aIpal;
@end



NS_ASSUME_NONNULL_END
