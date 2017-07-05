/* Insert your pool's unique Javascript here */
isOpen = true

function hamburger_cross(isOpen, trigger, overlay) {

  trigger = trigger || $('.hamburger')
  overlay = overlay || $('.overlay')
  sidebar = $('#wrapper')
  isOpen = isOpen === true

  if (isOpen == true) { // If open, close
    overlay.hide()
    trigger.addClass('is-closed')
    trigger.removeClass('is-open')
    sidebar.removeClass('toggled')
  } else {              // If close, open
    overlay.show()
    trigger.removeClass('is-closed')
    trigger.addClass('is-open')
    sidebar.addClass('toggled')
  }

  return !isOpen
}
