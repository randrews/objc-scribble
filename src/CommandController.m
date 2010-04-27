#include "CommandController.h"

//////////////////////////////////////////////////
/// Categories ///////////////////////////////////
//////////////////////////////////////////////////

@interface CommandController (Internals)
+(BOOL) commandIsValid: (NSArray*) sexp;
+(NSColor*) colorForArray: (NSArray*) array;
-(NSBezierPath*) shapeForSexp: (NSArray*) sexp;
@end

@interface CommandController (Commands)
-(void) shapeCommand: (NSArray*) sexp;
-(void) strokeCommand: (NSArray*) sexp;
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
    return [self shapeForName: (NSString*)sexp];

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
      } else {
	return nil;
      }
  } else {
    return nil;
  }
}

+(NSColor*) colorForArray: (NSArray*) array {
  // Either (r g b) or (r g b a)
  if([array count] < 3 || [array count] > 4){
    return nil;
  }

  // Make sure everything's an atom
  for(id obj in array){
    if(![obj isKindOfClass: [NSString class]]){
      return nil;
    }
  }

  NSArray* color_elements;

  // If it's r g b, then copy into a larger array and add an alpha
  if([array count] == 3){
    color_elements = [NSMutableArray arrayWithCapacity: 4];
    [(NSMutableArray*)color_elements addObjectsFromArray: array];
    [(NSMutableArray*)color_elements addObject: @"1.0"];
  } else {
    // Otherwise, we're fine as is
    color_elements = array;
  }

  return [NSColor colorWithCalibratedRed: [[color_elements objectAtIndex: 0] floatValue]
		  green: [[color_elements objectAtIndex: 1] floatValue]
		  blue: [[color_elements objectAtIndex: 2] floatValue]
		  alpha: [[color_elements objectAtIndex: 3] floatValue]];
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
  } else if([command isEqual: @"stroke"]){
    [self strokeCommand: sexp];
  }
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

-(void) strokeCommand: (NSArray*) sexp {
  // First, make sure we have the right number of arguments.
  // We need five, including "stroke", with an optional sixth
  if([sexp count] != 5 && [sexp count] != 6){
    NSLog(@"ERROR: Expected (stroke [shape] [red] [green] [blue] [alpha?]), got %@",
	  [sexp printAsSexp]);
    return;
  }

  // Now, we need to find the shape.
  NSBezierPath* shape = [self shapeForSexp: [sexp objectAtIndex: 1]];

  // Check that we have a shape
  if(!shape){
    NSLog(@"ERROR: %@ isn't a valid shape", [sexp printAsSexp]);
    return;
  }

  // We have a shape, now we need a color.
  NSColor* color = [CommandController colorForArray:
					[sexp subarrayWithRange:
						NSMakeRange(2, [sexp count] - 2)]];

  if(!color){
    NSLog(@"ERROR: Expected (stroke [shape] [red] [green] [blue] [alpha?]), got %@",sexp);
    return;
  }

  DrawingCommand* dc = [[DrawingCommand alloc] init];
  dc.shape = shape;
  dc.shouldFill = NO;
  dc.color = color;

  [scribbleView addDrawingCommand: dc];
  [scribbleView setNeedsDisplay: YES];
}

@end

