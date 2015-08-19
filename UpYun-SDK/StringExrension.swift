//
//  StringExrension.swift
//  UpYunSDK-Demo
//
//  Created by 史凯迪 on 15/8/19.
//  Copyright © 2015年 msy. All rights reserved.
//

import UIKit

extension String  {
    var MD5: String! {
        let str = self.cStringUsingEncoding(NSUTF8StringEncoding)
        let strLen = CC_LONG(self.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.alloc(digestLen)
        
        CC_MD5(str!, strLen, result)
        
        let hash = NSMutableString()
        for i in 0..<digestLen {
            hash.appendFormat("%02x", result[i])
        }
        result.dealloc(digestLen)
        
        return String(format: hash as String)
    }
}