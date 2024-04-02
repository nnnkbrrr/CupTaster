//
//  Cupping Sample Preview.swift
//  CupTaster
//
//  Created by Никита Баранов on 23.07.2023.
//

import SwiftUI

struct SamplePreview: View {
    @Environment(\.managedObjectContext) private var moc
    @FetchRequest(
        entity: Folder.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Folder.ordinalNumber, ascending: true)]
    ) var folders: FetchedResults<Folder>
    @ObservedObject var samplesControllerModel: SamplesControllerModel = .shared
    @State var foldersModalIsActive: Bool = false
    
    let sample: Sample
    let showCupping: Bool
    let animationId: UUID?
    
    init(_ sample: Sample, showCupping: Bool = false, animationId: UUID? = nil) {
        self.sample = sample
        self.showCupping = showCupping
        self.animationId = animationId
    }
    
    var body: some View {
        if sample.isFault {
            EmptyView()
        } else {
            var matchedGeometryId: String {
                var matchedGeometryAnimationDescription: String {
                    if let animationId { return animationId.uuidString }
                    else { return "no-animation-id" }
                }
                return "\(matchedGeometryAnimationDescription).radar.chart.\(sample.id)"
            }
            
            if samplesControllerModel.selectedSample != sample {
                VStack(alignment: .leading) {
                    RoseChart(sample: sample)
                        .frame(maxWidth: .infinity)
                        .matchedGeometryEffect(
                            id: matchedGeometryId,
                            in: NamespaceControllerModel.shared.namespace
                        )
                        .zIndex(2.1)
                        .aspectRatio(contentMode: .fit)
                    
                    Text(sample.name)
                        .font(.subheadline)
                    
                    if showCupping { CuppingLink(cupping: sample.cupping) }
                    
                    HStack(spacing: 0) {
                        Text("Final score: ")
                        Text(String(format: "%.1f", sample.finalScore))
                        
                        Spacer()
                        
                        if sample.isFavorite {
                            Image(systemName: "heart.fill")
                                .foregroundStyle(.red)
                        }
                    }
                    .foregroundStyle(.gray)
                    .font(.caption)
                }
                .padding(.small)
                .frame(maxHeight: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: .defaultCornerRadius)
                        .foregroundStyle(Color.backgroundSecondary)
                )
                .matchedGeometryEffect(
                    id: matchedGeometryId + ".container",
                    in: NamespaceControllerModel.shared.namespace
                )
                .zIndex(2.1)
                .contextMenu {
                    Section {
                        Button {
                            sample.cupping.objectWillChange.send()
                            sample.isFavorite.toggle()
                            try? moc.save()
                        } label: {
                            if sample.isFavorite {
                                Label("Remove from Favorites", systemImage: "heart.slash.fill")
                            } else {
                                Label("Add to Favorites", systemImage: "heart")
                            }
                        }
                        
                        Button {
                            foldersModalIsActive = true
                        } label: {
                            Label("Manage Folders", systemImage: "folder.badge.gearshape")
                        }
                    }
                    
                    Section {
                        Button(role: .destructive) {
                            withAnimation {
                                samplesControllerModel.deleteSample(sample, moc: moc)
                                try? moc.save()
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
                .modalView(
                    isPresented: $foldersModalIsActive,
                    toolbar: .init(
                        title: "Folders",
                        trailingToolbarItem: .init("Done", action: { foldersModalIsActive = false })
                    )
                ) {
                    ScrollView {
                        LazyVStack(spacing: .extraSmall) {
                            ForEach([FolderFilter.favorites] + folders.map { FolderFilter(folder: $0) }) { folderFilter in
                                let folderContainsSample: Bool = folderFilter.containsSample(sample)
                                
                                SettingsButtonSection(title: folderFilter.name ?? folderFilter.folder?.name ?? "New Folder") {
                                    if folderContainsSample { folderFilter.removeSample(sample, context: moc) }
                                    else { folderFilter.addSample(sample, context: moc) }
                                    sample.cupping.objectWillChange.send()
                                } leadingContent: {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(Color.accentColor)
                                        .opacity(folderContainsSample ? 1 : 0)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, .small)
                }
                .onTapGesture {
                    samplesControllerModel.setSelectedSample(sample, animationId: animationId)
                }
            } else {
                Color.clear
                    .frame(minHeight: 200)
            }
        }
    }
    
    struct CuppingLink: View {
        @ObservedObject var cupping: Cupping
        
        var body: some View {
            NavigationLink(destination: CuppingView(cupping)) {
                Group {
                    Text(Image(systemName: "arrow.turn.down.right")) +
                    Text(" ") +
                    Text(cupping.name == "" ? "New Cupping" : cupping.name)
                }
                .font(.caption)
                .multilineTextAlignment(.leading)
            }
        }
    }
}

