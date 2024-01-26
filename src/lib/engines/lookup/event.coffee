import assert from "@dashkite/assert"
import * as Type from "@dashkite/joy/type"
import { HTTP, Remap } from "@dashkite/vega-client"
import { queue } from "$lib/helpers/queue.coffee"

{ remap, VegaEventMaps:maps } = Remap

getEvents = ( reactor ) ->
  events = []
  for await event from Remap.remap Remap.VegaEventMaps, reactor
    events.push event
  events



prepare = ( Helpers ) ->

  [
    Helpers.test "success", ->
      events = await getEvents HTTP.get
        origin: Helpers.origin
        name: "happy sky"
        bindings:
          alpha: "foo"
          beta: "bar"

      event = events.find ( e ) -> e.name == "success"
      assert event?

    Helpers.test "failure", ->
      events = await getEvents HTTP.get
        origin: Helpers.origin
        name: "unhappy sky"
        bindings:
          alpha: "foo"
          beta: "bar"

      event = events.find ( e ) -> e.name == "failure"
      assert event?

    Helpers.test "json", ->
      content = foo: "foo"
      events = await getEvents HTTP.put
        origin: Helpers.origin
        name: "happy json"
        content: content

      event = events.find ( e ) -> e.name == "json"
      assert event?
      assert.deepEqual content, event.value

    Helpers.test "text", ->
      content = "foo is foo"
      events = await getEvents HTTP.put
        origin: Helpers.origin
        name: "happy text"
        content: content
      
      event = events.find ( e ) -> e.name == "text"
      assert event?
      assert.deepEqual content, event.value

    Helpers.test "blob", ->
      content = new ArrayBuffer 8

      events = await getEvents HTTP.put
        origin: Helpers.origin
        name: "happy binary"
        content: content

      event = events.find ( e ) -> e.name == "blob"
      assert event?
      assert Type.isType Blob, event.value
      assert.equal 2, event.value.size

    Helpers.test "content", ->
      content = foo: "foo"
      events = await getEvents HTTP.put
        origin: Helpers.origin
        name: "happy json"
        content: content

      event = events.find ( e ) -> e.name == "content"
      assert event?
      assert.deepEqual content, event.value

  ]

export default prepare