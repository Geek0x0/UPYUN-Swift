//
//  UpYunSDK.swift
//
//  Created by 史凯迪 on 15/8/19.
//  Copyright © 2015年 msy. All rights reserved.
//

import UIKit
import Alamofire

let DEBUG: Bool = true

class UPYUN: NSObject {
    
    private let UploadURL: String = "http://v0.api.upyun.com"
    
    /* 空间名、操作员名、操作员密码 */
    private var SpaceName: String
    private var OperatorName: String
    private var OperatorPasswd: String
    
    /* 计算上传进度相关 */
    private var totalSize: Int64 = 0
    private var uploadSize: Int64 = 0
    private var uploadDataCount: Int = 0
    private var allUploadStatus: [Bool] = []
    
    private var _finish: (()->Void)?
    private var _error: (()->Void)?
    
    /* 初始化 */
    init(SpaceName: String, OperatorName: String, OperatorPasswd: String) {
            self.SpaceName = SpaceName
            self.OperatorName = OperatorName
            self.OperatorPasswd = OperatorPasswd
    }
    
    @objc private func finishAction(notification: NSNotification) {
        
        if let _ = self._finish {
            self._finish!()
        }
    }
    
    @objc private func errorAction(notification: NSNotification) {
        
        if let _ = self._error {
            self._error!()
        }
    }
    
    internal func setNotification(finishAction: (()->Void),
        errorAction: (()->Void)) {
            
            NSNotificationCenter.defaultCenter().removeObserver(self,
                name: "UPYUN_UploadFinish", object: nil)
            NSNotificationCenter.defaultCenter().removeObserver(self,
                name: "UPYUN_UploadError", object: nil)
            
            self._finish = finishAction
            self._error = errorAction
            
            NSNotificationCenter.defaultCenter().addObserver(self,
                selector: "finishAction:", name: "UPYUN_UploadFinish", object: nil)
            NSNotificationCenter.defaultCenter().addObserver(self,
                selector: "errorAction:", name: "UPYUN_UploadError", object: nil)
    }
    
    private func GMT() -> String {
        let date = NSDate()
        let dateFormatter: NSDateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEE, d MMM yyyy HH:mm:ss zzzz"
        dateFormatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        dateFormatter.calendar =
            NSCalendar(calendarIdentifier: NSCalendarIdentifierISO8601)!
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        return dateFormatter.stringFromDate(date)
    }
    
    private func initUploadRecordData() {
        self.totalSize = 0
        self.uploadSize = 0
        self.allUploadStatus = []
    }
    
    private func uploadCallBack() {
        if self.uploadDataCount == self.allUploadStatus.count {
            for uploadStatus in self.allUploadStatus {
                if !uploadStatus {
                    NSNotificationCenter.defaultCenter().postNotificationName("UPYUN_UploadError", object: nil)
                    return
                }
            }
            NSNotificationCenter.defaultCenter().postNotificationName("UPYUN_UploadFinish", object: nil)
        }
    }
    
    private func uploadData(UploadData: NSData, path: String, name: String,
        uploadDate: String) {
            
            var authorURL: String = ""
            if path.isEmpty {
                authorURL = "/\(self.SpaceName)/\(name)"
            } else {
                authorURL = "/\(self.SpaceName)/\(path)/\(name)"
            }
            let uploadAuthor: String =
            CreateAuthorizationOperator("PUT", requestURL: authorURL,
                ContentLength: UploadData.length, AuthorDate: uploadDate)
            let uploadURLString: String =  "\(self.UploadURL)\(authorURL)"
            let uploadRequestURL: NSURL = NSURL(string: uploadURLString)!
            let uploadRequest: NSMutableURLRequest =
                NSMutableURLRequest(URL: uploadRequestURL)
            uploadRequest.HTTPMethod = "PUT"
            uploadRequest.setValue(uploadDate, forHTTPHeaderField: "Date")
            uploadRequest.setValue("UpYun \(OperatorName):\(uploadAuthor)",
                forHTTPHeaderField: "Authorization")
            if !path.isEmpty {
                uploadRequest.setValue("true", forHTTPHeaderField: "mkdir")
            }
            Alamofire.upload(uploadRequest, data: UploadData)
            .progress { (bytesWritten, totalBytesWritten, BytesOfExpected) -> Void in
                self.uploadSize += bytesWritten
            }
            .responseData { (request, response, responseData) -> Void in
                if response?.statusCode == 200 {
                    //Upload Success
                    self.allUploadStatus.append(true)
                } else {
                    //Upload Failed
                    self.allUploadStatus.append(true)
                    //print(__FILE__, __LINE__, response)
                }
                self.uploadCallBack()
            }
    }
    
    private func CreateAuthorizationOperator(method: String,
        requestURL: String, ContentLength: Int, AuthorDate: String) -> String {
            
            //MD5(METHOD & URL(/BUCKET/PATH/FILE) & DATE & CONTENT-LENGTH & MD5(PASSWORD))
            let passwdMD5: String = OperatorPasswd.MD5
            if DEBUG { print("password to md5 : \(passwdMD5)")}
            
            /*Assembly ALL MESSAGE*/
            var authorization: String = method + "&"
            authorization += requestURL + "&"
            authorization += AuthorDate + "&"
            authorization += "\(ContentLength)" + "&"
            authorization += passwdMD5
            //print(Authorization)
            /*MD5 ALL*/
            if DEBUG { print("authorization : \(authorization)")}
            authorization = authorization.MD5
            if DEBUG { print("authorization to md5 : \(authorization)")}
            
            return authorization
    }
    
    private func imageToData(images: [UIImage],
        compressionQuality: CGFloat) -> (resault: Bool, datas: [NSData]) {
            
            var datas: [NSData] = []
            for image in images {
                if let imageData: NSData =
                    UIImageJPEGRepresentation(image, compressionQuality) {
                        datas.append(imageData)
                        self.totalSize += imageData.length
                } else {
                    return (false, [])
                }
            }
            return (true, datas)
    }

    internal func uploadImages(images: [UIImage], names: [String],
        uploadPath: String, imageCompressionQuality: CGFloat) -> Bool {
            
            self.initUploadRecordData()
            if images.count != names.count { return false }
            
            let imageTodataRet = self.imageToData(images,
                compressionQuality: imageCompressionQuality)
            if !imageTodataRet.resault {
                return false
            }
            
            let imageDatas: [NSData] = imageTodataRet.datas
            self.uploadDataCount = imageDatas.count
            
            let uploadDate: String = self.GMT()
            for var index = 0; index < images.count; index++ {
                self.uploadData(imageDatas[index], path: uploadPath,
                    name: names[index], uploadDate: uploadDate)
            }
            return true
    }
    
    static func getDataFromUrl(urL:NSURL, completion: ((data: NSData?) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(urL) { (data, response, error) in
            completion(data: data)
            }.resume()
    }
    
    static func downloadImage(imageURL: String,
        imageView: UIImageView?, waitView: UIView?) {
            if let url: NSURL = NSURL(string: imageURL) {
                self.getDataFromUrl(url, completion: { (data) -> Void in
                    dispatch_async(dispatch_get_main_queue()) {
                        imageView?.image = UIImage(data: data!)
                        waitView?.removeFromSuperview()
                    }
                })
            }
    }
    
    
    internal func getUploadProgress() -> Double {
        if self.uploadSize == 0 {
            return 0
        } else {
            return (Double(self.uploadSize) / Double(self.totalSize))
        }
    }
}