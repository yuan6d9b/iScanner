//
//  Macro.h
//  PDFScanner
//
//  Created by Y on 2018/11/5.
//  Copyright © 2018 Y. All rights reserved.
//

#ifndef Macro_h
#define Macro_h

#define StatusBarHeight [UIApplication sharedApplication].statusBarFrame.size.height

#define NavigationBarHeight self.navigationController.navigationBar.frame.size.height

#define ToolbarHeight self.navigationController.toolbar.frame.size.height

#define IS_IPHONEX CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(375, 812))
#define IS_IPHONEXR CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(414, 896))
#define IS_IPHONEXSM CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(375, 896))

// 主目录
#define HomeFolderName @"HomeFolder"
// 原图
#define OriginalFolderName @"OriginalFolder"
// 主目录路径
#define HomeFolderPath [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:HomeFolderName]
// 原图路径
#define OriginalFolderPath [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:OriginalFolderName]

#define alert(msg) {\
UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:msg preferredStyle:UIAlertControllerStyleAlert];\
UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {\
}];\
[alert addAction:action];\
[self presentViewController:alert animated:YES completion:nil];\
}

#define dismissAlert(msg) {\
UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:msg preferredStyle:UIAlertControllerStyleAlert];\
UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {\
[self dismissViewControllerAnimated:YES completion:nil];\
}];\
[alert addAction:action];\
[self presentViewController:alert animated:YES completion:nil];\
}

#define APPID @"1444564505"

#endif /* Macro_h */
