//
//  RegisterView.swift
//  Numina
//
//  Registration screen UI
//

import SwiftUI

struct RegisterView: View {
    @ObservedObject var viewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "person.badge.plus.fill")
                            .font(.system(size: 50))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.orange, .red],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )

                        Text("Create Account")
                            .font(.title.bold())

                        Text("Join the fitness community")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 24)
                    .padding(.bottom, 16)

                    // Name Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Full Name")
                            .font(.subheadline.weight(.medium))
                            .foregroundColor(.secondary)

                        TextField("John Doe", text: $name)
                            .textFieldStyle(.plain)
                            .textContentType(.name)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                    }

                    // Email Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email")
                            .font(.subheadline.weight(.medium))
                            .foregroundColor(.secondary)

                        TextField("your.email@example.com", text: $email)
                            .textFieldStyle(.plain)
                            .textContentType(.emailAddress)
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                    }

                    // Password Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Password")
                            .font(.subheadline.weight(.medium))
                            .foregroundColor(.secondary)

                        SecureField("••••••••", text: $password)
                            .textFieldStyle(.plain)
                            .textContentType(.newPassword)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)

                        Text("Minimum 6 characters")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    // Confirm Password Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Confirm Password")
                            .font(.subheadline.weight(.medium))
                            .foregroundColor(.secondary)

                        SecureField("••••••••", text: $confirmPassword)
                            .textFieldStyle(.plain)
                            .textContentType(.newPassword)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)

                        if !confirmPassword.isEmpty && password != confirmPassword {
                            Text("Passwords do not match")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }

                    // Error Message
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                    }

                    // Register Button
                    Button(action: {
                        Task {
                            await viewModel.register(email: email, password: password, name: name)
                            if viewModel.isAuthenticated {
                                dismiss()
                            }
                        }
                    }) {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Create Account")
                                .font(.headline)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [.orange, .red],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .disabled(!isFormValid || viewModel.isLoading)
                    .opacity((isFormValid && !viewModel.isLoading) ? 1.0 : 0.6)

                    // Login Link
                    HStack {
                        Text("Already have an account?")
                            .foregroundColor(.secondary)

                        Button("Log In") {
                            dismiss()
                        }
                        .foregroundColor(.orange)
                    }
                    .font(.subheadline)
                    .padding(.top, 8)
                }
                .padding(24)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    private var isFormValid: Bool {
        viewModel.isValidName(name) &&
        viewModel.isValidEmail(email) &&
        viewModel.isValidPassword(password) &&
        password == confirmPassword
    }
}

#Preview {
    RegisterView(viewModel: AuthViewModel(userRepository: UserRepository()))
}
