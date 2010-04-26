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

@end
