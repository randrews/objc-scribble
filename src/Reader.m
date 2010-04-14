#import "Reader.h"

@implementation Reader

// The arg is actually ignored
-(void) startListening: (id) arg {

  while(true){
    NSData* inputData = [[NSFileHandle fileHandleWithStandardInput]
			  availableData];
    NSString* inputString = [[NSString alloc] initWithData:inputData
					      encoding:NSASCIIStringEncoding];

    NSLog(@"%@",inputString);
  }
}

@end
