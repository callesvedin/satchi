//
//  EditTrackView.swift
//  Satchi
//
//  Created by carl-johan.svedin on 2021-04-05.
//

import SwiftUI
import CloudKit

struct EditTrackView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject private var stack: CoreDataStack
    var track: Track
    @State private var share: CKShare?
    @State private var showShareSheet = false
    @State private var comment = ""
    @StateObject var viewModel = TrackViewModel()
    let dateFormatter: DateFormatter
    let elapsedTimeFormatter: DateComponentsFormatter
    let shortElapsedTimeFormatter: DateComponentsFormatter

    @Environment(\.managedObjectContext) var managedObjectContext

    init(_ track: Track) {
        self.track = track
        dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        dateFormatter.locale = Locale.current

        elapsedTimeFormatter = DateComponentsFormatter()
        elapsedTimeFormatter.unitsStyle = .abbreviated
        elapsedTimeFormatter.zeroFormattingBehavior = .dropAll
        elapsedTimeFormatter.allowedUnits = [.day, .hour, .minute]

        shortElapsedTimeFormatter = DateComponentsFormatter()
        shortElapsedTimeFormatter.unitsStyle = .abbreviated
        shortElapsedTimeFormatter.zeroFormattingBehavior = .dropAll
        shortElapsedTimeFormatter.allowedUnits = [.hour, .minute, .second]
    }

    var body: some View {
        VStack {
            ScrollView {
                LazyVStack(alignment: .leading) {
                    HStack {
                        Spacer()
                        TrackMapView(track: track, preview: true)
                            .scaledToFit()
                            .cornerRadius(10)
                            .padding(.bottom, 30)
                        Spacer()
                    }
                    Group {
                        HStack {
                            Text("**Name:**")
                            TextField("Name", text: $viewModel.trackName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }

                        Text("**Created:** \(track.created != nil ? dateFormatter.string(from: track.created!) : "-")")

                        HStack {
                            Text("**Difficulty:**")
                            DifficultyView(difficulty: $viewModel.difficulty)
                        }.padding(0)

                        Text("**Length**: \(track.length)m")
                        Text("**Time to create:** \(shortElapsedTimeFormatter.string(from: track.timeToCreate) ?? "-")")

                    }.padding(.vertical, 4)
                    Group {
                        if track.started != nil {
                            Text("""
                            **Track rested:** \
                            \(getTimeBetween(date: track.created, and: track.started))
                            """
                            )
                        } else {
                            Text("**Time since created**:\(getTimeSinceCreated())")
                        }
                        if track.started != nil {
                            Text("**Tracking started:** \(dateFormatter.string(from: track.started!))")

                            Text("""
                             **Time to finish:** \
                             \(shortElapsedTimeFormatter.string(from: track.timeToFinish) ?? "**-**")
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
            }            
        }
        .font(Font.system(size: 22))
        .padding()
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    Task {await createShare(track)}
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }.sheet(isPresented: $showShareSheet, content: {
                    if let share = share {
                        CloudSharingView(
                            container: stack.ckContainer,
                            share: share
                        )
                    }
                })
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: TrackMapView(track: track)) {
                    if viewModel.runningState == .tracked {
                        Text("Show Track")
                    } else if viewModel.runningState == .notCreated {
                        Text("Create track")
                    } else {
                        Text("Follow Track")
                    }
                }
                .isDetailLink(false)
            }
        }
        .navigationBarTitle(viewModel.trackName)
        .navigationBarHidden(false)
        .navigationBarBackButtonHidden(false)
        .onAppear {
            self.share = stack.getShare(track)
            print("Share:\(String(describing: self.share))")
            viewModel.trackName = track.name  ?? ""
            viewModel.comments = track.comments ?? ""
            viewModel.difficulty = max(1, track.difficulty)
            viewModel.setState(pathLaid: !(track.laidPath?.isEmpty ?? true),
                               tracked: !(track.trackPath?.isEmpty ?? true))
        }
        .onDisappear() {
            save()
        }

    }

    private func getTimeBetween(date: Date?, and toDate: Date?) -> String {
        guard let fromDate = date, let toDate = toDate else {return "-"}
        return elapsedTimeFormatter.string(from: fromDate.distance(to: toDate)) ?? "-"
    }

    private func getTimeSinceCreated() -> String {
        guard let timeDistance = track.created?.distance(to: Date()) else {return "-"}

        return elapsedTimeFormatter.string(from: timeDistance) ?? "-"
    }

    private func save() {
        managedObjectContext.performAndWait {
            track.name = viewModel.trackName
            track.comments = viewModel.comments
            track.difficulty = viewModel.difficulty
            stack.save()
        }
    }
}

extension EditTrackView {
    private func string(for permission: CKShare.ParticipantPermission) -> String {
        switch permission {
        case .unknown:
            return "Unknown"
        case .none:
            return "None"
        case .readOnly:
            return "Read-Only"
        case .readWrite:
            return "Read-Write"
        @unknown default:
            fatalError("A new value added to CKShare.Participant.Permission")
        }
    }

    private func string(for role: CKShare.ParticipantRole) -> String {
        switch role {
        case .owner:
            return "Owner"
        case .privateUser:
            return "Private User"
        case .publicUser:
            return "Public User"
        case .unknown:
            return "Unknown"
        @unknown default:
            fatalError("A new value added to CKShare.Participant.Role")
        }
    }

    private func string(for acceptanceStatus: CKShare.ParticipantAcceptanceStatus) -> String {
        switch acceptanceStatus {
        case .accepted:
            return "Accepted"
        case .removed:
            return "Removed"
        case .pending:
            return "Invited"
        case .unknown:
            return "Unknown"
        @unknown default:
            fatalError("A new value added to CKShare.Participant.AcceptanceStatus")
        }
    }
    private func createShare(_ track: Track) async {
        if !stack.isShared(object: track) {
            do {
                let (_, share, _) = try await stack.persistentContainer.share([track], to: nil)
                share[CKShare.SystemFieldKey.title] = track.name
                self.share = share
            } catch {
                print("Failed to create share")
            }
        }

        print("URL to share:\(String(describing: share?.url))")
        showShareSheet = true
    }
}

struct EditTrackView_Previews: PreviewProvider {
    static var previews: some View {
        let track = CoreDataStack.preview.getTracks()[3]
        return ForEach(ColorScheme.allCases, id: \.self) {
            EditTrackView(track)
                .preferredColorScheme($0)
                .environmentObject(CoreDataStack.preview)
                .environment(\.managedObjectContext, CoreDataStack.preview.context)
        }
    }
}
