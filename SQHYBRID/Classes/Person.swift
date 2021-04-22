//
//  Person.swift
//  SQHYBRID
//
//  Created by yuehuig on 2021/4/19.
//

import Foundation

@objcMembers public class Person: NSObject {
    public var name: String?
    public var age: String?
    
    public convenience init(name: String?, age: String?) {
        self.init()
        self.name = name
        self.age = age
    }
}
