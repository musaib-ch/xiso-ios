import SwiftUI
import UniformTypeIdentifiers

private enum StudioTab: String, CaseIterable {
    case home = "Home"
    case files = "Files"
    case activity = "Activity"
    case settings = "Settings"

    var symbol: String {
        switch self {
        case .home: return "opticaldisc"
        case .files: return "folder"
        case .activity: return "list.bullet.rectangle"
        case .settings: return "gearshape"
        }
    }
}

private enum StudioOperation: String, CaseIterable, Identifiable {
    case extract = "Extract"
    case create = "Create"
    case list = "List"
    case rewrite = "Rewrite"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .extract: return "archivebox"
        case .create: return "opticaldisc"
        case .list: return "list.tree"
        case .rewrite: return "wand.and.stars"
        }
    }

    var subtitle: String {
        switch self {
        case .extract: return "Unpack an XISO image into a folder"
        case .create: return "Build an XISO from a game folder"
        case .list: return "Inspect image contents and entries"
        case .rewrite: return "Rewrite an image with supported options"
        }
    }

    var detail: String {
        switch self {
        case .extract: return "Choose an ISO image, then select a destination folder. The extraction engine will be connected in a later step."
        case .create: return "Choose a source folder and output location. XISO creation is not connected yet."
        case .list: return "Choose an image to inspect its contents. Listing is not connected yet."
        case .rewrite: return "Choose an image and an output location. The original image will not be overwritten by default."
        }
    }
}

private enum StudioPalette {
    static let background = Color(red: 0.055, green: 0.059, blue: 0.071)
    static let surface = Color(red: 0.105, green: 0.11, blue: 0.125)
    static let elevated = Color(red: 0.16, green: 0.17, blue: 0.19)
    static let green = Color(red: 0.47, green: 0.87, blue: 0.40)
    static let muted = Color(red: 0.72, green: 0.76, blue: 0.70)
}

struct ContentView: View {
    @State private var selectedTab: StudioTab = .home
    @State private var selectedOperation: StudioOperation?
    @State private var showingFilePicker = false
    @State private var selectedFileName: String?
    @State private var showingFileError = false
    @State private var fileErrorMessage = ""

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                homeView
                    .navigationBarHidden(true)
            }
            .tabItem { Label("Home", systemImage: StudioTab.home.symbol) }
            .tag(StudioTab.home)

            NavigationStack {
                filesView
                    .navigationTitle("Files")
                    .navigationBarTitleDisplayMode(.large)
            }
            .tabItem { Label("Files", systemImage: StudioTab.files.symbol) }
            .tag(StudioTab.files)

            NavigationStack {
                activityView
                    .navigationTitle("Activity")
                    .navigationBarTitleDisplayMode(.large)
            }
            .tabItem { Label("Activity", systemImage: StudioTab.activity.symbol) }
            .tag(StudioTab.activity)

            NavigationStack {
                settingsView
                    .navigationTitle("Settings")
                    .navigationBarTitleDisplayMode(.large)
            }
            .tabItem { Label("Settings", systemImage: StudioTab.settings.symbol) }
            .tag(StudioTab.settings)
        }
        .tint(StudioPalette.green)
        .preferredColorScheme(.dark)
        .background(StudioPalette.background.ignoresSafeArea())
        .fileImporter(
            isPresented: $showingFilePicker,
            allowedContentTypes: [.data],
            allowsMultipleSelection: false,
            onCompletion: handleFileImport
        )
        .alert("File Selection", isPresented: $showingFileError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(fileErrorMessage)
        }
        .sheet(item: $selectedOperation) { operation in
            OperationInfoSheet(operation: operation, selectedFileName: selectedFileName) {
                showingFilePicker = true
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
    }

    private var homeView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("XISO STUDIO")
                            .font(.caption.weight(.bold))
                            .tracking(1.8)
                            .foregroundStyle(StudioPalette.green)
                        Text("Dashboard")
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                    }
                    Spacer()
                    Image(systemName: "opticaldisc")
                        .font(.system(size: 25, weight: .medium))
                        .foregroundStyle(StudioPalette.green)
                        .frame(width: 48, height: 48)
                        .background(StudioPalette.surface, in: RoundedRectangle(cornerRadius: 15))
                }

                HStack(spacing: 8) {
                    Circle().fill(StudioPalette.green).frame(width: 7, height: 7)
                    Text("CORE ENGINE NOT CONNECTED")
                        .font(.system(size: 10, weight: .semibold, design: .monospaced))
                        .tracking(0.5)
                        .foregroundStyle(StudioPalette.green)
                    Spacer()
                    Text("iOS")
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundStyle(StudioPalette.muted)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(StudioPalette.surface, in: Capsule())

                storageCard

                VStack(alignment: .leading, spacing: 12) {
                    Text("Start a new operation")
                        .font(.headline)
                    operationCard(.extract, featured: true)
                    HStack(alignment: .top, spacing: 10) {
                        operationCard(.create)
                        operationCard(.list)
                    }
                    operationCard(.rewrite)
                }

                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Recent Activity")
                            .font(.headline)
                        Spacer()
                        Button("See all") { selectedTab = .activity }
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(StudioPalette.green)
                    }
                    emptyState(
                        symbol: "clock.arrow.circlepath",
                        title: "No operations yet",
                        message: "Completed and active jobs will appear here when processing is implemented."
                    )
                }

                Text("Native SwiftUI interface • Local file access")
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundStyle(StudioPalette.muted.opacity(0.75))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
            }
            .padding(16)
        }
        .background(StudioPalette.background)
    }

    private var storageCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: "internaldrive")
                    .font(.title3)
                    .foregroundStyle(StudioPalette.green)
                    .frame(width: 42, height: 42)
                    .background(StudioPalette.elevated, in: RoundedRectangle(cornerRadius: 12))
                VStack(alignment: .leading, spacing: 3) {
                    Text("Device Storage")
                        .font(.subheadline.weight(.semibold))
                    Text("Storage is managed by iOS")
                        .font(.caption)
                        .foregroundStyle(StudioPalette.muted)
                }
                Spacer(minLength: 0)
            }
            Text("Choose files from Files or iCloud Drive. Available space will be shown here when device storage reporting is added.")
                .font(.subheadline)
                .foregroundStyle(StudioPalette.muted)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(StudioPalette.surface, in: RoundedRectangle(cornerRadius: 18))
    }

    private func operationCard(_ operation: StudioOperation, featured: Bool = false) -> some View {
        Button {
            selectedOperation = operation
        } label: {
            HStack(spacing: 12) {
                Image(systemName: operation.symbol)
                    .font(.system(size: featured ? 23 : 20, weight: .medium))
                    .foregroundStyle(StudioPalette.green)
                    .frame(width: featured ? 48 : 42, height: featured ? 48 : 42)
                    .background(StudioPalette.elevated, in: RoundedRectangle(cornerRadius: 12))
                VStack(alignment: .leading, spacing: 4) {
                    Text(operation.rawValue)
                        .font(featured ? .headline : .subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                    Text(operation.subtitle)
                        .font(.caption)
                        .foregroundStyle(StudioPalette.muted)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(StudioPalette.muted)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(StudioPalette.surface, in: RoundedRectangle(cornerRadius: 16))
            .contentShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }

    private var filesView: some View {
        ScrollView {
            VStack(spacing: 16) {
                emptyState(
                    symbol: "folder",
                    title: selectedFileName ?? "Your selected files",
                    message: selectedFileName == nil
                        ? "Select an ISO or other file from the iOS Files app. This screen does not scan your device automatically."
                        : "File selection is available. Processing support will be added when the XISO engine is integrated."
                )
                Button {
                    showingFilePicker = true
                } label: {
                    Label("Browse Files", systemImage: "folder.badge.plus")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(StudioPalette.green, in: RoundedRectangle(cornerRadius: 14))
                        .foregroundStyle(.black)
                }
                .buttonStyle(.plain)
            }
            .padding(16)
        }
        .background(StudioPalette.background)
    }

    private var activityView: some View {
        ScrollView {
            emptyState(
                symbol: "list.bullet.rectangle",
                title: "No jobs to show",
                message: "Operation history, progress reporting, and logs will appear here after the processing engine is connected."
            )
            .padding(16)
        }
        .background(StudioPalette.background)
    }

    private var settingsView: some View {
        List {
            Section("Processing") {
                Label("Original files are not overwritten by default", systemImage: "shield.lefthalf.filled")
                Label("File access uses the iOS document picker", systemImage: "folder")
            }
            Section("About") {
                LabeledContent("App", value: "XISO Studio")
                LabeledContent("Interface", value: "Native SwiftUI")
                LabeledContent("Engine", value: "Not integrated")
            }
            Section {
                Text("The current build is an interface scaffold. Extract, Create, List, and Rewrite do not process image data yet.")
                    .font(.footnote)
                    .foregroundStyle(StudioPalette.muted)
            }
        }
        .scrollContentBackground(.hidden)
        .background(StudioPalette.background)
    }

    private func emptyState(symbol: String, title: String, message: String) -> some View {
        VStack(spacing: 10) {
            Image(systemName: symbol)
                .font(.system(size: 28))
                .foregroundStyle(StudioPalette.green)
                .frame(width: 60, height: 60)
                .background(StudioPalette.elevated, in: RoundedRectangle(cornerRadius: 18))
            Text(title)
                .font(.headline)
                .multilineTextAlignment(.center)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(StudioPalette.muted)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(StudioPalette.surface, in: RoundedRectangle(cornerRadius: 18))
    }

    private func handleFileImport(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            selectedFileName = url.lastPathComponent
            let granted = url.startAccessingSecurityScopedResource()
            defer {
                if granted {
                    url.stopAccessingSecurityScopedResource()
                }
            }
        case .failure(let error):
            fileErrorMessage = error.localizedDescription
            showingFileError = true
        }
    }
}

private struct OperationInfoSheet: View {
    let operation: StudioOperation
    let selectedFileName: String?
    let chooseFile: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 18) {
                HStack(spacing: 14) {
                    Image(systemName: operation.symbol)
                        .font(.system(size: 26))
                        .foregroundStyle(StudioPalette.green)
                        .frame(width: 56, height: 56)
                        .background(StudioPalette.elevated, in: RoundedRectangle(cornerRadius: 16))
                    VStack(alignment: .leading, spacing: 4) {
                        Text(operation.rawValue)
                            .font(.title2.bold())
                        Text("Operation setup")
                            .font(.subheadline)
                            .foregroundStyle(StudioPalette.muted)
                    }
                }
                Text(operation.detail)
                    .font(.body)
                    .foregroundStyle(StudioPalette.muted)
                if let selectedFileName {
                    Label(selectedFileName, systemImage: "doc")
                        .font(.subheadline.weight(.medium))
                        .lineLimit(2)
                }
                Button(action: chooseFile) {
                    Label("Choose file", systemImage: "folder")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(StudioPalette.green, in: RoundedRectangle(cornerRadius: 14))
                        .foregroundStyle(.black)
                }
                .buttonStyle(.plain)
                Spacer(minLength: 0)
                Text("Processing is not available in this scaffold yet.")
                    .font(.caption)
                    .foregroundStyle(StudioPalette.muted)
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(StudioPalette.background.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .tint(StudioPalette.green)
                }
            }
        }
    }
}
