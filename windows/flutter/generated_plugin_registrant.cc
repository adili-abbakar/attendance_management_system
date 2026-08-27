//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <camera_desktop/camera_desktop_plugin.h>
#include <file_selector_windows/file_selector_windows.h>
#include <flutter_lite_camera/flutter_lite_camera_plugin_c_api.h>
#include <printing/printing_plugin.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  CameraDesktopPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("CameraDesktopPlugin"));
  FileSelectorWindowsRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("FileSelectorWindows"));
  FlutterLiteCameraPluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("FlutterLiteCameraPluginCApi"));
  PrintingPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("PrintingPlugin"));
}
