#import <Foundation/Foundation.h>
#import "sexp.h"
#import "PrintSexp.h"

@interface NSArray (ParseSexp)
+ (NSArray*) arrayForSexp: (sexp_t*) sexp;
- (void) assertSexpFormat: (NSString*) expected withLength: (int) length, ...;
@end
