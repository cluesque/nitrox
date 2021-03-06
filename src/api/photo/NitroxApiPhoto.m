//
//  NitroxApiPhoto.m
//  nitroxy1
//
//  Created by Robert Sanders on 10/3/08.
//  Copyright 2008 ViTrue, Inc.. All rights reserved.
//

#import "NitroxApiPhoto.h"


@implementation NitroxApiPhoto

@synthesize picker, urlFormat, saveDir;

- (id) init {
    [super init];
    completionCondition = [[NSCondition alloc] init];
    self.urlFormat = @"%@";
    NSString *tmpdir = [NSString stringWithCString:getenv("TMPDIR")];
    self.saveDir = [tmpdir retain];
    return self;
}

- (void) dealloc {
    self.picker = nil;
    self.saveDir = nil;
    self.urlFormat = nil;
    [lastImage release];
    [completionCondition release];
    [super dealloc];
}

#pragma mark Photo specific methods

/*
 * Data URI
 *
 *
 */

- (id) hasCamera {
    return [NSNumber numberWithBool:
            [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]];
}

- (id) hasLibrary {
    return [NSNumber numberWithBool:
            [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]];
}

- (void) setupPicker {
    self.picker = [[NitroxImagePicker alloc] initWithNibName:@"NitroxImagePickerUI"
                                                      bundle:[NSBundle mainBundle]];
    picker.delegate = self;
    picker.hostingController = (UIViewController *)self.dispatcher.webViewController;
}

- (id) showPicker {
    [self setupPicker];
    UIView *view = [self.dispatcher.webViewController webView];

    [picker performSelectorOnMainThread:@selector(showInView:)
                             withObject:view waitUntilDone:NO];
    
//    NSLog(@"acquiring lock");
//    [completionCondition lock];
//    NSLog(@"waiting for completion");
//    [completionCondition wait];
//    NSLog(@"completed");
//    [completionCondition unlock];
//    
//    NSLog(@"returning new image path %@", lastImage);

    return nil;
}

- (id) takePhoto {
    [self setupPicker];

    picker.delegate = self;
    [picker performSelectorOnMainThread:@selector(pickNewPhoto)
                             withObject:nil waitUntilDone:NO];
    return nil;
}

- (id) chooseFromLibrary {
    [self setupPicker];

    picker.delegate = self;
    // [picker pickExistingPhoto];
    [picker performSelectorOnMainThread:@selector(pickExistingPhoto)
                             withObject:nil waitUntilDone:NO];
    return nil;
}

- (NSString *) saveImageToTempFile:(UIImage *)image
{
    NSString *filepart = [NSString stringWithFormat:@"%d.jpg", time(NULL)];
    NSString *filename = [NSString stringWithFormat:@"%@/%@", 
                          self.saveDir, filepart];

    if (![[NSFileManager defaultManager] 
                            createFileAtPath:filename 
                            contents:UIImageJPEGRepresentation(image, 0.9)  
                            attributes:nil]) 
    {
        NSLog(@"couldn't create image file at path %@", filename);
        return nil;
    }

    return filepart;
}

- (void) cleanupPicker {
    self.picker = nil;
}

#pragma mark Imagepicker delegate methods

- (void)imagePickerController:(UIImagePickerController *)thispicker 
        didFinishPickingImage:(UIImage *)image 
                  editingInfo:(NSDictionary *)editingInfo {
    
    NSLog(@"Picked an image in NAP!");
    
    [image retain];
    
    NSString *filename = [self saveImageToTempFile:image];

    lastImage = [filename retain];
    NSLog(@"saved image to path %@", filename);
    
    CGSize size = [image size];
    NSMutableDictionary *meta = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithDouble:size.width], @"width",
                                    [NSNumber numberWithDouble:size.height], @"height",
                                    [NSNumber numberWithInt:[image imageOrientation]], @"orientation",
                                    @"jpeg", @"format",
                                    nil];
    
    NSString *jsstring = [NSString stringWithFormat:@"Nitrox.Photo._success(%@, %@)",
                          [self serialize:lastImage], [self serialize:meta]];
    
    [dispatcher scheduleCallback:[NitroxRPCCallback callbackWithString:jsstring] immediate:NO];

//    [completionCondition lock];
//    [completionCondition signal];
//    [completionCondition unlock];    

    [image release];
    
    [self cleanupPicker];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)thispicker {
    NSLog(@"Canceled picking an image in PIP");

    NSString *jsstring = [NSString stringWithFormat:@"Nitrox.Photo._cancel({})"];
    
    [dispatcher scheduleCallback:[NitroxRPCCallback callbackWithString:jsstring] immediate:NO];
    
//    [completionCondition lock];
//    [completionCondition signal];
//    [completionCondition unlock];

    [self cleanupPicker];
}

#pragma mark Stub methods; should refactor out


- (NSString *) instanceMethods {
    return nil;
}

- (NSString *) classMethods {
    return nil;
}

- (id) newInstance {
    return nil;
}

- (id) newInstanceWithArgs:(NSDictionary *)args {
    return nil;
}

- (id) invoke:(NSString *)method args:(NSDictionary *)args {
    return nil;
}


@end
