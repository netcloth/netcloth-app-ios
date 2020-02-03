  
  
  
  
  
  
  

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ChainAssets : NSObject
@property (nonatomic, copy) NSString *denom;
@property (nonatomic, copy) NSString *amount;
@end

@interface  IPALServiceAddress: NSObject
@property (nonatomic, copy) NSString *type;  
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
@property (nonatomic, assign) NSInteger ping;   
@property (nonatomic, assign) int isClaimOk;   
@end



NS_ASSUME_NONNULL_END
