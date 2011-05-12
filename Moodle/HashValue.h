/**
 Library to generate MD5 (and other hashes method if needed)
 */


#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>

@interface HashValue : NSObject{}
+ (NSString *)getMD5FromString:(NSString *)source;
@end


