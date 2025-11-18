//
//  LoginView.swift
//  Numina
//
//  Login screen UI
//

import SwiftUI

struct LoginView: View {
    @ObservedObject var viewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var showingRegister = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                // Logo/Title
                VStack(spacing: 8) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.orange, .red],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    Text("Numina")
                        .font(.largeTitle.bold())

                    Text("Find your fitness community")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 32)

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
                        .textContentType(.password)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                }

                // Error Message
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                }

                // Login Button
                Button(action: {
                    Task {
                        await viewModel.login(email: email, password: password)
                    }
                }) {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Log In")
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
                .disabled(viewModel.isLoading || email.isEmpty || password.isEmpty)
                .opacity((viewModel.isLoading || email.isEmpty || password.isEmpty) ? 0.6 : 1.0)

                Spacer()

                // Register Link
                HStack {
                    Text("Don't have an account?")
                        .foregroundColor(.secondary)

                    Button("Sign Up") {
                        showingRegister = true
                    }
                    .foregroundColor(.orange)
                }
                .font(.subheadline)
            }
            .padding(24)
            .navigationBarHidden(true)
            .sheet(isPresented: $showingRegister) {
                RegisterView(viewModel: viewModel)
            }
        }
    }
}

#Preview {
    LoginView(viewModel: AuthViewModel(userRepository: UserRepository()))
}
