#import "Reader.h"

@implementation Reader

// The arg is actually ignored
-(void) startListening: (id) arg {
  sexp_io = init_iowrap(0);

  while(true){
    sexp_t* sexp = read_one_sexp(sexp_io);

    if(!sexp){
      continue;
    }

    NSLog(@"Length: %d", sexp_list_length(sexp));
    NSLog(@"Type: %d", sexp->ty);

    if(sexp->ty == SEXP_VALUE){
      NSLog(@"Atom type: %d", sexp->aty);
      NSLog(@"Atom: %s", sexp->val);
    }

    destroy_sexp(sexp);
  }
}

@end
