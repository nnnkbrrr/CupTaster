//
//  Cupping Form Info.swift
//  CupTaster
//
//  Created by Никита Баранов on 13.10.2022.
//

import SwiftUI

extension CFManager {
    struct CuppingFormInfoView: View {
        @Environment(\.managedObjectContext) private var moc
        @FetchRequest(entity: CuppingForm.entity(), sortDescriptors: []) var cuppingForms: FetchedResults<CuppingForm>
        @FetchRequest(
            entity: Cupping.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Cupping.date, ascending: false)]
        ) var cuppings: FetchedResults<Cupping>
        
        @State var cuppingForm: CuppingForm?
        let cfModel: CFModel
        
        init(cfModel: CFModel) {
            self.cfModel = cfModel
            self.cuppingForm = nil
        }

        init(cuppingForm: CuppingForm) {
            self.cfModel = shared.allCFModels.first(where: {
                $0.title == cuppingForm.title
            }) ?? CFModel(title: "", version: "", info: "")
            self.cuppingForm = cuppingForm
        }
        
        var body: some View {
            NavigationView {
                ScrollView {
                    VStack(alignment: .leading, spacing: 30) {
                        Text(cfModel.info)
                        Text("version " + cfModel.version)
                            .foregroundColor(.gray)
                        
                        if let cuppingForm {
                            ForEach(cuppings.filter({ $0.form == cuppingForm })) { cupping in
                                VStack(spacing: 5) {
                                    Text(cupping.name)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    HStack {
                                        HStack {
                                            Text("\(cupping.form?.title ?? "-")")
                                            Divider()
                                                .frame(height: 15)
                                            Text("\(cupping.samples.count) samples x \(cupping.cupsCount) cups")
                                            let favoritesCount: Int = cupping.samples.filter{ $0.isFavorite }.count
                                            if favoritesCount > 0 {
                                                Divider()
                                                    .frame(height: 15)
                                                Text("\(favoritesCount)")
                                                Image(systemName: "heart.fill")
                                            }
                                        }
                                        
                                        Spacer()
                                        
                                        Text(cupping.date, style: .date)
                                    }
                                    .foregroundColor(.gray)
                                    .font(.caption)
                                }
                                
                                Divider()
                            }
                            .background(Color(uiColor: .systemGray5))
                            .cornerRadius(10)
                            
                            Button {
                                moc.delete(cuppingForm)
                                try? moc.save()
                            } label: {
                                Text("Delete")
                                    .foregroundColor(.red)
                                    .padding()
                                    .contentShape(Rectangle())
                            }
                        }
                    }
                    .navigationTitle(cfModel.title)
                    .padding(20)
                }
                .safeAreaInset(edge: .bottom) {
                    Button {
                        if let cuppingForm, shared.defaultCFDescription != cuppingForm.shortDescription {
                            shared.setDefaultCuppingForm(cuppingForm: cuppingForm)
                        } else if cuppingForm == nil {
                            if let addedForm = cfModel.createCuppingForm(context: moc) {
                                withAnimation {
                                    shared.setDefaultCuppingForm(cuppingForm: addedForm)
                                }
                                cuppingForm = addedForm
                            }
                        }
                    } label: {
                        Group {
                            if cuppingForm == nil {
                                HStack {
                                    Image(systemName: "plus")
                                    Text("Add")
                                }
                            } else if shared.defaultCFDescription == cuppingForm?.shortDescription {
                                HStack {
                                    Image(systemName: "checkmark")
                                    Text("Default form")
                                }
                            } else {
                                Text("Use as default form")
                            }
                        }
                        .padding(.vertical)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.white)
                        .background(Color.accentColor)
                        .cornerRadius(10)
                    }
                    .padding(20)
                    .disabled(shared.defaultCFDescription == cuppingForm?.shortDescription)
                }
            }
        }
    }
}
