//
//  KPDefine.swift
//  KP
//
//  Created by Adoma's MacbookPro on 2017/5/23.
//  Copyright © 2017年 adoma. All rights reserved.
//

import UIKit

//eg:
func RGBCOLOR(r: Float, g: Float, b: Float, alpha: Float = 1) -> UIColor {
    return UIColor.init(red: CGFloat(r/255.0), green: CGFloat(g/255.0), blue: CGFloat(b/255.0), alpha: CGFloat(alpha))
}

let Main_Screen_Width = UIScreen.main.bounds.size.width

let Main_Screen_Height = UIScreen.main.bounds.size.height

let Main_Theme_Color = RGBCOLOR(r: 255, g: 87, b: 34)

let Main_Theme_Color_Dark = RGBCOLOR(r: 20, g: 20, b: 20)

let Content_Color = RGBCOLOR(r: 248, g: 248, b: 246)

let Line_Color = RGBCOLOR(r: 243, g: 243, b: 243)

let Separator_Color = RGBCOLOR(r: 217, g: 217, b: 217)

let Border_Color = RGBCOLOR(r: 207, g: 207, b: 207)

let Main_Text_Color = RGBCOLOR(r: 51, g: 51, b: 51)

let Detail_Text_Color = RGBCOLOR(r: 102, g: 102, b: 102)

let Sub_Text_Color = RGBCOLOR(r: 153, g: 153, b: 153)

let Red_Text_Color = RGBCOLOR(r: 255, g: 0, b: 51)

let Green_Text_Color = RGBCOLOR(r: 40, g: 144, b: 162)

let Blue_Color = RGBCOLOR(r: 2, g: 121, b: 255)

let Search_Color = RGBCOLOR(r: 184, g: 148, b: 119)

//广告id
let AD_App_Id = "1106385728"
let AD_Banner_Id = "6050028504429040"
let AD_Lanuch_Id = "9010826514528012"

//推送
#if DEBUG //dev
let kGtAppId = "aDDHov9fon7YVSUdNShV12"
let kGtAppKey = "WPLoXgk8va5qyDXlliHhS3"
let kGtAppSecret = "cEpML4UnsM6sztancrKOF2"
#else //dis
let kGtAppId = "mgsdeVI5DE9pbtJ2jQAFv8"
let kGtAppKey = "ruYzt7KujSA7tH2o4PsSLA"
let kGtAppSecret = "p1I1QoQW0N7VCca598GYz9"
#endif

//bugly
let kBuglyAppId = "04b8c1cd69"


//MARK: default
let Book_Default_Image = UIImage.init(named: "book_default")

//MARK: keys
let APP_THEME_DARK_KEY = "APP_THEME_DARK"
let APP_USER_LOGIN_KEY = "APP_USER_LOGIN"
let APP_USER_AUTH_KEY = "APP_USER_AUTH"

let APP_USER_SEARCHTEXT_KEY = "APP_USER_SEARCHTEXT"

//MARK: layout
func kp_layout(_ arg: CGFloat) -> CGFloat{
    return arg * Main_Screen_Width / 375
}

func ad_layout(_ arg: CGFloat) -> CGFloat{
    return arg * Main_Screen_Width / 320
}

let kNavH :CGFloat = 64
let kIphoneXNavH :CGFloat = 88

let kStatusBarH = UIApplication.shared.statusBarFrame.size.height

let kTabH :CGFloat = 49
let kIphoneXTabH :CGFloat = 83

var kLayoutNavH = isIphoneX ? kIphoneXNavH : kNavH

var kLayoutTabH = isIphoneX ? kIphoneXTabH : kTabH

var kLayoutBottom :CGFloat = isIphoneX ? 49 : 5

let isIphoneX = (Main_Screen_Width == 375 && Main_Screen_Height == 812)

let isIphone4 = (Main_Screen_Height == 480)
let isIphone5_5C_5S_SE = (Main_Screen_Height == 568)
let isIphone678_6S7S8S = (Main_Screen_Height == 667)
let isIphonePlus = (Main_Screen_Height == 736)
