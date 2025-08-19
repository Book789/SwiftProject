//
//  String_value.swift
//  Start
//
//  Created by cloud on 2025/8/5.
//

extension String {
    

    /**
     *  小数点后最多保持2位  如果小数点后的  0  不显示 0
     *   1.00 显示 1        1.20 显示 1.2    1.234 显示  1.23
     */
    static func formatNumber(_ number: Double,fractionDigits:Int = 2) -> String {

        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0              // 最少小数位数
        formatter.maximumFractionDigits = fractionDigits // 最多小数位数（Swift Double的最大精度）
        formatter.decimalSeparator = "."                 // 确保使用点作为小数点
        formatter.usesGroupingSeparator = false // 禁用千分位分隔符

        // 移除末尾的零和小数点（如果有）
        if number.truncatingRemainder(dividingBy: 1) == 0 {
            formatter.maximumFractionDigits = 0
        }
        
        return formatter.string(from: NSNumber(value: number)) ?? ""

    }

}
