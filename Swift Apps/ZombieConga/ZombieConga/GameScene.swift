//
//  GameScene.swift
//  ZombieConga
//
//  Created by Doolittle, Jonathan J on 3/2/22.
//

import SpriteKit
class GameScene: SKScene {
    
    let background = SKSpriteNode(imageNamed: "background1")
    let 🧟 = SKSpriteNode(imageNamed: "zombie1")
    var 💌 = 5
    var gameOver = false
    let 📷 = SKCameraNode()
    let cameraMovePointsPerSec: CGFloat = 200.0
    
    let livesLabel = SKLabelNode(fontNamed: "Glimstick")
    let catLabel = SKLabelNode(fontNamed: "Glimstick")
    
    let playableRect: CGRect
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var cameraRect : CGRect {
        let x = 📷.position.x - size.width/2
        + (size.width - playableRect.width)/2
        let y = 📷.position.y - size.height/2
        + (size.height - playableRect.height)/2
        return CGRect(
            x: x,
            y: y,
            width: playableRect.width,
            height: playableRect.height)
    }
    
    var lastUpdateTime: TimeInterval = 0
    var dt: TimeInterval = 0
    var lastTouchLocation: CGPoint
    
    var isZombieInvincible = false
    let zombieAnimation: SKAction
    let zombieInitialPosition = CGPoint(x: 400, y: 400)
    let zombieRotateRadiansPerSec: CGFloat = 4.0 * π
    let zombieMovePointsPerSec: CGFloat = 480.0
    var velocity = CGPoint.zero
    
    let catCollisionSound: SKAction = SKAction.playSoundFileNamed(
     "hitCat.wav", waitForCompletion: false)
    let enemyCollisionSound: SKAction = SKAction.playSoundFileNamed(
     "hitCatLady.wav", waitForCompletion: false)
    
    override init(size: CGSize) {
        let maxAspectRatio: CGFloat = 16.0 / 9.0
        let playableHeight = size.width / maxAspectRatio
        let playableMargin = (size.height - playableHeight)/2.0
        playableRect = CGRect(x: 0, y: playableMargin,
                              width: size.width,
                              height: playableHeight)
        lastTouchLocation = zombieInitialPosition
        var textures:[SKTexture] = []
        for i in 1...4 {
            textures.append(SKTexture(imageNamed: "zombie\(i)"))
        }
        textures.append(textures[2])
        textures.append(textures[1])
        zombieAnimation = SKAction.animate(with: textures,
                                           timePerFrame: 0.1)
        super.init(size: size)
    }
    
    func backgroundNode() -> SKSpriteNode {
        let backgroundNode = SKSpriteNode()
        backgroundNode.anchorPoint = CGPoint.zero
        backgroundNode.name = "background"
        let background1 = SKSpriteNode(imageNamed: "background1")
        background1.anchorPoint = CGPoint.zero
        background1.position = CGPoint(x: 0, y: 0)
        backgroundNode.addChild(background1)
        let background2 = SKSpriteNode(imageNamed: "background2")
        background2.anchorPoint = CGPoint.zero
        background2.position =
        CGPoint(x: background1.size.width, y: 0)
        backgroundNode.addChild(background2)
        backgroundNode.size = CGSize(
            width: background1.size.width + background2.size.width,
            height: background1.size.height)
        return backgroundNode
    }
    
    func moveCamera() {
        let backgroundVelocity =
        CGPoint(x: cameraMovePointsPerSec, y: 0)
        let amountToMove = backgroundVelocity * CGFloat(dt)
        📷.position += amountToMove
        enumerateChildNodes(withName: "background") { node, _ in
            let background = node as! SKSpriteNode
            if background.position.x + background.size.width <
                self.cameraRect.origin.x {
                background.position = CGPoint(
                    x: background.position.x + background.size.width*2,
                    y: background.position.y)
            }
        }
    }
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.black
        for i in 0...1 {
            let background = backgroundNode()
            background.anchorPoint = CGPoint.zero
            background.position =
            CGPoint(x: CGFloat(i)*background.size.width, y: 0)
            background.name = "background"
            background.zPosition = -1
            addChild(background)
        }
        
        run(SKAction.repeatForever(
            SKAction.sequence(
                [SKAction.run() {
                    self.spawnEnemy()
                    },
                 SKAction.wait(forDuration: 4.0)])))
        
        run(SKAction.repeatForever(
            SKAction.sequence(
                [SKAction.run() {
                    self.spawnCat()
                    },
                 SKAction.wait(forDuration: 1.0)])))
        
        addChild(🧟)
        🧟.position = zombieInitialPosition
        playBackgroundMusic(filename: "backgroundMusic.mp3")
        addChild(📷)
        camera = 📷
        📷.position = CGPoint(x: size.width/2, y: size.height/2)
        
        livesLabel.text = "Lives: X"
        livesLabel.fontColor = SKColor.black
        livesLabel.fontSize = 100
        livesLabel.zPosition = 150
        livesLabel.horizontalAlignmentMode = .left
        livesLabel.verticalAlignmentMode = .bottom
        livesLabel.position = CGPoint(
            x: -playableRect.size.width/2 + CGFloat(30),
            y: -playableRect.size.height/2 + CGFloat(30)
        )
        
        catLabel.text = "Cats: X"
        catLabel.fontColor = SKColor.black
        catLabel.fontSize = 100
        catLabel.zPosition = 150
        catLabel.horizontalAlignmentMode = .right
        catLabel.position = CGPoint(
            x: playableRect.size.width/2 - CGFloat(30),
            y: -playableRect.size.height/2 + CGFloat(30)
        )
        📷.addChild(livesLabel)
        📷.addChild(catLabel)
    }
    
    func startZombieAnimation() {
        if 🧟.action(forKey: "animation") == nil {
            🧟.run(
                SKAction.repeatForever(zombieAnimation),
                withKey: "animation")
        }
    }
    
    func stopZombieAnimation() {
        🧟.removeAction(forKey: "animation")
    }
    
    func move(sprite: SKSpriteNode, velocity: CGPoint) {
        let amountToMove = velocity * CGFloat(dt)
        print("Amount to move: \(amountToMove)")
        sprite.position += amountToMove
    }
    
    func debugDrawPlayableArea() {
        let shape = SKShapeNode(rect: playableRect)
        shape.strokeColor = SKColor.red
        shape.lineWidth = 4.0
        addChild(shape)
    }
    
    func moveTrain() {
        var trainCount = 0
        var targetPosition = 🧟.position
        
        enumerateChildNodes(withName: "train") { node, stop in
            trainCount += 1
            if !node.hasActions() {
                let actionDuration = 0.3
                let offset = targetPosition - node.position
                let direction = offset.normalized()
                let amountToMovePerSec = direction * 400
                let amountToMove = amountToMovePerSec * CGFloat(actionDuration)
                let moveAction = SKAction.moveBy(x: amountToMove.x, y: amountToMove.y, duration: actionDuration)
                node.run(moveAction)
            }
            targetPosition = node.position
        }
        
        catLabel.text = "Cats: \(trainCount)"
        
        if trainCount >= 15 && !gameOver {
            gameOver = true
            backgroundMusicPlayer.stop()
            let gameOverScene = GameOverScene(size: size, won: true)
            gameOverScene.scaleMode = scaleMode
            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            view?.presentScene(gameOverScene, transition: reveal)
        }
    }
    
    func spawnEnemy() {
        let 👵 = SKSpriteNode(imageNamed: "enemy")
        👵.name = "enemy"
        👵.position = CGPoint(
            x: cameraRect.maxX + 👵.size.width/2,
            y: CGFloat.random(
                in: (playableRect.minY + 👵.size.height/2)...(playableRect.maxY - 👵.size.height/2)))
        addChild(👵)
        let actionMove =
        SKAction.moveBy(x: -playableRect.width, y: 0, duration: 3.0)
        let actionRemove = SKAction.removeFromParent()
        👵.run(SKAction.sequence([actionMove, actionRemove]))
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        } else {
            dt = 0
        }
        
        lastUpdateTime = currentTime
        
        let amountToMove = velocity * CGFloat(dt)
        if (🧟.position - lastTouchLocation).length() < amountToMove.length() {
            🧟.position = lastTouchLocation
            velocity = CGPoint.zero
            stopZombieAnimation()
        } else if velocity != CGPoint.zero {
            move(sprite: 🧟, velocity: velocity)
            rotate(sprite: 🧟, direction: velocity, rotateRadiansPerSec: zombieRotateRadiansPerSec)
        }
        
        boundsCheckZombie()
        moveTrain()
        moveCamera()
        livesLabel.text = "Lives: \(💌)"
        
        if 💌 <= 0 && !gameOver {
            
            gameOver = true
            
            backgroundMusicPlayer.stop()
            
            let gameOverScene = GameOverScene(size: size, won: false)
            gameOverScene.scaleMode = scaleMode
            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            view?.presentScene(gameOverScene, transition: reveal)
        }
    }
    
    override func didEvaluateActions() {
     checkCollisions()
    }
    
    func spawnCat() {
        let 🐱 = SKSpriteNode(imageNamed: "cat")
        🐱.name = "cat"
        🐱.position = CGPoint(
            x: CGFloat.random(min: cameraRect.minX,
                              max: cameraRect.maxX),
            y: CGFloat.random(min: cameraRect.minY,
                              max: cameraRect.maxY))
        🐱.zPosition = 50
        🐱.setScale(0)
        addChild(🐱)
        let appear = SKAction.scale(to: 1.0, duration: 0.5)
        🐱.zRotation = -π / 16.0
        let leftWiggle = SKAction.rotate(byAngle: π/8.0, duration: 0.5)
        let rightWiggle = leftWiggle.reversed()
        let fullWiggle = SKAction.sequence([leftWiggle, rightWiggle])
        
        let scaleUp = SKAction.scale(by: 1.2, duration: 0.25)
        let scaleDown = scaleUp.reversed()
        let fullScale = SKAction.sequence(
            [scaleUp, scaleDown, scaleUp, scaleDown])
        let group = SKAction.group([fullScale, fullWiggle])
        let groupWait = SKAction.repeat(group, count: 10)
        
        let disappear = SKAction.scale(to: 0, duration: 0.5)
        let removeFromParent = SKAction.removeFromParent()
        
        let actions = [appear, groupWait, disappear, removeFromParent]
        🐱.run(SKAction.sequence(actions))
    }
    
    func loseCats() {
        var loseCount = 0
        enumerateChildNodes(withName: "train") { node, stop in
            var randomSpot = node.position
            randomSpot.x += CGFloat.random(in:-100...100)
            randomSpot.y += CGFloat.random(in:-100...100)
            node.name = ""
            node.run(
                SKAction.sequence([
                    SKAction.group([
                        SKAction.rotate(byAngle: π*4, duration: 1.0),
                        SKAction.move(to: randomSpot, duration: 1.0),
                        SKAction.scale(to: 0, duration: 1.0)
                        ]),
                    SKAction.removeFromParent()
                    ]))
            loseCount += 1
            if loseCount >= 2 {
                stop[0] = true
            }
        }
    }
    
    func zombieHit(cat: SKSpriteNode) {
        cat.name = "train"
        cat.removeAllActions()
        cat.setScale(1)
        cat.zRotation = 0
        let turnGreenAction = SKAction.colorize(with: UIColor.green, colorBlendFactor: 1.0, duration: 0.2)
        cat.run(turnGreenAction)
        run(catCollisionSound)
    }
    
    func zombieHit(enemy: SKSpriteNode) {
        
        if isZombieInvincible {
            return
        }
        
        isZombieInvincible = true
        let blinkTimes = 10.0
        let duration = 3.0
        let blinkAction = SKAction.customAction(
        withDuration: duration) { node, elapsedTime in
            let slice = duration / blinkTimes
            let remainder = Double(elapsedTime).truncatingRemainder(
                dividingBy: slice)
            node.isHidden = remainder > slice / 2
        }
        let endBlinkAction = SKAction.run() {
            self.🧟.isHidden = false
            self.isZombieInvincible = false
        }
        let zombieHitAction = SKAction.sequence([blinkAction, endBlinkAction])
        🧟.run(zombieHitAction)
        
        run(enemyCollisionSound)
        loseCats()
        💌 -= 1
    }
    
    func checkCollisions() {
        var hitCats: [SKSpriteNode] = []
        enumerateChildNodes(withName: "cat") { node, _ in
            let cat = node as! SKSpriteNode
            if cat.frame.intersects(self.🧟.frame) {
                hitCats.append(cat)
            }
        }
        for cat in hitCats {
            zombieHit(cat: cat)
        }
        var hitEnemies: [SKSpriteNode] = []
        enumerateChildNodes(withName: "enemy") { node, _ in
            let enemy = node as! SKSpriteNode
        
            if node.frame.insetBy(dx: 70, dy: 60).intersects(
                self.🧟.frame) {
                hitEnemies.append(enemy)
            }
        }
        for enemy in hitEnemies {
            zombieHit(enemy: enemy)
        }
    }
    
    func moveZombieToward(location: CGPoint) {
        startZombieAnimation()
        let offset = location - 🧟.position
        let direction = offset.normalized()
        velocity = direction * zombieMovePointsPerSec
    }
    
    func sceneTouched(touchLocation:CGPoint) {
        lastTouchLocation = touchLocation
        moveZombieToward(location: touchLocation)
    }
    
    func boundsCheckZombie() {
        let bottomLeft = CGPoint(x: cameraRect.minX, y: cameraRect.minY)
        let topRight = CGPoint(x: cameraRect.maxX, y: cameraRect.maxY)
        
        if 🧟.position.x <= bottomLeft.x {
            🧟.position.x = bottomLeft.x
         velocity.x = abs(velocity.x)
        }
        
        if 🧟.position.x >= topRight.x {
            🧟.position.x = topRight.x
            velocity.x = -velocity.x
        }
        if 🧟.position.y <= bottomLeft.y {
            🧟.position.y = bottomLeft.y
            velocity.y = -velocity.y
        }
        if 🧟.position.y >= topRight.y {
            🧟.position.y = topRight.y
            velocity.y = -velocity.y
        }
    }
    
    func rotate(sprite: SKSpriteNode, direction: CGPoint, rotateRadiansPerSec: CGFloat) {
        let shortest = shortestAngleBetween(angle1: sprite.zRotation, angle2: direction.angle)
        var amountToRotate = rotateRadiansPerSec * CGFloat(dt)
        if abs(shortest) < amountToRotate {
            amountToRotate = abs(shortest)
        }
        amountToRotate *= shortest.sign()
        sprite.zRotation += amountToRotate
    }
    
    override func touchesBegan(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.location(in: self)
        sceneTouched(touchLocation: touchLocation)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.location(in: self)
        sceneTouched(touchLocation: touchLocation)
    }
    
    
}
