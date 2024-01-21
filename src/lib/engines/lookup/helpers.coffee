import assert from "@dashkite/assert"
import { confidential } from "panda-confidential"
import { PUBLIC_ORIGIN as origin } from "$env/static/public"
import { queue } from "$lib/helpers/queue.coffee"
import { setDispatcher } from "$lib/engines/fetch/echo.coffee"
import * as RunesClient from "@dashkite/runes-client"
import { Async } from "@dashkite/talos"


Confidential = confidential()
domain = ( new URL origin ).hostname


random = ( options = {} ) ->
  { length = 16, encoding = "base36" } = options
  Confidential.convert from: "bytes", to: encoding,
    await Confidential.randomBytes length

nonce = ->
  await random encoding: "base64", length: 4

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

clearRunes = ( identity ) ->
  localStorage.setItem "identity", identity
  localStorage.removeItem identity

encode = ( object ) ->
  Confidential.convert from: "utf8", to: "base64", JSON.stringify object

issueRune = ( authorization ) ->
  url = new URL "/echo-rune", origin
  url.searchParams.set "authorization", encode authorization
  response = await fetch url.href
  if response.status != 200
    throw new Error "failed to get echo test rune"
  await response.json()

Request = 
  run: ( reactor ) ->
    talos = await Async.run reactor
    if talos.failure
      throw talos.error
    talos.context.sublime?.response?.content


export {
  random
  nonce
  now

  origin
  domain
  test
  assertDiscover
  clearRunes
  setDispatcher

  encode
  issueRune

  Request
}