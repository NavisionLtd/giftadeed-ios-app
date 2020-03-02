//
//  PostServiceFireBase.swift
//  fireBaseUploadImage
//
//  Created by Ascra on 28/10/17.
//  Copyright © 2017 Ascracom.ascratech. All rights reserved.
//

import Foundation
import UIKit
import FirebaseStorage


struct PostServiceFireBase {
    static func create(for image: UIImage,path: String, completion: @escaping (String?) -> ()) {
        let filePath = path
		
        let imageRef = FIRStorage.storage().reference().child(filePath)
		StorageServiceFireBase.uploadImage(image, at: imageRef) { (downloadURL) in
			guard let downloadURL = downloadURL else {
				print("Download url not found or error to upload")
				return completion(nil)
			}
			
			completion(downloadURL.absoluteString)
		}
	}
	
}


