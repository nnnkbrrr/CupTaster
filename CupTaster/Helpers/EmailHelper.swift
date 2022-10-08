//
//  EmailHelper.swift
//  CupTaster
//
//  Created by Никита Баранов on 06.10.2022.
//

import Foundation
import MessageUI

class EmailHelper: NSObject {
    // singleton
    static let shared = EmailHelper()
    private override init() {}
}

extension EmailHelper {
    func send(subject: String = "", body: String = "", to: String) {
        guard let viewController = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController else { return }
        
        if !MFMailComposeViewController.canSendMail() {
            let mails = to
            let alert = UIAlertController(title: "Cannot open Mail!", message: "", preferredStyle: .actionSheet)
            
            if let defaultUrl = URL(string: "mailto:\(mails)"),
               UIApplication.shared.canOpenURL(defaultUrl) {
                alert.addAction(UIAlertAction(title: "Mail", style: .default, handler: { (action) in
                    UIApplication.shared.open(defaultUrl)
                }))
            }
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            viewController.present(alert, animated: true, completion: nil)
        }
        
        let mailCompose = MFMailComposeViewController()
        mailCompose.setSubject(subject)
        mailCompose.setMessageBody(body, isHTML: false)
        mailCompose.setToRecipients([to])
        mailCompose.mailComposeDelegate = self
        
        viewController.present(mailCompose, animated: true, completion: nil)
    }
}

// MARK: - MFMailComposeViewControllerDelegate
extension EmailHelper: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
