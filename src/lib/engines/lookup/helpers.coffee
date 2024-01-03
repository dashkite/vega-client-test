import assert from "@dashkite/assert"
import { confidential } from "panda-confidential"
import { convert } from "@dashkite/bake"
import API from "./api.yaml"
import { PUBLIC_ORIGIN as origin } from "$env/static/public"

Confidential = confidential()
cache = {}


random = ( options = {} ) ->
  { length = 16, encoding = "base36" } = options
  Confidential.convert from: "bytes", to: encoding,
    await Confidential.randomBytes length

now = -> ( new Date ).toISOString()


echo = ( object ) ->
  convert from: "utf8", to: "safe-base64", JSON.stringify object

echoDiscovery = ->
  cache.discovery ?= echo
    description: "ok"
    content: API
    headers:
      "content-type": [ "application/json" ]

echoJSON = ( description, body ) ->
  echo
    description: description
    content: body
    headers:
      "content-type": [ "application/json" ]



class Test
  constructor: ({ @name, @test }) ->
    @state = "start"
  
  @make: ( name, test ) -> new @ { name, test }

  run: ->
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


export {
  random
  now
  API
  origin
  test

  echo
  echoDiscovery
  echoJSON
}