//
//  BasicInfoStep.swift
//  Numina
//
//  Basic info step in profile setup
//

import SwiftUI

struct BasicInfoStep: View {
    @ObservedObject var viewModel: ProfileSetupViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Photo Placeholder
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color(.systemGray5))
                            .frame(width: 120, height: 120)

                        if let photoURL = viewModel.photoURL, !photoURL.isEmpty {
                            AsyncImage(url: URL(string: photoURL)) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                            } placeholder: {
                                Image(systemName: "person.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(.gray)
                            }
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                        } else {
                            Image(systemName: "person.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.gray)
                        }
                    }

                    Text("Add Photo")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
                .padding(.top, 24)

                // Name Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Full Name *")
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(.secondary)

                    TextField("Your name", text: $viewModel.name)
                        .textFieldStyle(.plain)
                        .textContentType(.name)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                }

                // Bio Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Bio")
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(.secondary)

                    TextEditor(text: $viewModel.bio)
                        .frame(height: 120)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .overlay(
                            Group {
                                if viewModel.bio.isEmpty {
                                    Text("Tell us a bit about yourself...")
                                        .foregroundColor(.gray.opacity(0.6))
                                        .padding(.leading, 12)
                                        .padding(.top, 16)
                                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                                        .allowsHitTesting(false)
                                }
                            }
                        )
                }

                Text("* Required fields")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(24)
        }
    }
}

#Preview {
    BasicInfoStep(viewModel: ProfileSetupViewModel(userRepository: UserRepository()))
}
