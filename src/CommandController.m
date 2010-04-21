#include "CommandController.h"

@implementation CommandController

-(id) initWithScribbleView: (ScribbleView*) scribbleView_p {
  self = [super init];

  if(self==nil){
    return nil;
  }

  scribbleView = scribbleView_p;

  return self;
}

-(void) handleSexpr: (sexp_t*) sexpr {}
-(NSBezierPath*) pathForName: (NSString*) name { return nil; }

@end
