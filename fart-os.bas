var prevTime
var deltaTime
var maxDeltaTime = 0.03
var canvasWidth, canvasHeight
var levelWidth, levelHeight
var scrollViewX = 0, scrollViewY = 0
var isDone = false

var unitVectorX = 0
var unitVectorY = 0
var velocityMag = 0
var swimForce = 950
var resistanceFactor = 0.95
var minVelocityMag = 0
var maxVelocityMag = 300

var fishCenterX, fishCenterY

var pointerDown = false

setup()

mainLoop()

wait


function setup()
  print "Loading images..."

  if not loadImage("bg", "../examples/images/street.bmp") then
    print "Failed to load image 'street.bmp'."
    end
  end if
  
  if not loadSpriteSheet("ship-sheet", "../examples/images/ship-sheet.png", 2, 1) then
    print "Failed to load image 'ship-sheet.png'."
    end
  end if
  
  print "Images loaded."
  
  addSprite("fish", "ship-sheet", 10, 10)
  setSpriteFrameRate("fish", 5)
  fishCenterX = int(getSpriteDrawWidth("fish") / 2)
  fishCenterY = int(getSpriteDrawHeight("fish") / 2)
  
  canvasWidth = getImageWidth("bg")
  canvasHeight = getImageHeight("bg")
  levelWidth = canvasWidth * 2
  levelHeight = canvasHeight * 2

  setCanvasWidth(canvasWidth)
  setCanvasHeight(canvasHeight)
    
  hideConsole()
  showCanvas()
  
  enableCanvasBuffer()
  
  setCanvasEvent("pointerdown", onPointerDown)
  setCanvasEvent("pointermove", onPointerMove)
  setCanvasEvent("pointerup", onPointerUp)
  
  prevTime = time()
end function


function cleanup()
  removeSprite("fish")
  unloadSpriteSheet("ship-sheet")  
  unloadImage("bg")
end function


function mainLoop()
  if isDone then
    cleanup()
    end
  end if
  
  updatePhysics()
  
  checkCollisions()
  
  moveScrollView()
  
  clearCanvas()
  
  drawImageTiled("bg", 0, 0, canvasWidth, canvasHeight, -scrollViewX, -scrollViewY)
  
  drawSprites()
  
  drawCanvasBuffer(mainLoop)
end function


function onPointerDown(pointerX, pointerY)
  setUnitVector(pointerX, pointerY)
  pointerDown = true
end function


function onPointerMove(pointerX, pointerY)
  if not pointerDown then return
  setUnitVector(pointerX, pointerY)
end function


function onPointerUp(pointerX, pointerY)
  pointerDown = false
end function


function setUnitVector(pointerX, pointerY)
  var deltaX, deltaY, normScale
  
  deltaX = (pointerX + scrollViewX) - (getSpriteX("fish") + fishCenterX)
  deltaY = (pointerY + scrollViewY) - (getSpriteY("fish") + fishCenterY)
  normScale = 1 / sqr((deltaX ^ 2) + (deltaY ^ 2))
  unitVectorX = deltaX * normScale
  unitVectorY = deltaY * normScale
end function


function updatePhysics()
  deltaTime = min(((time() - prevTime) / 1000), maxDeltaTime)
  prevTime = time()
  
  velocityMag = velocityMag * resistanceFactor
  if abs(velocityMag) < 1 then velocityMag = 0
  
  if pointerDown then
    velocityMag = velocityMag + (swimForce * deltaTime)
  end if

  velocityMag = clamp(velocityMag, minVelocityMag, maxVelocityMag)
  
  setSpriteVelocityX("fish", unitVectorX * velocityMag)
  setSpriteVelocityY("fish", unitVectorY * velocityMag)
  
  updateSprites(deltaTime)
end function


function checkCollisions()
  checkHitEdge()
end function


function moveScrollView()
  scrollViewX = getSpriteX("fish") - int(canvasWidth / 2)
  scrollViewY = getSpriteY("fish") - int(canvasHeight / 2)

  scrollViewX = clamp(scrollViewX, 0, levelWidth - canvasWidth)
  scrollViewY = clamp(scrollViewY, 0, levelHeight - canvasHeight)
  
  setScrollX(scrollViewX)
  setScrollY(scrollViewY)
end function


function checkHitEdge()
  var newX = clamp(getSpriteX("fish"), 0, levelWidth - getSpriteDrawWidth("fish"))
  var newY = clamp(getSpriteY("fish"), 0, levelHeight - getSpriteDrawHeight("fish"))
  
  setSpriteX("fish", newX)
  setSpriteY("fish", newY)
end function