import SwiftUI

struct ContentView: View {
    @State private var sampleText: String = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    header

                    keyboardsCard

                    instructions

                    testField

                    iastReferenceCard

                    hkReferenceCard

                    velthuisReferenceCard
                }
                .padding(20)
            }
            .navigationTitle("Sanskrit Keyboards")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Saṃskṛta on iOS, finally")
                .font(.title2.bold())
            Text("Six keyboards for typing Sanskrit. Pick the one that matches your habits.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var keyboardsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Keyboards")
                .font(.headline)
            keyboardRow(name: "IAST",
                        subtitle: "QWERTY + long-press for diacritics. For occasional Sanskrit.")
            Divider()
            keyboardRow(name: "HK → IAST",
                        subtitle: "Type Harvard-Kyoto, see IAST appear live (A→ā, R→ṛ, S→ṣ, …).")
            Divider()
            keyboardRow(name: "HK → Devanāgarī",
                        subtitle: "Type Harvard-Kyoto, see Devanāgarī appear live (kRSNa → कृष्ण).")
            Divider()
            keyboardRow(name: "IAST → Devanāgarī",
                        subtitle: "Type IAST (long-press for ā ṛ ṣ ṇ …), see Devanāgarī appear live.")
            Divider()
            keyboardRow(name: "Velthuis → IAST",
                        subtitle: "Type Velthuis (.r .s ~n \"n aa …), see IAST appear live.")
            Divider()
            keyboardRow(name: "Velthuis → Devanāgarī",
                        subtitle: "Type Velthuis, see Devanāgarī appear live (k.r.s.na → कृष्ण).")
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func keyboardRow(name: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(name).font(.subheadline.bold())
            Text(subtitle).font(.footnote).foregroundStyle(.secondary)
        }
    }

    private var instructions: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Enable a keyboard")
                .font(.headline)
            stepRow(number: "1", text: "Open Settings → General → Keyboard → Keyboards.")
            stepRow(number: "2", text: "Tap “Add New Keyboard…” and choose any of: IAST, HK → IAST, HK → Devanāgarī, IAST → Devanāgarī, Velthuis → IAST, Velthuis → Devanāgarī.")
            stepRow(number: "3", text: "Switch to it from any text field via the 🌐 globe key.")
            Text("None of these keyboards request “Allow Full Access” — they do no networking and store nothing.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .padding(.top, 4)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func stepRow(number: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Text(number)
                .font(.caption.bold())
                .foregroundStyle(.white)
                .frame(width: 22, height: 22)
                .background(Color.accentColor, in: Circle())
            Text(text)
                .font(.subheadline)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var testField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Try it")
                .font(.headline)
            TextEditor(text: $sampleText)
                .frame(minHeight: 140)
                .padding(8)
                .background(Color(.tertiarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(Color(.separator), lineWidth: 0.5)
                )
            if sampleText.isEmpty {
                Text("Tap here, then 🌐 to switch keyboards. Try typing  saMskRtam.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var iastReferenceCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("IAST keyboard — long-press cheatsheet")
                .font(.headline)
            VStack(alignment: .leading, spacing: 6) {
                referenceRow("a", "ā")
                referenceRow("i", "ī")
                referenceRow("u", "ū")
                referenceRow("r", "ṛ ṝ")
                referenceRow("l", "ḷ ḹ")
                referenceRow("n", "ñ ṅ ṇ")
                referenceRow("t", "ṭ")
                referenceRow("d", "ḍ")
                referenceRow("s", "ś ṣ")
                referenceRow("m", "ṃ ṁ")
                referenceRow("h", "ḥ")
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var hkReferenceCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Harvard-Kyoto cheatsheet")
                .font(.headline)
            Text("Used by both HK keyboards. Capitals are reserved for long vowels and retroflex/palatal consonants.")
                .font(.footnote)
                .foregroundStyle(.secondary)
            VStack(alignment: .leading, spacing: 6) {
                referenceRow("A I U", "ā ī ū")
                referenceRow("R RR", "ṛ ṝ")
                referenceRow("lR lRR", "ḷ ḹ")
                referenceRow("e ai", "e ai")
                referenceRow("o au", "o au")
                referenceRow("G J N", "ṅ ñ ṇ")
                referenceRow("T D Th Dh", "ṭ ḍ ṭh ḍh")
                referenceRow("z S", "ś ṣ")
                referenceRow("M H", "ṃ ḥ")
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var velthuisReferenceCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Velthuis cheatsheet")
                .font(.headline)
            Text("Used by both Velthuis keyboards. Prefix `.` for retroflex/vocalic, `\"` for palatal sibilant & velar nasal, `~` for palatal nasal. Case is cosmetic.")
                .font(.footnote)
                .foregroundStyle(.secondary)
            VStack(alignment: .leading, spacing: 6) {
                referenceRow("aa ii uu", "ā ī ū")
                referenceRow(".r .rr", "ṛ ṝ")
                referenceRow(".l .ll", "ḷ ḹ")
                referenceRow("e ai", "e ai")
                referenceRow("o au", "o au")
                referenceRow("\"n ~n .n", "ṅ ñ ṇ")
                referenceRow(".t .th .d .dh", "ṭ ṭh ḍ ḍh")
                referenceRow("\"s .s", "ś ṣ")
                referenceRow(".m .h", "ṃ ḥ")
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func referenceRow(_ base: String, _ alts: String) -> some View {
        HStack {
            Text(base)
                .font(.system(.body, design: .monospaced))
                .frame(width: 80, alignment: .leading)
            Text("→")
                .foregroundStyle(.secondary)
            Text(alts)
                .font(.system(.body, design: .serif))
        }
    }
}

#Preview {
    ContentView()
}
