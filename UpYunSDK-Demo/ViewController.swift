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
    
    private var updateTimer: NSTimer?
    
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
    
    @objc private func updateUploadProgress() {
        let progress = self.upload.getUploadProgress()
        if progress >= 1 {
            self.clearAllNotice()
            self.UploadProgress.text = "100%"
            self.UploadResault.text = "上传成功"
            self.updateTimer?.invalidate()
        } else {
            let showProgress: Double = progress * 100
            self.UploadProgress.text = "\(Int(showProgress))%"
        }
    }
    
    @IBAction func UploadImage(sender: UIButton) {
        
        if let _ = self.uploadImage {
            upload.uploadImages([uploadImage!], names: ["picture"],
                uploadPath: "dir", imageCompressionQuality: 1)
            self.UploadResault.text = "正在上传..."
            self.pleaseWait()
            self.updateTimer = NSTimer.scheduledTimerWithTimeInterval(0.01,
                target: self, selector: Selector("updateUploadProgress"),
                userInfo: nil, repeats: true)
        }
    }
    
    @IBAction func DownloadAction(sender: UIButton) {
        UPYUN.downloadImage("", imageView: self.image, waitView: nil)
    }
}

