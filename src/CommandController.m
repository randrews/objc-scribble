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
-(void) fillCommand: (NSArray*) sexp;
-(void) clearCommand: (NSArray*) sexp;
-(void) backgroundCommand: (NSArray*) sexp;
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
      [sexp assertSexpFormat: @"(rect [x] [y] [width] [height])"
	    withLength: 5,
	    false, false, false, false, false];

      float x = [[sexp objectAtIndex: 1] floatValue] + 0.5;
      float y = [[sexp objectAtIndex: 2] floatValue] + 0.5;
      float width = [[sexp objectAtIndex: 3] floatValue];
      float height = [[sexp objectAtIndex: 4] floatValue];

      return [NSBezierPath bezierPathWithRect: NSMakeRect(x, y, width, height)];
    } else {
      [NSException raise: @"badShape"
		   format: @"Unable to make shape from %@",
		   [sexp printAsSexp]];
    }
  }
}

+(NSColor*) colorForArray: (NSArray*) array {
  if([array count] == 3){
    NSArray* color_elements = [NSMutableArray arrayWithCapacity: 4];

    [(NSMutableArray*)color_elements addObjectsFromArray: array];
    [(NSMutableArray*)color_elements addObject: @"1.0"];

    return [self colorForArray: color_elements];
  } else {
    [array assertSexpFormat: @"(red green blue [alpha])"
	   withLength: 4,
	   false, false, false, false];

    return [NSColor colorWithCalibratedRed: [[array objectAtIndex: 0] floatValue]
		    green: [[array objectAtIndex: 1] floatValue]
		    blue: [[array objectAtIndex: 2] floatValue]
		    alpha: [[array objectAtIndex: 3] floatValue]];
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

  @try {
    if([command isEqual: @"echo"]){
      NSLog(@"%@", [sexp printAsSexp]);
    } else if([command isEqual: @"shape"]){
      [self shapeCommand: sexp];
    } else if([command isEqual: @"stroke"]){
      [self strokeCommand: sexp];
    } else if([command isEqual: @"fill"]){
      [self fillCommand: sexp];
    } else if([command isEqual: @"clear"]){
      [self clearCommand: sexp];
    } else if([command isEqual: @"background"]){
      [self backgroundCommand: sexp];
    }
  } @catch(NSException* e){
    NSLog(@"ERROR: %@, command was %@",
	  [e reason],
	  [sexp printAsSexp]);
  }
}

// Return the shape named "name", or raise an exception. Never returns nil.
-(NSBezierPath*) shapeForName: (NSString*) name {
  id shape = [shapes objectForKey: name];
  if(!shape){
    [NSException raise: @"shapeNotFound" format: @"Couldn't find shape named %@", name];
  }

  return shape;
}

@end

//////////////////////////////////////////////////
/// Commands /////////////////////////////////////
//////////////////////////////////////////////////

@implementation CommandController (Commands)

-(void) shapeCommand: (NSArray*) sexp {
  if([sexp count] != 3 ||
     ![[sexp objectAtIndex: 1] isKindOfClass: [NSString class]]){
    [NSException raise:@"badCmdFmt" format: @"ERROR: Expected (shape [name] [shape])"];
  }

  [shapes setValue: [self shapeForSexp: [sexp objectAtIndex: 2]]
	  forKey: [sexp objectAtIndex: 1]];
}

-(void) strokeCommand: (NSArray*) sexp {
  // First, make sure we have the right number of arguments.
  // We need five, including "stroke", with an optional sixth
  if([sexp count] != 5 && [sexp count] != 6){
    [NSException raise: @"badCmdFmt"
		 format: @"ERROR: Expected (stroke [shape] [red] [green] [blue] [alpha?])"];
  }

  // Now, we need to find the shape.
  NSBezierPath* shape = [self shapeForSexp: [sexp objectAtIndex: 1]];

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

-(void) fillCommand: (NSArray*) sexp {
  // First, make sure we have the right number of arguments.
  // We need five, including "stroke", with an optional sixth
  if([sexp count] != 5 && [sexp count] != 6){
    NSLog(@"ERROR: Expected (fill [shape] [red] [green] [blue] [alpha?]), got %@",
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
    NSLog(@"ERROR: Expected (fill [shape] [red] [green] [blue] [alpha?]), got %@",sexp);
    return;
  }

  DrawingCommand* dc = [[DrawingCommand alloc] init];
  dc.shape = shape;
  dc.shouldFill = YES;
  dc.color = color;

  [scribbleView addDrawingCommand: dc];
  [scribbleView setNeedsDisplay: YES];
}

-(void) clearCommand: (NSArray*) sexp {
  if([sexp count] != 1){
    NSLog(@"ERROR: clear accepts no arguments, got %@", [sexp printAsSexp]);
  }

  [scribbleView clearDrawingCommands];
  [scribbleView setNeedsDisplay: YES];
}

-(void) backgroundCommand: (NSArray*) sexp {
  if([sexp count] != 4){
    NSLog(@"ERROR: Expected (background [red] [green] [blue]), got %@", [sexp printAsSexp]);
  }

  NSColor* color = [CommandController colorForArray:
					[sexp subarrayWithRange:
						NSMakeRange(1, 3)]];

  if(!color){
    NSLog(@"ERROR: Expected (fill [shape] [red] [green] [blue] [alpha?]), got %@",sexp);
    return;
  }

  [scribbleView setBackgroundColor: color];
  [scribbleView setNeedsDisplay: YES];
}

@end

