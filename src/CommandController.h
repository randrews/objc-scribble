#import <Foundation/Foundation.h>
#import "ScribbleView.h"
#import "DrawingCommand.h"
#import "PrintSexp.h"
#import "ParseSexp.h"

@interface CommandController : NSObject {
  NSMutableDictionary* shapes;
  ScribbleView* scribbleView;
}

-(id) initWithScribbleView: (ScribbleView*) scribbleView;
-(void) handleSexp: (NSArray*) sexp;
-(NSBezierPath*) shapeForName: (NSString*) name;

@end
