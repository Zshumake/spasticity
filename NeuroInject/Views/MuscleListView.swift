import SwiftUI

struct MuscleListView: View {
    @EnvironmentObject var store: MuscleStore
    @State private var searchText = ""
    @State private var selectedFilter = "All"
    
    var filteredMuscles: [Muscle] {
        store.muscles.filter { muscle in
            let matchesSearch = searchText.isEmpty || muscle.name.localizedCaseInsensitiveContains(searchText)
            let matchesFilter = selectedFilter == "All" || muscle.group.contains(selectedFilter)
            return matchesSearch && matchesFilter
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredMuscles) { muscle in
                    NavigationLink(destination: MuscleDetailView(muscle: muscle)) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(muscle.name)
                                .font(.headline)
                                .foregroundColor(.primary)
                            Text(muscle.group)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Injection Guide")
            .searchable(text: $searchText, prompt: "Search muscles...")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("All") { selectedFilter = "All" }
                        Button("Upper Extremity") { selectedFilter = "Upper" }
                        Button("Lower Extremity") { selectedFilter = "Lower" }
                    } label: {
                        Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                    }
                }
            }
        }
    }
}

struct MuscleListView_Previews: PreviewProvider {
    static var previews: some View {
        MuscleListView()
            .preferredColorScheme(.dark)
    }
}
