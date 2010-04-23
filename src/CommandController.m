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

+(BOOL) fillArray: (NSMutableArray*) array fromSexp: (sexp_t*) sexp {
  sexp_t* current = sexp;

  while(current){
    if(current->ty != SEXP_VALUE){
      NSLog(@"ERROR: Expected a list of atoms: %@",[self stringForSexp: sexp]);
      return NO;
    } else {
      [array addObject: [NSString stringWithUTF8String: current->val]];
      current = current->next;
    }
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

  if([self fillArray: arr fromSexp: sexp->list]){
    return arr;
  } else {
    return nil;
  }
}

//////////////////////////////////////////////////

-(void) handleSexp: (sexp_t*) sexp {
  if(! [CommandController sexpIsValid: sexp]){ return; }

  id command = [[NSString alloc] initWithUTF8String: sexp->list->val ];
  //NSLog(@"Command: %@",command);
  //NSLog(@"String: %@",[CommandController stringForSexp: sexp]);
  if([command isEqual: @"echo"]){
    NSLog(@"%@", [CommandController stringForSexp: sexp]);
  } else if([command isEqual: @"shape"]){

    // Check that first arg is an atom
    if(sexp->list->next && sexp->list->next->ty == SEXP_VALUE){

      NSString* name = [NSString stringWithUTF8String: sexp->list->next->val];
      id shape = [self shapeForSexp: sexp->list->next->next];

      if(shape){
	[shapes setValue: shape forKey: name];
      } else {
	NSLog(@"ERROR: Expected (shape [name] [shape]), got %@", [CommandController stringForSexp: sexp]);
      }
    } else {
      NSLog(@"ERROR: Expected (shape [name] [shape]), got %@", [CommandController stringForSexp: sexp]);
    }
  } else if([command isEqual: @"stroke"]){

    // First, make sure we have the right number of arguments.
    // We need five, including "stroke", with an optional sixth
    int length = sexp_list_length(sexp);
    if(length == 5 || length == 6){

      // Now, we need to find the shape.
      NSBezierPath* shape;

      // It's either a name, in which case shapeForName
      if(sexp->list->next->ty == SEXP_VALUE){
	shape = [self shapeForName: [NSString stringWithUTF8String: sexp->list->next->val]];

	// Or it's a list, in which case shapeForSexp
      } else if(sexp->list->next->ty == SEXP_LIST){
	shape = [self shapeForSexp: sexp->list->next];
      }

      // Check that we have a shape
      if(!shape){
	NSLog(@"ERROR: %@ isn't a valid shape", [CommandController stringForSexp: sexp->list->next]);
      } else {

	// We have a shape, now we need a color.
	NSMutableArray* color_elements = [NSMutableArray arrayWithCapacity: 4];
	[CommandController fillArray: color_elements fromSexp: sexp->list->next->next];

	// if an alpha isn't specified, default to 1.0
	if([color_elements count] < 4){
	  [color_elements addObject: @"1.0"];
	}

	DrawingCommand* dc = [[DrawingCommand alloc] init];
	dc.shape = shape;
	dc.shouldFill = NO;
	dc.color = [NSColor colorWithCalibratedRed: [[color_elements objectAtIndex: 0] floatValue]
			    green: [[color_elements objectAtIndex: 1] floatValue]
			    blue: [[color_elements objectAtIndex: 2] floatValue]
			    alpha: [[color_elements objectAtIndex: 3] floatValue]];

	[scribbleView addDrawingCommand: dc];
	[scribbleView setNeedsDisplay: YES];
      }
    } else {
      NSLog(@"ERROR: Expected (stroke [shape] [red] [green] [blue] [alpha?]), got %@", [CommandController stringForSexp: sexp]);
    }
  }
}

-(NSBezierPath*) shapeForName: (NSString*) name { return [shapes objectForKey: name]; }

-(NSBezierPath*) shapeForSexp: (sexp_t*) sexp {
  if(!sexp){ return nil; }

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

      float x = [[rect_params objectAtIndex: 1] floatValue] + 0.5;
      float y = [[rect_params objectAtIndex: 2] floatValue] + 0.5;
      float width = [[rect_params objectAtIndex: 3] floatValue];
      float height = [[rect_params objectAtIndex: 4] floatValue];

      return [NSBezierPath bezierPathWithRect: NSMakeRect(x, y, width, height)];
    }
  } else {
    return nil;
  }
}

@end
