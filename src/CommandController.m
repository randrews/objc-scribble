#include "CommandController.h"

@implementation CommandController

-(id) initWithScribbleView: (ScribbleView*) scribbleView_p {
  self = [super init];

  if(self==nil){
    return nil;
  }

  scribbleView = scribbleView_p;
  shapes = [NSMutableDictionary dictionaryWithCapacity: 10];

  return self;
}

//////////////////////////////////////////////////

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

+(NSArray*) arrayForSexp: (sexp_t*) sexp {
  if(sexp->ty != SEXP_LIST){
    NSLog(@"ERROR: Expected a list: %@",[self stringForSexp: sexp]);
    return nil;
  }

  if(sexp_list_length(sexp) < 1){
    NSLog(@"ERROR: Didn't expect an empty list");
    return nil;
  }

  NSMutableArray* arr = [NSMutableArray arrayWithCapacity: sexp_list_length(sexp)];
  sexp_t* current = sexp->list;

  while(current){
    if(current->ty != SEXP_VALUE){
      NSLog(@"ERROR: Expected a list of atoms: %@",[self stringForSexp: sexp]);
      return nil;
    } else {
      [arr addObject: [NSString stringWithUTF8String: current->val]];
      current = current->next;
    }
  }

  return arr;
}

//////////////////////////////////////////////////

-(void) handleSexp: (sexp_t*) sexp {
  if(! [CommandController sexpIsValid: sexp]){ return; }

  id command = [[NSString alloc] initWithUTF8String: sexp->list->val ];
  //NSLog(@"Command: %@",command);
  //NSLog(@"String: %@",[CommandController stringForSexp: sexp]);
  if([command isEqual: @"echo"]){
    NSLog(@"%@", [CommandController stringForSexp: sexp]);
  } else if([command isEqual: @"rect"]){
    id shape = [self shapeForSexp: sexp];
    if(shape){ NSLog(@"Successfully created rect"); }
  }
}

-(NSBezierPath*) shapeForName: (NSString*) name { return [shapes objectForKey: name]; }

-(NSBezierPath*) shapeForSexp: (sexp_t*) sexp {
  if([CommandController sexpIsValid: sexp]){
    NSString* type = [NSString stringWithUTF8String: sexp->list->val];

    // Currently, we only support rects
    if([type isEqual: @"rect"]){
      NSArray* rect_params = [CommandController arrayForSexp: sexp];
      if(!rect_params){return nil;}
      if([rect_params count] != 5){
	NSLog(@"ERROR: Expected (rect [x] [y] [width] [height]), got %@", [CommandController stringForSexp: sexp]);
	return nil;
      }

      float x = [[rect_params objectAtIndex: 1] floatValue];
      float y = [[rect_params objectAtIndex: 2] floatValue];
      float width = [[rect_params objectAtIndex: 3] floatValue];
      float height = [[rect_params objectAtIndex: 4] floatValue];

      return [NSBezierPath bezierPathWithRect: NSMakeRect(x, y, width, height)];
    }
  } else {
    return nil;
  }
}

@end
