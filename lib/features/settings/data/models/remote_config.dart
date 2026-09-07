class RemoteConfig {
  final bool needLoadFromRemote;
  final bool needResetData;

  const RemoteConfig({
    required this.needLoadFromRemote,
    required this.needResetData,
  });

  factory RemoteConfig.fromJson(Map<String, dynamic> json) {
    return RemoteConfig(
      needLoadFromRemote: json['needLoadFromRemote'] as bool? ?? false,
      needResetData: json['needResetData'] as bool? ?? false,
    );
  }
}
