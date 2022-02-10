import Foundation
import UIKit

/*
The setup() function is called once when the app launches. Without it, your app won't compile.
Use it to set up and start your app.

You can create as many other functions as you want, and declare variables and constants,
at the top level of the file (outside any function). You can't write any other kind of code,
for example if statements and for loops, at the top level; they have to be written inside
of a function.
*/

let ball = OvalShape(width: 40, height: 40)
let barrierHeight = 25
let barrierWidth = 300

let funnelPoints = [Point(x: 0, y: 50), Point(x: 80, y: 50), Point(x: 60, y: 0), Point(x: 20, y: 0)]

var barriers: [Shape] = []
var targets: [Shape] = []

let funnel = PolygonShape(points: funnelPoints)

fileprivate func setupBall() {
    scene.add(ball)
    ball.position = Point(x: 250, y: 400)
    ball.fillColor = .blue
    ball.hasPhysics = true
    ball.onCollision = ballCollision(with:)
    ball.isDraggable = false
    scene.trackShape(ball)
    ball.onTapped = resetGame
    ball.onExitedScene = ballExitedScreen
    ball.bounciness = 0.6
    
}

fileprivate func setupFunnel() {
    scene.add(funnel)
    funnel.position = Point(x: 200, y: scene.height - 30)
    funnel.isImmobile = true
    funnel.isDraggable = false
    funnel.onTapped = dropBall
    funnel.fillColor = .purple
    
}

fileprivate func addBarrier(at position: Point, width: Double, height: Double, angle: Double) {
    let barrierPoints = [Point(x: 0, y: 0), Point(x: 0, y: height), Point(x: width, y: height), Point(x: width, y: 0)]
    let barrier = PolygonShape(points: barrierPoints)
    scene.add(barrier)
    barrier.position = position
    barrier.hasPhysics = true
    barrier.isImmobile = true
    barrier.fillColor = .orange
    barrier.angle = angle
    barriers.append(barrier)
}

fileprivate func addTarget(at position: Point) {
    let targetPoints = [Point(x: 10, y: 0), Point(x: 0, y: 10), Point(x: 10, y: 20), Point(x: 20, y: 10)]
    let target = PolygonShape(points: targetPoints)
    
    target.position = position
    target.name = "target"
    target.hasPhysics = true
    target.isImmobile = true
    target.isImpermeable = false
    //target.isDraggable = false
    target.fillColor = .green
    scene.add(target)
    targets.append(target)
}

func setup() {
    setupBall()
    setupFunnel()
    addBarrier(at: Point(x: 200, y: 150), width: 80, height: 25, angle: 0.2)
    addBarrier(at: Point(x: 200, y: 150), width: 80, height: 25, angle: -0.2)
    addBarrier(at: Point(x: 200, y: 150), width: 80, height: 25, angle: 0.1)
    
    addTarget(at: Point(x: 150, y: 400))
    addTarget(at: Point(x: 150, y: 400))
    addTarget(at: Point(x: 150, y: 400))
    
    resetGame()
}

func dropBall() {
    ball.stopAllMotion()
    ball.position = funnel.position
    setBarriersDraggability(canDrag: false)
    for target in targets {
        target.fillColor = .green
    }
}

func ballCollision(with otherShape: Shape) {
    if otherShape.name != "target" {
        return
    }
    
    otherShape.fillColor = .magenta
}

func ballExitedScreen() {
    var hitTargets = 0;
    
    for target in targets {
        if target.fillColor == .magenta {
            hitTargets += 1
        }
    }
    
    if hitTargets == targets.count {
        print("You won!")
        scene.presentAlert(text: "You won the game!", completion: alertDismissed)
    }
    
    setBarriersDraggability(canDrag: true)
}

func setBarriersDraggability(canDrag: Bool) {
    barriers.forEach { shape in shape.isDraggable = canDrag }
}

func resetGame() {
    ball.position = Point(x: 0, y: -80)
    ballExitedScreen()
}

func alertDismissed() {
    resetGame()
}

func printPosition(of shape: Shape) {
    print(shape.position)
}
