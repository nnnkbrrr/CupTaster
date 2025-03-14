//
//  Cupping Settings Modal.swift
//  CupTaster
//
//  Created by Nikita on 05.02.2024.
//

import SwiftUI
import MapKit
import CoreLocation

extension CuppingView {
    struct CuppingSettingsView: View {
        @Environment(\.dismiss) var dismiss
        @Environment(\.managedObjectContext) private var moc
        @FetchRequest(
            entity: Folder.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Folder.ordinalNumber, ascending: true)]
        ) var folders: FetchedResults<Folder>
        
        @ObservedObject var cupping: Cupping
        @Binding var isActive: Bool
        let onDelete: () -> ()
        
        @State var foldersModalIsActive: Bool = false
        @State var mapIsExpanded: Bool = false
        
        private let nameLengthLimit = 50
        
        var body: some View {
            if cupping.isFault {
                EmptyView()
            } else {
                VStack(spacing: .extraSmall) {
                    if TestingManager.shared.cuppingDatePickerIsVisible {
                        DatePicker("", selection: $cupping.date, displayedComponents: [.date])
                    }
                    
                    TextField("Cupping Name", text: $cupping.name)
                        .resizableText(weight: .light)
                        .submitLabel(.done)
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                        .padding(.vertical, .regular)
                        .onChange(of: cupping.name) { name in
                            if cupping.name.count > nameLengthLimit {
                                cupping.name = String(cupping.name.prefix(nameLengthLimit))
                            }
                            save(moc)
                        }
                        .bottomSheetBlock()
                    
                    Text("\(cupping.form?.title ?? "") • \(cupping.samples.count) Samples • \(cupping.cupsCount) Cups")
                        .font(.caption)
                        .foregroundStyle(.gray)
                        .padding(.vertical, .extraSmall)
                    
                    HStack(spacing: .extraSmall) {
                        Button {
                            foldersModalIsActive = true
                        } label: {
                            HStack(spacing: .extraSmall) {
                                Image(systemName: "folder")
                                Text("Folders")
                            }
                        }
                        .buttonStyle(.bottomSheetBlock)
                        .modalView(
                            isPresented: $foldersModalIsActive,
                            toolbar: .init(
                                title: "Folders",
                                trailingToolbarItem: .init("Done") {
                                    foldersModalIsActive = false
                                }
                            )
                        ) {
                            ScrollView {
                                LazyVStack(spacing: .extraSmall) {
                                    ForEach([FolderFilter.favorites] + folders.map { FolderFilter(folder: $0) }) { folderFilter in
                                        let folderContainsCupping: Bool = folderFilter.containsCupping(cupping)
                                        
                                        SettingsButtonSection(title: folderFilter.name ?? folderFilter.folder?.name ?? "New Folder") {
                                            if folderContainsCupping { folderFilter.removeCupping(cupping, context: moc) }
                                            else { folderFilter.addCupping(cupping, context: moc) }
                                        } leadingContent: {
                                            Image(systemName: "checkmark")
                                                .foregroundStyle(Color.accentColor)
                                                .opacity(folderContainsCupping ? 1 : 0)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, .small)
                        }
                        
                        Button {
                            cupping.shareCSV()
                        } label: {
                            HStack(spacing: .extraSmall) {
                                Image(systemName: "square.and.arrow.up")
                                Text("Share")
                            }
                        }
                        .buttonStyle(.bottomSheetBlock)
                    }
                    
                    HStack(spacing: .regular) {
                        let address: String = cupping.location?.address ?? "No location"
                        
                        ZStack {
                            if let location = cupping.location {
                                Map (
                                    coordinateRegion: .constant(
                                        MKCoordinateRegion(
                                            center: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude),
                                            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                                        )
                                    ),
                                    annotationItems: [location],
                                    annotationContent: { MapMarker(coordinate: .init(latitude: $0.latitude, longitude: $0.longitude)) }
                                )
                                .frame(width: .smallElement * 2, height: .smallElement * 2)
                                .scaleEffect(0.5)
                                .fullScreenCover(isPresented: $mapIsExpanded) {
                                    MapModalView(location: location) { newLocation, coordinates, address in
                                        if let newLocation {
                                            cupping.location = newLocation
                                        } else {
                                            (location.latitude, location.longitude) = (coordinates.latitude, coordinates.longitude)
                                            location.address = address
                                        }
                                        save(moc)
                                    }
                                    .edgesIgnoringSafeArea(.all)
                                }
                            } else {
                                Image(systemName: "mappin.slash")
                            }
                        }
                        .frame(width: .smallElement, height: .smallElement)
                        .cornerRadius(.small)
                        .overlay {
                            RoundedRectangle(cornerRadius: .small)
                                .stroke(Color.separatorPrimary, lineWidth: 2)
                        }
                        .allowsHitTesting(false)
                        
                        VStack(alignment: .leading) {
                            Text(address)
                                .lineLimit(1)
                            
                            Text(cupping.date, style: .date)
                                .foregroundStyle(.gray)
                                .font(.caption)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.small)
                    .bottomSheetBlock()
                    .contentShape(Rectangle())
                    .onTapGesture { if cupping.location != nil { mapIsExpanded = true } }
                    
                    HStack(spacing: .extraSmall) {
                        Menu {
                            Button("Delete", role: .destructive) {
                                dismiss()
                                onDelete()
                            }
                        } label: {
                            Text("Delete")
                                .foregroundStyle(.red)
                        }
                        .buttonStyle(.bottomSheetBlock)
                        
                        Button("Done") {
                            isActive = false
                        }
                        .buttonStyle(.accentBottomSheetBlock)
                    }
                }
                .padding([.horizontal, .bottom], .small)
            }
        }
    }
}
