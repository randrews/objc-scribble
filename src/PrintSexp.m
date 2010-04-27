#include "PrintSexp.h"

@implementation NSArray (PrintSexp)

- (NSString*) printAsSexp {
  NSMutableArray* printed = [NSMutableArray arrayWithCapacity: [self count]];

  for(id obj in self){
    [printed addObject: [obj printAsSexp]];
  }

  return [NSString stringWithFormat: @"(%@)",
		   [printed componentsJoinedByString: @" "]];
}

@end

@implementation NSString (PrintSexp)

- (NSString*) printAsSexp {
  return self;
}

@end

@implementation NSObject (PrintSexp)

- (NSString*) printAsSexp {
  return @"";
}

@end
