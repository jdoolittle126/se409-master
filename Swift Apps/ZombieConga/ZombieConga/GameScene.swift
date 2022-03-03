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

    let playableRect: CGRect
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.black
        addChild(background)
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        background.zPosition = -1
        
        run(SKAction.repeatForever(
            SKAction.sequence(
                [SKAction.run() {
                    self.spawnEnemy()
                    },
                 SKAction.wait(forDuration: 2.0)])))
        
        run(SKAction.repeatForever(
            SKAction.sequence(
                [SKAction.run() {
                    self.spawnCat()
                    },
                 SKAction.wait(forDuration: 1.0)])))
        
        addChild(🧟)
        🧟.position = zombieInitialPosition
        debugDrawPlayableArea()
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
    
    func spawnEnemy() {
        let enemy = SKSpriteNode(imageNamed: "enemy")
        let halfEnemyHeight: CGFloat = enemy.size.height / 2
        enemy.name = "enemy"
        enemy.position = CGPoint(
            x: size.width + enemy.size.width / 2,
            y: CGFloat.random(
                in: (playableRect.minY + halfEnemyHeight)...(playableRect.maxY - halfEnemyHeight)))
        addChild(enemy)
        let actionMove =
            SKAction.moveTo(x: -enemy.size.width/2, duration: 2.0)
        let actionRemove = SKAction.removeFromParent()
        enemy.run(SKAction.sequence([actionMove, actionRemove]))
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
    }
    
    override func didEvaluateActions() {
     checkCollisions()
    }
    
    func spawnCat() {
        let cat = SKSpriteNode(imageNamed: "cat")
        cat.name = "cat"
        cat.position = CGPoint(
            x: CGFloat.random(in: playableRect.minX...playableRect.maxX),
            y: CGFloat.random(in: playableRect.minY...playableRect.maxY))
        cat.setScale(0)
        addChild(cat)
        let appear = SKAction.scale(to: 1.0, duration: 0.5)
        cat.zRotation = -π / 16.0
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
        cat.run(SKAction.sequence(actions))
    }
    
    func zombieHit(cat: SKSpriteNode) {
        cat.removeFromParent()
        run(catCollisionSound)
    }
    
    
    
    func zombieHit(enemy: SKSpriteNode) {
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
            if node.frame.insetBy(dx: 20, dy: 20).intersects(
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
        let bottomLeft = CGPoint(x: 0, y: playableRect.minY)
        let topRight = CGPoint(x: size.width, y: playableRect.maxY)
        
        if 🧟.position.x <= bottomLeft.x {
            🧟.position.x = bottomLeft.x
            velocity.x = -velocity.x
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
