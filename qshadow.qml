import Quickshell
import QtQuick.Window
import QtQuick.Controls
import Quickshell.Wayland
import QtQuick.Controls.Universal
import QtQuick
import Qt5Compat.GraphicalEffects
import Quickshell.Io

// import Quickshell.Wayland._WlrLayerShell

ShellRoot {

  property bool amdCard: Quickshell.env("AMDCARD")
  property bool nvCard: Quickshell.env("NVIDIACARD")
  property string wskey: Quickshell.env("WSKEY")
  property string obscmd: Quickshell.env("OBSCMD")
  property string wsport: Quickshell.env("WSPORT")
  Variants {
    model: Quickshell.screens
  //     variants: Quickshell.screens.map(screen => {
  //         return ({
  //           "screen": screen
  //             });
  //     })
  //
  PanelWindow {
    id: shadowDash
    property var modelData
    screen: modelData
    height: 800
    color: "transparent"
    // visible: false
    anchors {
      left: true
      top: true
      right: true
    }

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    WlrLayershell.namespace: "qtshadow"
    exclusionMode: ExclusionMode.Ignore

    property bool recordingStatus: !(recstatus.text.substring(28).trim() == "false") ? true : false

    Rectangle {
      id: obsRectangle
      x: parent.width / 1.2 - width / 2
      // y: parent.height / 2 height / 2
      width: 60
      property bool clicked: false
      height: 200
      color: "#00000000"
      layer.enabled: true
      layer.effect: DropShadow {
        transparentBorder: true
        horizontalOffset: 3
        verticalOffset: 2
        radius: 8.0
        samples: 16
        color: "#80000000"
      }

      Button {
        id: obsButton
        y: 70
        width: 60
        height: 60
        onClicked: {
          var recOn = recstatus.text.substring(28);
          if (recOn === "false") {
            obsKill.running = true;
          } else {
            obsLaunch.running = true;
          }
          obsButton.checked = parent.clicked = !parent.clicked;
        }
        background: Rectangle {
          radius: 100
          color: imageToggle.checked ? "#AA77B900" : "#D31131"
          border.color: obsButton.checked ? "#AA77B900" : "transparent"
          border.width: 2
        }
        contentItem: Image {
          scale: 0.8
          source: "icons/obslogo3.png"
          anchors.fill: parent
          fillMode: Image.PreserveAspectFit
        }
      }
    }
    Image {
      id: nvLogo
      scale: 0.7
      source: "icons/nvidia.png"
      width: 220
      height: 110
      anchors.horizontalCenter: parent.horizontalCenter
      fillMode: Image.PreserveAspectFit
      visible: imageToggle.checked
      opacity: imageToggle.checked ? 1 : 0
      Behavior on opacity {
        PropertyAnimation {
          duration: 500
        }
      }
    }
    DropShadow {
      scale: 0.7
      anchors.fill: nvLogo
      horizontalOffset: 3
      verticalOffset: 3
      radius: 8.0
      color: "#80000000"
      source: nvLogo
      opacity: imageToggle.checked ? 1 : 0
      Behavior on opacity {
        PropertyAnimation {
          duration: 500
        }
      }
    }

    Image {
      id: amdLogo
      scale: 0.7
      source: "icons/amd.png"
      width: 220
      height: 110
      anchors.horizontalCenter: parent.horizontalCenter
      fillMode: Image.PreserveAspectFit
      visible: !imageToggle.checked
      opacity: imageToggle.checked ? 0 : 1
      Behavior on opacity {
        PropertyAnimation {
          duration: 500
        }
      }
    }
    DropShadow {
      scale: 0.7
      anchors.fill: amdLogo
      horizontalOffset: 3
      verticalOffset: 3
      radius: 8.0
      color: "#80000000"
      source: amdLogo
      opacity: imageToggle.checked ? 0 : 1
      Behavior on opacity {
        PropertyAnimation {
          duration: 500
        }
      }
    }
    Switch {
      id: imageToggle
      x: 100
      y: 200
      checked: true ? nvCard : amdCard
      anchors.left: parent.left
      anchors.top: parent.top
      anchors.leftMargin: 20
      anchors.topMargin: 20
      background: Rectangle {
        implicitWidth: 50
        implicitHeight: 20
        color: imageToggle.checked ? "#9977B900" : "#99FB0329"
        radius: 20
      }
    }
    Text {
      id: recstatus
      y: 100
      x: parent.width / 1.7
      font.pixelSize: 15
      color: (recstatus.text.substring(28) == "false") ? "#C34B16" : "#BAFB00"
    }
    property var maskRegion: Region {
      Region {
        item: buttonColumn
      }
      Region {
        item: obsRectangle
      }
    }
    Item {
      id: buttonItems

      visible: true
      width: parent.width
      height: 500
      function obsCmd(args) {
        return ["obs-cmd", "-w", `obsws://localhost:${wsport}/${wskey}`].concat(args);
      }
      Text {
        id: obsPid
        font.pixelSize: 40
        color: "white"
        text: obsLaunch.processId
      }
      Column {
        id: buttonColumn
        anchors.centerIn: parent
        spacing: 10
        Row {
          spacing: 10
          anchors.horizontalCenter: parent.horizontalCenter

          Process {
            id: streamToggle
            command: buttonItems.obsCmd(["streaming", "toggle"])
          }
          Process {
            id: streamStart
            command: buttonItems.obsCmd(["streaming", "start"])
          }
          Process {
            id: replayToggle
            command: buttonItems.obsCmd(["replay", "toggle"])
          }
          Process {
            id: replaySave
            command: buttonItems.obsCmd(["replay", "save"])
          }
          Process {
            id: recordStart
            command: buttonItems.obsCmd(["recording", "start"])
          }
          Process {
            id: recordToggle
            command: buttonItems.obsCmd(["recording", "toggle"])
          }
          Process {
            id: recordStop
            command: buttonItems.obsCmd(["recording", "stop"])
          }
          Process {
            id: obsKill
            command: ["pkill", "obs"]
          }
          Process {
            id: notifyRec
            command: ["notify-send", "OBS is not currently running... Click the OBS button to launch."]
          }
          Process {
            id: obsLaunch
            command: [`${obscmd}`, "--minimize-to-tray"]
          }
          Process {
            id: recordCheck
            running: true
            // clearEnvironment: true
            command: buttonItems.obsCmd(["recording", "status"])
            stdout: SplitParser {
              splitMarker: ""
              onRead: data => recstatus.text = data.trim()
            }
          }
          Rectangle {
            width: 200
            property bool clicked: false
            height: 200
            color: "#00000000"
            layer.enabled: true
            layer.effect: DropShadow {
              transparentBorder: true
              horizontalOffset: 3
              verticalOffset: 2
              radius: 8.0
              samples: 16
              color: "#80000000"
            }

            Button {
              id: replayButton
              width: 200
              height: 200
              onClicked: {
                // !replayButton.checked ? replayToggle.running = true : replaySave.running = true
                replayButton.checked ? replaySave.running = true : replayToggle.running = true;
                replayButton.checked = parent.clicked = !parent.clicked;
              }
              background: Rectangle {
                radius: 20
                color: replayButton.checked ? "#8877B900" : "#CC1B1D1C"
                border.color: replayButton.checked ? "#AA77B900" : "transparent"
                border.width: 2
              }
              contentItem: Image {
                scale: 0.6
                source: "icons/instant_replay_white.png"
                anchors.fill: parent
                fillMode: Image.PreserveAspectFit
              }
            }
          }

          Rectangle {
            property bool clicked: false
            width: 200
            height: 200
            color: "#00000000"
            layer.enabled: true
            layer.effect: DropShadow {
              transparentBorder: true
              horizontalOffset: 3
              verticalOffset: 2
              radius: 8.0
              samples: 16
              color: "#80000000"
            }
            Button {
              id: recordButton
              width: parent.width
              height: parent.height
              checked: recordingStatus
              onClicked: {
                recordToggle.running = true;
                recordButton.checked = recordingStatus = !recordingStatus;
              }
              contentItem: Image {
                id: recordSQ
                scale: 0.6
                source: "icons/record_white.png"
                anchors.fill: parent
                fillMode: Image.PreserveAspectFit
                smooth: true
                visible: true
              }

              background: Rectangle {
                id: recStat
                radius: 20
                color: recordButton.checked ? "#88FB0329" : "#CC1B1D1C"

                border.color: recordButton.checked ? "#AA77B900" : "transparent"
                border.width: 2

                SequentialAnimation on color {
                  id: recStatAnimation
                  running: recordButton.checked
                  loops: Animation.Infinite
                  SequentialAnimation {
                    ColorAnimation {
                      to: "#88FF0000"
                      duration: 1000
                    }
                    ColorAnimation {
                      to: "#CC1B1D1C"
                      duration: 1000
                    }
                  }
                }
              }
            }
          }
          Rectangle {
            property bool clicked: false
            width: 200
            height: 200
            color: "#00000000"
            layer.enabled: true
            layer.effect: DropShadow {
              transparentBorder: true
              horizontalOffset: 3
              verticalOffset: 2
              radius: 8.0
              samples: 16
              color: "#80000000"
            }
            Button {
              id: broadcastButton
              width: 200
              height: 200
              onClicked: {
                streamToggle.running = true;
                broadcastButton.checked = parent.clicked = !parent.clicked;
              }
              contentItem: Image {
                scale: 0.6
                source: "icons/broadcast_white.png"
                anchors.fill: parent
                fillMode: Image.PreserveAspectFit
              }
              background: Rectangle {
                radius: 20
                color: broadcastButton.checked ? "#8877B900" : "#CC1B1D1C"
                border.color: broadcastButton.checked ? "#AA77B900" : "transparent"
                border.width: 2
              }
            }
          }
        }
      }
    }
  }
}
}
