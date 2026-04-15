import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowly/core/services/auth_service.dart';
import 'package:nowly/core/services/auth_service_provider.dart';
import 'package:nowly/l10n/app_localizations.dart';

enum LinkedProvider { google }

extension LinkedProviderX on LinkedProvider {
  String get id => switch (this) {
        LinkedProvider.google => 'google.com',
      };
}

class LinkedAccount {
  const LinkedAccount({required this.provider, this.email});

  final LinkedProvider provider;
  final String? email;

  bool get isLinked => email != null;
}

class LinkedAccountsState {
  const LinkedAccountsState({
    this.accounts = const [],
    this.busyProvider,
    this.errorMessage,
  });

  final List<LinkedAccount> accounts;
  final LinkedProvider? busyProvider;
  final String? errorMessage;

  bool isBusy(LinkedProvider p) => busyProvider == p;

  LinkedAccountsState copyWith({
    List<LinkedAccount>? accounts,
    LinkedProvider? Function()? busyProvider,
    String? errorMessage,
  }) {
    return LinkedAccountsState(
      accounts: accounts ?? this.accounts,
      busyProvider:
          busyProvider != null ? busyProvider() : this.busyProvider,
      errorMessage: errorMessage,
    );
  }
}

class LinkedAccountsNotifier extends Notifier<LinkedAccountsState> {
  late final AuthService _authService;

  @override
  LinkedAccountsState build() {
    _authService = ref.read(authServiceProvider);
    // Rebuild when auth state changes (sign-in / sign-out / link / unlink).
    ref.watch(authStateProvider);
    return LinkedAccountsState(accounts: _currentAccounts());
  }

  List<LinkedAccount> _currentAccounts() {
    final user = _authService.currentUser;
    final providerData = user?.providerData ?? const [];

    return LinkedProvider.values.map((p) {
      final match = providerData.where((d) => d.providerId == p.id).firstOrNull;
      return LinkedAccount(provider: p, email: match?.email);
    }).toList();
  }

  void _refresh() {
    state = state.copyWith(accounts: _currentAccounts());
  }

  Future<void> link(LinkedProvider provider, AppLocalizations l10n) async {
    state = state.copyWith(
      busyProvider: () => provider,
      errorMessage: null,
    );

    try {
      switch (provider) {
        case LinkedProvider.google:
          await _authService.linkGoogle();
      }
      await _authService.currentUser?.reload();
      _refresh();
    } on AuthException catch (e) {
      if (e.code == 'sign-in-cancelled') return;
      state = state.copyWith(errorMessage: e.message(l10n));
    } finally {
      state = state.copyWith(busyProvider: () => null);
    }
  }

  Future<void> unlink(LinkedProvider provider, AppLocalizations l10n) async {
    state = state.copyWith(
      busyProvider: () => provider,
      errorMessage: null,
    );

    try {
      await _authService.unlinkProvider(provider.id);
      await _authService.currentUser?.reload();
      _refresh();
    } on AuthException catch (e) {
      state = state.copyWith(errorMessage: e.message(l10n));
    } finally {
      state = state.copyWith(busyProvider: () => null);
    }
  }
}

final linkedAccountsProvider =
    NotifierProvider<LinkedAccountsNotifier, LinkedAccountsState>(
  LinkedAccountsNotifier.new,
);
