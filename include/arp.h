#import <Foundation/Foundation.h>

@interface ARP : NSObject

+ (nullable NSString *)walkMACAddressOf: (nonnull NSString *)ipAddress;
+ (nullable NSString *)MACAddressOf: (nonnull NSString *)ipAddress;

@end
