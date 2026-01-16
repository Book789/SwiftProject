//
//  SwiftUIStudy.swift
//  SwiftProject
//
//  Created by cloud on 2026/1/4.
//
import SwiftUI

struct BackgroundView : View {
   
    var body: some View {
     
        //此方案设置背景色 同时 HStack 在安全区内
        ZStack{
            Color.blue.ignoresSafeArea()
            HStack{
                
            }
        }
        
    }
}

struct ListView : View {
    
    
    //编辑框右上角按钮->Minimap 右侧出现代码引导小地图
    //下面的注视方便 快速查找代码位置跳转
   
    //MARK: PROPERTY

    //MARK: BODY
    
    //MARK: FUNCTION

    //MARK: PREVIEW


    var body: some View {
     
        ZStack{
            Color.blue.ignoresSafeArea()
            List{
                ForEach(0..<5){_ in
                    HStack{
                        Text("List")
                    }.listRowInsets(EdgeInsets())//cell 去除所有边距
                    .frame(maxWidth: .infinity,maxHeight: 44)//HStack maxWidth: .infinity  横向充满宽度

                }
            }
            .listStyle(.plain)
        }
        
    }
}

