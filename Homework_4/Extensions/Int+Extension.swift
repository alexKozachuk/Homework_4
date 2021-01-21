//
//  Int+Extension.swift
//  Homework_4
//
//  Created by Sasha on 20/01/2021.
//

import Foundation

extension Int {
    
    func getTime() -> Date {
        let epocTime = TimeInterval(self)
        let myDate = Date(timeIntervalSince1970: epocTime)
        return myDate
    }
    
}
