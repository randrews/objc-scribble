#import <Foundation/Foundation.h>
#include "sexp.h"
#import "ScribbleView.h"

@interface CommandController : NSObject {
  NSMutableDictionary* shapes;
  ScribbleView* scribbleView;
}

+(NSString*) stringForSexp: (sexp_t*) sexp;
+(BOOL) sexpIsValid: (sexp_t*) sexp;
+(NSArray*) arrayForSexp: (sexp_t*) sexp;

-(id) initWithScribbleView: (ScribbleView*) scribbleView;
-(void) handleSexp: (sexp_t*) sexpr;
-(NSBezierPath*) shapeForName: (NSString*) name;
-(NSBezierPath*) shapeForSexp: (sexp_t*) sexp;

@end
