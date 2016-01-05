# UPYUN-Swift
[![WeiBo](http://img.shields.io/badge/contact-@Caydyn-orange.svg?style=flat)](http://weibo.com/372145087)
[![ghit.me](https://ghit.me/badge.svg?repo=caydyn-skd/UPYUN-Swift)](https://ghit.me/repo/caydyn-skd/UPYUN-Swift)
[![Language](http://img.shields.io/badge/language-swift-orange.svg?style=flat)](https://developer.apple.com/swift)
[![Platform](https://img.shields.io/badge/platform-ios-lightgrey.svg?style=flat)](https://developer.apple.com/resources/)
[![Issues](https://img.shields.io/github/issues/caydyn-skd/UPYUN-Swift.svg?style=flat)](https://github.com/caydyn-skd/UPYUN-Swift/issues)

Swift 2.0 环境下使用又拍云HTTP REST API的封装<br>
不依赖于其它第三方库<br>

##编译环境
- iOS 8.0+
- Xcode 7.0 beta 6+

##使用说明
使用SDK:<br>
```swift
import UpYunSDK
```
上传初始化:<br>
```swift
let upload: UPYUN = UPYUN(SpaceName: "空间名", 
  OperatorName: "操作员名", OperatorPasswd: "操作员密码")
```
上传操作:(可上传多个图片)
```swift
upload.uploadImages(images: [UIImage], names: [String], uploadPath: String, 
imageCompressionQuality: CGFloat)
```
上传结果处理: <br>
```swift
upload.setNotification(finishAction: (()->Void),errorAction: (()->Void))
```
下载操作(静态方法):
```swift
UPYUN.downloadImage(imageURL: String, imageView: UIImageView?, waitView: UIView?)
```
