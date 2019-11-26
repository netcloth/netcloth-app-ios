







import Foundation


class Time {
    
    
    static func timeDesc(from timeInterval: Double, includeH_M: Bool) -> String
    {
        var ret: String? = nil

        let currentDate = NSDate()
        let currentYear = currentDate.year
        let currentMonth = currentDate.month
        let currentDay =  currentDate.day
        

        let srcDate = NSDate(timeIntervalSince1970: timeInterval)
        
        let srcYear = srcDate.year
        let srcMonth = srcDate.month
        let srcDay = srcDate.day
        

        var timeExtraStr = ""
        if includeH_M {
            timeExtraStr = " \(srcDate.string(withFormat: "HH:mm")!)"
        }
        

        if (currentYear == srcYear) {
            let currentTimestamp = currentDate.timeIntervalSince1970
            let srcTimestamp = timeInterval
            

            let delta = currentTimestamp - srcTimestamp
            

            if (currentMonth == srcMonth && currentDay == srcDay) {

                if (delta < 60) {
                    ret = "Just now".localized()
                }
                else {

                    ret = srcDate.string(withFormat: "HH:mm")
                }
            }
            else {


                var yesterdayDate = NSDate()
                yesterdayDate = NSDate(timeInterval: -24*60*60, since: yesterdayDate as Date)
                
                
                let yesterdayMonth = yesterdayDate.month
                let yesterdayDay = yesterdayDate.day
                
                if (false) {//srcMonth == yesterdayMonth && srcDay == yesterdayDay
                    ret = NSLocalizedString("Yesterday", comment: "") + timeExtraStr
                }
                else {

                    let deltaHour = (delta/3600);

                    if (deltaHour <= 7*24){
                        let d_7 = NSLocalizedString("Sunday", comment: "")
                        let d_1 = NSLocalizedString("Monday", comment: "")
                        let d_2 = NSLocalizedString("Tuesday", comment: "")
                        let d_3 = NSLocalizedString("Wednesday", comment: "")
                        let d_4 = NSLocalizedString("Thursday", comment: "")
                        let d_5 = NSLocalizedString("Friday", comment: "")
                        let d_6 = NSLocalizedString("Saturday", comment: "")
                        
                        var weekdayAry = [d_7, d_1, d_2, d_3, d_4, d_5, d_6]

                        let srcWeekday = srcDate.weekday
                        

                        let weekdayDesc = weekdayAry[srcWeekday-1]
                        ret = weekdayDesc + timeExtraStr
                    }
                    else {

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
