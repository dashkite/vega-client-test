import assert from "@dashkite/assert"
import * as Type from "@dashkite/joy/type"
import { HTTP, Remap } from "@dashkite/vega-client"
import { queue } from "$lib/helpers/queue.coffee"

find = ( events, message ) ->
  event = events.find ( e ) -> e.name == "announce" && e.message == message 
  assert event?

prepare = ( Helpers ) ->

  [
    Helpers.test "bad resource", ->
      events = await Helpers.Request.events HTTP.get
        name: "happy sky"
        bindings:
          alpha: "foo"
          beta: "bar"

      find events, "unable to parse resource description"

    Helpers.test "discovery failure", ->
      Helpers.setDispatcher "bad discovery"
      
      events = await Helpers.Request.events HTTP.get
        origin: Helpers.origin
        name: "happy sky"
        bindings:
          alpha: "foo"
          beta: "bar"

      find events, "discovery failure"

    Helpers.test "network failure", ->
      Helpers.setDispatcher "network failure"
      
      events = await Helpers.Request.events HTTP.get
        origin: Helpers.origin
        name: "happy sky"
        bindings:
          alpha: "foo"
          beta: "bar"

      find events, "network failure"
      find events, "discovery failure"

    Helpers.test "resource match failure", ->
      events = await Helpers.Request.events HTTP.get
        origin: Helpers.origin
        name: "doesn't exist"
        bindings:
          alpha: "foo"
          beta: "bar"

      find events, "unable to match resource"

    Helpers.test "method match failure", ->
      events = await Helpers.Request.events HTTP.get
        origin: Helpers.origin
        name: "unhappy sky"
        bindings:
          alpha: "foo"
          beta: "bar"

      find events, "unable to match method"

    Helpers.test "authorization header failure", ->
      events = await Helpers.Request.events HTTP.put
        origin: Helpers.origin
        name: "unhappy rune"
        authorization:
          rune: await Helpers.random encoding: "base64", length: 16
          nonce: await Helpers.nonce()
        content:
          foo: "foo"

      find events, "unable to construct authorization header"
  
  ]

export default prepare