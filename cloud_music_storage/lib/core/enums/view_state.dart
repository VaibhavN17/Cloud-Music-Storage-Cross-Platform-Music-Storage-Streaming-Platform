/// Standard UI View State enum across all features.
library;

enum ViewState {
  loading,
  empty,
  loaded,
  error,
  offline,
}

extension ViewStateX on ViewState {
  bool get isLoading => this == ViewState.loading;
  bool get isEmpty => this == ViewState.empty;
  bool get isLoaded => this == ViewState.loaded;
  bool get isError => this == ViewState.error;
  bool get isOffline => this == ViewState.offline;
}
