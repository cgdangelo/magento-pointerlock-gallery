$ = jQuery

$ ->
  $document = $(document)
  canvas = document.getElementById 'fancy-gallery'
  $canvas = $ canvas
  ctx = canvas.getContext '2d'

  scale = 1
  x = y = 0

  stashImage = document.getElementById 'image'
  $stashImage = $ stashImage
  viewportImage = new Image()

  # Normalize PointerLock API functions
  canvas.requestPointerLock = canvas.requestPointerLock    ||
                              canvas.mozRequestPointerLock ||
                              canvas.webkitRequestPointerLock

  document.exitPointerLock = document.exitPointerLock    ||
                             document.mozExitPointerLock ||
                             document.webkitExitPointerLock

  isPointerLocked = ->
    document.pointerLockElement or document.mozPointerLockElement or document.webkitPointerLockElement

  getMovement = (e) ->
    return [
      e.movementX || e.mozMovementX || e.webkitMovementX,
      e.movementY || e.mozMovementY || e.webkitMovementY,
    ]

  drawImage = ->
    # Clear canvas
    ctx.save()
    ctx.setTransform 1, 0, 0, 1, 0, 0
    ctx.clearRect 0, 0, ctx.canvas.width, ctx.canvas.height

    # Fix boundaries
    x = 0 if x > 0 # Left bound
    x = canvas.width - (canvas.width * scale) if x < canvas.width - (canvas.width * scale) # Right bound
    y = 0 if y > 0 # Upper bound
    y = canvas.height - (canvas.height * scale) if y < canvas.height - (canvas.height * scale) # Right bound

    ctx.translate x, y

    ctx.drawImage viewportImage, 0, 0, canvas.width * scale, canvas.height * scale

  viewportImage.onload = drawImage

  $document.on 'click', ->
    if isPointerLocked() then document.exitPointerLock()

  $canvas.on('click', ->
    if !isPointerLocked() then canvas.requestPointerLock()
  )
  .on('DOMMouseScroll mousewheel', (evt) ->
    return if not isPointerLocked()

    originalEvent = evt.originalEvent
    delta = if originalEvent.wheelDelta
        originalEvent.wheelDelta / 120
      else
        -originalEvent.detail / 3

    originalEvent.preventDefault()
    originalEvent.returnValue = false

    scale += delta * 0.03

    # Check scaling
    if scale < 1
      scale = 1 # Image is full-size
    else if scale > 4
      scale = 4 # Image is pixelated and ugly
    else if scale > 2.5 && viewportImage.src isnt image.getAttribute 'data-large-src'
      viewportImage.src = image.getAttribute 'data-large-src' # Load larger image for greater fidelity

    drawImage()
  )
  .on('mousemove', (evt) ->
    return if not isPointerLocked()

    originalEvent = evt.originalEvent
    [dx, dy] = getMovement originalEvent
    x += dx
    y += dy

    drawImage()
  )

  $('.more-views ul li a img').on 'click', ->
    for attr in ['base', 'large']
      stashImage.setAttribute "data-#{attr}-src", $(@).attr "data-#{attr}-src"

    viewportImage.src = stashImage.src = $(@).attr 'data-base-src'

  viewportImage.src = stashImage.src
