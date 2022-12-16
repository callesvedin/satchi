//
//  EditTrackView.swift
//  Satchi
//
//  Created by carl-johan.svedin on 2021-04-05.
//

import SwiftUI
import CloudKit

struct EditTrackView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.preferredColorPalette) private var palette
    @EnvironmentObject private var stack: CoreDataStack

    @StateObject var viewModel:TrackViewModel
    var theTrack:Track
    @State var sharingTrack:Track?

    init(_ track: Track) {
        theTrack = track
        theTrack.state = track.getState().rawValue
        _viewModel = StateObject(wrappedValue: TrackViewModel(track))
    }

    var body: some View {
        VStack {
            ScrollView {
                LazyVStack(alignment: .leading) {
                    HStack {
                        Spacer()
                        PreviewTrackMapView(track:theTrack)
                            .scaledToFit()
                            .cornerRadius(10)
                            .padding(.bottom, 30)

                        Spacer()
                    }
                    FieldsView(viewModel: viewModel)
                }
            }            
        }
        .font(Font.system(size: 22))
        .foregroundColor(palette.primaryText)
        .padding()
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    createShare()
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
                .accentColor(palette.link)
                .sheet(item: $sharingTrack){
                    sharingTrack = nil
                } content: { tr in
                    CloudSharingView(
                        container: stack.ckContainer,
                        share: tr.share!,
                        title: tr.name!
                    )
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: TrackMapView(track:theTrack, preview: false )) {
                    if viewModel.getState() == .trailTracked {
                        Text("Show Track")
                    } else if viewModel.getState()  == .notStarted {
                        Text("Create track")
                    } else {
                        Text("Follow Track")
                    }
                }
                .isDetailLink(false)
                .accentColor(palette.link)
            }
        }
        .background(palette.mainBackground)
        .navigationBarTitle(viewModel.trackName)
        .navigationBarHidden(false)
        .navigationBarBackButtonHidden(false)
        .onChange(of: viewModel.difficulty, perform: {_ in
            theTrack.difficulty = viewModel.difficulty
        })
        .onChange(of: viewModel.comments, perform: {_ in
            theTrack.comments = viewModel.comments
        })
        .onChange(of: viewModel.trackName, perform: {_ in
            theTrack.name = viewModel.trackName
        })
        .onDisappear {
            stack.save()
        }
    }

    func createShare()  {
        stack.context.perform {
            Task {
                if theTrack.share != nil {
                    sharingTrack = theTrack
                    return
                }
                do {
                    let (_, share, _) = try await stack.persistentContainer.share([theTrack], to: nil)
                    share[CKShare.SystemFieldKey.title] = theTrack.name
                    print("Created share with url:\(String(describing: share.url))")
                    theTrack.share = share
                    sharingTrack = theTrack
                }catch{
                    print("Failed to create share")
                }
            }
        }
    }

}
//
extension EditTrackView {
//    private func string(for permission: CKShare.ParticipantPermission) -> String {
//        switch permission {
//        case .unknown:
//            return "Unknown"
//        case .none:
//            return "None"
//        case .readOnly:
//            return "Read-Only"
//        case .readWrite:
//            return "Read-Write"
//        @unknown default:
//            fatalError("A new value added to CKShare.Participant.Permission")
//        }
//    }
//
//    private func string(for role: CKShare.ParticipantRole) -> String {
//        switch role {
//        case .owner:
//            return "Owner"
//        case .privateUser:
//            return "Private User"
//        case .publicUser:
//            return "Public User"
//        case .unknown:
//            return "Unknown"
//        @unknown default:
//            fatalError("A new value added to CKShare.Participant.Role")
//        }
//    }
//
//    private func string(for acceptanceStatus: CKShare.ParticipantAcceptanceStatus) -> String {
//        switch acceptanceStatus {
//        case .accepted:
//            return "Accepted"
//        case .removed:
//            return "Removed"
//        case .pending:
//            return "Invited"
//        case .unknown:
//            return "Unknown"
//        @unknown default:
//            fatalError("A new value added to CKShare.Participant.AcceptanceStatus")
//        }
//    }
//
//    private func createShare(_ track: Track) async {
//        if !stack.isShared(object: track) {
//            do {
//                let (_, share, _) = try await stack.persistentContainer.share([track], to: nil)
//                share[CKShare.SystemFieldKey.title] = track.name
//                self.share = share
//                print("Created share with url:\(String(describing: share.url))")
//            } catch {
//                print("Failed to create share")
//            }
//        }
//
//        showShareSheet = true
//    }
}

struct EditTrackView_Previews: PreviewProvider {
    static var previews: some View {
        let track = CoreDataStack.preview.getTracks()[3]
        return ForEach(ColorScheme.allCases, id: \.self) {
            EditTrackView(track)
                .preferredColorScheme($0)
                .environmentObject(CoreDataStack.preview)
//                .environment(\.managedObjectContext, CoreDataStack.preview.context)
        }
    }
}

struct FieldsView: View {
    @Environment(\.preferredColorPalette) private var palette
    @ObservedObject var viewModel:TrackViewModel

    var body: some View {
        Group {
            HStack {
                Text("**Name:**")
                TextField("Name", text: $viewModel.trackName)
                    .padding(.horizontal,8)
                    .background(RoundedRectangle(cornerRadius: 4)
                        .fill(palette.midBackground)
                    )
            }

            Text("**Created:** \(viewModel.created != nil ? TimeFormatter.dateStringFrom(date: viewModel.created) : "-")")

            HStack {
                Text("**Difficulty:**")
                DifficultyView(difficulty: $viewModel.difficulty)
            }.padding(0)

            Text("**Length:** \(DistanceFormatter.distanceFor(meters:Double(viewModel.length)))")
            Text("**Time to create:** \(TimeFormatter.shortTimeWithSecondsFor(seconds:viewModel.timeToCreate))")


            if viewModel.started != nil {
                Text("""
                     **Track rested:** \
                     \(getTimeBetween(date: viewModel.created, and: viewModel.started))
                     """
                )
            } else {
                Text("**Time since created:** \(getTimeSinceCreated())")
            }
            if viewModel.started != nil {
                Text("**Tracking started:** \(TimeFormatter.dateStringFrom(date: viewModel.started!))")

                Text("""
                     **Time to finish:** \
                     \(TimeFormatter.shortTimeWithSecondsFor(seconds:viewModel.timeToFinish))
                     """
                )
            }

            Text("**Comments:**")
            TextField("Comments", text: $viewModel.comments)
                .font(.body)
                .frame(minHeight: 80)
                .border(Color.gray, width: 1)
        }
        .padding(.vertical, 4)
    }

    private func getTimeBetween(date: Date?, and toDate: Date?) -> String {
        guard let fromDate = date, let toDate = toDate else {return "-"}
        return TimeFormatter.shortTimeWithMinutesFor(seconds: fromDate.distance(to: toDate))
    }

    private func getTimeSinceCreated() -> String {
        guard let timeDistance = viewModel.created?.distance(to: Date()) else {return "-"}
        return TimeFormatter.shortTimeWithMinutesFor(seconds: timeDistance)
    }

}
