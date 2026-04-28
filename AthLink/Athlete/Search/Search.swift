import SwiftUI

struct Search: View {
    @EnvironmentObject var rootView: RootViewObj
    @EnvironmentObject var fSearch: SearchHelp
    @State var zMessage: String = "Enter Zip Code"
    private var loc: String {
        fSearch.validZ ? "location.fill" : "location"
    }

    var body: some View {
        VStack(spacing: 0) {
            // Search bar area
            VStack(spacing: 12) {
                // Sport picker
                Picker(selection: $fSearch.sportVal, label: Text("Select a Sport")) {
                    Text("Select a Sport").tag(0)
                    Text("Football").tag(1).foregroundColor(.black)
                }
                .pickerStyle(MenuPickerStyle())
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .frame(maxWidth: .infinity)

                // Zip code
                HStack {
                    Image(systemName: loc)
                        .foregroundColor(.blue)
                    TextField(zMessage, text: $fSearch.zip)
                        .foregroundColor(Color.primary)
                        .onSubmit { fSearch.validate() }
                    if fSearch.zEditing {
                        Button(action: {
                            fSearch.zip = ""
                            fSearch.zEditing = false
                            fSearch.validZ = false
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .onTapGesture { fSearch.zEditing = true }
                .frame(maxWidth: .infinity)
            }
            .padding()
            .background(Color.white)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)

            // Empty state
            VStack(spacing: 16) {
                Spacer()

                Image(systemName: "magnifyingglass")
                    .font(.system(size: 60))
                    .foregroundColor(.gray.opacity(0.4))

                Text("Find a Coach")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.gray)

                Text("Select a sport and enter your zip code to search for coaches near you")
                    .font(.subheadline)
                    .foregroundColor(.gray.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)

                Spacer()
            }
            .frame(maxWidth: .infinity)
        }
        .background(Color(.systemGroupedBackground))
        .onChange(of: fSearch.zip) {
            zMessage = fSearch.validZ ? "Enter Zip Code" : "Enter a Valid Zip Code"
        }
        .onAppear() {
            if rootView.currentLocation != nil {
                Task {
                    fSearch.zip = await rootView.zipFromLocation() ?? ""
                    fSearch.validate()
                }
            }
        }
    }
}
