# UPYUN-Swift
Swift 2.0 环境下使用又拍云HTTP REST API的封装<br>
依赖于 <a href="https://github.com/Alamofire/Alamofire/tree/swift-2.0">Alamofire</a>请在使用前在项目中导入<br>

##编译环境
- iOS 8.0+
- Xcode 7.0 beta 5+

##使用说明
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
