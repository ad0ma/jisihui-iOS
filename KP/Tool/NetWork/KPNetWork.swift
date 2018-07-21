//
//  KPNetWork.swift
//  KP
//
//  Created by Adoma's MacbookPro on 2017/6/5.
//  Copyright © 2017年 adoma. All rights reserved.
//

import Foundation
@_exported import Alamofire
@_exported import SwiftyJSON

typealias CALLBACK = (Any?, Bool) -> Void

protocol KPNetWorkProtocol: class {
    func getData (callback: @escaping CALLBACK) -> Void
    func updateData () -> Void
    func loadMoreData () -> Void
}

class KPNetWork {
    
    enum MethodType: String {
        case get = "GET"
        case post = "POST"
        case delete = "DELETE"
    }
    
    enum RequestType {
        case form
        case json
    }
    
    #if DEBUG
    static let base = "http://139.224.12.154:8080/"
    #else
    static let base = "https://www.jisihui.com/"
    #endif
    
    static let timeoutInterval: TimeInterval = 30
     
    typealias HTTPHeader = [String: String]

    static let formatter: DateFormatter = {
        let formatter = DateFormatter.init()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
    
    static func timeString(timeInterval: TimeInterval) -> String {
        let date = Date.init(timeIntervalSinceReferenceDate: timeInterval)
        return formatter.string(from: date)
    }
    
    @discardableResult
    static func request(base: String = base, path: String, method: MethodType = .post, requestType: RequestType = .form, para: [String: Any]? = nil, closure: @escaping (DataResponse<Data>) -> Void) -> DataRequest {
        
        var encoding: ParameterEncoding = URLEncoding.default
        
        if requestType == .json {
            encoding = JSONEncoding.default
        }
        
        let url = base + path
        
        let HEADER = NSMutableDictionary()
        
        if KPUser.share.isLogin {
            let AUTH = KPUser.share.auth
            HEADER.setValue(AUTH, forKey: "auth")
        }
        
        let alaHeader = HEADER as? HTTPHeaders
        
        Alamofire.SessionManager.default.session.configuration.timeoutIntervalForRequest = timeoutInterval
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        return Alamofire.request(url, method: HTTPMethod.init(rawValue: method.rawValue)!, parameters: para, encoding: encoding, headers: alaHeader).responseData(completionHandler: { (response) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
            #if DEBUG
                var log = KPLog()
                log.requestType = method.rawValue
                log.requestUrl = response.request?.url?.absoluteString ?? "Unknow"
                log.requestHeader = response.request?.allHTTPHeaderFields
                log.parament = para
                
                if let data = response.data {
                    log.result = String.init(data: data, encoding: .utf8) ?? "响应错误"
                }
                
                log.requestTime = self.timeString(timeInterval: TimeInterval(response.timeline.requestStartTime))
                log.requestDuration = String.init(format: "%.2f秒", response.timeline.totalDuration)
                
                KPLogManager.logs.insert(log, at: 0)
            #endif
            
            closure(response)
        })
    }
    
    static func upload(path: String, data: Data, para: [String : String]? = nil, method: MethodType = .post, closure: @escaping (DataResponse<Data>) -> Void)  {
        
        let url = base + path
        
        let HEADER = NSMutableDictionary()
        
        if KPUser.share.isLogin {
            let AUTH = KPUser.share.auth
            HEADER.setValue(AUTH, forKey: "auth")
        }
        
        let alaHeader = HEADER as? HTTPHeaders
        
        Alamofire.SessionManager.default.session.configuration.timeoutIntervalForRequest = timeoutInterval
        
        Alamofire.upload(multipartFormData: { (formData) in
            formData.append(data, withName: "file", fileName: "file.jpeg", mimeType:"image/jpeg")
            if let para = para {
                for (key,value) in para {
                    formData.append(value.data(using: String.Encoding.utf8)!, withName: key)
                }
            }
        }, to: url, headers: alaHeader) { (encodingResult) in
            
            switch encodingResult {
            case .success(let upload, _, _):
                upload.responseData(completionHandler: { (response) in
                    #if DEBUG
                    var log = KPLog()
                    log.requestType = method.rawValue
                    log.requestUrl = upload.request?.url?.absoluteString ?? "Unknow"
                    log.requestHeader = upload.request?.allHTTPHeaderFields
                    log.parament = para
                    
                    if let data = response.data {
                        log.result = String.init(data: data, encoding: .utf8) ?? "响应错误"
                    }
                    
                    log.requestTime = self.timeString(timeInterval: TimeInterval(response.timeline.requestStartTime))
                    log.requestDuration = String.init(format: "%.2f秒", response.timeline.totalDuration)
                    
                    KPLogManager.logs.insert(log, at: 0)
                    #endif
                    closure(response)
                })
            case .failure(_):
                print("上传失败")
            }
        }
    }
}

extension KPNetWork {
    
    enum KPNetWorkRequestType: String {
        case GetBookShelfData = "m/auth/collect"
        case GetUserHeaderIcon = "m/auth/getImage"
        case UpdateUserInfo = "m/auth/updateUserInfo"
        case UploadUserHeaderIcon = "m/auth/uploadImage"
    }
    
    enum IconType: String {
        case Header = "PROFILE"
        case Background = "BACKGROUND"
    }
    
    class func getBookShelfData(bookShelfType: String, page: Int, pageSize: Int = 20, searchKey: String? = nil, closure: @escaping (DataResponse<Data>) -> Void) -> DataRequest {
        
        var path = KPNetWorkRequestType.GetBookShelfData.rawValue + "?bookshelfType=\(bookShelfType)&page=\(page)&pageSize=\(pageSize)"
        if let searchKey = searchKey, let sKey = searchKey.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            path += "&sKey=\(sKey)"
        }
        return self.request(path: path, method: .get, closure:closure)
    }
    
    @discardableResult
    class func getUserIcon(type: IconType, closure: @escaping (DataResponse<Data>) -> Void) -> DataRequest {
        let path = KPNetWorkRequestType.GetUserHeaderIcon.rawValue
        return self.request(path: path, method: .get, para: ["imageType" : type.rawValue], closure:closure)
    }
    
    @discardableResult
    class func updateUserInfo(nickName: String? = nil, gender: String? = nil, city: String? = nil, birthDay: String? = nil, introduce: String? = nil, closure: @escaping (DataResponse<Data>) -> Void) -> DataRequest {
        
        let path = KPNetWorkRequestType.UpdateUserInfo.rawValue
        var para = [String : Any]()
        if let nickname = nickName {
            para["nickName"] = nickname
        }
        if let gender = gender {
            para["gender"] = gender
        }
        if let city = city {
            para["city"] = city
        }
        
        if let birthday = birthDay {
            para["birthday"] = birthday
        }
        
        if let introduce = introduce {
            para["introduce"] = introduce
        }
        return self.request(path: path, method: .post, requestType: .json, para: para, closure: closure)
    }
    
    class func uploadUserIcon(data: Data, type: IconType, closure: @escaping (DataResponse<Data>) -> Void) {
        let path = KPNetWorkRequestType.UploadUserHeaderIcon.rawValue
        return self.upload(path: path, data: data, para: ["imageType" : type.rawValue], closure: closure)
    }
}
