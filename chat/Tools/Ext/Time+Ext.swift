//
//  Time+Ext.swift
//  chat
//
//  Created by Grand on 2019/8/12.
//  Copyright © 2019 netcloth. All rights reserved.
//

import Foundation

// Wechat 时间构造类别
class Time {
    
    /**
     https://36kr.com/p/5213185
     http://www.52im.net/thread-2371-1-1.html
     
     * 仿照微信中的消息时间显示逻辑，将时间戳（单位：毫秒）转换为友好的显示格式.
     *
     * 1）7天之内的日期显示逻辑是：今天、昨天(-1d)、前天(-2d)、星期？（只显示总计7天之内的星期数，即<=-4d）；
     * 2）7天之外（即>7天）的逻辑：直接显示完整日期时间。
     *
     * @param dt 日期时间对象（本次被判断对象）
     * @param includeTime YES表示输出的格式里一定会包含“时间:分钟”，否则不包含（参考微信，不包含时分的情况，用于首页“消息”中显示时）
     *
     * @return 输出格式形如：“刚刚”、“10:30”、“昨天 12:04”、“前天 20:51”、“星期二”、“2019/2/21 12:09”等形式
     * @since 1.3
     */
    
    static func timeDesc(from timeInterval: Double, includeH_M: Bool) -> String
    {
        var ret: String? = nil
        // 当前时间
        let currentDate = NSDate()
        let currentYear = currentDate.year
        let currentMonth = currentDate.month
        let currentDay =  currentDate.day
        let currentWeekYear = currentDate.weekOfYear
        
        // 目标判断时间
        let srcDate = NSDate(timeIntervalSince1970: timeInterval)
        
        let srcYear = srcDate.year
        let srcMonth = srcDate.month
        let srcDay = srcDate.day
        let srcWeekYear = srcDate.weekOfYear
        
        // 要额外显示的时间分钟
        var timeExtraStr = ""
        if includeH_M {
            timeExtraStr = " \(srcDate.string(withFormat: "HH:mm")!)"
        }
        
        // 当年
        if (currentYear == srcYear) {
            let currentTimestamp = currentDate.timeIntervalSince1970
            let srcTimestamp = timeInterval
            
            // 相差时间（单位：秒）
            let delta = currentTimestamp - srcTimestamp
            
            // 当天（月份和日期一致才是）
            if (currentMonth == srcMonth && currentDay == srcDay) {
                // 时间相差60秒以内
                if (delta < 60) {
                    ret = "Just now".localized()
                }
                else {
                    // 否则当天其它时间段的，直接显示“时:分”的形式
                    ret = srcDate.string(withFormat: "HH:mm")
                }
            }
            else {
                // 当年 && 当天之外的时间（即昨天及以前的时间）
                // 昨天（以“现在”的时候为基准-1天）
                var yesterdayDate = NSDate()
                yesterdayDate = NSDate(timeInterval: -24*60*60, since: yesterdayDate as Date)
                
                
                let yesterdayMonth = yesterdayDate.month
                let yesterdayDay = yesterdayDate.day
                
                if (false) {//srcMonth == yesterdayMonth && srcDay == yesterdayDay
                    ret = NSLocalizedString("Yesterday", comment: "") + timeExtraStr
                }
                else {
                    // 跟当前时间相差的小时数
                    let deltaHour = (delta/3600);
                    // 同一周
                    if (currentWeekYear == srcWeekYear){
                        let d_7 = NSLocalizedString("Sunday", comment: "")
                        let d_1 = NSLocalizedString("Monday", comment: "")
                        let d_2 = NSLocalizedString("Tuesday", comment: "")
                        let d_3 = NSLocalizedString("Wednesday", comment: "")
                        let d_4 = NSLocalizedString("Thursday", comment: "")
                        let d_5 = NSLocalizedString("Friday", comment: "")
                        let d_6 = NSLocalizedString("Saturday", comment: "")
                        
                        var weekdayAry = [d_7, d_1, d_2, d_3, d_4, d_5, d_6]
                        // 取出的星期数：1表示星期天，2表示星期一，3表示星期二。。。。 6表示星期五，7表示星期六
                        let srcWeekday = srcDate.weekday
                        
                        // 取出当前是星期几
                        let weekdayDesc = weekdayAry[srcWeekday-1]
                        ret = weekdayDesc + timeExtraStr
                    }
                    else {
                        // 否则直接显示完整日期时间
                        var srcDateStr : String?
                        if Bundle.is_zh_Hans() {
                            srcDateStr = srcDate.string(withFormat: "M月d日")
                        } else {
                            srcDateStr = srcDate.string(withFormat: "d/M")
                        }
                        ret = (srcDateStr ?? "") + timeExtraStr
                    }
                }
            }
        }
        else {
            // 往年
            var srcDateStr : String?
            if Bundle.is_zh_Hans() {
                srcDateStr = srcDate.string(withFormat: "yyyy年M月d日")
            } else {
                srcDateStr = srcDate.string(withFormat: "d/M/yyyy")
            }
            ret = (srcDateStr ?? "") + timeExtraStr
        }
        
        return ret ?? "";
    }
}
