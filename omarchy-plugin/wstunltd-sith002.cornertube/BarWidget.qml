import QtQuick
import qs.Ui
import qs.Commons

// CornerTube: a play icon in the bar. Left click opens the Play a Video
// input box (search or paste a link -> video-only PiP in the corner).
BarWidget {
  id: root
  moduleName: "wstunltd-sith002.cornertube"

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    tooltipText: "Play a Video (PiP)"
    iconComponent: Component {
      Image {
        source: Qt.resolvedUrl("icon.png")
        sourceSize: Qt.size(64, 64)
        fillMode: Image.PreserveAspectFit
        smooth: true
      }
    }
    onPressed: function(b) {
      if (b === Qt.LeftButton) {
        root.bar.run("/home/wstunltd-sith002/.local/bin/cornertube-input")
      }
    }
  }
}
