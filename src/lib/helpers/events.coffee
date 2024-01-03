allyEvent = ( f ) ->
  ( event ) ->
    event.preventDefault()
    if event.type == "keypress"
      if event.key == "Enter"
        f event
    else
      f event
 

export {
  allyEvent
}