import SwiftUI

/*
 * A simple title area
 */
struct TitleView: View {

    private let onTapped: () -> Void

    init(onTapped: @escaping () -> Void) {
        self.onTapped = onTapped
    }

    /*
     * Render the title area
     */
    var body: some View {

        Text("Mobile Web Integration")
            .font(.title)
            .underline()
            .foregroundColor(Colors.lightBlue)
            .padding(.bottom)
            .onTapGesture(perform: self.onTapped)
    }
}
