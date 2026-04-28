import SwiftUI
import CoreLocation
import MapKit

struct CouchAccount: View {
    @EnvironmentObject var rootView: RootViewObj
    @State private var camera: MapCameraPosition = .automatic
    @State private var selectedLoc: structLocation? = nil
    @State private var ratings: CoachRating?
    
    var body: some View {
        if let selectedSession = rootView.selectedSession {
            VStack(spacing: 0) {
                // Header
                HStack(spacing: 14) {
                    // Profile Image
                    if selectedSession.imageURL.hasPrefix("http"),
                       let url = URL(string: selectedSession.imageURL) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .success(let img):
                                img.resizable().scaledToFill()
                            default:
                                Image("athlinklogo").resizable().scaledToFill()
                            }
                        }
                        .frame(width: 56, height: 56)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    } else {
                        Image("athlinklogo")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 56, height: 56)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(selectedSession.fullName)
                            .font(.headline)
                            .foregroundColor(.white)

                        if let ratings {
                            HStack(spacing: 4) {
                                HStack(spacing: 1) {
                                    ForEach(0..<5) { index in
                                        let threshold = Float(index) + 1
                                        if ratings.avgStar >= threshold {
                                            Image(systemName: "star.fill")
                                                .foregroundColor(.yellow)
                                        } else if ratings.avgStar >= threshold - 0.5 {
                                            Image(systemName: "star.leadinghalf.fill")
                                                .foregroundColor(.yellow)
                                        } else {
                                            Image(systemName: "star")
                                                .foregroundColor(.yellow)
                                        }
                                    }
                                }
                                .font(.caption2)
                                Text(String(format: "%.1f", ratings.avgStar))
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.white)
                                Text("(\(ratings.reviewCount))")
                                    .font(.caption2)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        }

                        // Pricing inline
                        HStack(spacing: 8) {
                            if let individualCost = selectedSession.individualCost {
                                Text(String(format: "$%.0f/hr ind.", individualCost))
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.9))
                            }
                            if let groupCost = selectedSession.groupCost {
                                Text(String(format: "$%.0f/hr grp.", groupCost))
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.9))
                            }
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.vertical, 14)
                .background(Color(red: 0.4627, green: 0.8392, blue: 1.0))

                // Action Buttons
                if rootView.lastPage != "Account" {
                    HStack(spacing: 12) {
                        Button(action: {
                            rootView.path.append("Request")
                        }) {
                            Text("Request Session")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.blue)
                                .cornerRadius(10)
                        }

                        Button(action: {
                            rootView.chatPartner = PublicUser(
                                id: selectedSession.id,
                                firstName: selectedSession.firstName,
                                lastName: selectedSession.lastName,
                                avatarURL: nil,
                                cardOnFile: false
                            )
                            rootView.path.append("MessageAccount")
                        }) {
                            Text("Message")
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(10)
                        }
                    }
                    .padding()
                }

                // Content
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 16) {
                        // Stats Card
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Stats")
                                .font(.headline)

                            if let dis = closestDistanceMeters(selectedSession.trainingLocations, myLocal: rootView.currentLocation) {
                                HStack {
                                    Image(systemName: "mappin.circle")
                                        .foregroundColor(.blue)
                                        .frame(width: 24)
                                    Text("Closest Location")
                                        .foregroundColor(.gray)
                                    Spacer()
                                    VStack(alignment: .trailing) {
                                        Text(dis.0.name)
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                        let miles = dis.1 / 1609.344
                                        Text(String(format: "%.1f mi", miles))
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                }
                                .font(.subheadline)
                            }

                            statRow(icon: "person.2", label: "People Coached", value: "\(selectedSession.peopleCoached)")
                            statRow(icon: "clock", label: "Hours Coaching", value: "\(selectedSession.hoursCoached)")

                            if let cancel = selectedSession.cancellationNotice {
                                statRow(icon: "calendar.badge.exclamationmark", label: "Cancellation Notice", value: "\(cancel)hr")
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                        .padding(.horizontal)

                        // About Card
                        if !selectedSession.personalQuote.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("About")
                                    .font(.headline)
                                Text(selectedSession.personalQuote)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                            .padding(.horizontal)
                        }

                        // Experience Card
                        if !selectedSession.coachingExperience.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Experience")
                                    .font(.headline)
                                ForEach(selectedSession.coachingExperience, id: \.self) { exp in
                                    HStack(alignment: .top, spacing: 8) {
                                        Circle()
                                            .fill(Color.blue)
                                            .frame(width: 6, height: 6)
                                            .padding(.top, 6)
                                        Text(exp)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                            .padding(.horizontal)
                        }

                        // Achievements Card
                        if !selectedSession.coachingAchievements.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Achievements")
                                    .font(.headline)
                                ForEach(selectedSession.coachingAchievements, id: \.self) { ach in
                                    HStack(alignment: .top, spacing: 8) {
                                        Image(systemName: "trophy.fill")
                                            .font(.caption)
                                            .foregroundColor(.yellow)
                                            .padding(.top, 2)
                                        Text(ach)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                            .padding(.horizontal)
                        }

                        // Reviews Card
//                        VStack(alignment: .leading, spacing: 10) {
//                            HStack {
//                                Text("Reviews")
//                                    .font(.headline)
//                                Spacer()
//                                HStack(spacing: 4) {
//                                    HStack(spacing: 2) {
//                                        ForEach(1..<6) { index in
//                                            if selectedSession.rating - Float(index) >= 0 {
//                                                Image(systemName: "star.fill")
//                                                    .foregroundColor(.yellow)
//                                            } else if selectedSession.rating - Float(index) == -0.5 {
//                                                Image(systemName: "star.leadinghalf.fill")
//                                                    .foregroundColor(.yellow)
//                                            } else {
//                                                Image(systemName: "star")
//                                                    .foregroundColor(.yellow)
//                                            }
//                                        }
//                                    }
//                                    .font(.caption2)
//                                    Text(String(format: "%.1f", selectedSession.rating))
//                                        .font(.subheadline)
//                                        .fontWeight(.medium)
//                                }
//                            }
//
//                            if let lastReview = selectedSession.reviews.last {
//                                VStack(alignment: .leading, spacing: 4) {
//                                    Text(lastReview.quote)
//                                        .font(.subheadline)
//                                        .foregroundColor(.secondary)
//                                    Text(lastReview.date.formatted(date: .abbreviated, time: .omitted))
//                                        .font(.caption)
//                                        .foregroundColor(.gray)
//                                }
//                                .padding(12)
//                                .frame(maxWidth: .infinity, alignment: .leading)
//                                .background(Color(.systemGray6))
//                                .cornerRadius(10)
//                            } else {
//                                HStack(spacing: 8) {
//                                    Image(systemName: "text.bubble")
//                                        .foregroundColor(.gray.opacity(0.5))
//                                    Text("No reviews yet")
//                                        .font(.subheadline)
//                                        .foregroundColor(.gray)
//                                }
//                                .padding(.vertical, 8)
//                            }
//                        }
//                        .padding()
//                        .background(Color.white)
//                        .cornerRadius(16)
//                        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
//                        .padding(.horizontal)

                        // Training Locations Card
                        if !selectedSession.trainingLocations.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Training Locations")
                                    .font(.headline)

                                ForEach(selectedSession.trainingLocations, id: \.id) { loc in
                                    HStack(spacing: 6) {
                                        Image(systemName: "mappin.circle.fill")
                                            .foregroundColor(.blue)
                                        Text(loc.name)
                                            .font(.subheadline)
                                        Spacer()
                                    }
                                    .padding(.vertical, 2)
                                }

                                Map(position: $camera, selection: $selectedLoc) {
                                    ForEach(selectedSession.trainingLocations, id: \.id) { loc in
                                        Marker(loc.name, coordinate: loc.coordinate)
                                            .tag(loc)
                                    }
                                }
                                .frame(height: 220)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .mapStyle(.hybrid)
                                .onAppear {
                                    if let reg = regionThatFits(selectedSession.trainingLocations) {
                                        camera = .region(reg)
                                    }
                                }
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                            .padding(.horizontal)
                        }

                        // Sports/Positions Card
                        if !selectedSession.sports.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Sports & Positions")
                                    .font(.headline)

                                ForEach(selectedSession.sports, id: \.self) { sp in
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(sp)
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                        if let positions = selectedSession.sportPositions[sp], !positions.isEmpty {
                                            ForEach(positions, id: \.self) { p in
                                                HStack(spacing: 6) {
                                                    Circle()
                                                        .fill(Color.blue.opacity(0.5))
                                                        .frame(width: 5, height: 5)
                                                    Text(p)
                                                        .font(.subheadline)
                                                        .foregroundColor(.secondary)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                            .padding(.horizontal)
                        }

                        // Availability Card
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Availability")
                                .font(.headline)
                            AvailabilityGridRead(selectedA: selectedSession.timeAvailability)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    }
                    .padding(.top, 16)
                }
            }
            .background(Color(.systemGroupedBackground))
            .task {
                ratings = await getCoachRating(client: rootView.client, coachID: selectedSession.id)
            }
        }
    }

    private func statRow(icon: String, label: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 24)
            Text(label)
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
        .font(.subheadline)
    }
}
