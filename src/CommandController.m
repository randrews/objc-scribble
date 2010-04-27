#include "CommandController.h"

//////////////////////////////////////////////////
/// Categories ///////////////////////////////////
//////////////////////////////////////////////////

@interface CommandController (Internals)
+(BOOL) commandIsValid: (NSArray*) sexp;
-(NSBezierPath*) shapeForSexp: (NSArray*) sexp;
@end

@interface CommandController (Commands)
-(void) shapeCommand: (NSArray*) sexp;
@end

//////////////////////////////////////////////////
/// Internal functions ///////////////////////////
//////////////////////////////////////////////////

@implementation CommandController (Internals)

+(BOOL) commandIsValid: (NSArray*) sexp{
  if(!sexp){
    NSLog(@"ERROR: sexp was nil");
    return NO;
  }

  if([sexp count] == 0){
    NSLog(@"Command was an empty list");
    return NO;
  }

  id car = [sexp objectAtIndex: 0];

  if(![car isKindOfClass: [NSString class]]){
    NSLog(@"Command wasn't a symbol: %@", [car printAsSexp]);
    return NO;
  }

  return YES;
}

-(NSBezierPath*) shapeForSexp: (NSArray*) sexp {
  if(!sexp){ return nil; }

  // It's a name of a shape
  if([sexp isKindOfClass: [NSString class]]){
    [self shapeForName: (NSString*)sexp];

    // It's a literal shape
  } else if([sexp isKindOfClass: [NSArray class]]) {
      NSString* type = [sexp objectAtIndex: 0];

    // Currently, we only support rects
    if([type isEqual: @"rect"]){
      if([sexp count] != 5){
	NSLog(@"ERROR: Expected (rect [x] [y] [width] [height]), got %@", [sexp printAsSexp]);
	return nil;
      }

      // Ensure these are all atoms
      for(id obj in sexp){
	if(![obj isKindOfClass: [NSString class]]){
	  NSLog(@"ERROR: Expected (rect [x] [y] [width] [height]), got %@", [sexp printAsSexp]);
	  return nil;
	}
      }

      float x = [[sexp objectAtIndex: 1] floatValue] + 0.5;
      float y = [[sexp objectAtIndex: 2] floatValue] + 0.5;
      float width = [[sexp objectAtIndex: 3] floatValue];
      float height = [[sexp objectAtIndex: 4] floatValue];

      return [NSBezierPath bezierPathWithRect: NSMakeRect(x, y, width, height)];
    }
  } else {
    return nil;
  }
}

@end

//////////////////////////////////////////////////
/// Main class ///////////////////////////////////
//////////////////////////////////////////////////

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

-(void) handleSexp: (NSArray*) sexp {
  if(! [CommandController commandIsValid: sexp]){ return; }

  id command = [sexp objectAtIndex: 0];

  if([command isEqual: @"echo"]){
    NSLog(@"%@", [sexp printAsSexp]);
  } else if([command isEqual: @"shape"]){
    [self shapeCommand: sexp];
  }
//   } else if([command isEqual: @"stroke"]){

//     // First, make sure we have the right number of arguments.
//     // We need five, including "stroke", with an optional sixth
//     int length = sexp_list_length(sexp);
//     if(length == 5 || length == 6){

//       // Now, we need to find the shape.
//       NSBezierPath* shape;

//       // It's either a name, in which case shapeForName
//       if(sexp->list->next->ty == SEXP_VALUE){
// 	shape = [self shapeForName: [NSString stringWithUTF8String: sexp->list->next->val]];

// 	// Or it's a list, in which case shapeForSexp
//       } else if(sexp->list->next->ty == SEXP_LIST){
// 	shape = [self shapeForSexp: sexp->list->next];
//       }

//       // Check that we have a shape
//       if(!shape){
// 	NSLog(@"ERROR: %@ isn't a valid shape", [CommandController stringForSexp: sexp->list->next]);
//       } else {

// 	// We have a shape, now we need a color.
// 	NSMutableArray* color_elements = [NSMutableArray arrayWithCapacity: 4];
// 	[CommandController fillArray: color_elements fromSexp: sexp->list->next->next];

// 	// if an alpha isn't specified, default to 1.0
// 	if([color_elements count] < 4){
// 	  [color_elements addObject: @"1.0"];
// 	}

// 	DrawingCommand* dc = [[DrawingCommand alloc] init];
// 	dc.shape = shape;
// 	dc.shouldFill = NO;
// 	dc.color = [NSColor colorWithCalibratedRed: [[color_elements objectAtIndex: 0] floatValue]
// 			    green: [[color_elements objectAtIndex: 1] floatValue]
// 			    blue: [[color_elements objectAtIndex: 2] floatValue]
// 			    alpha: [[color_elements objectAtIndex: 3] floatValue]];

// 	[scribbleView addDrawingCommand: dc];
// 	[scribbleView setNeedsDisplay: YES];
//       }
//     } else {
//       NSLog(@"ERROR: Expected (stroke [shape] [red] [green] [blue] [alpha?]), got %@", [CommandController stringForSexp: sexp]);
}

-(NSBezierPath*) shapeForName: (NSString*) name { return [shapes objectForKey: name]; }

@end

//////////////////////////////////////////////////
/// Commands /////////////////////////////////////
//////////////////////////////////////////////////

@implementation CommandController (Commands)

-(void) shapeCommand: (NSArray*) sexp {
  if([sexp count] != 3 ||
     ![[sexp objectAtIndex: 1] isKindOfClass: [NSString class]]){
    NSLog(@"ERROR: Expected (shape [name] [shape]), got %@", [sexp printAsSexp]);
    return;
  }

  NSString* name = [sexp objectAtIndex: 1];
  id shape = [self shapeForSexp: [sexp objectAtIndex: 2]];

  if(shape){
    [shapes setValue: shape forKey: name];
  } else {
    NSLog(@"ERROR: Failed to create shape from %@", [sexp objectAtIndex: 2]);
  }
}

@end

