import SwiftUI

struct AppRootView: View {
    @StateObject private var viewModel = HomeViewModel()

    var body: some View {
        NavigationStack {
            HomeView(viewModel: viewModel)
        }
       // .preferredColorScheme(colorScheme)
    }
}

struct AppRootView_Previews: PreviewProvider {
    static var previews: some View {
        AppRootView()
    }
}
