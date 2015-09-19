import QtQuick 2.3
import QtQuick.Controls 1.2

ApplicationWindow {
    visible: true
    width: 640
    height: 480
    title: qsTr("Minmal Platformer")

    Rectangle {
        id: gameBoard
        focus: true
        anchors.fill: parent;
        color: "black";

        Rectangle {
            id: floor

            x: 0
            y: 400
            width: gameBoard.width
            height: 1
            color: "white"
        }

        Rectangle {
            id: player

            color: "white"

            x: 250
            y: 200

            width: 100
            height: 200

            function startJump() {
                if (isJumping) {
                    return;
                }

                isJumping = true;
                player.yVelocity = player.yVelocityStart;
            }

            property int moveAmount: 5;
            property double yVelocity: 0;
            property double yVelocityStart: 40;
            property bool isJumping: false;

            function run() {
                var direction = gameBoard.getMoveDirection();
                if (direction === gameBoard.dir_left) {
                    player.x -= moveAmount;
                    if (player.x < 0) {
                        player.x = 0;
                    }
                } else if (direction === gameBoard.dir_right) {
                    player.x += moveAmount;
                    if (player.x + player.width > gameBoard.width) {
                        player.x = gameBoard.width - player.width
                    }
                }

                // Handle jumps
                if (isJumping) {
                    y -= yVelocity;
                    yVelocity -= moveAmount;

                    // HACK: we're just saying the floor is 200 for now
                    if (y >= 200) {
                        y = 200;
                        isJumping = false;
                    }
                }
            }
        }

        Timer {
            id: gameTimer;
            running: true;
            repeat: true;
            interval: 50;

            onTriggered: {
                player.run();
            }
        }

        property string dir_stationary: "stationary";
        property string dir_left: "left";
        property string dir_right: "right";
        property var directionStack: [];


        function getMoveDirection() {
            if (directionStack.length === 0) {
                return dir_stationary;
            }

            return directionStack[0];
        }

        function pushDirection(dir) {
            directionStack.unshift(dir);
        }

        function removeDirection(dir) {
            var index = directionStack.indexOf(dir);
            directionStack.splice(index, 1);
        }

        Keys.onPressed: {
            // Ignore auto-repeat events.
            if (event.isAutoRepeat) {
                return;
            }

            if (event.key === Qt.Key_Left) {
                event.accepted = true;
                pushDirection(dir_left);
            } else if (event.key === Qt.Key_Right) {
                event.accepted = true;
                pushDirection(dir_right);
            } else if (event.key === Qt.Key_Space) {
                event.accepted = true;
                player.startJump();
            }
        }

        Keys.onReleased:  {
            if (event.key === Qt.Key_Left) {
                event.accepted = true;
                removeDirection(dir_left);
            } else if (event.key === Qt.Key_Right) {
                event.accepted = true;
                removeDirection(dir_right);
            } else if (event.key === Qt.Key_Space) {
                // Don't really need to do anything here.
                event.accepted = true;
            }
        }
    }
}
