//
//  KPCustomSignatureView.swift
//  KP
//
//  Created by Shawley on 18/03/2018.
//  Copyright © 2018 adoma. All rights reserved.
//

import UIKit

@objc protocol KPCustomSignatureViewDelegate {
    func textChanged(text: String?)
}

class KPCustomSignatureView: UIView {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var textView: UITextView!
    
    
    @IBOutlet weak var count: UILabel!
    
    static let maxLength = 20

    weak var delegate: KPCustomSignatureViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textView.delegate = self
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = true
        addGestureRecognizer(tapGesture)
    }
    
    @objc func hideKeyboard() {
        endEditing(true)
    }
}

extension KPCustomSignatureView: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if text == "\n" {
            textView.resignFirstResponder()
            return false;
        }
        
        let currentString: NSString = textView.text! as NSString
        let newString: NSString = currentString.replacingCharacters(in: range, with: text) as NSString
        return newString.length <= KPCustomSignatureView.maxLength
    }
    
    func textViewDidChange(_ textView: UITextView) {
        count.text = "\(textView.text.count)/\(KPCustomSignatureView.maxLength)"
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        delegate?.textChanged(text: textView.text)
    }
    
}
