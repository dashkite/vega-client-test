import * as helpers from "./helpers.coffee"
import happySky from "./happy-sky.coffee"
import unhappySky from "./unhappy-sky.coffee"
import happyMedia from "./happy-media.coffee"

table = {
  happySky
  unhappySky
  happyMedia
}


lookup = ( id ) ->
  if ( prepare = table[ id ] )?
    await prepare helpers
  else
    throw new Error "test block #{ id } is not defined."
  

export default lookup