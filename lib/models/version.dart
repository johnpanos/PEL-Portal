class Version {
  int major = 0;
  int minor = 0;
  int patch = 0;
  int build = 0;

  Version(String version) {
    this.major = int.parse(version.split('.')[0]);
    this.minor = int.parse(version.split('.')[1]);
    this.patch = int.parse((version.split('.')[2]).split('+')[0]);
    this.build = int.parse((version.split('.')[2]).split('+')[1]);
  }

  @override
  String toString() {
    return "$major.$minor.$patch";
  }

  int getVersionCode() {
    return major*10^6 + minor*10^3 + patch;
  }

  int getBuild() {
    return build;
  }

}