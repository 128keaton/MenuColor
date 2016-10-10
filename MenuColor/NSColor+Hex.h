//
//  NSColor+Hex.h
//  MenuColor
//
//  Created by Keaton Burleson on 10/9/16.
//  Copyright © 2016 Keaton Burleson. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSColor (Hex)




- (NSString *)hexadecimalValue;
+ (NSColor *)colorFromHexadecimalValue:(NSString *)hex;


@end
