//
//  String+UPYUN.swift
//  UpYunSDK-Demo
//
//  Created by 史凯迪 on 15/8/28.
//  Copyright © 2015年 msy. All rights reserved.
//

import Foundation

extension String {
    func MD5String() -> String? {
        if let data = self.dataUsingEncoding(NSUTF8StringEncoding) {
            let MD5Calculator = MD5(data)
            let MD5Data = MD5Calculator.calculate()
            let resultBytes = UnsafeMutablePointer<CUnsignedChar>(MD5Data.bytes)
            let resultEnumerator = UnsafeBufferPointer<CUnsignedChar>(start: resultBytes, count: MD5Data.length)
            let MD5String = NSMutableString()
            for c in resultEnumerator {
                MD5String.appendFormat("%02x", c)
            }
            return MD5String as String
        } else {
            return nil
        }
    }
}