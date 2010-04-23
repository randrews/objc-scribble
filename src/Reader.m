#import "Reader.h"

@implementation Reader

-(id) initWithCommandController: (CommandController*) commandController_p {
  self = [super init];

  if(self==nil){
    return nil;
  }

  commandController = commandController_p;

  return self;
}

-(BOOL) bufferOneSexpToPipe: (FILE*) fd {
  int ch;

  int depth = 0;
  char mode = 's'; // [s]tart, [q]uote, [b]ackslash, [c]omment

  while(ch = getchar()){
    if(ch==EOF){ return NO; }

    // This begins a comment, which we have to catch before
    // writing the char to out:
    if(mode == 's' && ch == '#'){
      mode = 'c';
    }

    if(mode != 'c'){
      write((long int)fd, &ch, 1);
    }

    switch(mode){
    case 's':
      switch(ch){
      case '(':
	depth++;
	break;
      case ')':
	depth--;
	if(depth==0){ return YES; }
	break;
      case '"':
	mode = 'q';
	break;
      }
      break;

    case 'q':
      switch(ch){
      case '"':
	mode = 's';
	break;
      case '\\':
	mode = 'b';
	break;
      }
      break;

    case 'b':
      mode = 'q';
      break;

    case 'c':
      if(ch=='\n'){
	mode = 's';
      }
      break;
    }
  }
}

// The arg is actually ignored
-(void) startListening: (id) arg {
  int fd[2];
  pipe(fd);

  sexp_io = init_iowrap(fd[0]);

  while([self bufferOneSexpToPipe: (FILE*)(long int)fd[1]]){
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

    // Send it to the CommandController
    [commandController handleSexp: sexp];

    // Clean it up.
    destroy_sexp(sexp);
  }

  exit(0);
}

@end
