import * as helpers from "./helpers.coffee"
import basic from "./basic.coffee"

table = {
  basic
}


lookup = ( id ) ->
  if ( prepare = table[ id ] )?
    await prepare helpers
  else
    throw new Error "test block #{ id } is not defined."
  

export default lookup