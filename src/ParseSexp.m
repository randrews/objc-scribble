#include "ParseSexp.h"

@implementation NSArray (ParseSexp)

+ (NSArray*) arrayForSexp: (sexp_t*) sexp {
  if(!sexp || sexp->ty != SEXP_LIST || sexp_list_length(sexp) == 0){
    return [NSArray array];
  } else {
    NSMutableArray* array = [NSMutableArray arrayWithCapacity: sexp_list_length(sexp)];
    sexp_t* current = sexp->list;

    while(current){
      if(current->ty == SEXP_LIST){
	[array addObject: [NSArray arrayForSexp: current]];
      } else {
	[array addObject: [NSString stringWithUTF8String: current->val]];
      }

      current = current->next;
    }

    return array;
  }
}

// "expected" is a textual description of the sexp,
// length is the length, and the varargs are booleans for whether the elements
// should be sublists or not.
// If self doesn't match, then this raises an exception
- (void) assertSexpFormat: (NSString*) expected withLength: (int) length, ... {
  if([self count] != length) {
    [NSException raise: @"sexpFormat"
		 format: @"expected %@, got %@",
		 expected,
		 [self printAsSexp]];
  } else {
    BOOL good = true;
    int sublist;
    va_list args;
    int n = 0;

    va_start(args, length);

    while(n < length){
      sublist = va_arg(args, int);
      BOOL isArray = [[self objectAtIndex: n] isKindOfClass: [NSArray class]];

      //NSLog(@"sublist: %d isArray: %d", sublist, isArray);
      if((sublist && !isArray) || (!sublist && isArray)) {
	good = false;
	break;
      }

      n += 1;
    }	  

    va_end(args);

    if(!good){
      [NSException raise: @"sexpFormat"
		   format: @"expected %@, got %@",
		   expected,
		   [self printAsSexp]];
    }
  }
}

@end
