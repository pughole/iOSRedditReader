//
//  CommentsViewModel.swift
//  RedditReader
//
//  Created by Ivan Christian on 17/04/22.
//

import Foundation

class CommentsViewModel : ObservableObject {
    let post : Post;
    @Published var comments : [CommentAPIResponseListing] = []
    @Published var loadingState : loadingStateEnum = .LOADING
    
    enum loadingStateEnum{
        case IDLE
        case LOADING
        case ERROR
    }
    
    init(_ post:Post){
        self.post = post
        fetchComments()
    }
    
    func fetchComments () {
        loadingState = .LOADING
        callFetchCommentAPI() { result, error in
            if let error = error {
                print(error.localizedDescription)
                self.loadingState = .ERROR
            }
            if let result = result {
                
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                do{
                    let decoded = try decoder.decode(CommentAPIResponseMostOuter.self, from:result)
                    
                    DispatchQueue.main.async {
                        self.comments.append(decoded.data.children[0])
                        
//                        self.after = decoded.after
                        self.loadingState = .IDLE
                    }
                    
                }catch{
                    print("Error decoding post \(error)")
                }
                 
            }
            
        }
    }
    
    private func callFetchCommentAPI (completion: @escaping (_ data: Data?, _ error: Error?) -> Void) {
        let url = "https://www.reddit.com\(post.permalink)/.json"
        
//        if(after != nil){
//            url+="after="+after!
//        }
        let task = URLSession.shared.dataTask(with: URL(string: url)!, completionHandler: { data, response, error in
            if let error = error {
                completion(nil, error)
            }
            
            if let data = data {
                completion(data, nil)
            } else {
                completion(nil, nil)
            }
        })
        task.resume()
    }
}
