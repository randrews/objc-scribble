#include "CommandController.h"

@implementation CommandController

-(id) initWithScribbleView: (ScribbleView*) scribbleView_p {
  self = [super init];

  if(self==nil){
    return nil;
  }

  scribbleView = scribbleView_p;
  paths = [NSMutableDictionary dictionaryWithCapacity: 10];

  return self;
}

//////////////////////////////////////////////////

-(void) handleSexp: (sexp_t*) sexp {
  if(! [CommandController sexpIsValid: sexp]){ return; }

  id command = [[NSString alloc] initWithUTF8String: sexp->list->val ];
  NSLog(@"Command: %@",command);
}

-(NSBezierPath*) pathForName: (NSString*) name { return [paths objectForKey: name]; }

+(NSString*) stringForSexp: (sexp_t*) sexp {
  char* p = malloc(sizeof(char)*100);
  print_sexp(p,100,sexp);
  NSString* str = [[NSString alloc] initWithUTF8String: p];
  free(p);
  return str;
}

// First, some basic validation. This must be a list, with length at least 1, and the car must
// be a value. If not, we log an error and return.
+(BOOL) sexpIsValid: (sexp_t*) sexp {
  if(sexp->ty != SEXP_LIST){
    NSLog(@"ERROR: Command wasn't a list: %@",[self stringForSexp: sexp]);
    return NO;
  }

  if(sexp_list_length(sexp) < 1){
    NSLog(@"ERROR: Command was an empty list");
    return NO;
  }

  sexp_t* car = sexp->list;

  if(car->ty != SEXP_VALUE || car->aty != SEXP_BASIC){
    NSLog(@"ERROR: First element of command wasn't a symbol: %@", [self stringForSexp: car]);
    return NO;
  }

  return YES;
}
@end
