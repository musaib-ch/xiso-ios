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
                VStack(alignment: .leading, spacing: 24) {
                    HStack(alignment: .center) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("XISO STUDIO")
                                .font(.caption.weight(.bold))
                                .tracking(2)
                                .foregroundStyle(StudioStyle.green)
                            Text("Your workspace")
                                .font(.system(size: 31, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                        }
                        Spacer()
                        Image(systemName: "opticaldisc.fill")
                            .font(.system(size: 28, weight: .medium))
                            .foregroundStyle(StudioStyle.green)
                            .frame(width: 58, height: 58)
                            .background(StudioStyle.surface, in: RoundedRectangle(cornerRadius: 18))
                            .accessibilityHidden(true)
                    }

                    VStack(alignment: .leading, spacing: 13) {
                        HStack {
                            Label(engine.busy ? "Processing now" : "Ready to work",
                                  systemImage: engine.busy ? "arrow.triangle.2.circlepath" : "checkmark.circle.fill")
                                .font(.headline)
                                .foregroundStyle(StudioStyle.green)
                            Spacer()
                            Text("ON DEVICE")
                                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                                .foregroundStyle(StudioStyle.muted)
                        }
                        Text(engine.busy ? engine.status : "Select a tool to extract, create, or inspect an Xbox disc image.")
                            .font(.subheadline)
                            .foregroundStyle(StudioStyle.muted)
                            .fixedSize(horizontal: false, vertical: true)
                        if engine.busy {
                            HStack {
                                ProgressView(value: engine.progress)
                                    .tint(StudioStyle.green)
                                Text("\(Int(engine.progress * 100))%")
                                    .font(.caption.monospacedDigit().weight(.semibold))
                                    .foregroundStyle(StudioStyle.green)
                            }
                        }
                    }
                    .padding(18)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(StudioStyle.surface)
                            .overlay(RoundedRectangle(cornerRadius: 20)
                                .stroke(StudioStyle.green.opacity(engine.busy ? 0.45 : 0.16), lineWidth: 1))
                    )

                    VStack(alignment: .leading, spacing: 13) {
                        Text("Quick actions")
                            .font(.title3.bold())
                            .foregroundStyle(.white)
                        operationCard(.extract, featured: true)
                        operationCard(.god, featured: true)
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("More tools")
                            .font(.title3.bold())
                            .foregroundStyle(.white)
                        operationCard(.create)
                        operationCard(.list)
                        operationCard(.rewrite)
                    }

                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "lock.shield")
                            .font(.title3)
                            .foregroundStyle(StudioStyle.green)
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Private, local processing")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.white)
                            Text("Choose files using the iOS document picker. Nothing is uploaded by XISO Studio.")
                                .font(.caption)
                                .foregroundStyle(StudioStyle.muted)
                        }
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(StudioStyle.surface.opacity(0.8), in: RoundedRectangle(cornerRadius: 18))
                }
                .padding(18)
            }
            .background(StudioStyle.background.ignoresSafeArea())
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
        Button { selectedOperation = operation } label: {
            HStack(spacing: 14) {
                Image(systemName: operation.symbol)
                    .font(.system(size: featured ? 25 : 21, weight: .medium))
                    .foregroundStyle(StudioStyle.green)
                    .frame(width: featured ? 58 : 50, height: featured ? 58 : 50)
                    .background(StudioStyle.elevated, in: RoundedRectangle(cornerRadius: 15))
                VStack(alignment: .leading, spacing: 5) {
                    Text(operation.rawValue)
                        .font(.headline)
                        .foregroundStyle(.white)
                    Text(operation.subtitle)
                        .font(.caption)
                        .foregroundStyle(StudioStyle.muted)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.leading)
                }
                Spacer(minLength: 6)
                Image(systemName: "arrow.up.right")
                    .font(.footnote.weight(.bold))
                    .foregroundStyle(StudioStyle.green)
                    .frame(width: 30, height: 30)
                    .background(StudioStyle.elevated, in: Circle())
            }
            .padding(15)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(StudioStyle.surface, in: RoundedRectangle(cornerRadius: 20))
        }
        .buttonStyle(.plain)
        .accessibilityHint("Opens \(operation.rawValue) tool")
    }
}

struct OperationScaffold<Content: View>: View {
    @Environment(\.dismiss) private var dismiss
    let title: String
    let subtitle: String
    let symbol: String
    @ViewBuilder let content: Content

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    HStack(spacing: 14) {
                        Image(systemName: symbol)
                            .font(.system(size: 28))
                            .foregroundStyle(StudioStyle.green)
                            .frame(width: 58, height: 58)
                            .background(StudioStyle.elevated, in: RoundedRectangle(cornerRadius: 18))
                        VStack(alignment: .leading, spacing: 4) {
                            Text(title)
                                .font(.system(size: 27, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                            Text(subtitle)
                                .font(.subheadline)
                                .foregroundStyle(StudioStyle.muted)
                        }
                    }
                    .padding(.bottom, 6)
                    content
                }
                .padding(18)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(StudioStyle.background.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(StudioStyle.green)
                }
            }
        }
        .presentationDragIndicator(.visible)
    }
}

struct StudioSection<Content: View>: View {
    let heading: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 13) {
            Text(heading.uppercased())
                .font(.caption.weight(.bold))
                .tracking(1)
                .foregroundStyle(StudioStyle.muted)
            content
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(StudioStyle.surface, in: RoundedRectangle(cornerRadius: 20))
    }
}

struct StudioActionButton: View {
    let title: String
    let symbol: String
    let disabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: symbol)
                Text(title)
                Spacer()
                Image(systemName: "arrow.right")
            }
            .font(.headline)
            .padding(17)
            .foregroundStyle(.black)
            .background(disabled ? StudioStyle.muted : StudioStyle.green,
                        in: RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
        .disabled(disabled)
        .accessibilityHint(disabled ? "Select the required files first" : "Starts processing on this device")
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


struct OperationProgressCard: View {
    @EnvironmentObject private var engine: XisoEngine
    @State private var showDetails = false
    @State private var showMonitor = false

    var body: some View {
        if engine.busy || engine.status != "Idle" {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 10) {
                    Image(systemName: engine.busy ? "arrow.triangle.2.circlepath" :
                            (engine.status.localizedCaseInsensitiveContains("failed") ? "exclamationmark.triangle.fill" : "checkmark.circle.fill"))
                        .foregroundStyle(StudioStyle.green)
                    Text(engine.busy ? "Processing" : "Last operation")
                        .font(.headline)
                    Spacer()
                    if engine.busy {
                        Text("\(Int(engine.progress * 100))%")
                            .font(.system(.subheadline, design: .monospaced, weight: .bold))
                            .foregroundStyle(StudioStyle.green)
                    }
                }
                ProgressView(value: engine.progress)
                    .tint(StudioStyle.green)
                Text(engine.status)
                    .font(.subheadline)
                    .foregroundStyle(StudioStyle.muted)
                    .fixedSize(horizontal: false, vertical: true)
                HStack {
                    Button {
                        showMonitor = true
                    } label: {
                        Label("Open monitor", systemImage: "gauge.with.dots.needle.50percent")
                    }
                    .font(.subheadline.weight(.medium))
                    Button {
                        showDetails.toggle()
                    } label: {
                        Label(showDetails ? "Hide details" : "View details", systemImage: "list.bullet.rectangle")
                    }
                    .font(.subheadline.weight(.medium))
                    Spacer()
                    if engine.busy {
                        Button("Cancel", role: .destructive) {
                            engine.cancel()
                        }.font(.subheadline.weight(.semibold))
                    }
                }
                if showDetails {
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 5) {
                            ForEach(Array(engine.log.suffix(40).enumerated()), id: \.offset) { _, line in
                                Text(line)
                                    .font(.system(size: 11, design: .monospaced))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                    .frame(maxHeight: 160)
                    .textSelection(.enabled)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(StudioStyle.surface, in: RoundedRectangle(cornerRadius: 18))
            .fullScreenCover(isPresented: $showMonitor) { ProcessingMonitorView() }
        }
    }
}


struct ProcessingMonitorView: View {
    @EnvironmentObject private var engine: XisoEngine
    @Environment(\.dismiss) private var dismiss
    @State private var showLog = false
    @State private var confirmCancel = false

    private let accent = Color(red: 0.47, green: 0.87, blue: 0.40)

    var body: some View {
        NavigationStack {
            TimelineView(.periodic(from: .now, by: 1)) { timeline in
                let elapsed = max(0, (engine.finishedAt ?? timeline.date).timeIntervalSince(engine.startedAt ?? timeline.date))
                let fraction = min(max(engine.progress, 0), 1)
                let ratePerMinute = elapsed > 0 ? fraction / elapsed * 6000 : 0
                let estimate = fraction >= 0.05 && fraction < 0.99 && elapsed >= 5 && engine.busy
                    ? elapsed * (1 - fraction) / fraction : nil

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        VStack(spacing: 10) {
                            Image(systemName: engine.busy ? "opticaldisc.fill" : "checkmark.circle.fill")
                                .font(.system(size: 64))
                                .foregroundStyle(accent)
                                .frame(width: 118, height: 118)
                                .background(accent.opacity(0.1), in: Circle())
                            Text(engine.busy ? "Processing your image" : "Operation summary")
                                .font(.system(size: 26, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                            Text(engine.operationName.isEmpty ? "XISO Studio" : engine.operationName)
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(.secondary)
                            Text(engine.status)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 16)

                        VStack(spacing: 13) {
                            Text("\(Int(fraction * 100))%")
                                .font(.system(size: 66, weight: .bold, design: .rounded))
                                .monospacedDigit()
                                .foregroundStyle(.white)
                                .contentTransition(.numericText())
                            ProgressView(value: fraction)
                                .tint(accent)
                                .scaleEffect(x: 1, y: 2, anchor: .center)
                                .accessibilityLabel("Processing progress")
                            Text(engine.busy ? "IN PROGRESS" : "LAST OPERATION")
                                .font(.caption.weight(.bold))
                                .tracking(1.5)
                                .foregroundStyle(accent)
                        }
                        .padding(22)
                        .frame(maxWidth: .infinity)
                        .background(StudioStyle.surface, in: RoundedRectangle(cornerRadius: 22))

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            metric("Elapsed", value: Self.duration(elapsed), symbol: "clock")
                            metric("Remaining", value: estimate.map { "~" + Self.duration($0) } ?? "Calculating", symbol: "hourglass")
                            metric("Average speed", value: elapsed >= 5 && fraction > 0 ? String(format: "%.1f%%/min", ratePerMinute) : "Calculating", symbol: "speedometer")
                            metric("Progress", value: "\(Int(fraction * 100))%", symbol: "chart.line.uptrend.xyaxis")
                        }

                        Text("Remaining time is estimated from overall progress, and may change between processing stages. Speed is measured in percentage points per minute, not data throughput.")
                            .font(.caption)
                            .foregroundStyle(StudioStyle.muted)
                            .fixedSize(horizontal: false, vertical: true)

                        VStack(alignment: .leading, spacing: 12) {
                            Button {
                                withAnimation { showLog.toggle() }
                            } label: {
                                HStack {
                                    Label("Processing log", systemImage: "terminal")
                                        .font(.headline)
                                    Spacer()
                                    Text("\(engine.log.count) entries")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Image(systemName: showLog ? "chevron.up" : "chevron.down")
                                        .font(.caption)
                                }
                                .foregroundStyle(.white)
                            }
                            .buttonStyle(.plain)
                            if showLog {
                                ScrollView {
                                    LazyVStack(alignment: .leading, spacing: 6) {
                                        ForEach(Array(engine.log.suffix(80).enumerated()), id: \.offset) { _, entry in
                                            Text(entry)
                                                .font(.system(size: 11, design: .monospaced))
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                        }
                                    }
                                }
                                .frame(maxHeight: 230)
                                .textSelection(.enabled)
                            }
                        }
                        .padding(18)
                        .background(StudioStyle.surface, in: RoundedRectangle(cornerRadius: 18))

                        if engine.busy {
                            Button(role: .destructive) { confirmCancel = true } label: {
                                Label("Cancel operation", systemImage: "xmark.circle")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding(14)
                            }
                            .buttonStyle(.bordered)
                            .confirmationDialog("Cancel the running operation?", isPresented: $confirmCancel) {
                                Button("Cancel operation", role: .destructive) { engine.cancel() }
                            } message: {
                                Text("Incomplete output files may remain at the destination.")
                            }
                        }
                    }
                    .padding(18)
                }
            }
            .background(StudioStyle.background.ignoresSafeArea())
            .navigationTitle("Processing monitor")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }.foregroundStyle(accent)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private func metric(_ title: String, value: String, symbol: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(title, systemImage: symbol)
                .font(.caption)
                .foregroundStyle(StudioStyle.muted)
            Text(value)
                .font(.system(.title3, design: .rounded, weight: .bold))
                .monospacedDigit()
                .minimumScaleFactor(0.7)
                .lineLimit(1)
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, minHeight: 62, alignment: .leading)
        .padding(16)
        .background(StudioStyle.surface, in: RoundedRectangle(cornerRadius: 17))
    }

    private static func duration(_ seconds: TimeInterval) -> String {
        let value = Int(max(0, min(seconds, 86_400_000)))
        let hours = value / 3600
        let minutes = (value % 3600) / 60
        let remaining = value % 60
        return hours > 0
            ? String(format: "%dh %02dm", hours, minutes)
            : String(format: "%02d:%02d", minutes, remaining)
    }
}
