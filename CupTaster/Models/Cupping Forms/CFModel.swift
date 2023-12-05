//
//  CFModel.swift
//  CupTaster
//
//  Created by Никита on 08.09.2022.
//

import SwiftUI
import CoreData

extension CFManager {
    class CFModel: Identifiable {
        let title: String
        let version: String
        
        init(title: String, version: String) {
            self.title = title
            self.version = version
        }
        
        func createCuppingForm(context: NSManagedObjectContext) -> CuppingForm? {
            guard let url: URL = Bundle.main.url(forResource: title, withExtension: "json") else { return nil }
            
            do {
                let data: Data = try Data(contentsOf: url)
                let form: CuppingForm = try JSONDecoder(context: context).decode(CuppingForm.self, from: data)
                try context.save()
                return form
            } catch {
                fatalError("\(error)")
            }
        }
        
        func getCuppingForm(storedCuppingForms: FetchedResults<CuppingForm>) -> CuppingForm? {
            for cuppingForm in storedCuppingForms {
                if cuppingForm.title != self.title { continue }
                if cuppingForm.version != self.version { continue }
                return cuppingForm
            }
            return nil
        }
    }
}
