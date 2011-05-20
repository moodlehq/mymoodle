//
//  NSString+XMLExtensions.h
//  WordPress
//
//  Created by Janakiram on 26/08/08.
//


@interface NSString (XMLExtensions)

+ (NSString *)encodeXMLCharactersIn : (NSString *)source;
+ (NSString *)decodeXMLCharactersIn : (NSString *)source;

@end
