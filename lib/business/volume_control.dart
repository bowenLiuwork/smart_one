import 'package:volume/volume.dart';


class VolumeKeyClickManager {
  //单例 --------
  factory VolumeKeyClickManager() => _getInstance();

  static VolumeKeyClickManager get instance => _getInstance();

  static VolumeKeyClickManager _instance;

  VolumeKeyClickManager._internal() {
    // 初始化
  }

  static VolumeKeyClickManager _getInstance() {
    if (_instance == null) {
      _instance = new VolumeKeyClickManager._internal();
    }
    return _instance;
  }

//-------------------



  void register() {
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    // pass any stream as parameter as per requirement
    await Volume.controlVolume(AudioManager.STREAM_SYSTEM);
  }
}
