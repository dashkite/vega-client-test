import assert from "@dashkite/assert"
import { confidential } from "panda-confidential"
import { PUBLIC_ORIGIN as origin } from "$env/static/public"
import { queue } from "$lib/helpers/queue.coffee"
import { setDispatcher } from "$lib/engines/fetch/echo.coffee"

Confidential = confidential()


random = ( options = {} ) ->
  { length = 16, encoding = "base36" } = options
  Confidential.convert from: "bytes", to: encoding,
    await Confidential.randomBytes length

now = -> ( new Date ).toISOString()


class Test
  constructor: ({ @name, @test }) ->
    @state = "start"
  
  @make: ( name, test ) -> new @ { name, test }

  run: ->
    await window.caches.delete "vega-client"
    queue.clear()
    setDispatcher "normal"
    if !@test?
      @state = "warning"
      return

    try
      await @test()
      @state = "success"
    catch error
      console.error @name, error
      @state = "failure"


test = ( name, _test ) -> Test.make name, _test

assertDiscover = ->
  event = await queue.get()
  assert.equal "request", event.type
  assert.equal "get", event.options.method
  assert.equal "/", event.url.pathname

  event = await queue.get()
  assert.equal "response", event.type
  assert.equal 200, event.response.status


export {
  random
  now
  origin
  test
  assertDiscover
  setDispatcher
}