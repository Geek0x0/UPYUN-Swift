//
//  UPYUN.swift
//  
//
//  Created by Caydyn on 15/8/6.
//
//

import UIKit
import Alamofire
import CryptoSwift

/* 图片空间信息 */
let ImageUploadURL: String = "http://v0.api.upyun.com"
let ImageDownloadURL: String = "http://"

/* 请设置您的空间名称 和 操作员信息 */
let SpaceName: String = ""
let OperatorName: String = ""
let OperatorPasswd: String = ""

/* 图片压缩参数 */
let CompressionSize: CGSize = CGSizeMake(400, 400)
let CompressionRect: CGRect = CGRectMake(0, 0, 400, 400)

/* 压缩图片 */
func CompressionImage(image: UIImage) -> UIImage {
    UIGraphicsBeginImageContext(CompressionSize)
    image.drawInRect(CompressionRect)
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return newImage
}

/* 获取图片类型 */
enum imageType: Int {
    case jpeg
    case png
    case gif
    case tiff
    case null
}
func getImageType(date: NSData) -> imageType {
    var one_byte: UInt8 = 0
    date.getBytes(&one_byte, length: 1)
    switch one_byte {
    case 0xFF:
        return .jpeg
    case 0x89:
        return .png
    case 0x47:
        return .gif
    case 0x49:
        fallthrough
    case 0x4D:
        return .tiff
    default:
        return .null
    }
}

/* 获取当前时间的GMT时间 */
func GMTTimestamp() -> String {
    let date = NSDate()
    let dateFormatter: NSDateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "EEE, d MMM yyyy HH:mm:ss zzzz"
    dateFormatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
    dateFormatter.calendar =
        NSCalendar(calendarIdentifier: NSCalendarIdentifierISO8601)!
    dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
    return dateFormatter.stringFromDate(date)
}

/* 创建签名认证 */
func CreateAuthorizationOperator(method: String,
    requestURL: String, ContentLength: Int, AuthorDate: String) -> String {
        
        //MD5(METHOD & URL(/BUCKET/PATH/FILE) & DATE & CONTENT-LENGTH & MD5(PASSWORD))
        let passwdMD5: String = OperatorPasswd.md5()!.lowercaseString
        
        /*Assembly ALL MESSAGE*/
        var Authorization: String = method + "&"
        Authorization += requestURL + "&"
        Authorization += AuthorDate + "&"
        Authorization += "\(ContentLength)" + "&"
        Authorization += passwdMD5
        //print(Authorization)
        /*MD5 ALL*/
        Authorization = Authorization.md5()!.lowercaseString
        
        return Authorization
}

func BuildImageNamePrefix() -> String {
    let date = NSDate()
    let dateFormatter: NSDateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yyMMdd-HHmmss"
    return dateFormatter.stringFromDate(date)
}

var uploadStatus: [Bool] = []

func uploadCallBack(imageNames: [String], data: AnyObject?) {
    if uploadStatus.count == imageNames.count {
        for status in uploadStatus{
            if !status {
                //Upload Failed
                return
            }
        }
        //Upload Success
    } else {
        //Not Finish
    }
}

/* 上传图片处理 */
func uploadImage(images: [UIImage], path: String, finishData: AnyObject?) -> [String] {
    
    /* 清空统计 */
    uploadStatus = []
    
    var uploadImageNames: [String] = []
    let nameDatePrefix: String = BuildImageNamePrefix()
    let uploadDate: String = GMTTimestamp()
    
    for var index = 0; index < images.count; index++ {
        /* 1. 压缩图片 */
        let imageAfterCompression = CompressionImage(images[index])
        //let imageAfterCompression = images[index]
        /* 2. 将压缩后的图片转换为数据形式 *///TODO
        let imageData = UIImagePNGRepresentation(imageAfterCompression)!
        /* 3. 指定上传文件名 */
        let imageName: String = "\(GlobalUserData.userID)_" + nameDatePrefix + "_\(index)"
        uploadImageNames.append(imageName)
        /* 4. 创建授权 */
        var authorURL: String = ""
        if path.isEmpty {
            authorURL = "/\(SpaceName)/\(imageName).png"
        } else {
            authorURL = "/\(SpaceName)/\(path)/\(imageName).png"
        }
        let uploadAuthor: String = CreateAuthorizationOperator("PUT", requestURL: authorURL,
            ContentLength: imageData.length, AuthorDate: uploadDate)
        /* 5. 创建上传请求 */
        let uploadURLString: String =  "\(ImageUploadURL)\(authorURL)"
        let uploadRequestURL: NSURL = NSURL(string: uploadURLString)!
        let uploadRequest: NSMutableURLRequest = NSMutableURLRequest(URL: uploadRequestURL)
        uploadRequest.HTTPMethod = "PUT"
        uploadRequest.setValue(uploadDate, forHTTPHeaderField: "Date")
        uploadRequest.setValue("UpYun \(OperatorName):\(uploadAuthor)",
            forHTTPHeaderField: "Authorization")
        
        
        Alamofire.upload(uploadRequest, data: imageData)
            .progress { (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) in
                //print(totalBytesWritten)
            }
            .responseString { (request, response, data, error) -> Void in
                if response?.statusCode == 200 {
                    //Upload Success
                    uploadStatus.append(true)
                } else {
                    //Upload Failed
                    uploadStatus.append(false)
                    print(data)
                    print(response)
                }
                uploadCallBack(uploadImageNames, data: finishData)
        }
    }
    return uploadImageNames
}

func getDataFromUrl(urL:NSURL, completion: ((data: NSData?) -> Void)) {
    NSURLSession.sharedSession().dataTaskWithURL(urL) { (data, response, error) in
        completion(data: data)
        }.resume()
}
/* 下载图片处理 */
func downloadImage(urlString: String, imageView: UIImageView, waitView: UIView?){
    let url: NSURL = NSURL(string: urlString)!
    getDataFromUrl(url) { data in
        dispatch_async(dispatch_get_main_queue()) {
            imageView.image = UIImage(data: data!)
            waitView?.removeFromSuperview()
        }
    }
}
