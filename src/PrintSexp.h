#include <Foundation/Foundation.h>

@interface NSArray (PrintSexp)
- (NSString*) printAsSexp;
@end

@interface NSString (PrintSexp)
- (NSString*) printAsSexp;
@end

@interface NSObject (PrintSexp)
- (NSString*) printAsSexp;
@end
