import SwiftUI

struct MoreView: View {
    @State private var searchText = ""
    @State private var showLogoutAlert = false
    @State private var showProfile = false
    @State private var showSettings = false

    let menuItems: [(String, String)] = [
        ("bag",                    "Accounts"),
        ("creditcard",             "Cards"),
        ("arrow.left.arrow.right", "Payments"),
        ("umbrella",               "Insurance"),
        ("banknote",               "Loans & credit"),
        ("house",                  "Property"),
        ("car",                    "Vehicles"),
    ]

    var filteredMenu: [(String, String)] {
        searchText.isEmpty ? menuItems : menuItems.filter { $0.1.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Search
                    HStack {
                        Image(systemName: "magnifyingglass").foregroundColor(.secondary)
                        TextField("Product, settings etc.", text: $searchText)
                    }
                    .padding(.horizontal, 14).padding(.vertical, 11)
                    .background(Color.white).cornerRadius(14)
                    .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                    .padding(.horizontal, 16)

                    // Profile row
                    HStack(spacing: 16) {
                        ZStack {
                            Circle().fill(Color.dnbTeal).frame(width: 56, height: 56)
                            Text("U").font(.system(size: 13, weight: .bold)).foregroundColor(.white)
                        }
                        Text("Umair Mehmood Imam")
                            .font(.system(size: 13, weight: .semibold))
                        Spacer()
                    }
                    .padding(.horizontal, 20)

                    // Profile / Settings chips
                    HStack(spacing: 10) {
                        Button(action: { showProfile = true }) {
                            HStack(spacing: 6) {
                                Image(systemName: "person.fill").font(.system(size: 13))
                                Text("Profile").font(.system(size: 13))
                            }
                            .foregroundColor(Color.dnbTeal)
                            .padding(.horizontal, 18).padding(.vertical, 9)
                            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.dnbTeal, lineWidth: 1.5))
                        }
                        .buttonStyle(PlainButtonStyle())

                        Button(action: { showSettings = true }) {
                            HStack(spacing: 6) {
                                Image(systemName: "gearshape.fill").font(.system(size: 13))
                                Text("Settings").font(.system(size: 13))
                            }
                            .foregroundColor(Color.dnbTeal)
                            .padding(.horizontal, 18).padding(.vertical, 9)
                            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.dnbTeal, lineWidth: 1.5))
                        }
                        .buttonStyle(PlainButtonStyle())

                        Spacer()
                    }
                    .padding(.horizontal, 20)

                    // SAGA banner
                    HStack {
                        VStack(alignment: .center, spacing: 2) {
                            Text("SAGA")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(Color(hex: "#c8a84b"))
                                .tracking(1.5)
                            Text("See your benefits as a SAGA customer")
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        Image(systemName: "arrow.up.right.square")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }
                    .padding(16)
                    .background(Color.white)
                    .cornerRadius(14)
                    .shadow(color: .black.opacity(0.06), radius: 3, x: 0, y: 1)
                    .padding(.horizontal, 16)

                    // Menu items
                    VStack(spacing: 0) {
                        ForEach(Array(filteredMenu.enumerated()), id: \.offset) { index, item in
                            NavigationLink(destination: AnyView(MenuDetailView(title: item.1, icon: item.0))) {
                                HStack(spacing: 10) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.dnbTeal)
                                            .frame(width: 28, height: 28)
                                        Image(systemName: item.0)
                                            .foregroundColor(.white)
                                            .font(.system(size: 13))
                                    }
                                    Text(item.1).font(.system(size: 13)).foregroundColor(.primary)
                                    Spacer()
                                    Image(systemName: "chevron.right").font(.system(size: 13)).foregroundColor(.secondary)
                                }
                                .padding(.horizontal, 14).padding(.vertical, 9)
                            }
                            if index < filteredMenu.count - 1 { Divider().padding(.leading, 52) }
                        }
                    }
                    .background(Color.white).cornerRadius(14)
                    .shadow(color: .black.opacity(0.06), radius: 3, x: 0, y: 1)
                    .padding(.horizontal, 16)

                    // Customer service + Log out
                    VStack(spacing: 0) {
                        Button(action: {}) {
                            HStack(spacing: 10) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 8).fill(Color.dnbTeal).frame(width: 28, height: 28)
                                    Image(systemName: "headphones").foregroundColor(.white).font(.system(size: 13))
                                }
                                Text("Customer service").font(.system(size: 13)).foregroundColor(.primary)
                                Spacer()
                                Image(systemName: "chevron.right").font(.system(size: 13)).foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 14).padding(.vertical, 9)
                        }
                        .buttonStyle(PlainButtonStyle())

                        Divider().padding(.leading, 52)

                        Button(action: { showLogoutAlert = true }) {
                            HStack(spacing: 10) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 8).fill(Color.red.opacity(0.1)).frame(width: 28, height: 28)
                                    Image(systemName: "rectangle.portrait.and.arrow.right").foregroundColor(.red).font(.system(size: 13))
                                }
                                Text("Log out").font(.system(size: 13)).foregroundColor(.red)
                                Spacer()
                                Image(systemName: "chevron.right").font(.system(size: 13)).foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 14).padding(.vertical, 9)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .background(Color.white).cornerRadius(14)
                    .shadow(color: .black.opacity(0.06), radius: 3, x: 0, y: 1)
                    .padding(.horizontal, 16)

                    Spacer(minLength: 32)
                }
                .padding(.top, 16)
            }
            .background(Color.dnbBackground)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) { EmptyView() }
            }
        }
        .alert("Log out", isPresented: $showLogoutAlert) {
            Button("Log out", role: .destructive) {}
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to log out of DNB?")
        }
        .sheet(isPresented: $showProfile) { ProfileSheet() }
        .sheet(isPresented: $showSettings) { SettingsSheet() }
    }
}

struct MenuDetailView: View {
    let title: String
    let icon: String

    private var items: [(String, String, String)] {
        switch title {
        case "Accounts":
            return [("bag", "Current Account", "1503.82.71264"), ("eurosign", "Euro Account", "1687.44.20938"), ("building.columns", "BSU", "1742.19.83605")]
        case "Cards":
            return [("creditcard", "Visa Debit •••• 4821", "Active"), ("creditcard", "Visa Credit •••• 9034", "Active"), ("creditcard.fill", "Virtual card", "Active")]
        case "Payments":
            return [("person.2", "Recipients", ""), ("doc.text", "eInvoice", ""), ("arrow.triangle.2.circlepath", "AvtaleGiro", ""), ("repeat", "Standing orders", "")]
        case "Insurance":
            return [("house.fill", "Home insurance", "Active"), ("car.fill", "Car insurance", "Active"), ("figure.walk", "Travel insurance", "Active")]
        case "Loans & credit":
            return [("building.2.fill", "Home loan", "NOK 2 850 000"), ("creditcard.fill", "Credit card", "NOK 0 of 50 000")]
        case "Property":
            return [("house.fill", "Hauptstraße 12, Oslo", "Est. NOK 4 200 000"), ("chart.line.uptrend.xyaxis", "Property value history", "")]
        case "Vehicles":
            return [("car.fill", "Toyota Yaris 2019", "AB 12345"), ("bicycle", "Add vehicle", "")]
        default:
            return []
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                if items.isEmpty {
                    VStack(spacing: 16) {
                        ZStack {
                            Circle().fill(Color.dnbLightTeal).frame(width: 80, height: 80)
                            Image(systemName: icon).font(.system(size: 22)).foregroundColor(Color.dnbTeal)
                        }
                        .padding(.top, 48)
                        Text(title).font(.system(size: 13, weight: .bold))
                        Text("Nothing here yet.").font(.system(size: 13)).foregroundColor(.secondary)
                    }
                } else {
                    VStack(spacing: 0) {
                        ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                            HStack(spacing: 14) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10).fill(Color.dnbTeal).frame(width: 38, height: 38)
                                    Image(systemName: item.0).font(.system(size: 13)).foregroundColor(.white)
                                }
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(item.1).font(.system(size: 13))
                                    if !item.2.isEmpty {
                                        Text(item.2).font(.system(size: 13)).foregroundColor(.secondary)
                                    }
                                }
                                Spacer()
                                Image(systemName: "chevron.right").font(.system(size: 13)).foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 16).padding(.vertical, 13)
                            if index < items.count - 1 { Divider().padding(.leading, 68) }
                        }
                    }
                    .background(Color.white).cornerRadius(14)
                    .shadow(color: .black.opacity(0.06), radius: 3, x: 0, y: 1)
                    .padding(16)
                }
            }
        }
        .background(Color.dnbBackground)
        .navigationTitle(title).navigationBarTitleDisplayMode(.large)
    }
}

struct ProfileSheet: View {
    @Environment(\.dismiss) var dismiss
    var body: some View {
        NavigationStack {
            Form {
                Section("Personal information") {
                    HStack { Text("Name").foregroundColor(.secondary); Spacer(); Text("Umair Imam") }
                    HStack { Text("Email").foregroundColor(.secondary); Spacer(); Text("umair@example.no") }
                    HStack { Text("Phone").foregroundColor(.secondary); Spacer(); Text("+47 *** ** ***") }
                }
                Section("Notifications") {
                    Toggle("Email", isOn: .constant(true)).tint(Color.dnbTeal)
                    Toggle("Push", isOn: .constant(true)).tint(Color.dnbTeal)
                }
            }
            .navigationTitle("Profile").navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .navigationBarTrailing) { Button("Done") { dismiss() }.foregroundColor(Color.dnbTeal) } }
        }
    }
}

struct SettingsSheet: View {
    @Environment(\.dismiss) var dismiss
    @State private var faceID = true
    var body: some View {
        NavigationStack {
            Form {
                Section("Security") {
                    Toggle("Face ID / Touch ID", isOn: $faceID).tint(Color.dnbTeal)
                    Button("Change PIN") {}.foregroundColor(Color.dnbTeal)
                }
                Section("App") {
                    HStack { Text("Version"); Spacer(); Text("1.0.0").foregroundColor(.secondary) }
                }
            }
            .navigationTitle("Settings").navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .navigationBarTrailing) { Button("Done") { dismiss() }.foregroundColor(Color.dnbTeal) } }
        }
    }
}

#Preview {
    MoreView().environmentObject(MockData.shared)
}
