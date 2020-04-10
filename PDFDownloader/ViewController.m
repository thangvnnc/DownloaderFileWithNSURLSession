//
//  ViewController.m
//  PDFDownloader
//
//  Created by Malek T. on 10/27/15.
//  Copyright © 2015 Medigarage Studios LTD. All rights reserved.
//

#import "ViewController.h"

@interface ViewController (){
    NSURLSessionDownloadTask *download;

}
@property (strong, nonatomic) IBOutlet UIProgressView *progressView;
@property (nonatomic, strong)NSURLSession *backgroundSession;
@end

@implementation ViewController
- (IBAction)downloadFile:(id)sender {
    if (nil == download){
         NSURL *url = [NSURL URLWithString:@"http://www.nbb.be/DOC/BA/PDF7MB/2010/201000200051_1.PDF"];
         download = [self.backgroundSession downloadTaskWithURL:url];
        [download resume];
    }
}
- (IBAction)pauseDownload:(id)sender {
    if (nil != download){
        [download suspend];
    }
}
- (IBAction)resumeDownload:(id)sender {
    if (nil != download){
        [download resume];
    }
}
- (IBAction)cancelDownload:(id)sender {
    if (nil != download){
        [download cancel];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    // 1
    NSURLSessionConfiguration *backgroundConfigurationObject = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"myBackgroundSessionIdentifier"];
    
    // 2
    self.backgroundSession = [NSURLSession sessionWithConfiguration:backgroundConfigurationObject delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    
    // 3
    [self.progressView setProgress:0 animated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//
// 1
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectoryPath = [paths objectAtIndex:0];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSURL *destinationURL = [NSURL fileURLWithPath:[documentDirectoryPath stringByAppendingPathComponent:@"file.pdf"]];
    
    NSError *error = nil;
    
    if ([fileManager fileExistsAtPath:[destinationURL path]]){
        [fileManager replaceItemAtURL:destinationURL withItemAtURL:destinationURL backupItemName:nil options:NSFileManagerItemReplacementUsingNewMetadataOnly resultingItemURL:nil error:&error];
        [self showFile:[destinationURL path]];
        
    }else{
        
        if ([fileManager moveItemAtURL:location toURL:destinationURL error:&error]) {
            
            [self showFile:[destinationURL path]];
        }else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"PDFDownloader" message:[NSString stringWithFormat:@"An error has occurred when moving the file: %@",[error localizedDescription]] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
        }
    }
}

// 2
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    [self.progressView setProgress:(double)totalBytesWritten/(double)totalBytesExpectedToWrite
                          animated:YES];
}

// 3
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"PDFDownloader" message:@"Download is resumed successfully" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [alert show];
}

//
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    
    download = nil;
    [self.progressView setProgress:0];
    
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"PDFDownloader" message:[error localizedDescription] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
}

//
- (void)showFile:(NSString*)path{
    
    // Check if the file exists
    BOOL isFound = [[NSFileManager defaultManager] fileExistsAtPath:path];
    if (isFound) {
        
        UIDocumentInteractionController *viewer = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:path]];
        viewer.delegate = self;
        [viewer presentPreviewAnimated:YES];
    }
}

//
- (UIViewController *) documentInteractionControllerViewControllerForPreview: (UIDocumentInteractionController *) controller{
    
    return self;
}


                      

                      
@end
