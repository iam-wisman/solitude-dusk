import QtQuick
import QtQuick.Effects
import Quickshell
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "wuisman.kitten"

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    hasVisualContent: true
    fixedWidth: logo.width + Style.spaceReal(7.5) * 2
    onPressed: function(button) {
      if (button === Qt.RightButton) Quickshell.execDetached(["xdg-terminal-exec"])
      else Quickshell.execDetached(["omarchy-shell", "shell", "toggle", "omarchy.menu", "{\"menu\":\"root\"}"])
    }

    Image {
      id: logo
      anchors.centerIn: parent
      // Text glyphs sit slightly above the bar's geometric middle; match them
      // so the logo lines up with the workspace numbers.
      anchors.verticalCenterOffset: -1
      source: Qt.resolvedUrl("kitten.svg")
      sourceSize.width: 24
      sourceSize.height: 25
      width: 12
      height: 12.5
      smooth: true
      // The SVG is plain white; draw it through the effect below so it takes
      // the bar's foreground colour and stays visible on light themes too.
      // Kept as a hidden layer so the effect can sample it as a texture.
      visible: false
      layer.enabled: true
    }

    MultiEffect {
      anchors.fill: logo
      source: logo
      colorization: 1.0
      colorizationColor: button.foreground
    }
  }
}
