# UPYUN-Swift
Swift 2.0 环境下使用又拍云HTTP REST API的封装<br>
依赖于 <a href="https://github.com/Alamofire/Alamofire/tree/swift-2.0">Alamofire</a>请在使用前在项目中导入<br>

#使用说明
上传初始化:<br>
<pre><code>let upload: UPYUN = UPYUN(SpaceName: "空间名",OperatorName: "操作员名", OperatorPasswd: "操作员密码")</code></pre>
上传操作:(可上传多个图片)
<pre><code>upload.uploadImages(images: [UIImage], names: [String], uploadPath: String, <br>imageCompressionQuality: CGFloat)</code></pre>
上传结果处理: <br>
<pre><code>upload.setNotification(finishAction: (()->Void),errorAction: (()->Void))</code></pre>
下载操作(静态方法):
<pre><code>UPYUN.downloadImage(imageURL: String, imageView: UIImageView?, waitView: UIView?)</code></pre>
