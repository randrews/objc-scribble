#import <Foundation/Foundation.h>
#include "sexp.h"

@interface Reader : NSObject {
  sexp_iowrap_t* sexp_io;
}

-(void) startListening: (id) arg;

@end
