//
//  NetworkService.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-05-28.
//

import Foundation
import Alamofire

class Headers {
    static func defaultHeader() -> HTTPHeaders {
        return HTTPHeaders(["Content-Type": "application/json"])
    }
    
    static func urlEncodingHeader() -> HTTPHeaders{
        return HTTPHeaders(["Content-Type": "application/x-www-form-urlencoded"])
    }
}

final class RequestInterceptor: Alamofire.RequestInterceptor {
    var accessToken: String?
    
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        guard let accessToken = accessToken, let urlString = urlRequest.url?.absoluteString, APIRequestURLs.needAuthToken(url: urlString) else {
            // If the request does not require authentication, we can directly return it as unmodified.
            return completion(.success(urlRequest))
        }
        var urlRequest = urlRequest

        // Set the Authorization header value using the access token.
        urlRequest.setValue("Bearer " + accessToken, forHTTPHeaderField: "Authorization")
        completion(.success(urlRequest))
    }
}

enum UploadType {
    case image
    case video
    
    func filename() -> String {
        switch self {
        case .image:
            return "image.jpg"
        case .video:
            return "video.mp4"
        }
    }
    
    func mimeType() -> String {
        switch self {
        case .image:
            return "image/jpeg"
        case .video:
            return "video.mp4"
        }
    }
}
class NetworkService {
    private let logging = true
    private let sessionManager: Session
    private let interceptor = RequestInterceptor()
    
    var accessToken: String? {
        didSet {
            interceptor.accessToken = accessToken
        }
    }
    
    init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 60
        sessionManager = Session(interceptor: interceptor)
    }
    
    func uploadData<T>(url: String,
                    method: HTTPMethod = .post,
                    parameters: [String] = [],
                    headers: HTTPHeaders?,
                    data: Data? = nil,
                    fileURL: URL? = nil,
                    uploadType: UploadType = .image,
                    progressUpdate: ((Double) -> Void)? = nil,
                    callBack: @escaping (AFResult<T>) -> Void) where T : Decodable {
        var url = url
        for parameter in parameters {
            url = "\(url)/\(parameter)"
        }
        var dataToUpload: Data?
        if let fileUrl = fileURL {
            dataToUpload = try? Data(contentsOf: fileUrl)
        } else {
            if let unwrappedData = data { dataToUpload = unwrappedData }
        }
        
        if let uploadData = dataToUpload {
            sessionManager.upload(multipartFormData: { multipart in
                multipart.append(uploadData, withName: "file", fileName: uploadType.filename(), mimeType: uploadType.mimeType())
            }, to: url).responseJSON { result in
                if let encodingError = result.error {
                    self.print(encodingError.localizedDescription)
                    DispatchQueue.main.async {
                        callBack(.failure(encodingError))
                    }
                } else {
                    DispatchQueue.main.async {
                        self.processResponse(result: result, callBack: callBack)
                    }
                }
            }.uploadProgress { progress in
                self.print("Upload Progress: \(progress.fractionCompleted)")
                progressUpdate?(progress.fractionCompleted)
            }
        }
    }
    
    func uploadVideo<T>(url: String,
                    method: HTTPMethod = .post,
                    headers: HTTPHeaders?,
                    thumbnailData: Data,
                    fileURL: URL,
                    progressUpdate: ((Double) -> Void)? = nil,
                    callBack: @escaping (AFResult<T>) -> Void) where T : Decodable {
        let url = url
        let dataToUpload: Data? = try? Data(contentsOf: fileURL)
        
        if let videoData = dataToUpload {
            sessionManager.upload(multipartFormData: { multipart in
                multipart.append(videoData, withName: "file", fileName: UploadType.video.filename(), mimeType: UploadType.video.mimeType())
                multipart.append(thumbnailData, withName: "fileImage", fileName: UploadType.image.filename(), mimeType: UploadType.image.mimeType())
            }, to: url).responseJSON { result in
                if let encodingError = result.error {
                    self.print(encodingError.localizedDescription)
                    DispatchQueue.main.async {
                        callBack(.failure(encodingError))
                    }
                } else {
                    DispatchQueue.main.async {
                        self.processResponse(result: result, callBack: callBack)
                    }
                }
            }.uploadProgress { progress in
                self.print("Upload Progress: \(progress.fractionCompleted)")
                progressUpdate?(progress.fractionCompleted)
            }
        }
    }
    
    func httpRequestSimple(url: String,
                           method: HTTPMethod,
                           parameters: [String: Any]?,
                           headers: HTTPHeaders?,
                           callBack: @escaping (AFResult<Void>) -> Void) {
        
        var params: [String: Any]?
        let requestURL: String
        if let parameters = parameters, !parameters.isEmpty, method == .get {
            do {
                let originalRequest = try URLRequest(url: url, method: method, headers: headers)
                let encodedURLRequest = try URLEncoding.default.encode(originalRequest, with: parameters)
                requestURL = encodedURLRequest.url?.absoluteString ?? url
            } catch {
                params = parameters
                requestURL = url
            }
        } else {
            params = parameters
            requestURL = url
        }
        let processedRequest = sessionManager.request(requestURL,
                                                      method: method,
                                                      parameters: params,
                                                      encoding: JSONEncoding.default,
                                                      headers: headers)
        processedRequest.validate().response { result in
            if let err = result.error {
                callBack(.failure(err))
            } else {
                callBack(.success(()))
            }
        }
    }
    
    func httpRequest<T>(url: String,
                        method: HTTPMethod,
                        parameters: [String: Any]? = nil,
                        headers: HTTPHeaders?,
                        callBack: @escaping (AFResult<T>) -> Void) where T : Decodable {
        
        var params: [String: Any]?
        let requestURL: String
        if let parameters = parameters, !parameters.isEmpty, method == .get {
            do {
                let originalRequest = try URLRequest(url: url, method: method, headers: headers)
                let encodedURLRequest = try URLEncoding.default.encode(originalRequest, with: parameters)
                requestURL = encodedURLRequest.url?.absoluteString ?? url
            } catch {
                params = parameters
                requestURL = url
            }
        } else {
            params = parameters
            requestURL = url
        }
        let processedRequest = sessionManager.request(requestURL,
                                                      method: method,
                                                      parameters: params,
                                                      encoding: JSONEncoding.default,
                                                      headers: headers)
        processedRequest.validate().responseJSON { [weak self] result in
            if let err = result.error {
                callBack(.failure(err))
            } else {
                self?.processResponse(result: result, callBack: callBack)
            }
        }
    }
    
    func httpRequest<T, Y>(url: String,
                           method: HTTPMethod,
                           json: Y,
                           headers: HTTPHeaders?,
                           callBack: @escaping (AFResult<T>) -> Void) where T : Decodable, Y : Encodable {
        guard let object = try? JSONEncoder().encode(json) else {
            let err: Error = NSError(domain: "Invalid JSON input", code: 0, userInfo: nil) as Error
            callBack(.failure(err.asAFError!))
            return
        }
        guard let jsonObject = try? JSONSerialization.jsonObject(with: object, options: .mutableLeaves) else {
            let err: Error = NSError(domain: "Invalid JSON input", code: 0, userInfo: nil) as Error
            callBack(.failure(err.asAFError!))
            return
        }
        
        guard let parameters = jsonObject as? [String: Any] else {
            let err: Error = NSError(domain: "Invalid JSON input", code: 0, userInfo: nil) as Error
            callBack(.failure(err.asAFError!))
            return
        }
        
        let processedRequest = sessionManager.request(url,
                                                      method: method,
                                                      parameters: parameters,
                                                      encoding: JSONEncoding.default,
                                                      headers: headers)
        processedRequest.validate().responseJSON { [weak self] result in
            if let err = result.error {
                callBack(.failure(err))
            } else {
                self?.processResponse(result: result, callBack: callBack)
            }
        }
    }
    
    private func processResponse<T: Decodable>(result: AFDataResponse<Any>, callBack: (AFResult<T>) -> Void) {
        switch result.result {
            
        case .success(_ ):
            guard var data = result.data else {
                callBack(.failure(result.error!))
                return
            }
            
            var responseString = String(data: data, encoding: .utf8) ?? ""
            print(responseString)
            if let statusCode = result.response?.statusCode,
                statusCode >= 200, statusCode < 300, responseString.isEmpty {
                
                responseString = "{}"
                data = responseString.data(using: .utf8)!
            }
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Full)
            if let object = try? decoder.decode(T.self, from: data) {
                callBack(.success(object))
            } else {
                callBack(.failure(result.error ?? AFError.parameterEncodingFailed(reason: .jsonEncodingFailed(error: NSError(domain: "decode error", code: 0, userInfo: nil) as Error))))
                return
            }
            
        case .failure(let error):
            guard var data = result.data else {
                callBack(.failure(error))
                return
            }
            var responseString = String(data: data, encoding: .utf8) ?? ""
            print(responseString)
            
            if let statusCode = result.response?.statusCode ,
                statusCode >= 200, statusCode < 300, responseString.isEmpty {
                
                responseString = "{}"
                data = responseString.data(using: .utf8)!
            }
            
            if let object = try? JSONDecoder().decode(T.self, from: data) {
                callBack(.success(object))
            } else {
                callBack(.failure(error))
                return
            }
        }
    }
    
    private func print(_ string: String) {
        logging ? Swift.print(string) : nil
    }
}
