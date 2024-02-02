import * as helpers from "./helpers.coffee"
import happySky from "./happy-sky.coffee"
import unhappySky from "./unhappy-sky.coffee"
import happyMedia from "./happy-media.coffee"
import unhappyMedia from "./unhappy-media.coffee"
import cache from "./cache.coffee"
import happyAuthorization from "./happy-authorization.coffee"
import unhappyAuthorization from "./unhappy-authorization.coffee"
import event from "./event.coffee"
import announce from "./announce.coffee"

import sierraBuild from "./sierra-build.coffee"

table = {
  happySky
  unhappySky
  happyMedia
  unhappyMedia
  cache
  happyAuthorization
  unhappyAuthorization
  event
  announce

  sierraBuild
}


lookup = ( id ) ->
  if ( prepare = table[ id ] )?
    await prepare helpers
  else
    throw new Error "test block #{ id } is not defined."
  

export default lookup