#import "Reader.h"

@implementation Reader

// The arg is actually ignored
-(void) startListening: (id) arg {
  sexp_io = init_iowrap(0);
  char* p = malloc(sizeof(char)*100);

  while(true){
    sexp_t* sexp = read_one_sexp(sexp_io);

    // If it's null for some reason, just keep going.
    // Probably means we're at EOF. If so, just bail.
    if(!sexp){
      if(sexp_errno == SEXP_ERR_IO_EMPTY){
	NSLog(@"Pipe closed");
	break;
      }else{
	continue;
      }
    }

    // If there's a newline right before the final paren
    // of a sexp, it shows up as two sexps, one being an atom.
    // This can screw things up, so we'll just ignore anything
    // that's not a list. All sexps we read should be lists anyway.
    if(sexp->ty != SEXP_LIST){
      destroy_sexp(sexp);
      continue;
    }

    // Print out some basic info about the list, for now.
    NSLog(@"Length: %d", sexp_list_length(sexp));
    NSLog(@"Type: %d", sexp->ty);

    print_sexp(p, 100, sexp);
    NSLog(@"Printed: %s", p);

    if(sexp->ty == SEXP_VALUE){
      NSLog(@"Atom type: %d", sexp->aty);
      NSLog(@"Atom: %s", sexp->val);
    }

    // Clean it up.
    destroy_sexp(sexp);

    /*
      Destroying the iowrap each time fixes some weird parse
      problems with newlines before the final close-paren, but
      causes it to ignore everything after the first sexp on a line.

      destroy_iowrap(sexp_io);
      sexp_io = init_iowrap(0);
    */
  }
}

@end
