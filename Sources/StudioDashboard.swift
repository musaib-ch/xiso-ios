import SwiftUI
import UniformTypeIdentifiers

private enum StudioOperation: String, CaseIterable, Identifiable {
    case extract = "Extract"
    case create = "Create"
    case list = "List"
    case rewrite = "Rewrite"
    case god = "Convert to GOD"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .extract: return "archivebox"
        case .create: return "opticaldisc"
        case .list: return "list.tree"
        case .rewrite: return "wand.and.stars"
        case .god: return "externaldrive"
        }
    }

    var subtitle: String {
        switch self {
        case .extract: return "Unpack an image into a folder"
        case .create: return "Build an XISO from a folder"
        case .list: return "Inspect image contents"
        case .rewrite: return "Rewrite an image safely"
        case .god: return "Convert an Xbox image to GOD format"
        }
    }
}

private enum StudioStyle {
    static let background = Color(red: 0.055, green: 0.059, blue: 0.071)
    static let surface = Color(red: 0.105, green: 0.11, blue: 0.125)
    static let elevated = Color(red: 0.16, green: 0.17, blue: 0.19)
    static let green = Color(red: 0.47, green: 0.87, blue: 0.40)
    static let muted = Color(red: 0.72, green: 0.76, blue: 0.70)
}

struct DashboardView: View {
    @EnvironmentObject private var engine: XisoEngine
    @State private var selectedOperation: StudioOperation?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("XISO STUDIO")
                                .font(.caption.weight(.bold))
                                .tracking(1.8)
                                .foregroundStyle(StudioStyle.green)
                            Text("Dashboard")
                                .font(.system(size: 30, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                        }
                        Spacer()
                        Image(systemName: "opticaldisc")
                            .font(.system(size: 25, weight: .medium))
                            .foregroundStyle(StudioStyle.green)
                            .frame(width: 48, height: 48)
                            .background(StudioStyle.surface, in: RoundedRectangle(cornerRadius: 15))
                    }

                    HStack(spacing: 8) {
                        Circle()
                            .fill(StudioStyle.green)
                            .frame(width: 7, height: 7)
                        Text(engine.busy ? "ENGINE WORKING" : "XISO ENGINE READY")
                            .font(.system(size: 10, weight: .semibold, design: .monospaced))
                            .tracking(0.5)
                            .foregroundStyle(StudioStyle.green)
                        Spacer()
                        Text("LOCAL PROCESSING")
                            .font(.system(size: 9, weight: .medium, design: .monospaced))
                            .foregroundStyle(StudioStyle.muted)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(StudioStyle.surface, in: Capsule())

                    VStack(alignment: .leading, spacing: 12) {
                        Label("Local file workflow", systemImage: "internaldrive")
                            .font(.headline)
                        Text("Choose source images and destination folders through the iOS Files picker. Storage usage is not guessed or fabricated.")
                            .font(.subheadline)
                            .foregroundStyle(StudioStyle.muted)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(StudioStyle.surface, in: RoundedRectangle(cornerRadius: 18))

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Start a new operation")
                            .font(.headline)
                        operationCard(.extract, featured: true)
                        HStack(alignment: .top, spacing: 10) {
                            operationCard(.create)
                            operationCard(.list)
                        }
                        operationCard(.rewrite)
                        operationCard(.god)
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Current activity")
                                .font(.headline)
                            Spacer()
                            Text(engine.busy ? "RUNNING" : "IDLE")
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .foregroundStyle(engine.busy ? StudioStyle.green : StudioStyle.muted)
                        }
                        if engine.busy {
                            ProgressView(value: engine.progress)
                                .tint(StudioStyle.green)
                            Text(engine.status)
                                .font(.subheadline)
                                .foregroundStyle(StudioStyle.muted)
                        } else {
                            Label("No active operation", systemImage: "checkmark.circle")
                                .font(.subheadline)
                                .foregroundStyle(StudioStyle.muted)
                        }
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(StudioStyle.surface, in: RoundedRectangle(cornerRadius: 18))

                    Text("XISO Studio • Native SwiftUI")
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundStyle(StudioStyle.muted.opacity(0.75))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
                .padding(16)
            }
            .background(StudioStyle.background)
            .toolbar(.hidden, for: .navigationBar)
        }
        .sheet(item: $selectedOperation) { operation in
            operationDestination(operation)
        }
    }

    @ViewBuilder
    private func operationDestination(_ operation: StudioOperation) -> some View {
        switch operation {
        case .extract: ExtractView()
        case .create: CreateView()
        case .list: ListView()
        case .rewrite: RewriteView()
        case .god: GodView()
        }
    }

    private func operationCard(_ operation: StudioOperation, featured: Bool = false) -> some View {
        Button {
            selectedOperation = operation
        } label: {
            HStack(spacing: 12) {
                Image(systemName: operation.symbol)
                    .font(.system(size: featured ? 23 : 20, weight: .medium))
                    .foregroundStyle(StudioStyle.green)
                    .frame(width: featured ? 48 : 42, height: featured ? 48 : 42)
                    .background(StudioStyle.elevated, in: RoundedRectangle(cornerRadius: 12))
                VStack(alignment: .leading, spacing: 4) {
                    Text(operation.rawValue)
                        .font(featured ? .headline : .subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                    Text(operation.subtitle)
                        .font(.caption)
                        .foregroundStyle(StudioStyle.muted)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(StudioStyle.muted)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(StudioStyle.surface, in: RoundedRectangle(cornerRadius: 16))
            .contentShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
}

struct FilesLibraryView: View {
    @State private var showingPicker = false
    @State private var selectedNames: [String] = []
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Image(systemName: "folder")
                    .font(.system(size: 32))
                    .foregroundStyle(StudioStyle.green)
                Text(selectedNames.isEmpty ? "Browse your files" : "Selected items")
                    .font(.headline)
                Text(selectedNames.isEmpty
                     ? "Select ISO images or folders from Files and iCloud Drive. XISO Studio does not scan your device automatically."
                     : selectedNames.joined(separator: "\n"))
                    .font(.subheadline)
                    .foregroundStyle(StudioStyle.muted)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                Button {
                    showingPicker = true
                } label: {
                    Label("Browse Files", systemImage: "folder.badge.plus")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(StudioStyle.green, in: RoundedRectangle(cornerRadius: 14))
                        .foregroundStyle(.black)
                }
                .buttonStyle(.plain)
                .padding(.horizontal)
                Spacer()
            }
            .padding(.top, 36)
            .frame(maxWidth: .infinity)
            .background(StudioStyle.background)
            .navigationTitle("Files")
            .fileImporter(isPresented: $showingPicker, allowedContentTypes: [.data, .folder], allowsMultipleSelection: true) { result in
                switch result {
                case .success(let urls):
                    selectedNames = urls.map(\.lastPathComponent)
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
            .alert("Could not open files", isPresented: Binding(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )) {
                Button("OK", role: .cancel) { errorMessage = nil }
            } message: {
                Text(errorMessage ?? "")
            }
        }
    }
}

struct ActivityLibraryView: View {
    @EnvironmentObject private var engine: XisoEngine

    var body: some View {
        NavigationStack {
            List {
                Section("Current job") {
                    LabeledContent("Status", value: engine.status)
                    if engine.busy {
                        ProgressView(value: engine.progress)
                            .tint(StudioStyle.green)
                        Button("Cancel operation", role: .destructive) {
                            engine.cancel()
                        }
                    }
                }
                Section("Log") {
                    if engine.log.isEmpty {
                        Text("No log entries yet.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(Array(engine.log.enumerated()), id: \.offset) { _, line in
                            Text(line)
                                .font(.system(size: 11, design: .monospaced))
                                .textSelection(.enabled)
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(StudioStyle.background)
            .navigationTitle("Activity")
        }
    }
}

struct SettingsLibraryView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Safety") {
                    Label("Original images should be preserved unless deletion is explicitly enabled.", systemImage: "shield.lefthalf.filled")
                    Label("File access is provided through the iOS document picker.", systemImage: "folder")
                }
                Section("About") {
                    LabeledContent("App", value: "XISO Studio")
                    LabeledContent("Interface", value: "Native SwiftUI")
                    LabeledContent("Processing", value: "Local")
                }
            }
            .scrollContentBackground(.hidden)
            .background(StudioStyle.background)
            .navigationTitle("Settings")
        }
    }
}
