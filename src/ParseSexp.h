#include <Foundation/Foundation.h>
#include "sexp.h"

@interface NSArray (ParseSexp)
+ (NSArray*) arrayForSexp: (sexp_t*) sexp;
@end
