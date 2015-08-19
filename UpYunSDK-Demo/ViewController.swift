//
//  ViewController.swift
//  UpYunSDK-Demo
//
//  Created by 史凯迪 on 15/8/19.
//  Copyright © 2015年 msy. All rights reserved.
//

import UIKit

class ViewController: UIViewController,
UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var UploadProgress: UILabel!
    @IBOutlet weak var UploadResault: UILabel!
    
    var iPC: UIImagePickerController = UIImagePickerController()
    var uploadImage: UIImage?
    
    let upload: UPYUN = UPYUN(SpaceName: "",
        OperatorName: "", OperatorPasswd: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.UploadProgress.text = "0%"
        self.UploadResault.text = "未上传图片"
        
        self.iPC.delegate = self
        self.iPC.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        self.iPC.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
    }
    
    func imagePickerController(picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [String : AnyObject]) {
            self.iPC.dismissViewControllerAnimated(true, completion:nil)
            let gotImage = info[UIImagePickerControllerOriginalImage]as! UIImage
            self.image.image = gotImage
            self.uploadImage = gotImage
    }
    
    @IBAction func ChooseImage(sender: UIButton) {
        self.presentViewController(self.iPC, animated:true,
            completion: nil)
    }
    
    func finish() {
        self.UploadResault.text = "上传成功"
    }
    
    func error() {
        self.UploadResault.text = "上传失败"
    }
    
    @IBAction func UploadImage(sender: UIButton) {
        
        if let _ = self.uploadImage {
            upload.setNotification({ () -> Void in
                self.finish()
                }, errorAction: { () -> Void in
                    self.error()
            })
            upload.uploadImages([uploadImage!], names: ["picture"],
                uploadPath: "dir", imageCompressionQuality: 1)
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                while true {
                    let Progress = self.upload.getUploadProgress()
                    if Progress >= 1 {
                        self.UploadProgress.text = "100%"
                        break
                    } else {
                        let showProgress: Double = Progress * 100
                        print(Int(showProgress))
                        self.UploadProgress.text = "\(showProgress)"
                    }
                    usleep(100)
                }
            })
        }
    }
    
    @IBAction func DownloadAction(sender: UIButton) {
        UPYUN.downloadImage("", imageView: self.image, waitView: nil)
    }
}

