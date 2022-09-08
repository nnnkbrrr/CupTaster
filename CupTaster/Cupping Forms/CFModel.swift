//
//  CFModel.swift
//  CupTaster
//
//  Created by Никита on 08.09.2022.
//

import SwiftUI
import CoreData

extension CFManager {
    class CFModel {
        let title: String
        let version: String
        
        init(title: String, version: String) {
            self.title = title
            self.version = version
        }
        
        func createCuppingForm(context: NSManagedObjectContext) -> CuppingForm? {
            guard let url = Bundle.main.url(forResource: title, withExtension: "json") else { return nil }
            let data = try? Data(contentsOf: url)
            guard let form = try? JSONDecoder(context: context).decode(CuppingForm.self, from: data!) else { return nil }
            form.languageCode = Locale.current.languageCode ?? ""
            
            try? context.save()
            return form
        }
        
        func isAdded(storedCuppingForms: FetchedResults<CuppingForm>) -> Bool {
            for cuppingForm in storedCuppingForms {
                if cuppingForm.languageCode != Locale.current.languageCode { continue }
                if cuppingForm.title != self.title { continue }
                if cuppingForm.version != self.version { continue }
                return true
            }
            return false
        }
    }
}
